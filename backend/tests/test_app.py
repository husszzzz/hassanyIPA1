import os
import unittest
from unittest.mock import patch

os.environ.setdefault("SESSION_SECRET","test-session-secret-not-for-production")
os.environ.setdefault("ADMIN_PASSWORD","test-password-not-for-production")
os.environ.setdefault("DATABASE_URL","postgresql://invalid:invalid@localhost:5432/test")

from app import app, hash_value

class BackendTests(unittest.TestCase):
    def setUp(self):
        app.config["TESTING"]=True
        self.client=app.test_client()

    def test_hash_is_deterministic(self):
        self.assertEqual(hash_value("CODE"),hash_value("CODE"))
        self.assertNotEqual(hash_value("CODE"),hash_value("CODE2"))

    def test_admin_redirect_when_logged_out(self):
        response=self.client.get("/admin")
        self.assertEqual(response.status_code,302)
        self.assertIn("/login",response.location)

    def test_api_rejects_bad_input_without_hitting_database(self):
        response=self.client.post("/api/activate",json={"code":"short","device_id":"tiny"})
        self.assertEqual(response.status_code,400)
        self.assertFalse(response.get_json()["ok"])

    def test_login_requires_csrf(self):
        response=self.client.post("/login",data={"password":"test-password-not-for-production"})
        self.assertEqual(response.status_code,403)

if __name__=="__main__": unittest.main()
