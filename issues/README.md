# 议题存档索引

本目录保存向 [xingji-studio/OpenXJ380](https://github.com/xingji-studio/OpenXJ380) 提交的全部 Issue 的**发布时原文**（GitHub API 抓取，含抓取时刻的全部评论），以及第三方时间戳快照链接。

为什么要做双重存档：Issue 的正文可被作者与仓库管理员编辑、Issue 本身可被删除或锁定。本目录的文件由 Git 提交时间戳背书（谁都能核对提交历史），Wayback Machine 快照则提供不受任何一方控制的第三方时间戳，两者互相独立。

| Issue | 主题 | 发布时间（UTC） | 存档原文 | Wayback 快照 |
|---|---|---|---|---|
| [#12](https://github.com/xingji-studio/OpenXJ380/issues/12) | `font/hankaku.bin` 与 MikanOS 字体逐字节一致（4096/4096），未声明来源且被标注"保留所有权利" | 2026-08-01 21:48:56 | [issue-12.md](./issue-12.md) | [发布时](https://web.archive.org/web/20260801215205/https://github.com/xingji-studio/OpenXJ380/issues/12) · [含回复](https://web.archive.org/web/20260802091552/https://github.com/xingji-studio/OpenXJ380/issues/12) |
| [#23](https://github.com/xingji-studio/OpenXJ380/issues/23) | libwebp 缺上游 `COPYING`/`PATENTS`/`AUTHORS`，manifest 指定的 license file 不含许可证全文 | 2026-08-02 09:12:00 | [issue-23.md](./issue-23.md) | [快照](https://web.archive.org/web/20260802091612/https://github.com/xingji-studio/OpenXJ380/issues/23) |
| [#24](https://github.com/xingji-studio/OpenXJ380/issues/24) | `frameworks/StardustUI/fonts/xiaolai.ttf`（小赖字体 SC，OFL-1.1）无任何声明 | 2026-08-02 09:12:28 | [issue-24.md](./issue-24.md) | [快照](https://web.archive.org/web/20260802091632/https://github.com/xingji-studio/OpenXJ380/issues/24) |
| [#26](https://github.com/xingji-studio/OpenXJ380/issues/26) | 根目录 `OVMF.fd`（edk2-stable202011 预编译固件）无来源/版本/许可证记录 | 2026-08-02 09:12:47 | [issue-26.md](./issue-26.md) | [快照](https://web.archive.org/web/20260802091656/https://github.com/xingji-studio/OpenXJ380/issues/26) |

存档抓取时间：2026-08-02 09:14 UTC。抓取时四条 Issue 状态均为 open。

仓库根目录的 `ISSUE.md` 与 `issue12_as_published.md` 是 #12 的早期存档（不含后续评论），保留不动；[issues/issue-12.md](./issue-12.md) 是含完整评论的版本。

---

## #12 的处理进展（截至 2026-08-02 09:14 UTC）

对方（Rainy101112）在 #12 下两次回复并于 commit [`c6bcfb3`](https://github.com/xingji-studio/OpenXJ380/commit/c6bcfb33e9b3a4341fd73bd30e62759d12552eeb) 作出修改：`THIRD_PARTY_NOTICES.md` 新增 MikanOS hankaku.bin / maple-font / Source Han Sans 三行，新增 `font/ttf/LICENSES.md`（两份 OFL 全文），并从 `include/efi/efi.h`、`include/efi/fbc.h`、`include/graphics/GOP.hpp` 删除"版权所有©XINGJI Studios…保留所有权利"。

响应速度与态度值得记录在案。但在 commit [`4349e4d`](https://github.com/xingji-studio/OpenXJ380/commit/4349e4d546406d11fc4bd0b4bcfa628ad2eef81f) 上复核，修改只落在人读文档层面，三项客观残留（复核命令见 [issue-12.md](./issue-12.md) 中的第三条评论）：

1. 三项新声明未进入 `third_party/compliance-manifest.json`（其 `components` 仍为 16 项），而 `THIRD_PARTY_NOTICES.md` 自述该 manifest 才是机器可读清单、发行包 `out/compliance/third-party` 由它生成——因此**最终分发物的合规状态尚未改变**；
2. MikanOS 的 Apache-2.0 全文未随仓库提供（`licenses/` 下仅 4 个文件，无对应条目），与 Apache-2.0 §4(a) 不符；
3. `include/efi/fbc.h`、`include/graphics/GOP.hpp` 只删除了不准确的版权行，未补来源归属注释。

上述三点已作为评论提交至 #12，等待处理。

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
