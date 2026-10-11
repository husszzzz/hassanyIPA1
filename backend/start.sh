#!/bin/sh
set -eu
python -c "from app import init_db; init_db()"
exec gunicorn --bind "0.0.0.0:${PORT:-10000}" --workers 2 --threads 2 app:app
