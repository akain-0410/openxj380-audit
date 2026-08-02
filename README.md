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

## 时间戳存证

已向该仓库提交 4 条 Issue，全部保留发布时原文与第三方时间戳：**[issues/](./issues/)（存档索引）**

| Issue | 主题 | 存档 |
|---|---|---|
| [#12](https://github.com/xingji-studio/OpenXJ380/issues/12) | MikanOS 字体逐字节一致、未声明且被标注"保留所有权利" | [原文+评论](./issues/issue-12.md) · [快照](https://web.archive.org/web/20260802091552/https://github.com/xingji-studio/OpenXJ380/issues/12) |
| [#23](https://github.com/xingji-studio/OpenXJ380/issues/23) | libwebp 缺 `COPYING`/`PATENTS`/`AUTHORS` | [原文](./issues/issue-23.md) · [快照](https://web.archive.org/web/20260802091612/https://github.com/xingji-studio/OpenXJ380/issues/23) |
| [#24](https://github.com/xingji-studio/OpenXJ380/issues/24) | `xiaolai.ttf`（小赖字体，OFL-1.1）无任何声明 | [原文](./issues/issue-24.md) · [快照](https://web.archive.org/web/20260802091632/https://github.com/xingji-studio/OpenXJ380/issues/24) |
| [#26](https://github.com/xingji-studio/OpenXJ380/issues/26) | `OVMF.fd`（EDK II 预编译固件）无来源与许可证记录 | [原文](./issues/issue-26.md) · [快照](https://web.archive.org/web/20260802091656/https://github.com/xingji-studio/OpenXJ380/issues/26) |

- 官网"完全由我们自主开发"宣称页快照：https://web.archive.org/web/20260801215244/https://www.xingjisoft.com/os/xj380/
- #12 发布当时的快照（对方修改前）：https://web.archive.org/web/20260801215205/https://github.com/xingji-studio/OpenXJ380/issues/12

## 被审方的响应（如实记录）

2026-08-02，对方在 #12 下回复并于 commit [`c6bcfb3`](https://github.com/xingji-studio/OpenXJ380/commit/c6bcfb33e9b3a4341fd73bd30e62759d12552eeb) 补充了 MikanOS 与两个字体的声明、删除了派生文件上不准确的版权行——响应在 24 小时内完成，这一点应予承认。经复核，该修改尚未同步到机器可读的 `compliance-manifest.json`（发行合规包由它生成），MikanOS 的 Apache-2.0 全文也未随仓库提供，因此分发物层面的合规状态暂未改变；详见 [issues/README.md](./issues/README.md)。本存档会随后续进展更新，包括他们完成整改的记录。