import os
import time
import subprocess
from playwright import sync_api


class funcDocker:
    def __init__(self):
        # 初始化账号和密码
        self.account, self.password = "WA24301127", "050814"

    def run_auto_login(self) -> None:
        """执行校园网自动登录"""
        with sync_api.sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            page = browser.new_page()
            page.goto("http://172.16.253.3/")
            page.fill('input[class="edit_lobo_cell"][name="DDDDD"]', self.account)
            page.fill('input[class="edit_lobo_cell"][name="upass"]', self.password)
            page.click('input[value="登录"]')
            page.wait_for_timeout(1000)
            browser.close()
        print("[INFO] 已尝试重新登录校园网")

    def is_connected(self) -> bool:
        """检测网络是否连通（ping外网DNS）"""
        try:
            # ping 3次，若成功返回0表示网络连通
            result = subprocess.run(
                ["ping", "-c", "3", "114.114.114.114"],  # Linux/macOS
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return result.returncode == 0
        except Exception:
            return False

    def run(self, interval=30):
        """循环检测校园网是否连通，掉线则自动重登"""
        while True:
            if not self.is_connected():
                print("[WARN] 检测到网络掉线，正在重新登录...")
                self.run_auto_login()
            else:
                print("[OK] 网络正常")
            time.sleep(interval)  # 每 interval 秒检测一次


if __name__ == "__main__":
    func_docker = funcDocker()
    func_docker.run(interval=60)  # 每60秒检测一次

