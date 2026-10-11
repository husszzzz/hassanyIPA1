# Hassany License Administration

Flask/psycopg web admin panel with PostgreSQL.

- `DATABASE_URL` = private PostgreSQL connection string
- `SESSION_SECRET` = random secure session key
- `ADMIN_PASSWORD` = long private password

Run from `backend/`: `pip install -r requirements.txt && sh start.sh`.
Endpoints: `GET /health`, `GET /login`, `GET /admin`, `POST /api/activate`.
Code generation and revocation require authenticated administrator access.
Only a SHA-256 hash of the license code is stored; code is displayed once upon creation.

**Security / readiness:** basic starter version. Before public production use add IP-based rate limiting, reliable audit logs, stronger device attestation, backup policy and tests. Do not commit secrets to GitHub. A Render Free Postgres database may have expiration/limits. 
