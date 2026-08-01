# OpenXJ380 对抗性审计报告

对 [xingji-studio/OpenXJ380](https://github.com/xingji-studio/OpenXJ380)（宣称"完全自主研发"的操作系统）的独立对抗性审计，基于第一性原则，所有结论均可复现。

**完整报告：[REPORT.md](./REPORT.md)**

## 核心结论

- 按源码物理行数，约 **92.6%** 来自第三方开源项目（lwIP、FatFs、litehtml、lexbor、mbedTLS、libwebp、BusyBox 等，大部分已声明），约 7.4%（~10 万行）为第一方代码。
- **字节级实锤**：内核字体 `font/hankaku.bin` 与日本教材项目 [MikanOS](https://github.com/uchan-nos/mikanos)（Apache-2.0）的字体 **4096/4096 字节逐字节一致**；图形基础层结构与 MikanOS 同构。该来源未在其第三方声明中出现，派生文件上标注"版权所有©XINGJI Studios 保留所有权利"。
- `font/ttf/XJ380F.ttf` 内部元数据为 Adobe **思源黑体**（OFL-1.1），来源未声明。
- 沙盒实测：公开仓库按其 README **无法完成内核链接**（printk/serial 实现缺失），无法产出系统镜像；bootloader 可在 QEMU 运行。
- 全部约 170 万行代码于 2026-08-01 单次 "first commit" 提交，无开发历史可查。

审计不否认其真实工程量（约 10 万行第一方整合与子系统代码），审查对象是"完全自主研发"这一公开宣称与许可证合规性。报告附有全部证据的复现步骤，欢迎以证据反驳。
