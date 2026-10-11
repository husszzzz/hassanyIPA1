import os, secrets, hashlib, hmac, time
from datetime import datetime, timedelta, timezone
from functools import wraps
from flask import Flask, request, redirect, render_template_string, render_template, session, jsonify, abort
import psycopg
from psycopg.rows import dict_row

app = Flask(__name__)
app.secret_key = os.environ.get("SESSION_SECRET") or secrets.token_hex(32)
app.config.update(SESSION_COOKIE_HTTPONLY=True, SESSION_COOKIE_SECURE=True, SESSION_COOKIE_SAMESITE="Lax", PERMANENT_SESSION_LIFETIME=timedelta(hours=6))
DB_URL = os.environ.get("DATABASE_URL", "")
ADMIN_PASSWORD = os.environ.get("ADMIN_PASSWORD", "")

@app.before_request
def require_service_configuration():
    if not all(os.environ.get(k) for k in ("DATABASE_URL", "SESSION_SECRET", "ADMIN_PASSWORD")):
        if request.path != "/health":
            return jsonify(status="setup_required", message="Database and admin secrets are not configured"), 503

def db():
    return psycopg.connect(DB_URL, row_factory=dict_row)

def init_db():
    with db() as con:
        con.execute("""CREATE TABLE IF NOT EXISTS licenses (
           id BIGSERIAL PRIMARY KEY,
           code_hash TEXT UNIQUE NOT NULL,
           code_hint TEXT NOT NULL,
           duration_days INTEGER NOT NULL CHECK(duration_days BETWEEN 1 AND 3650),
           max_devices INTEGER NOT NULL CHECK(max_devices BETWEEN 1 AND 100),
           created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
           disabled BOOLEAN NOT NULL DEFAULT false
        )""")
        con.execute("""CREATE TABLE IF NOT EXISTS activations (
           license_id BIGINT NOT NULL REFERENCES licenses(id) ON DELETE CASCADE,
           device_hash TEXT NOT NULL,
           activated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
           PRIMARY KEY(license_id, device_hash)
        )""")

def hash_value(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()

def csrf():
    if "_csrf" not in session:
        session["_csrf"] = secrets.token_urlsafe(32)
    return session["_csrf"]

def check_csrf():
    expected = session.get("_csrf")
    supplied = request.form.get("csrf")
    if not expected or not supplied or not hmac.compare_digest(expected, supplied):
        abort(403)

def admin_only(fn):
    @wraps(fn)
    def wrapped(*a, **kw):
        if not session.get("admin"):
            return redirect("/login")
        return fn(*a, **kw)
    return wrapped

STYLE = """<style>
*{box-sizing:border-box}body{margin:0;min-height:100vh;background:radial-gradient(ellipse at top,#30205b,#080b19 70%);color:#f7f6ff;font-family:system-ui,Tahoma,sans-serif;direction:rtl}
main{max-width:1000px;margin:auto;padding:35px 18px}.box{background:#16172b;border:1px solid #4b367f;border-radius:18px;padding:22px;margin:18px 0;box-shadow:0 12px 50px #0005}
h1{font-size:30px;margin:0}h2{font-size:21px}p,small{color:#bcb9d7}label{display:block;margin:9px 0}
input{border-radius:10px;border:1px solid #5d5483;background:#0d1024;color:white;padding:12px;max-width:100%;width:100%;font:inherit}
button,.btn{display:inline-block;background:#754af0;border:0;border-radius:10px;color:white;padding:12px 19px;font-weight:bold;font:inherit;text-decoration:none;cursor:pointer}
.danger{background:#b43e66}.logout{float:left}.code{font-family:monospace;direction:ltr;display:inline-block;font-size:19px;letter-spacing:2px}
table{border-collapse:collapse;width:100%;font-size:14px}td,th{text-align:right;padding:12px;border-bottom:1px solid #3f395c} .scroll{overflow:auto}
header{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap}
</style>"""
def page(body, **kwargs):
    return render_template_string('<!doctype html><html lang="ar"><meta name="viewport" content="width=device-width, initial-scale=1"><meta charset="utf-8"><title>HASSANY IPA • Admin</title>'+STYLE+'<main>'+body+'</main></html>', **kwargs)

@app.get("/")
def root():
    return redirect("/admin" if session.get("admin") else "/login")

@app.get("/health")
def health():
    if not all(os.environ.get(k) for k in ("DATABASE_URL", "SESSION_SECRET", "ADMIN_PASSWORD")):
        return jsonify(status="setup_required"), 503
    try:
        with db() as con: con.execute("SELECT 1")
        return jsonify(status="ok")
    except Exception:
        return jsonify(status="database_unavailable"),503

@app.route("/login", methods=["GET","POST"])
def login():
    error=""
    if request.method=="POST":
        check_csrf()
        # One-second slow path to discourage rapid credential guesses on a single worker.
        if hmac.compare_digest(request.form.get("password",""), ADMIN_PASSWORD):
            session.clear()
            session["admin"] = True
            csrf()
            return redirect("/admin")
        time.sleep(1)
        error="كلمة المرور غير صحيحة"
    return render_template("login.html", token=csrf(), error=error)

@app.post("/logout")
@admin_only
def logout():
    check_csrf()
    session.clear()
    return redirect("/login")

@app.get("/admin")
@admin_only
def admin():
    with db() as con:
        licenses=con.execute("""SELECT l.id,l.code_hint,l.duration_days,l.max_devices,l.disabled,l.created_at,
             (SELECT count(*) FROM activations a WHERE a.license_id=l.id) AS used
             FROM licenses l ORDER BY l.id DESC LIMIT 200""").fetchall()
    with db() as con:
        settings=con.execute("SELECT * FROM app_settings WHERE id=1").fetchone()
    needle=(request.args.get("q") or "").strip().upper()
    if needle: licenses=[x for x in licenses if needle in x["code_hint"].upper()]
    with db() as con:
        metrics=con.execute("""SELECT
            (SELECT count(*) FROM licenses) AS total,
            (SELECT count(*) FROM licenses WHERE disabled=false) AS active,
            (SELECT count(*) FROM licenses WHERE disabled=true) AS disabled,
            (SELECT count(*) FROM activations) AS devices""").fetchone()
    code=session.pop("new_code",None)
    return render_template("dashboard.html", token=csrf(), licenses=licenses, code=code, settings=settings, metrics=metrics, search=(request.args.get("q") or "")[:6])

@app.post("/create")
@admin_only
def create():
    check_csrf()
    try:
        days=int(request.form["days"]); devices=int(request.form["devices"])
        if not (1 <= days <=3650 and 1<=devices<=100): raise ValueError()
    except (ValueError,KeyError):
        abort(400)
    code="HASSANY-"+"-".join(secrets.token_hex(3).upper() for _ in range(3))
    with db() as con:
        con.execute("INSERT INTO licenses(code_hash,code_hint,duration_days,max_devices) VALUES(%s,%s,%s,%s)",
                    (hash_value(code),code[-6:],days,devices))
    session["new_code"]=code
    return redirect("/admin")

@app.post("/disable/<int:license_id>")
@admin_only
def disable(license_id):
    check_csrf()
    with db() as con:
        con.execute("UPDATE licenses SET disabled=true WHERE id=%s",(license_id,))
    return redirect("/admin")

@app.post("/settings")
@admin_only
def save_settings():
    check_csrf()
    maintenance = request.form.get("maintenance") == "yes"
    force_update = request.form.get("force_update") == "yes"
    message = request.form.get("maintenance_message","").strip()[:250]
    version = request.form.get("latest_version","").strip()[:32]
    url = request.form.get("update_url","").strip()[:350]
    if url and not url.startswith("https://"): abort(400)
    if not version: abort(400)
    with db() as con:
        con.execute("UPDATE app_settings SET maintenance=%s,maintenance_message=%s,latest_version=%s,update_url=%s,force_update=%s,updated_at=now() WHERE id=1",(maintenance,message,version,url,force_update))
    return redirect("/admin")

@app.post("/toggle/<int:license_id>")
@admin_only
def toggle_license(license_id):
    check_csrf()
    with db() as con: con.execute("UPDATE licenses SET disabled=NOT disabled WHERE id=%s",(license_id,))
    return redirect("/admin")

@app.post("/delete/<int:license_id>")
@admin_only
def delete_license(license_id):
    check_csrf()
    with db() as con: con.execute("DELETE FROM licenses WHERE id=%s",(license_id,))
    return redirect("/admin")

@app.post("/edit/<int:license_id>")
@admin_only
def edit_license(license_id):
    check_csrf()
    try:
        days=int(request.form["days"]); devices=int(request.form["devices"])
        if not (1<=days<=3650 and 1<=devices<=100): abort(400)
    except (ValueError,KeyError): abort(400)
    with db() as con:
        con.execute("UPDATE licenses SET duration_days=%s,max_devices=%s WHERE id=%s",(days,devices,license_id))
    return redirect("/admin")

@app.get("/api/status")
def api_status():
    with db() as con:
        settings=con.execute("SELECT maintenance,maintenance_message,latest_version,update_url,force_update FROM app_settings WHERE id=1").fetchone()
    return jsonify(settings)

@app.post("/api/activate")
def activate():
    payload=request.get_json(silent=True) or {}
    code=payload.get("code"); device=payload.get("device_id")
    if not isinstance(code,str) or not isinstance(device,str) or not (10<=len(code)<=100 and 8<=len(device)<=128):
        return jsonify(ok=False,error="invalid_request"),400
    with db() as con:
        settings=con.execute("SELECT maintenance,maintenance_message FROM app_settings WHERE id=1").fetchone()
        if settings and settings["maintenance"]:
            return jsonify(ok=False,error="maintenance",message=settings["maintenance_message"]),503
        row=con.execute("SELECT * FROM licenses WHERE code_hash=%s FOR UPDATE",(hash_value(code),)).fetchone()
        if not row or row["disabled"]:
            return jsonify(ok=False,error="invalid_code"),403
        dh=hash_value(device)
        existing=con.execute("SELECT activated_at FROM activations WHERE license_id=%s AND device_hash=%s",
                             (row["id"],dh)).fetchone()
        if not existing:
            count=con.execute("SELECT count(*) AS n FROM activations WHERE license_id=%s",(row["id"],)).fetchone()["n"]
            if count>=row["max_devices"]:
                return jsonify(ok=False,error="device_limit"),403
            con.execute("INSERT INTO activations(license_id,device_hash) VALUES(%s,%s)",(row["id"],dh))
            activated_at=datetime.now(timezone.utc)
        else:
            activated_at=existing["activated_at"]
        expires=activated_at+timedelta(days=row["duration_days"])
        if datetime.now(timezone.utc)>=expires:
            return jsonify(ok=False,error="expired"),403
        return jsonify(ok=True,expires_at=expires.isoformat())

if __name__=="__main__":
    init_db()
    app.run(host="0.0.0.0",port=int(os.environ.get("PORT","10000")))
