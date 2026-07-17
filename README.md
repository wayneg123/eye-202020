# EyeBreak 20-20-20

一款原生 macOS 护眼提醒应用。默认每工作 20 分钟，提醒你看向 20 英尺（约 6 米）外并休息 20 秒。

## 功能

- 菜单栏常驻倒计时与主窗口概览
- 系统通知和跨空间置顶休息窗口
- 工作时间、观察距离与休息时长自定义
- 5 分钟后再次提醒、提前结束与跳过记录
- 今日摘要、最近 7 天趋势和连续完成天数
- 锁屏、睡眠和显示器休眠后重新开始工作周期
- 开机启动、通知声音和本地数据持久化

## 运行要求

- macOS 14 或更高版本
- 完整版 Xcode（仅安装 Command Line Tools 不足以构建 `.app`）

安装 Xcode 后，打开 `Eye202020.xcodeproj`，选择 `Eye202020` Scheme，按 `⌘R` 运行。首次启动会请求通知权限；不开启通知也不影响休息窗口出现。

## 测试

在 Xcode 中按 `⌘U`，或运行：

```sh
xcodebuild test -project Eye202020.xcodeproj -scheme Eye202020 -destination 'platform=macOS'
```

所有设置与统计都保存在本机 `UserDefaults` 中，不需要账号或网络服务。

## 视觉资源

- `Design/AppIcon.svg` 是可编辑的矢量图标源文件。
- 休息窗口山谷背景由 OpenAI 内置图像生成工具创建，作为项目内原创位图资源使用。
