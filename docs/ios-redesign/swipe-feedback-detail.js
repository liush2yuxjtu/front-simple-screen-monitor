(() => {
  const phone = document.querySelector(".phone");
  const card = document.querySelector(".demo");
  if (!phone || !card) return;

  const actionText = phone.innerText.includes("丢掉")
    ? "丢掉"
    : phone.innerText.includes("依据")
      ? "依据"
      : phone.innerText.includes("稍后")
        ? "稍后"
        : "执行";
  const vector = {
    "执行": [1, 0],
    "丢掉": [-1, 0],
    "依据": [0, -1],
    "稍后": [0, 1],
  }[actionText];
  const live = document.createElement("div");
  live.className = "swipe-live";
  phone.appendChild(live);

  const style = document.createElement("style");
  style.textContent = `
    .phone .feedback,.phone .stamp,.phone .drawer,.phone .slot,.phone .rail,
    .phone .tear,.phone .witness,.phone .ticker,.phone .route,.phone .line,
    .phone .beam,.phone .cells,.phone .halo,.phone .mask,.phone .receipt,
    .phone .harbor{pointer-events:none}
    .demo{cursor:grab;touch-action:none;user-select:none;will-change:transform}
    .demo:active{cursor:grabbing}
    .swipe-live{position:absolute;left:26px;right:26px;bottom:22px;z-index:30;
      padding:13px 16px;border-radius:999px;background:rgba(255,255,255,.13);
      border:1px solid rgba(255,255,255,.18);color:var(--text,#fff);
      font:800 13px/1 var(--ui-font);letter-spacing:.04em;text-align:center;
      opacity:.72;transition:background .18s ease,transform .18s ease}
    .swipe-live.ready{background:var(--accent);color:#17110c;transform:scale(1.03)}
    .swipe-live.done{background:#fff;color:#17110c;transform:scale(1.06)}
  `;
  document.head.appendChild(style);

  let startX = 0;
  let startY = 0;
  let baseTransform = "";
  let dragging = false;

  function setLive(progress, done = false) {
    const pct = Math.round(progress * 100);
    live.textContent = done
      ? `${actionText}已触发`
      : `${actionText} ${pct}% · 拖动卡片试手感`;
    live.classList.toggle("ready", progress >= 0.7);
    live.classList.toggle("done", done);
  }

  function progressFor(dx, dy) {
    return Math.max(0, Math.min(1, (dx * vector[0] + dy * vector[1]) / 150));
  }

  setLive(0);

  function begin(clientX, clientY) {
    dragging = true;
    startX = clientX;
    startY = clientY;
    baseTransform = getComputedStyle(card).transform;
    if (baseTransform === "none") baseTransform = "";
    card.style.transition = "none";
  }

  function move(clientX, clientY) {
    if (!dragging) return;
    const dx = clientX - startX;
    const dy = clientY - startY;
    const progress = progressFor(dx, dy);
    const lean = Math.max(-7, Math.min(7, dx / 16));
    card.style.transform = `${baseTransform} translate(${dx}px, ${dy}px) rotate(${lean}deg)`;
    setLive(progress);
  }

  function finish(clientX, clientY) {
    if (!dragging) return;
    dragging = false;
    const dx = clientX - startX;
    const dy = clientY - startY;
    const progress = progressFor(dx, dy);
    card.style.transition = "transform .34s cubic-bezier(.2,.8,.2,1)";
    if (progress >= 0.7) {
      card.style.transform = `${baseTransform} translate(${vector[0] * 180}px, ${vector[1] * 180}px) scale(.94)`;
      setLive(1, true);
      setTimeout(() => {
        card.style.transform = baseTransform;
        setLive(0);
      }, 900);
    } else {
      card.style.transform = baseTransform;
      setLive(0);
    }
  }

  card.addEventListener("pointerdown", (event) => {
    begin(event.clientX, event.clientY);
    card.setPointerCapture(event.pointerId);
  });
  card.addEventListener("pointermove", (event) => move(event.clientX, event.clientY));
  card.addEventListener("pointerup", (event) => finish(event.clientX, event.clientY));
  card.addEventListener("pointercancel", (event) => finish(event.clientX, event.clientY));

  card.addEventListener("touchstart", (event) => {
    const touch = event.changedTouches[0];
    if (!touch) return;
    event.preventDefault();
    begin(touch.clientX, touch.clientY);
  }, { passive: false });
  card.addEventListener("touchmove", (event) => {
    const touch = event.changedTouches[0];
    if (!touch) return;
    event.preventDefault();
    move(touch.clientX, touch.clientY);
  }, { passive: false });
  card.addEventListener("touchend", (event) => {
    const touch = event.changedTouches[0];
    if (!touch) return;
    event.preventDefault();
    finish(touch.clientX, touch.clientY);
  }, { passive: false });
})();
