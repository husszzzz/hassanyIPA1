# Supabase database for Hassany IPA

## Created

- Supabase project: `hassany-licenses`
- Region: `eu-central-1` (Frankfurt)
- Project reference: `yzohfxijsbcwgdjnphbc`
- Price shown by the Supabase project cost check at creation: **$0/month**
- Migration: `initialize_hassany_license_tables` applied successfully.
- Tables: `public.licenses`, `public.activations`
- RLS: enabled on both.
- Anon/authenticated table access: revoked. Do **not** disable RLS or add public read/write policies.

The backend application in `backend/app.py` uses direct `psycopg` PostgreSQL access. It requires a **private** pooled PostgreSQL connection string, **not** a Supabase publishable key. Never commit the connection string or password.

## Connect to Vercel

Existing production project: `backend`, domain `https://backend-black-delta-89.vercel.app`.

1. In Supabase project settings, copy the **pooled Session/Transaction mode PostgreSQL URI** via the Connect dialog. Vercel function environment often benefits from a pooler; use a pooler compatible with psycopg. Keep database password private.
2. In Vercel → Project `backend` → Settings → Environment Variables, set **encrypted** Production variables `DATABASE_URL`, `SESSION_SECRET` (strong random value) and `ADMIN_PASSWORD` (strong personal secret). Never submit the values into a chat.
3. Redeploy Production after saving.
4. Verify `GET /health` returns `{"status":"ok"}`. Until variables are configured it correctly returns `{"status":"setup_required"}`.
5. Verify `/login`, code creation and `/api/activate` on a device.
6. Set `HassanyAPIBaseURL` to `https://backend-black-delta-89.vercel.app` in app `Info.plist` and rebuild the IPA only after backend tests pass.

## Security notes

- Do not use the publicly accessible `anon` key in place of the database URI.
- The current backend needs a stronger rate limiter before mass distribution.
- Admin and device licensing are independent from gameplay; don't treat a successful login as a successful device activation until API tests pass.
- Supabase free project limits, backups and automatic pausing are subject to the provider plan.
