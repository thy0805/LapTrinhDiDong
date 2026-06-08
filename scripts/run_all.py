import os
import subprocess
import time

import requests

ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API_DIR = os.path.join(ROOT_DIR, "scripts", "food_recognition_api")
PYTHON_EXE = os.path.join(API_DIR, ".venv", "Scripts", "python.exe")
NGROK_EXE = r"C:\Users\thy\Downloads\ngrok-v3-stable-windows-amd64\ngrok.exe"
NGROK_URL = "https://nonaudible-mesophytic-gisele.ngrok-free.dev"

os.chdir(ROOT_DIR)

def kill_port(port):
    try:
        output = subprocess.check_output(f"netstat -ano | findstr :{port}", shell=True).decode("utf-8", errors="ignore")
        pids = set()
        for line in output.strip().splitlines():
            parts = line.split()
            if len(parts) >= 5:
                pid = parts[-1]
                if pid.isdigit() and int(pid) != os.getpid():
                    pids.add(pid)
        for pid in pids:
            subprocess.run(f"taskkill /F /PID {pid}", shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass

def get_ngrok_url():
    try:
        response = requests.get("http://127.0.0.1:4040/api/tunnels", timeout=3)
        data = response.json()
        for tunnel in data.get("tunnels", []):
            public_url = tunnel.get("public_url", "")
            if tunnel.get("proto") == "https" and public_url:
                return public_url
    except Exception:
        return None
    return None

def start_ngrok():
    current_url = get_ngrok_url()
    if current_url == NGROK_URL:
        print("Ngrok dang chay dung link cung:", current_url)
        return
    if current_url:
        print("Ngrok dang sai link, khoi dong lai link cung...")
        subprocess.run("taskkill /F /IM ngrok.exe", shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(2)
    print("Khoi chay Ngrok link cung...")
    subprocess.Popen(
        ["cmd", "/c", "start", "Ngrok NutriFit", "cmd", "/k", NGROK_EXE, "http", "8000", "--domain=nonaudible-mesophytic-gisele.ngrok-free.dev"],
    )
    for _ in range(15):
        time.sleep(1)
        current_url = get_ngrok_url()
        if current_url == NGROK_URL:
            print("Ngrok da san sang:", current_url)
            return
    print("Chua xac nhan duoc Ngrok, Thy kiem tra cua so ngrok nha.")

def start_fastapi():
    kill_port(8000)
    print("Khoi chay FastAPI Backend...")
    subprocess.Popen(
        ["cmd", "/c", "start", "NutriFit FastAPI", "cmd", "/k", PYTHON_EXE, "main.py"],
        cwd=API_DIR,
    )
    for _ in range(20):
        time.sleep(1)
        try:
            response = requests.get("http://127.0.0.1:8000/docs", timeout=2)
            if response.status_code == 200:
                print("FastAPI da san sang: http://127.0.0.1:8000")
                return
        except Exception:
            pass
    print("Chua xac nhan duoc FastAPI, Thy kiem tra cua so backend nha.")

start_ngrok()
start_fastapi()

print("Demo server da san sang.")
print("App Vivo da dung link:", NGROK_URL)
print("Lan sau chi can chay: python scripts\\run_all.py")
