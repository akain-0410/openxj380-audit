# StardustUI Issue #15（发布时原文存档）

- 原始链接：https://github.com/xingji-studio/StardustUI/issues/15
- 标题：License: `fonts/xiaolai.ttf` 为 OFL-1.1 的「小赖字体 SC」，但仓库 LICENSE 以 MIT 覆盖全仓且无任何字体声明
- 提出者：akain-0410
- 发布时间（GitHub API）：2026-08-03T11:10:41Z
- 抓取时间（UTC）：2026-08-03T11:20:30Z
- 当前状态：open，评论数 0

> 本条源自 [OpenXJ380 #24](https://github.com/xingji-studio/OpenXJ380/issues/24) 被审方以"应该在StardustUI库进行修改"为由关闭后，按其建议移往上游仓库提交。正文为 GitHub API 抓取的发布时原文，未经改动。

---

## 概述

`fonts/xiaolai.ttf`（25,056,308 字节）是第三方字体「小赖字体 SC / Xiaolai SC」，其内嵌元数据明确声明为 **SIL Open Font License 1.1**，版权属于 LXGW 与 Nozomi Seto（瀬戸のぞみ）。

但本仓库根目录的 `LICENSE` 是：

```
MIT License

Copyright (c) 2026 XINGJI Studios
```

MIT 许可证文本的授权范围是"the Software"，即本仓库内容整体。仓库内没有任何 `NOTICE`/`THIRD_PARTY_NOTICES`/`fonts/LICENSE` 之类的例外说明（`README.md` 中检索 `font`/`licen`/`第三方`/`OFL` 均无命中），因此对下游读者而言，当前的声明状态等于**把一个 OFL-1.1 字体连带声明为 XINGJI Studios 版权的 MIT 作品**。

这有两个独立的问题：

1. **OFL-1.1 字体不能被重新许可为 MIT。** OFL §2 要求任何再分发（无论是否修改）都必须随附本许可证副本；OFL 还禁止在未获授权的情况下变更版权归属。
2. **OFL §5 与 MIT 的授权范围直接冲突**：OFL 明确禁止单独出售字体软件本身，并要求衍生作品继续以 OFL 分发；MIT 则授予"无条件的商业与再许可权利"。两者叠加在同一个 `LICENSE` 文件的覆盖范围下无法同时成立。

## 证据（可复现）

```bash
sha256sum fonts/xiaolai.ttf
# 69f8f50a9a3696357b50b4c5d7d17efecb17a23c7a818ff917c21169f15555f9

python3 -c "
from fontTools.ttLib import TTFont
n = TTFont('fonts/xiaolai.ttf', lazy=True)['name']
for i in (0, 1, 5, 7, 9, 13, 14):
    print(i, '|', n.getDebugName(i))"
```

输出（字体自身的 name 表，非第三方推测）：

```
0  | Copyright © 2020 LXGW
1  | Xiaolai SC
5  | Version 3.00;June 18, 2020
7  | 小赖字体 SC
9  | Nozomi Seto 瀬戸のぞみ
13 | This Font Software is licensed under the SIL Open Font License, Version 1.1. …
14 | http://scripts.sil.org/OFL
```

上游：<https://github.com/lxgw/kose-font>（OFL-1.1）。

## 为什么提到这里

这个问题最初提在 XJ380 侧（[xingji-studio/OpenXJ380#24](https://github.com/xingji-studio/OpenXJ380/issues/24)），维护者的答复是应当在 StardustUI 仓库处理，因此按建议移到本仓库。

需要说明的是：**从 OpenXJ380 的角度看，问题并不会因为提到本仓库而消失**——OpenXJ380 的工作树里实际分发着同一个 25 MB 字体文件（`frameworks/StardustUI/fonts/xiaolai.ttf`，同哈希），而其 `third_party/compliance-manifest.json` 里已经有 `RapidJSON` 这个先例，其 `license_files` 指向 `frameworks/StardustUI/includes/rapidjson/rapidjson.h`——即"StardustUI 内的第三方资产"照样会在 OpenXJ380 的 manifest 中登记。所以理想的修法是两边都补：本仓库补齐许可证与归属，OpenXJ380 的 manifest 追加对应条目。

## 建议的修法（成本很低）

1. 新增 `fonts/LICENSE-OFL-1.1.txt`（OFL 全文）与 `fonts/README.md`，写明：

   ```
   xiaolai.ttf — Xiaolai SC (小赖字体 SC) v3.00
   Copyright © 2020 LXGW, Nozomi Seto (瀬戸のぞみ)
   Licensed under the SIL Open Font License, Version 1.1
   Upstream: https://github.com/lxgw/kose-font
   sha256: 69f8f50a9a3696357b50b4c5d7d17efecb17a23c7a818ff917c21169f15555f9
   ```

2. 在根 `LICENSE` 末尾或 `README.md` 中加一段范围排除，例如：

   ```
   The MIT license above applies to StardustUI's own source code.
   Third-party assets are licensed separately; see fonts/README.md
   and third_party/*/README.md.
   ```

3. 顺带一并处理同类情况：`third_party/ab_glyph_rasterizer/`（上游 `ab-glyph` 以 git submodule 引入，其 README 说明了来源与结构，但仓库内未附上游许可证文本，同样落在根 `LICENSE` 的字面覆盖范围内）。

以上都属于补文档，不需要改代码，也不影响构建。

## 说明

本条 Issue 来自对 XJ380 的独立第三方审计（存档：<https://github.com/akain-0410/openxj380-audit>），只针对许可证声明的完整性，不涉及对代码质量或工程量的评价。OpenXJ380 侧近期在第三方声明上的整改（补齐 MikanOS/字体的 manifest 条目、许可证全文与派生文件归属）是明显有效的，本条是同一标准向 StardustUI 的延伸。如有事实错误，欢迎以哈希或文件内容指出，我会更正。
