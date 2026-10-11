import os
import unittest
from unittest.mock import patch

os.environ.setdefault("SESSION_SECRET", "test_secret_only_in_ci")
os.environ.setdefault("ADMIN_PASSWORD", "local_test_password")
os.environ.setdefault("DATABASE_URL", "postgresql://test:test@localhost/test")

from app import app

class Result:
    def __init__(self, data):
        self.data = data
    def fetchall(self):
        return self.data
    def fetchone(self):
        return self.data

class FakeDatabase:
    def __enter__(self):
        return self
    def __exit__(self, typ, value, traceback):
        return False
    def execute(self, sql, parameters=None):
        if "SELECT l.id" in sql:
            return Result([{"id":1,"code_hint":"TEST42","duration_days":30,
                            "max_devices":1,"disabled":False,"created_at":None,"used":0}])
        if "SELECT * FROM app_settings" in sql:
            return Result({"maintenance":False,"maintenance_message":"تحت الصيانة",
                           "latest_version":"4.0","update_url":"",
                           "force_update":False,"id":1})
        if "AS total" in sql:
            return Result({"total":1,"active":1,"disabled":0,"devices":0})
        return Result(None)

class DashboardUITests(unittest.TestCase):
    def setUp(self):
        app.config["TESTING"]=True
        self.client=app.test_client()

    def test_login_template(self):
        response=self.client.get("/login")
        self.assertEqual(response.status_code,200)
        self.assertIn(b"HASSANY IPA",response.data)
        self.assertIn(b"admin.css",response.data)

    @patch("app.db",return_value=FakeDatabase())
    def test_dashboard_template(self, mocked):
        with self.client.session_transaction() as sess:
            sess["admin"]=True
        response=self.client.get("/admin")
        self.assertEqual(response.status_code,200)
        for token in [b"HASSANY IPA", b"TEST42", b"admin.css", b"LICENSE MANAGER"]:
            self.assertIn(token,response.data)

    @patch("app.db",return_value=FakeDatabase())
    def test_status_endpoint(self,mocked):
        response=self.client.get("/api/status")
        self.assertEqual(response.status_code,200)
        self.assertEqual(response.get_json()["latest_version"],"4.0")

if __name__=="__main__":
    unittest.main()
