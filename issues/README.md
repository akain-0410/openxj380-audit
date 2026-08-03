# 议题存档索引

本目录保存向 [xingji-studio/OpenXJ380](https://github.com/xingji-studio/OpenXJ380) 提交的全部 Issue 的**发布时原文**（GitHub API 抓取，含抓取时刻的全部评论），以及第三方时间戳快照链接。

为什么要做双重存档：Issue 的正文可被作者与仓库管理员编辑、Issue 本身可被删除或锁定。本目录的文件由 Git 提交时间戳背书（谁都能核对提交历史），Wayback Machine 快照则提供不受任何一方控制的第三方时间戳，两者互相独立。

| Issue | 主题 | 发布时间（UTC） | 当前状态 | 存档原文 | Wayback 快照 |
|---|---|---|---|---|---|
| [#12](https://github.com/xingji-studio/OpenXJ380/issues/12) | `font/hankaku.bin` 与 MikanOS 字体逐字节一致（4096/4096），未声明来源且被标注"保留所有权利" | 2026-08-01 21:48:56 | open（**整改已验证闭合，已同意关闭**） | [issue-12.md](./issue-12.md) | [发布时](https://web.archive.org/web/20260801215205/https://github.com/xingji-studio/OpenXJ380/issues/12) · [含回复](https://web.archive.org/web/20260802091552/https://github.com/xingji-studio/OpenXJ380/issues/12) · [整改完成后](https://web.archive.org/web/20260803110915/https://github.com/xingji-studio/OpenXJ380/issues/12) |
| [#23](https://github.com/xingji-studio/OpenXJ380/issues/23) | libwebp 缺上游 `COPYING`/`PATENTS`/`AUTHORS`，manifest 指定的 license file 不含许可证全文 | 2026-08-02 09:12:00 | open（未修复） | [issue-23.md](./issue-23.md) | [快照](https://web.archive.org/web/20260802091612/https://github.com/xingji-studio/OpenXJ380/issues/23) |
| [#24](https://github.com/xingji-studio/OpenXJ380/issues/24) | `frameworks/StardustUI/fonts/xiaolai.ttf`（小赖字体 SC，OFL-1.1）无任何声明 | 2026-08-02 09:12:28 | **closed**（被审方于 2026-08-02 12:37 关闭，理由为"应在 StardustUI 库修改"） | [issue-24.md](./issue-24.md) | [快照](https://web.archive.org/web/20260802091632/https://github.com/xingji-studio/OpenXJ380/issues/24) · [关闭后](https://web.archive.org/web/20260803110933/https://github.com/xingji-studio/OpenXJ380/issues/24) |
| [#26](https://github.com/xingji-studio/OpenXJ380/issues/26) | 根目录 `OVMF.fd`（edk2-stable202011 预编译固件）无来源/版本/许可证记录 | 2026-08-02 09:12:47 | open（未修复） | [issue-26.md](./issue-26.md) | [快照](https://web.archive.org/web/20260802091656/https://github.com/xingji-studio/OpenXJ380/issues/26) |

首次存档抓取时间：2026-08-02 09:14 UTC（当时四条均为 open）。各 `issue-*.md` 末尾附有 **2026-08-03 的状态更新与全部评论原文**。

仓库根目录的 `ISSUE.md` 与 `issue12_as_published.md` 是 #12 的早期存档（不含后续评论），保留不动；[issues/issue-12.md](./issue-12.md) 是含完整评论的版本。

---

## 处理进展汇总（截至 2026-08-03 11:13 UTC）

在公开仓库 commit [`ad39a67`](https://github.com/xingji-studio/OpenXJ380/commit/ad39a67) 上实测复核（不采信回复中的说法，只看仓库内字节）：

### #12：三项要求全部真实闭合，已同意关闭

| 复核项 | 命令 / 证据 | 结果 |
|---|---|---|
| manifest 同步 | `components` 从 16 项⇒ **21 项**，三项新声明均在内；逐个校验 `license_files` 路径，**缺失 0** | ✅ |
| Apache-2.0 全文 | 新增 `licenses/mikanos.txt`（200 行，含 APPENDIX）与 `third_party/mikanos-hankaku/{LICENSE,SOURCE.md,hankaku.txt}`，`SOURCE.md` 记录上游 commit `b5f7740c` 与哈希 | ✅ |
| 派生文件归属 | `include/efi/fbc.h`、`include/graphics/GOP.hpp` 首行均已加 `// Portions derived from MikanOS (…), Apache-2.0.` | ✅ |
| 额外整改（未要求） | 又补了 `talc allocator`、`libutf` 条目；`licenses/glibc-elf-h.txt` 换为 `musllibc-elf-h.txt` | — |

仅剩一个不影响关闭的 nit：`SOURCE.md` 记录的 `hankaku.txt`/`LICENSE` 哈希是**上游真值**（已从 `b5f7740c` 拉取复算，完全吻合），而入库副本的行尾换行符被去掉一个字节（38776→38775、11357→11356），除此一字节外逐字节相同；且 `tests/test_license_compliance.py` 对这两个哈希无断言，所以该偏差是静默的。`font/hankaku.bin` 本身的哈希与记录一致（`317e04a7…`）。

### #23、#26：仍未修复

均只有"会尽快处理"的回复。在 `ad39a67` 上：`user/browser/third_party/libwebp/` 下仍无 `COPYING`/`PATENTS`/`AUTHORS`（只有 `src`），manifest 的 libwebp 条目仍指向 `types.h`；`OVMF.fd` 在 `compliance-manifest.json` 与 `THIRD_PARTY_NOTICES.md` 中仍为 **0 次提及**。

### #24：被审方自行关闭，理由部分成立，但存在双重口径

关闭理由（原文）："这个应该在StardustUI库进行修改，因为StardustUI库也是XJ380的一个第三方引用"。

如实记录：**"应在上游修"这一点成立**，StardustUI 确实是独立仓库（submodule，`.gitmodules` 可证）。但两个客观事实使得 OpenXJ380 侧的义务并未因此消失：

1. OpenXJ380 的工作树里**实际分发着同一个 25 MB 字体**（`frameworks/StardustUI/fonts/xiaolai.ttf`，sha256 `69f8f50a9a3696357b50b4c5d7d17efecb17a23c7a818ff917c21169f15555f9`）；
2. 其 manifest 里已有 **`RapidJSON` 这个先例**——`license_files` 指向 `frameworks/StardustUI/includes/rapidjson/rapidjson.h`，即"StardustUI 内的第三方资产"照样会在 OpenXJ380 的 manifest 中登记。同一类资产两种口径。

另外，顺着对方指的路径查下去，在 StardustUI 仓库发现一个比原 #24 更严重的问题：该仓库的根 `LICENSE` 是 `MIT License / Copyright (c) 2026 XINGJI Studios`，**字面覆盖全仓**，而仓里就放着这个 OFL-1.1 字体（`fonts/xiaolai.ttf`）且无任何例外说明（`README.md` 内检索 `font`/`licen`/`OFL` 均无命中）。OFL 字体不能被重新许可为 MIT。快照：[StardustUI LICENSE](https://web.archive.org/web/20260803110951/https://github.com/xingji-studio/StardustUI/blob/main/LICENSE) · [fonts/](https://web.archive.org/web/20260803111301/https://github.com/xingji-studio/StardustUI/tree/main/fonts)。此事已按对方建议移往 StardustUI 仓库跟进。

---

## #12 的早期处理进展（截至 2026-08-02 09:14 UTC，保留原记录）

对方（Rainy101112）在 #12 下两次回复并于 commit [`c6bcfb3`](https://github.com/xingji-studio/OpenXJ380/commit/c6bcfb33e9b3a4341fd73bd30e62759d12552eeb) 作出修改：`THIRD_PARTY_NOTICES.md` 新增 MikanOS hankaku.bin / maple-font / Source Han Sans 三行，新增 `font/ttf/LICENSES.md`（两份 OFL 全文），并从 `include/efi/efi.h`、`include/efi/fbc.h`、`include/graphics/GOP.hpp` 删除"版权所有©XINGJI Studios…保留所有权利"。

响应速度与态度值得记录在案。但在 commit [`4349e4d`](https://github.com/xingji-studio/OpenXJ380/commit/4349e4d546406d11fc4bd0b4bcfa628ad2eef81f) 上复核，修改只落在人读文档层面，三项客观残留（复核命令见 [issue-12.md](./issue-12.md) 中的第三条评论）：

1. 三项新声明未进入 `third_party/compliance-manifest.json`（其 `components` 仍为 16 项），而 `THIRD_PARTY_NOTICES.md` 自述该 manifest 才是机器可读清单、发行包 `out/compliance/third-party` 由它生成——因此**最终分发物的合规状态尚未改变**；
2. MikanOS 的 Apache-2.0 全文未随仓库提供（`licenses/` 下仅 4 个文件，无对应条目），与 Apache-2.0 §4(a) 不符；
3. `include/efi/fbc.h`、`include/graphics/GOP.hpp` 只删除了不准确的版权行，未补来源归属注释。

上述三点已作为评论提交至 #12。**后续已全部完成，见本文开头的汇总。**

---

## 存档方法（可复核）

```bash
# 发布时原文（含评论）
gh api repos/xingji-studio/OpenXJ380/issues/<N>          --jq .body
gh api repos/xingji-studio/OpenXJ380/issues/<N>/comments --jq '.[] | .user.login, .created_at, .body'

# 第三方时间戳
curl -sL "https://web.archive.org/save/https://github.com/xingji-studio/OpenXJ380/issues/<N>"
```

每份快照在保存后均已回访验证确实抓到了正文关键内容（分别检索 `hankaku`、`PATENTS`、`xiaolai`、`edk2-stable202011`，命中数 8–14），排除了"快照页面只存到了 GitHub 加载壳"的情况。
