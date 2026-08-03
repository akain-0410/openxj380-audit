# OpenXJ380 对抗性审计报告

对 [xingji-studio/OpenXJ380](https://github.com/xingji-studio/OpenXJ380)（宣称"完全自主研发"的操作系统）的独立对抗性审计，基于第一性原则，所有结论均可复现。

**完整报告：**

- **[REPORT.md](./REPORT.md)** —— 对**公开源码仓库**的审计（代码溯源、许可证合规、字节级证据）
- **[IMAGE_AUDIT.md](./IMAGE_AUDIT.md)** —— 对**官方磁盘镜像 `XJ380.img`（实际分发物）**的审计。镜像与完整源码包（含 `.git`）取自第三方公开仓库 [xhdndmm/xj380os-full-report](https://github.com/xhdndmm/xj380os-full-report)（"XJ380OS的完整分析+源代码+磁盘镜像"），已在报告中标注来源。

## 核心结论

- 按源码物理行数，约 **92.6%** 来自第三方开源项目（lwIP、FatFs、litehtml、lexbor、mbedTLS、libwebp、BusyBox 等，大部分已声明），约 7.4%（~10 万行）为第一方代码。
- **字节级实锤**：内核字体 `font/hankaku.bin` 与日本教材项目 [MikanOS](https://github.com/uchan-nos/mikanos)（Apache-2.0）的字体 **4096/4096 字节逐字节一致**；图形基础层结构与 MikanOS 同构。该来源未在其第三方声明中出现，派生文件上标注"版权所有©XINGJI Studios 保留所有权利"。
- `font/ttf/XJ380F.ttf` 内部元数据为 Adobe **思源黑体**（OFL-1.1），来源未声明。
- 沙盒实测：公开仓库按其 README **无法完成内核链接**（printk/serial 实现缺失），无法产出系统镜像；bootloader 可在 QEMU 运行。
- 全部约 170 万行代码于 2026-08-01 单次 "first commit" 提交，无开发历史可查。

### 分发物层面（[IMAGE_AUDIT.md](./IMAGE_AUDIT.md)，2026-08-02 新增）

- **实际下载并解包了官方磁盘镜像 `XJ380.img`（sha256 `14daf0fe…`，128 MiB，GPT+FAT，101 个文件）**：镜像内**没有任何一个许可证、声明或版权文本文件**，而其中至少装着 13 个在二进制再分发时负有声明义务的第三方组件（BusyBox GPL-2.0、两款 OFL 字体、MikanOS hankaku、musl、libgcc、mbedTLS、litehtml、libwebp、lwIP、Mozilla CA 包等）。被审方自己的 `THIRD_PARTY_NOTICES.md` 白纸黑字写明"binary redistribution must reproduce the upstream notice"——**用他们自己的标准衡量他们自己的产物，这份镜像不合格**。
- **镜像里的 BusyBox 不是被审方公布 GPL 对应源码所对应的那个二进制**：哈希、体积（3,125,520 vs 2,485,536）、构建时间戳（`2020-02-24 14:41:50 +08` vs 空）三项全部不符。
- **源码考古发现一个名为 `No GPL！` 的提交（`89ac965f`，2026-04-04）**，删除了两个 GPL-3.0 上游（[Uinxed-Kernel](https://github.com/ViudiraTech/Uinxed-Kernel)、[cavOS](https://github.com/malwarepad/cavOS)）的版权署名。**但经量化核查，此次改写是实质性重写而非洗白**（改写后与上游 ≥3 行的连续相同代码块为 0），这一点对被审方有利，报告中如实认定。
- `mod/e1000.sys` 携带第三方个人版权声明 `Copyright (C) 2025  lihanrui2913`，但仓库内无任何许可授予记录，manifest 亦未列——分发物的许可状态目前无法确定。
- 如实更正：`include/elf.h` 已被真正替换为 musl 的 MIT 版本（与 musl 相似度 0.9806），不是改标签了事，该项应从缺口中划掉。

审计不否认其真实工程量（约 10 万行第一方整合与子系统代码），审查对象是"完全自主研发"这一公开宣称与许可证合规性。报告附有全部证据的复现步骤，欢迎以证据反驳。

## 时间戳存证

已向该仓库提交 4 条 Issue，全部保留发布时原文与第三方时间戳：**[issues/](./issues/)（存档索引）**

| Issue | 主题 | 当前状态（2026-08-03 复核） | 存档 |
|---|---|---|---|
| [#12](https://github.com/xingji-studio/OpenXJ380/issues/12) | MikanOS 字体逐字节一致、未声明且被标注"保留所有权利" | **已实际修复**，已同意关闭 | [原文+评论](./issues/issue-12.md) · [快照](https://web.archive.org/web/20260802091552/https://github.com/xingji-studio/OpenXJ380/issues/12) |
| [#23](https://github.com/xingji-studio/OpenXJ380/issues/23) | libwebp 缺 `COPYING`/`PATENTS`/`AUTHORS` | 未修复 | [原文](./issues/issue-23.md) · [快照](https://web.archive.org/web/20260802091612/https://github.com/xingji-studio/OpenXJ380/issues/23) |
| [#24](https://github.com/xingji-studio/OpenXJ380/issues/24) | `xiaolai.ttf`（小赖字体，OFL-1.1）无任何声明 | 被审方关闭（理由：应在 StardustUI 上游修），文件仍在且 manifest 未登记 | [原文](./issues/issue-24.md) · [快照](https://web.archive.org/web/20260802091632/https://github.com/xingji-studio/OpenXJ380/issues/24) |
| [#26](https://github.com/xingji-studio/OpenXJ380/issues/26) | `OVMF.fd`（EDK II 预编译固件）无来源与许可证记录 | 未修复 | [原文](./issues/issue-26.md) · [快照](https://web.archive.org/web/20260802091656/https://github.com/xingji-studio/OpenXJ380/issues/26) |

- 官网"完全由我们自主开发"宣称页快照：https://web.archive.org/web/20260801215244/https://www.xingjisoft.com/os/xj380/
- #12 发布当时的快照（对方修改前）：https://web.archive.org/web/20260801215205/https://github.com/xingji-studio/OpenXJ380/issues/12

## 被审方的响应（如实记录）

2026-08-02，对方在 #12 下回复并于 commit [`c6bcfb3`](https://github.com/xingji-studio/OpenXJ380/commit/c6bcfb33e9b3a4341fd73bd30e62759d12552eeb) 补充了 MikanOS 与两个字体的声明、删除了派生文件上不准确的版权行——响应在 24 小时内完成，这一点应予承认。当时复核指出三项残留（manifest 未同步、Apache-2.0 全文缺失、派生文件无归属注释）。

**2026-08-03 在 commit [`ad39a67`](https://github.com/xingji-studio/OpenXJ380/commit/ad39a67) 上再次实测复核：#12 的三项残留已全部真实闭合**——`compliance-manifest.json` 从 16 项补到 21 项（且所有 `license_files` 路径存在）、新增 `licenses/mikanos.txt` 与 `third_party/mikanos-hankaku/`（含上游 commit 与哈希的 `SOURCE.md`，可脱网验证）、`fbc.h` 与 `GOP.hpp` 补上了 MikanOS 来源归属，另额外补了 talc、libutf 条目并将 `licenses/glibc-elf-h.txt` 换为 `musllibc-elf-h.txt`。这是实质性、可验证的整改，已同意关闭 #12。

同一时点的其余三条仍有缺口：#23（libwebp）与 #26（`OVMF.fd`）在仓库内无任何变化；#24 被对方以"应在 StardustUI 库修改"为由关闭——上游当修这一点成立，但 OpenXJ380 自身仍分发着同一个 25 MB 的 OFL 字体，而其 manifest 已有 `RapidJSON`（同样位于 StardustUI 内）的登记先例，口径不一致。逐项复核命令与证据见 [issues/README.md](./issues/README.md)。