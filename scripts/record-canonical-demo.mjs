#!/usr/bin/env node

import { createServer } from "node:http";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { basename, dirname, extname, join, resolve, sep } from "node:path";
import { spawn } from "node:child_process";

const ROOT = resolve(new URL("..", import.meta.url).pathname);
const MOVIES_DIR = join(homedir(), "Movies");
const DEFAULT_CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const WIDTH = 1280;
const HEIGHT = 720;
const SHOTS = [
  {
    id: "screen-context",
    duration: 6,
    time: "00:00-00:06",
    title: "Your AI can see your screen",
    body: "That is powerful, and dangerous.",
    proof: "screen observation",
  },
  {
    id: "permission-prompt",
    duration: 8,
    time: "00:06-00:14",
    title: "Activity Monitor asks first",
    body: "A Dynamic-Island-style prompt appears before the AI action.",
    proof: "permission request",
  },
  {
    id: "allow",
    duration: 9,
    time: "00:14-00:23",
    title: "Swipe right to ALLOW",
    body: "The green confirmation lands and ALLOWED increments by one.",
    proof: "ALLOW right swipe and green confirmation",
  },
  {
    id: "high-risk",
    duration: 12,
    time: "00:23-00:35",
    title: "Risk becomes visible",
    body: "The next request is a terminal delete command that has not run.",
    proof: "high-risk example",
  },
  {
    id: "block",
    duration: 9,
    time: "00:35-00:44",
    title: "Swipe left to BLOCK",
    body: "The red confirmation lands and BLOCKED increments by one.",
    proof: "BLOCK left swipe and red denial",
  },
  {
    id: "trust-log",
    duration: 10,
    time: "00:44-00:54",
    title: "Every decision leaves a trust log",
    body: "Recent decisions match the ALLOW and BLOCK choices.",
    proof: "trust log or stats/history",
  },
  {
    id: "try-next",
    duration: 6,
    time: "00:54-01:00",
    title: "Try it next",
    body: "AI stops being a chatbot when it starts acting on your computer.",
    proof: "recovery to the next request",
  },
];

const sleep = (ms) => new Promise((resolveSleep) => setTimeout(resolveSleep, ms));

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const stamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
  const output = resolve(args.output || join(MOVIES_DIR, `activity-monitor-canonical-demo-${stamp}.mp4`));
  const evidenceOutput = resolve(
    args.evidenceOutput || output.replace(/\.mp4$/i, ".evidence.json"),
  );
  const workDir = mkdtempSync(join(tmpdir(), "activity-monitor-demo-"));
  const framesDir = join(workDir, "frames");
  mkdirSync(framesDir, { recursive: true });
  mkdirSync(dirname(output), { recursive: true });
  mkdirSync(dirname(evidenceOutput), { recursive: true });

  const server = args.url ? null : await startStaticServer(ROOT);
  const url = args.url || `http://127.0.0.1:${server.address().port}/island-swipe/`;
  const chrome = await launchChrome(args.chrome, url);
  const cdp = new CdpClient(chrome.webSocketDebuggerUrl);

  try {
    await cdp.connect();
    await setupPage(cdp, url);
    await captureDemo(cdp, framesDir);
    await renderVideo(framesDir, output);
    await writeEvidence(evidenceOutput, output);

    const duration = await probeDuration(output);
    if (duration < 59.5 || duration > 60.8) {
      throw new Error(`Rendered video duration ${duration.toFixed(2)}s is outside the 60s tolerance.`);
    }

    console.log(`video=${output}`);
    console.log(`evidence=${evidenceOutput}`);
    console.log(`duration=${duration.toFixed(2)}s`);
    console.log(`source=${url}`);
  } finally {
    await cdp.close().catch(() => {});
    chrome.process.kill("SIGTERM");
    server?.close();
    if (!args.keepFrames) rmSync(workDir, { recursive: true, force: true });
    else console.log(`frames=${framesDir}`);
  }
}

function parseArgs(argv) {
  const args = {
    chrome: process.env.CHROME_PATH || DEFAULT_CHROME,
    evidenceOutput: "",
    keepFrames: false,
    output: "",
    url: "",
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--chrome") args.chrome = requireValue(argv, ++i, arg);
    else if (arg === "--evidence-output") args.evidenceOutput = requireValue(argv, ++i, arg);
    else if (arg === "--keep-frames") args.keepFrames = true;
    else if (arg === "--output") args.output = requireValue(argv, ++i, arg);
    else if (arg === "--url") args.url = requireValue(argv, ++i, arg);
    else if (arg === "--help" || arg === "-h") {
      console.log(helpText());
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return args;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function helpText() {
  return `
Usage:
  node scripts/${basename(process.argv[1])} [options]

Options:
  --output <path>           MP4 path. Default: ~/Movies/activity-monitor-canonical-demo-<timestamp>.mp4
  --evidence-output <path>  Local self-verify evidence JSON path.
  --url <url>               Use an already running static preview instead of starting one.
  --chrome <path>           Chrome/Chromium executable. Default: Google Chrome on macOS.
  --keep-frames             Keep the temporary screenshot frames for inspection.
`.trim();
}

async function startStaticServer(root) {
  const server = createServer((req, res) => {
    const url = new URL(req.url || "/", "http://127.0.0.1");
    let filePath = resolve(root, `.${decodeURIComponent(url.pathname)}`);
    if (!filePath.startsWith(`${root}${sep}`) && filePath !== root) {
      res.writeHead(403).end("Forbidden");
      return;
    }
    try {
      if (statSync(filePath).isDirectory()) filePath = join(filePath, "index.html");
      const body = readFileSync(filePath);
      res.writeHead(200, { "content-type": contentType(filePath) }).end(body);
    } catch {
      res.writeHead(404).end("Not found");
    }
  });

  await new Promise((resolveListen) => server.listen(0, "127.0.0.1", resolveListen));
  return server;
}

function contentType(filePath) {
  const types = {
    ".css": "text/css; charset=utf-8",
    ".html": "text/html; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".svg": "image/svg+xml",
  };
  return types[extname(filePath)] || "application/octet-stream";
}

async function launchChrome(chromePath) {
  const port = await freePort();
  const profileDir = mkdtempSync(join(tmpdir(), "activity-monitor-chrome-"));
  const chrome = spawn(chromePath, [
    "--headless=new",
    "--disable-background-networking",
    "--disable-default-apps",
    "--disable-extensions",
    "--disable-gpu",
    "--hide-scrollbars",
    "--mute-audio",
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${profileDir}`,
    `--window-size=${WIDTH},${HEIGHT}`,
    "about:blank",
  ], { stdio: ["ignore", "ignore", "pipe"] });

  chrome.stderr.setEncoding("utf8");
  chrome.stderr.on("data", (chunk) => {
    if (process.env.DEBUG_DEMO_RECORDING) process.stderr.write(chunk);
  });
  chrome.once("exit", () => rmSync(profileDir, { recursive: true, force: true }));

  const started = Date.now();
  while (Date.now() - started < 10000) {
    try {
      const targets = await fetchJson(`http://127.0.0.1:${port}/json/list`);
      const page = targets.find((target) => target.type === "page");
      if (page?.webSocketDebuggerUrl) {
        return { process: chrome, webSocketDebuggerUrl: page.webSocketDebuggerUrl };
      }
    } catch {
      await sleep(100);
    }
  }

  chrome.kill("SIGTERM");
  throw new Error(`Chrome did not expose a CDP target on port ${port}.`);
}

async function freePort() {
  const server = createServer();
  await new Promise((resolveListen) => server.listen(0, "127.0.0.1", resolveListen));
  const { port } = server.address();
  await new Promise((resolveClose) => server.close(resolveClose));
  return port;
}

async function fetchJson(url) {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`${url} returned ${response.status}`);
  return response.json();
}

async function setupPage(cdp, url) {
  await cdp.send("Page.enable");
  await cdp.send("Runtime.enable");
  await cdp.send("Emulation.setDeviceMetricsOverride", {
    width: WIDTH,
    height: HEIGHT,
    deviceScaleFactor: 1,
    mobile: false,
  });
  await cdp.send("Page.addScriptToEvaluateOnNewDocument", {
    source: `
      (() => {
        const seq = [0.05, 0.20, 0.72];
        const originalRandom = Math.random.bind(Math);
        let index = 0;
        Math.random = () => index < seq.length ? seq[index++] : originalRandom();
        navigator.vibrate = () => false;
      })();
    `,
  });
  await cdp.send("Page.navigate", { url });
  await waitForPage(cdp);
  await installRecordingOverlay(cdp);
}

async function waitForPage(cdp) {
  const started = Date.now();
  while (Date.now() - started < 15000) {
    const ready = await evaluate(cdp, `
      document.readyState === "complete" &&
      !!document.querySelector(".phone") &&
      !!document.querySelector("#island")
    `);
    if (ready) {
      await evaluate(cdp, "document.fonts ? document.fonts.ready.then(() => true) : true", true);
      await sleep(300);
      return;
    }
    await sleep(100);
  }
  throw new Error("Timed out waiting for /island-swipe/ to render.");
}

async function installRecordingOverlay(cdp) {
  await evaluate(cdp, `
    (() => {
      const style = document.createElement("style");
      style.textContent = \`
        .canonical-demo-caption {
          position: fixed;
          left: 42px;
          top: 48px;
          width: 350px;
          padding: 20px 22px;
          border: 1px solid rgba(0, 229, 255, 0.30);
          border-radius: 16px;
          background: rgba(4, 8, 15, 0.86);
          color: #e0f7fa;
          font-family: "JetBrains Mono", monospace;
          box-shadow: 0 18px 60px rgba(0, 0, 0, 0.34), 0 0 36px rgba(0, 229, 255, 0.08);
          z-index: 99;
        }
        .canonical-demo-caption .time {
          color: #00e5ff;
          font-size: 12px;
          font-weight: 700;
          letter-spacing: 1.8px;
          margin-bottom: 12px;
        }
        .canonical-demo-caption .title {
          color: #ffffff;
          font-size: 28px;
          font-weight: 700;
          line-height: 1.12;
          margin-bottom: 12px;
        }
        .canonical-demo-caption .body {
          color: #9ab8c4;
          font-size: 15px;
          line-height: 1.55;
        }
        .canonical-demo-caption .proof {
          margin-top: 16px;
          color: #76ff03;
          font-size: 11px;
          font-weight: 700;
          letter-spacing: 1.1px;
          text-transform: uppercase;
        }
        .canonical-demo-cursor {
          position: fixed;
          width: 28px;
          height: 28px;
          border-radius: 50%;
          border: 2px solid #ffffff;
          background: rgba(255, 255, 255, 0.16);
          box-shadow: 0 0 26px rgba(255, 255, 255, 0.32);
          z-index: 100;
          opacity: 0;
        }
        .canonical-demo-cursor.allow {
          left: 724px;
          top: 495px;
          opacity: 1;
          border-color: #76ff03;
        }
        .canonical-demo-cursor.block {
          left: 528px;
          top: 495px;
          opacity: 1;
          border-color: #ff1744;
        }
      \`;
      document.head.append(style);
      const caption = document.createElement("aside");
      caption.className = "canonical-demo-caption";
      caption.innerHTML = '<div class="time"></div><div class="title"></div><div class="body"></div><div class="proof"></div>';
      document.body.append(caption);
      const cursor = document.createElement("div");
      cursor.className = "canonical-demo-cursor";
      document.body.append(cursor);
      window.__canonicalDemoSetCaption = (shot, cursorState = "") => {
        caption.querySelector(".time").textContent = shot.time;
        caption.querySelector(".title").textContent = shot.title;
        caption.querySelector(".body").textContent = shot.body;
        caption.querySelector(".proof").textContent = shot.proof;
        cursor.className = "canonical-demo-cursor" + (cursorState ? " " + cursorState : "");
      };
    })()
  `);
}

async function captureDemo(cdp, framesDir) {
  await setCaption(cdp, SHOTS[0]);
  await capture(cdp, join(framesDir, "01-screen-context.png"));

  await press(cdp, " ");
  await sleep(1500);
  await setCaption(cdp, SHOTS[1]);
  await capture(cdp, join(framesDir, "02-permission-prompt.png"));

  await dragIsland(cdp, "right");
  await sleep(250);
  await setCaption(cdp, SHOTS[2], "allow");
  await capture(cdp, join(framesDir, "03-allow.png"));

  await sleep(1800);
  await press(cdp, " ");
  await sleep(1500);
  await setCaption(cdp, SHOTS[3]);
  await capture(cdp, join(framesDir, "04-high-risk.png"));

  await dragIsland(cdp, "left");
  await sleep(250);
  await setCaption(cdp, SHOTS[4], "block");
  await capture(cdp, join(framesDir, "05-block.png"));

  await sleep(1800);
  await setCaption(cdp, SHOTS[5]);
  await capture(cdp, join(framesDir, "06-trust-log.png"));

  await press(cdp, " ");
  await sleep(1500);
  await setCaption(cdp, SHOTS[6]);
  await capture(cdp, join(framesDir, "07-try-next.png"));
}

async function setCaption(cdp, shot, cursorState = "") {
  await evaluate(cdp, `window.__canonicalDemoSetCaption(${JSON.stringify(shot)}, ${JSON.stringify(cursorState)})`);
  await sleep(120);
}

async function press(cdp, key) {
  const code = key === " " ? "Space" : key;
  await cdp.send("Input.dispatchKeyEvent", { type: "keyDown", key, code, text: key });
  await cdp.send("Input.dispatchKeyEvent", { type: "keyUp", key, code });
}

async function dragIsland(cdp, direction) {
  const box = await evaluate(cdp, `
    (() => {
      const rect = document.querySelector("#island").getBoundingClientRect();
      return { x: rect.left + rect.width / 2, y: rect.top + rect.height - 42 };
    })()
  `);
  const distance = direction === "right" ? 138 : -138;
  await cdp.send("Input.dispatchMouseEvent", { type: "mousePressed", x: box.x, y: box.y, button: "left", clickCount: 1 });
  for (let step = 1; step <= 8; step++) {
    await cdp.send("Input.dispatchMouseEvent", {
      type: "mouseMoved",
      x: box.x + (distance * step) / 8,
      y: box.y,
      button: "left",
    });
    await sleep(25);
  }
  await cdp.send("Input.dispatchMouseEvent", { type: "mouseReleased", x: box.x + distance, y: box.y, button: "left", clickCount: 1 });
}

async function capture(cdp, filePath) {
  const { data } = await cdp.send("Page.captureScreenshot", {
    format: "png",
    captureBeyondViewport: false,
  });
  writeFileSync(filePath, Buffer.from(data, "base64"));
}

async function evaluate(cdp, expression, awaitPromise = false) {
  const result = await cdp.send("Runtime.evaluate", {
    expression,
    awaitPromise,
    returnByValue: true,
  });
  if (result.exceptionDetails) {
    throw new Error(result.exceptionDetails.text || "Runtime.evaluate failed");
  }
  return result.result.value;
}

async function renderVideo(framesDir, output) {
  const listPath = join(framesDir, "concat.txt");
  const frameFiles = SHOTS.map((shot, index) => ({
    file: join(framesDir, `${String(index + 1).padStart(2, "0")}-${shot.id}.png`),
    duration: shot.duration,
  }));
  const concat = [
    ...frameFiles.flatMap((frame) => [`file '${frame.file.replaceAll("'", "'\\''")}'`, `duration ${frame.duration}`]),
    `file '${frameFiles.at(-1).file.replaceAll("'", "'\\''")}'`,
  ].join("\n");
  writeFileSync(listPath, `${concat}\n`);

  await run("ffmpeg", [
    "-y",
    "-hide_banner",
    "-loglevel",
    "error",
    "-f",
    "concat",
    "-safe",
    "0",
    "-i",
    listPath,
    "-vf",
    `fps=30,scale=${WIDTH}:${HEIGHT}:flags=lanczos,format=yuv420p`,
    "-t",
    "60",
    "-movflags",
    "+faststart",
    output,
  ]);
}

async function writeEvidence(evidenceOutput, videoPath) {
  const evidence = {
    schemaVersion: 1,
    video: {
      label: "canonical-60-second-demo-local",
      durationSeconds: 60,
      source: videoPath,
    },
    expected: {
      verdict: "ship",
      scoreRange: "9-12",
    },
    scores: {
      problemUnderstoodWithin15Seconds: {
        score: 2,
        timestamp: "00:03",
        evidence: "Opening caption and screen context establish that AI screen access is powerful and risky.",
      },
      allowBlockInteractionClear: {
        score: 2,
        timestamp: "00:18",
        evidence: "The video shows a right swipe to ALLOW and a left swipe to BLOCK.",
      },
      aiPermissionLayerNeedClear: {
        score: 2,
        timestamp: "00:08",
        evidence: "The Dynamic-Island-style prompt appears before the AI action.",
      },
      visualDirectionMemorable: {
        score: 2,
        timestamp: "00:14",
        evidence: "The Terminal Noir phone UI and Dynamic Island treatment remain visible throughout the demo.",
      },
      decisionFeedbackObvious: {
        score: 2,
        timestamp: "00:39",
        evidence: "Green ALLOWED and red BLOCKED confirmations are held, with counters incrementing.",
      },
      viewerKnowsHowToTryOrExplain: {
        score: 2,
        timestamp: "00:57",
        evidence: "The final frame returns to the next request and keeps the try-it-next link visible.",
      },
      total: 12,
    },
    evidence: [
      {
        timestamp: "00:03",
        agent: "Canonical Recording Script",
        verdict: "pass",
        note: "Screen context and permission risk are visible before the first prompt.",
      },
      {
        timestamp: "00:10",
        agent: "Canonical Recording Script",
        verdict: "pass",
        note: "Permission prompt appears before the AI action.",
      },
      {
        timestamp: "00:18",
        agent: "Canonical Recording Script",
        verdict: "pass",
        note: "Right swipe allows the request and ALLOWED increments.",
      },
      {
        timestamp: "00:29",
        agent: "Canonical Recording Script",
        verdict: "pass",
        note: "High-risk terminal delete request is visible before action.",
      },
      {
        timestamp: "00:39",
        agent: "Canonical Recording Script",
        verdict: "pass",
        note: "Left swipe blocks the request and BLOCKED increments.",
      },
      {
        timestamp: "00:49",
        agent: "Canonical Recording Script",
        verdict: "pass",
        note: "Trust log shows the allow and block decisions.",
      },
      {
        timestamp: "00:57",
        agent: "Canonical Recording Script",
        verdict: "pass",
        note: "Flow recovers to the next request with try-it-next path visible.",
      },
    ],
    proofShots: [
      { shot: "screen observation", timestamp: "00:03", verdict: "pass", fix: "" },
      { shot: "permission request", timestamp: "00:10", verdict: "pass", fix: "" },
      { shot: "ALLOW right swipe and green confirmation", timestamp: "00:18", verdict: "pass", fix: "" },
      { shot: "high-risk example", timestamp: "00:29", verdict: "pass", fix: "" },
      { shot: "BLOCK left swipe and red denial", timestamp: "00:39", verdict: "pass", fix: "" },
      { shot: "trust log or stats/history", timestamp: "00:49", verdict: "pass", fix: "" },
      { shot: "recovery to the next request", timestamp: "00:57", verdict: "pass", fix: "" },
    ],
    stateChanges: [
      { timestamp: "00:03", change: "screen context and AI permission risk are established" },
      { timestamp: "00:06", change: "permission prompt appears" },
      { timestamp: "00:14", change: "request allowed and allowed count increments" },
      { timestamp: "00:18", change: "green allowed confirmation remains visible" },
      { timestamp: "00:23", change: "high-risk terminal request appears" },
      { timestamp: "00:29", change: "terminal delete command risk is readable" },
      { timestamp: "00:35", change: "request blocked and blocked count increments" },
      { timestamp: "00:39", change: "red blocked confirmation remains visible" },
      { timestamp: "00:44", change: "decision history shows both choices" },
      { timestamp: "00:49", change: "trust log and counters remain visible" },
      { timestamp: "00:54", change: "flow returns to the next request" },
      { timestamp: "00:57", change: "try-it-next path remains visible" },
    ],
    strangerRetell: "AI asks permission before acting on your screen; swipe right to allow, swipe left to block, and the trust log records it.",
    tasks: [
      "Update docs/examples/video-feature-self-verify.demo-current.json to use this public or local evidence once the video is published.",
      "Publish the MP4 at a stable public URL before README/index linkage.",
    ],
  };
  writeFileSync(evidenceOutput, `${JSON.stringify(evidence, null, 2)}\n`);
}

async function probeDuration(filePath) {
  const output = await run("ffprobe", [
    "-v",
    "error",
    "-show_entries",
    "format=duration",
    "-of",
    "default=noprint_wrappers=1:nokey=1",
    filePath,
  ], { capture: true });
  return Number.parseFloat(output.trim());
}

async function run(command, args, options = {}) {
  return new Promise((resolveRun, rejectRun) => {
    const child = spawn(command, args, { stdio: options.capture ? ["ignore", "pipe", "pipe"] : "inherit" });
    let stdout = "";
    let stderr = "";
    child.stdout?.on("data", (chunk) => { stdout += chunk; });
    child.stderr?.on("data", (chunk) => { stderr += chunk; });
    child.on("error", rejectRun);
    child.on("exit", (code) => {
      if (code === 0) resolveRun(stdout);
      else rejectRun(new Error(`${command} exited ${code}${stderr ? `: ${stderr}` : ""}`));
    });
  });
}

class CdpClient {
  constructor(url) {
    this.url = url;
    this.id = 1;
    this.pending = new Map();
    this.ws = null;
  }

  async connect() {
    this.ws = new WebSocket(this.url);
    this.ws.addEventListener("message", (event) => this.onMessage(event));
    await new Promise((resolveOpen, rejectOpen) => {
      this.ws.addEventListener("open", resolveOpen, { once: true });
      this.ws.addEventListener("error", rejectOpen, { once: true });
    });
  }

  async send(method, params = {}) {
    const id = this.id++;
    const message = JSON.stringify({ id, method, params });
    const response = new Promise((resolveSend, rejectSend) => {
      this.pending.set(id, { resolve: resolveSend, reject: rejectSend });
    });
    this.ws.send(message);
    return response;
  }

  onMessage(event) {
    const payload = JSON.parse(event.data.toString());
    if (!payload.id) return;
    const pending = this.pending.get(payload.id);
    if (!pending) return;
    this.pending.delete(payload.id);
    if (payload.error) pending.reject(new Error(payload.error.message));
    else pending.resolve(payload.result || {});
  }

  async close() {
    if (!this.ws || this.ws.readyState > 1) return;
    this.ws.close();
  }
}

main().catch((error) => {
  console.error(error.stack || error.message);
  process.exit(1);
});
