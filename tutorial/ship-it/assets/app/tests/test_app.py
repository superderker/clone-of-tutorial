import json, os, subprocess, sys, time, unittest, urllib.request

APP_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PORT = 5099
BASE = "http://127.0.0.1:%d" % PORT


class AppTest(unittest.TestCase):
    proc = None

    @classmethod
    def setUpClass(cls):
        # Start the app on a private port, then poll until it answers.
        cls.proc = subprocess.Popen([sys.executable, "app.py", str(PORT)], cwd=APP_DIR)
        deadline = time.time() + 10
        while True:
            if cls.proc.poll() is not None:
                raise RuntimeError("app.py exited during startup - see its output above")
            try:
                urllib.request.urlopen(BASE + "/health", timeout=1).read()
                return
            except Exception:
                if time.time() > deadline:
                    cls.proc.terminate()
                    cls.proc.wait()
                    raise RuntimeError("app.py did not answer on port %d within 10s" % PORT)
                time.sleep(0.2)

    @classmethod
    def tearDownClass(cls):
        if cls.proc and cls.proc.poll() is None:
            cls.proc.terminate()
            try:
                cls.proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                cls.proc.kill()
                cls.proc.wait()

    def get(self, path):
        return urllib.request.urlopen(BASE + path, timeout=5)

    def test_health_ok(self):
        self.assertEqual(json.load(self.get("/health"))["status"], "ok")

    def test_version_matches_repo_file(self):
        v = open(os.path.join(APP_DIR, "VERSION")).read().strip()
        self.assertEqual(json.load(self.get("/version"))["version"], v)

    def test_homepage_renders(self):
        self.assertIn("Demo Shop", self.get("/").read().decode())


if __name__ == "__main__":
    unittest.main()