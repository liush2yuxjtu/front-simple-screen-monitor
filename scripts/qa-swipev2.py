#!/usr/bin/env python3

import argparse
import http.server
import socketserver
import threading
from pathlib import Path

from playwright.sync_api import expect, sync_playwright


ROOT = Path(__file__).resolve().parents[1]


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *_):
        return


def start_server(port: int):
    handler = lambda *args, **kwargs: QuietHandler(*args, directory=str(ROOT), **kwargs)
    server = socketserver.TCPServer(("127.0.0.1", port), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


def run(base_url: str):
    errors = []
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 390, "height": 844})
        page.set_default_timeout(5000)
        page.on(
            "console",
            lambda msg: errors.append(f"console:{msg.type}:{msg.text}")
            if msg.type in ["error", "warning"]
            else None,
        )
        page.on("pageerror", lambda exc: errors.append(f"pageerror:{exc}"))

        page.goto(f"{base_url.rstrip('/')}/swipev2/")
        page.wait_for_load_state("domcontentloaded")
        expect(page.locator(".card[data-depth='0']")).to_be_visible()
        expect(page.locator(".action-title").last).to_contain_text("北京北站")

        page.locator(".card[data-depth='0'] .chip.primary").click()
        expect(page.locator("#toast")).to_contain_text("demo")
        expect(page.locator("#toast")).to_contain_text("未实际跳转")

        page.keyboard.press("ArrowUp")
        expect(page.locator("#sheet.show")).to_be_visible()
        expect(page.locator("#sheetTitle")).to_contain_text("北京北站")
        page.keyboard.press("ArrowDown")
        expect(page.locator("#sheet.show")).not_to_be_visible()

        page.keyboard.press("ArrowDown")
        expect(page.locator("#toast")).to_contain_text("卡堆末尾")
        expect(page.locator(".action-title").last).to_contain_text("静音入会")

        page.keyboard.press("ArrowLeft")
        expect(page.locator("#toast")).to_contain_text("已丢掉")
        expect(page.locator(".action-title").last).to_contain_text("准备下楼取餐")

        page.keyboard.press("ArrowRight")
        expect(page.locator("#toast")).to_contain_text("demo only")
        expect(page.locator("#toast")).to_contain_text("骑手实时位置草稿")

        page.keyboard.press("ArrowRight")
        expect(page.locator("#toast")).to_contain_text("demo only")
        expect(page.locator("#toast")).to_contain_text("824591")

        page.keyboard.press("ArrowRight")
        expect(page.locator("#toast")).to_contain_text("demo only")
        expect(page.locator("#empty.show")).to_be_visible()
        expect(page.locator("#restart")).to_be_visible()

        page.locator("#restart").click()
        expect(page.locator(".card[data-depth='0']")).to_be_visible()
        expect(page.locator(".action-title").last).to_contain_text("北京北站")

        page.goto(base_url.rstrip("/") + "/")
        page.wait_for_load_state("domcontentloaded")
        expect(page.locator('a[href="swipev2/"]')).to_be_visible()

        page.goto(base_url.rstrip("/") + "/gallery/")
        page.wait_for_load_state("domcontentloaded")
        expect(page.locator('a[href="../swipev2/"]')).to_be_visible()

        page.screenshot(path="/tmp/swipev2-web-test.png", full_page=True)
        browser.close()

    if errors:
        raise AssertionError("\n".join(errors))
    print("PASS swipev2 focused browser QA")
    print("screenshot=/tmp/swipev2-web-test.png")


def main():
    parser = argparse.ArgumentParser(description="Focused browser QA for /swipev2/.")
    parser.add_argument("--base-url", default="http://127.0.0.1:4173")
    parser.add_argument("--serve", action="store_true", help="Serve repo root locally before running QA.")
    parser.add_argument("--port", type=int, default=4173)
    args = parser.parse_args()

    server = start_server(args.port) if args.serve else None
    try:
        run(args.base_url)
    finally:
        if server:
            server.shutdown()


if __name__ == "__main__":
    main()
