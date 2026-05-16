import schedule
import time
import subprocess
import os
from threading import Thread
from datetime import datetime

DB_NAME = "postgres"
DB_USER = "postgres"
DB_PASSWORD = "060321"
DB_HOST = "localhost"
DB_PORT = "5432"
BACKUP_DIR = "backups"


def make_backup():
    os.makedirs(BACKUP_DIR, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    filename = os.path.join(BACKUP_DIR, f"backup_{timestamp}.sql")

    env = os.environ.copy()
    env["PGPASSWORD"] = DB_PASSWORD

    result = subprocess.run([
    r"C:\Program Files\PostgreSQL\17\bin\pg_dump",
    "-h", DB_HOST,
    "-p", DB_PORT,
    "-U", DB_USER,
    "-F", "c",
    "-f", filename,
    DB_NAME
    ], env=env)

    if result.returncode == 0:
        print(f"[backup] Успешно: {filename}")
    else:
        print(f"[backup] Ошибка при создании бэкапа")


def run_scheduler():
    schedule.every(1).minutes.do(make_backup)  # каждые 24 часа
    while True:
        schedule.run_pending()
        time.sleep(60)


def start_backup_scheduler():
    thread = Thread(target=run_scheduler, daemon=True)
    thread.start()