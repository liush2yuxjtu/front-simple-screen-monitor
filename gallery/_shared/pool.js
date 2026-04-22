// Shared request pool for all gallery chambers.
window.REQUEST_POOL = [
  {
    intent: '开启浏览器，访问 YouTube',
    reason: '察觉用户将鼠标停于 Dock 中 Chrome 图标近旁。推断欲观览影像以解乏。',
    app: 'Chrome',
    risk: 'low'
  },
  {
    intent: '以 Terminal 执行 rm -rf node_modules',
    reason: '终端光标驻留于项目根目录，已键入删除之指令尚未敲回车。须慎之又慎。',
    app: 'iTerm2',
    risk: 'high'
  },
  {
    intent: '撰写邮件致 Anthropic 招聘官',
    reason: '邮箱草稿已填收件人，正文寥寥未成。观其反复删改，似求稳妥之措辞。',
    app: 'Mail',
    risk: 'med'
  },
  {
    intent: '打开 VS Code 续编 auth.ts',
    reason: '上次编辑中断于第 42 行 token 校验。时辰已过半刻，当续笔完工。',
    app: 'VS Code',
    risk: 'low'
  },
  {
    intent: '登陆网银转账五万两',
    reason: '浏览器驻留招商银行登陆页。此数非小，疑或受人所惑。',
    app: 'Safari',
    risk: 'high'
  },
  {
    intent: '关闭 Slack 通知两小时',
    reason: '察觉用户于深度编码之际频繁被扰。推断欲进入心流之境。',
    app: 'Slack',
    risk: 'low'
  }
];

window.pickRequest = function () {
  return window.REQUEST_POOL[Math.floor(Math.random() * window.REQUEST_POOL.length)];
};

window.riskLabel = function (r) {
  return { low: '轻', med: '中', high: '重' }[r] || '—';
};
