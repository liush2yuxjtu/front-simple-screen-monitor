// Shared chamber helpers. Include after pool.js.

window.showVerdict = function (kind, cb) {
  const flash = document.createElement('div');
  flash.className = 'verdict-flash ' + kind;
  flash.textContent = kind === 'approve' ? '准' : '驳';
  document.body.appendChild(flash);
  requestAnimationFrame(() => flash.classList.add('show'));
  if (navigator.vibrate) {
    navigator.vibrate(kind === 'approve' ? 40 : [80, 40, 80]);
  }
  setTimeout(() => {
    flash.classList.remove('show');
    setTimeout(() => {
      flash.remove();
      if (cb) cb();
    }, 500);
  }, 900);
};

window.cast = function (kind) {
  window.showVerdict(kind, () => {
    if (typeof window.nextRequest === 'function') window.nextRequest();
  });
};

window.installBack = function () {
  if (document.querySelector('.back')) return;
  const a = document.createElement('a');
  a.className = 'back';
  a.href = '../';
  a.textContent = '← 廊';
  document.body.appendChild(a);
};

document.addEventListener('DOMContentLoaded', () => {
  window.installBack();
  document.addEventListener('keydown', (e) => {
    if (e.key === 'a' || e.key === 'A') window.cast('approve');
    else if (e.key === 'd' || e.key === 'D') window.cast('reject');
  });
});
