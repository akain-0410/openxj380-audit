# Issue #23（发布时原文存档）

- 原始链接：https://github.com/xingji-studio/OpenXJ380/issues/23
- 标题：License: libwebp 缺少上游 COPYING/PATENTS/AUTHORS，manifest 指定的 license file 不含许可证全文
- 提出者：akain-0410
- 发布时间（GitHub API）：2026-08-02T09:12:00Z
- 抓取时间（UTC）：2026-08-02T09:15:46Z

> 正文为 GitHub API 抓取的发布时原文，未经改动。若原 Issue 被删除或正文被编辑，以本文件与其 Git 提交时间戳为准。

---

在 commit [`4349e4d`](https://github.com/xingji-studio/OpenXJ380/commit/4349e4d546406d11fc4bd0b4bcfa628ad2eef81f) 上核对。与 [#22](https://github.com/xingji-studio/OpenXJ380/issues/22) 不重叠（#22 覆盖 `elf.h`、`utflib`、`ioctl.h`、`llist.h`、`liballoc` 与许可证头，未涉及 libwebp）。

## 事实

[`third_party/compliance-manifest.json`](https://github.com/xingji-studio/OpenXJ380/blob/4349e4d/third_party/compliance-manifest.json) 中的条目：

```json
{"name":"libwebp","slug":"libwebp","license":"BSD-3-Clause",
 "license_files":["user/browser/third_party/libwebp/src/webp/types.h"],
 "source_files":["user/browser/third_party/libwebp"],"bundle_source":false}
```

被指定为 license file 的 [`src/webp/types.h`](https://github.com/xingji-studio/OpenXJ380/blob/4349e4d/user/browser/third_party/libwebp/src/webp/types.h) 头部原文：

```c
// Copyright 2010 Google Inc. All Rights Reserved.
//
// Use of this source code is governed by a BSD-style license
// that can be found in the COPYING file in the root of the source
// tree. An additional intellectual property rights grant can be found
// in the file PATENTS. All contributing project authors may
// be found in the AUTHORS file in the root of the source tree.
```

它本身不含 BSD-3-Clause 全文，而是指向 `COPYING`、`PATENTS`、`AUTHORS` 三个文件。这三个文件在仓库中都不存在：

```bash
find user/browser/third_party/libwebp \
  \( -iname 'COPYING*' -o -iname 'PATENTS*' -o -iname 'AUTHORS*' -o -iname 'LICENSE*' \) | wc -l
# 0        （该目录共 181 个入库文件）
```

## 为什么单独提出

- BSD-3-Clause 要求再分发时附带版权声明、条款列表与免责声明全文；目前仓库任何位置都没有这段全文，manifest 里那条 `license_files` 指向的只是一个"请看 COPYING"的指针。
- libwebp 的 [`PATENTS`](https://github.com/webmproject/libwebp/blob/main/PATENTS) 是与 BSD 许可证并列的**独立专利授权文件**，不是可选附件；缺失时下游拿到的分发物不携带该专利授权。这一点与普通的"忘拷 LICENSE"性质不同。
- 对照参考：同样以 "embedded in source headers" 方式声明的 NanoSVG（Zlib）与 RapidJSON（MIT），其头文件内确实内嵌了许可证全文，不存在这个问题——libwebp 是这一声明方式下的唯一例外，所以这更像是一次疏漏而非做法问题。

## 建议

1. 从对应上游版本拷入 `COPYING`、`PATENTS`、`AUTHORS` 到 `user/browser/third_party/libwebp/`；
2. 把 manifest 该条目的 `license_files` 改为指向 `COPYING` 与 `PATENTS`；
3. 可选：在 `THIRD_PARTY_NOTICES.md` 中把 libwebp 的 Material 一栏从 "embedded in source headers" 改为具体文件路径。

参照标准：BusyBox 那边的材料是完整的（[`third_party/busybox-source/`](https://github.com/xingji-studio/OpenXJ380/tree/4349e4d/third_party/busybox-source) 有上游归档、`LICENSE`、`.config`、编译补丁、`BUILDING.md`，测试里还有哈希断言）。按同一标准处理 libwebp 即可。


---

### 状态更新（抓取时间 2026-08-03T11:08:50Z）

- 当前状态：**open**
- 最后更新：2026-08-02T10:36:09Z
- 评论数：1

#### 全部评论原文

---

**Rainy101112** @ 2026-08-02T10:36:09Z

感谢你的Issue，我们已了解并将尽快处理。处理完成后将会提醒你。
