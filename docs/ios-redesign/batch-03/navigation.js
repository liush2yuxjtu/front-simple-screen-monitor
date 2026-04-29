const pages = [
  { name: "Current iOS App", href: "/docs/ios-redesign/design.current-ios-app.html" },
  { name: "Sand Signal", href: "/docs/ios-redesign/design.sand-signal.html" },
  { name: "Moss Agenda", href: "/docs/ios-redesign/batch-02/design.moss-agenda.html" },
  { name: "Moss Triad", href: "/docs/ios-redesign/batch-03/design.moss-triad.html" },
  { name: "Yolo Sprint", href: "/docs/ios-redesign/batch-03/design.yolo-sprint.html" },
  { name: "Safe Harbor", href: "/docs/ios-redesign/batch-03/design.safe-harbor.html" },
  { name: "Approval Gate", href: "/docs/ios-redesign/batch-03/design.approval-gate.html" },
  { name: "Agenda Relay", href: "/docs/ios-redesign/batch-03/design.agenda-relay.html" },
  { name: "Trust Ladder", href: "/docs/ios-redesign/batch-03/design.trust-ladder.html" },
  { name: "Calendar Guard", href: "/docs/ios-redesign/batch-03/design.calendar-guard.html" },
  { name: "Soft Escalation", href: "/docs/ios-redesign/batch-03/design.soft-escalation.html" }
];

const side = document.querySelector(".side");
const index = Number(document.body.dataset.navIndex || 0);
if (!side || !Number.isInteger(index) || !pages[index]) {
  throw new Error("Batch 03 navigation setup is missing or invalid.");
}

const prev = pages[(index - 1 + pages.length) % pages.length];
const next = pages[(index + 1) % pages.length];

const style = document.createElement("style");
style.textContent = ".batch3-nav{margin-top:18px}.batch3-nav-actions{display:grid;grid-template-columns:1fr auto 1fr;gap:8px;align-items:center}.batch3-nav-actions a{text-align:center}.batch3-nav-meta{text-align:center;font:700 11px/1.2 var(--ui-font);letter-spacing:.14em;text-transform:uppercase;color:var(--muted)}.batch3-nav-tip{margin-top:10px;color:var(--muted);font-size:13px;line-height:1.5}";
document.head.appendChild(style);

const nav = document.createElement("div");
nav.className = "notes batch3-nav";
nav.innerHTML = `
  <strong>Version Nav</strong>
  <div class="batch3-nav-actions">
    <a class="tile-link" href="${prev.href}">← ${prev.name}</a>
    <div class="batch3-nav-meta">${index + 1} / ${pages.length}</div>
    <a class="tile-link" href="${next.href}">${next.name} →</a>
  </div>
  <div class="batch3-nav-tip">键盘：按 <code>←</code> / <code>→</code> 切到上一版或下一版。</div>
`;
side.appendChild(nav);

document.addEventListener("keydown", (event) => {
  if (event.key === "ArrowLeft") {
    window.location.href = prev.href;
  }
  if (event.key === "ArrowRight") {
    window.location.href = next.href;
  }
});
