#!/usr/bin/env python3

import argparse
import http.server
import socketserver
import subprocess
import threading
from datetime import datetime
from pathlib import Path
from tempfile import TemporaryDirectory

from playwright.sync_api import sync_playwright


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets" / "demo"

SCENARIOS = {
    "mobile-flow": {
        "viewport": {"width": 390, "height": 844},
        "record_size": {"width": 390, "height": 844},
        "suffix": "swipev2-web-mobile-flow",
    },
    "desktop-showcase": {
        "viewport": {"width": 1280, "height": 720},
        "record_size": {"width": 1280, "height": 720},
        "suffix": "swipev2-web-desktop-showcase",
    },
}


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *_):
        return


def start_server(port: int):
    handler = lambda *args, **kwargs: QuietHandler(*args, directory=str(ROOT), **kwargs)
    server = socketserver.TCPServer(("127.0.0.1", port), handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server


def drag_front_card(page, dx: float, dy: float):
    card = page.locator(".card[data-depth='0']")
    box = card.bounding_box()
    if not box:
        raise RuntimeError("Front card is not visible.")
    x = box["x"] + box["width"] / 2
    y = box["y"] + box["height"] * 0.7
    page.mouse.move(x, y)
    page.mouse.down()
    steps = 12
    for step in range(1, steps + 1):
        page.mouse.move(x + dx * step / steps, y + dy * step / steps, steps=1)
        page.wait_for_timeout(22)
    page.mouse.up()


def run_mobile_flow(page, base_url: str):
    page.goto(f"{base_url.rstrip('/')}/swipev2/", wait_until="domcontentloaded")
    page.wait_for_timeout(1200)
    page.locator(".card[data-depth='0'] .chip.primary").click()
    page.wait_for_timeout(900)
    drag_front_card(page, 0, -180)
    page.wait_for_timeout(1200)
    page.locator(".header").click(position={"x": 40, "y": 40})
    page.wait_for_timeout(700)
    drag_front_card(page, 0, 170)
    page.wait_for_timeout(1000)
    drag_front_card(page, -170, 0)
    page.wait_for_timeout(1000)
    drag_front_card(page, 170, 0)
    page.wait_for_timeout(1000)
    drag_front_card(page, 170, 0)
    page.wait_for_timeout(1000)
    drag_front_card(page, 170, 0)
    page.wait_for_timeout(1400)
    page.locator("#restart").click()
    page.wait_for_timeout(1300)


def run_desktop_showcase(page, base_url: str):
    page.goto(f"{base_url.rstrip('/')}/swipev2/", wait_until="domcontentloaded")
    page.wait_for_timeout(1600)
    drag_front_card(page, 0, -180)
    page.wait_for_timeout(1400)
    page.locator(".header").click(position={"x": 120, "y": 50})
    page.wait_for_timeout(800)
    page.locator(".card[data-depth='0'] .chip.primary").click()
    page.wait_for_timeout(950)
    drag_front_card(page, 170, 0)
    page.wait_for_timeout(1050)
    drag_front_card(page, 0, 170)
    page.wait_for_timeout(1100)
    drag_front_card(page, -170, 0)
    page.wait_for_timeout(1050)
    drag_front_card(page, 170, 0)
    page.wait_for_timeout(1400)


def transcode_to_mp4(source: Path, output: Path):
    output.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-hide_banner",
            "-loglevel",
            "error",
            "-i",
            str(source),
            "-c:v",
            "libx264",
            "-pix_fmt",
            "yuv420p",
            "-movflags",
            "+faststart",
            str(output),
        ],
        check=True,
    )


def record_scenario(playwright, base_url: str, scenario_name: str, output: Path):
    config = SCENARIOS[scenario_name]
    browser = playwright.chromium.launch(headless=True)
    try:
        with TemporaryDirectory(prefix="swipev2-video-") as video_dir:
            context = browser.new_context(
                viewport=config["viewport"],
                record_video_dir=video_dir,
                record_video_size=config["record_size"],
            )
            page = context.new_page()
            page.set_default_timeout(10000)
            if scenario_name == "mobile-flow":
                run_mobile_flow(page, base_url)
            elif scenario_name == "desktop-showcase":
                run_desktop_showcase(page, base_url)
            else:
                raise RuntimeError(f"Unknown scenario: {scenario_name}")
            page.wait_for_timeout(800)
            context.close()
            video_path = Path(page.video.path())
            transcode_to_mp4(video_path, output)
    finally:
        browser.close()


def main():
    parser = argparse.ArgumentParser(description="Record swipev2 web demo videos.")
    parser.add_argument("--base-url", default="http://127.0.0.1:4173")
    parser.add_argument("--serve", action="store_true", help="Serve repo root locally before recording.")
    parser.add_argument("--port", type=int, default=4173)
    parser.add_argument(
        "--scenario",
        action="append",
        choices=sorted(SCENARIOS.keys()),
        help="Scenario to record. Default: record all scenarios.",
    )
    args = parser.parse_args()

    server = start_server(args.port) if args.serve else None
    stamp = datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    scenarios = args.scenario or list(SCENARIOS.keys())
    try:
        with sync_playwright() as playwright:
            for scenario_name in scenarios:
                output = ASSETS / f"{SCENARIOS[scenario_name]['suffix']}-{stamp}.mp4"
                record_scenario(playwright, args.base_url, scenario_name, output)
                print(f"{scenario_name}={output}")
    finally:
        if server:
            server.shutdown()


if __name__ == "__main__":
    main()
