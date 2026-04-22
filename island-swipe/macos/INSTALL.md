# Activity Monitor for Developers

这个文档只面向开发者：从源码在自己的 Mac 上构建并运行 `Activity Monitor.app`。

## 要求

- macOS 14 或更高
- Apple Silicon Mac
- 已安装 Apple 开发工具链

如果还没装命令行工具：

```bash
xcode-select --install
```

## 获取源码

```bash
git clone https://github.com/liush2yuxjtu/front-simple-screen-monitor.git
cd front-simple-screen-monitor/island-swipe/macos
```

如果你拿到的是源码压缩包，解压后进入：

```bash
cd island-swipe/macos
```

## 首次准备

```bash
chmod +x script/*.sh
```

## 验证交互逻辑

```bash
./script/self_check.sh
```

预期输出：

```bash
SELF CHECK PASSED
```

## 直接运行 app

```bash
./script/build_and_run.sh
```

这会：

- 构建 app
- 生成本地 `.app` bundle
- 自动打开应用

## 安装到自己机器

安装到当前用户目录：

```bash
./script/install_app.sh --user
```

安装完成后，app 会出现在：

```bash
~/Applications/Activity Monitor.app
```

也可以直接打开：

```bash
open "$HOME/Applications/Activity Monitor.app"
```

## 常用命令

调试运行：

```bash
./script/build_and_run.sh --debug
```

查看日志：

```bash
./script/build_and_run.sh --logs
```

校验 app 是否能拉起：

```bash
./script/build_and_run.sh --verify
```

## 已知边界

- 当前项目默认生成 `arm64` app，不面向 Intel Mac
- 最低系统版本是 macOS 14
- 给开发者自己本地构建自己用，优先走源码方式
- 当前仓库里的本地打包产物是 `adhoc` 签名，不是面向普通终端用户的正式分发包
