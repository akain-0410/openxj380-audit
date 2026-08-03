# XJ380 官方磁盘镜像（XJ380.img）对抗性审计 —— 分发物层面的许可证合规

**审计对象：** XJ380 OS 磁盘镜像 `XJ380.img`（`/etc/os-release`：`XJ380 Singularity 1.0.0`），及与之对应的完整源码快照
**证据来源：** [xhdndmm/xj380os-full-report](https://github.com/xhdndmm/xj380os-full-report) —— "XJ380OS 的完整分析+源代码+磁盘镜像"
　　镜像与源码包取自其 Release [`commit-08e49b98fea8903f3d9deddf067c68227e2ac932`](https://github.com/xhdndmm/xj380os-full-report/releases/tag/commit-08e49b98fea8903f3d9deddf067c68227e2ac932)；该仓库同时提供 [archive.org 永久存档](https://archive.org/details/xj-380)。其自撰的源码分析报告为 `review.md`（CC0）。**本文的一切镜像/源码素材均来自该仓库，特此标注来源。**
**审计日期：** 2026-08-02
**审计立场：** 对抗性审计。默认不信任任何一方的宣称——包括不信任证据提供方 xhdndmm、也不信任本审计自己的上一版结论。凡结论必须落到可被第三方独立复算的字节上（哈希、偏移量、行级比对），凡不能落地的一律标注为"未证实"。
**与既有报告的关系：** [REPORT.md](./REPORT.md) 审的是**公开源码仓库** [xingji-studio/OpenXJ380](https://github.com/xingji-studio/OpenXJ380)。本文审的是**实际在流通的二进制分发物**。二者的合规义务不同：源码仓库里放齐许可证文本，不等于分发出去的镜像里放齐了；绝大多数开源许可证的义务恰恰是绑定在"分发二进制"这个动作上的。

---

## 〇、一句话结论

**在源码仓库这一侧，被审方最近一个月的整改是真实且有效的；但在真正交到用户手里的这份磁盘镜像里，整个第三方许可证声明体系等于不存在——镜像内 101 个文件中，没有任何一个是许可证、声明或版权文本。** 与此同时，镜像里至少装着 13 个需要"二进制再分发时随附声明"的第三方组件，包括一个 GPL-2.0 的 BusyBox 可执行文件，且该文件与被审方公开提供的"对应源码"并非同一个二进制。

另外，源码考古发现一条此前所有公开报告（含 xhdndmm 的 `review.md`）都未提及的线索：一个名为 **"No GPL！"** 的提交，删除了两个 GPL-3.0 上游项目的版权署名。本文对它做了双向核查——既给出违规的部分，也给出对被审方有利的部分（见第五节）。

---

## 一、审计方法与可复现步骤

全部结论可用以下命令在任意 Linux 机器上复算，不依赖本报告作者。

> **证据可用性变动（2026-08-03 核实）：**该第三方仓库已被其作者置为只读，且 Release 中的 `XJ380.zip`（含 `.git` 的完整源码包）**已被撤下**，目前仅剩 `XJ380.img`。因此下文第三、四、五节中依赖源码包的对照项，现阶段已无法直接从该 Release 复现；但其中最关键的一项（MikanOS `hankaku.bin` 在 `kernel.krl` 内的偏移）**不受影响**：[evidence/image/repro.sh](./evidence/image/repro.sh) 已改为自动回退到从上游 MikanOS 重建同一字节串（实测得到 4096 B、`sha256 317e04a7…`，与已下线源码包内的副本逐字节相同，偏移仍为 `1404928`）。镜像本身的全部结论仍可完整复算。本仓库不转载该源码包（其中含非公开提交历史与开发者个人信息）。


```bash
# 1. 取得证据（来源：xhdndmm/xj380os-full-report）
gh release download commit-08e49b98fea8903f3d9deddf067c68227e2ac932 \
   -R xhdndmm/xj380os-full-report -p 'XJ380.*'
sha256sum XJ380.img XJ380.zip
# XJ380.img  14daf0fe40cb8e1bbcd24803a2fbfda28cf18a6d96d5822d37bc8d5dafcbe45e  134217728 bytes
# XJ380.zip  22a9552345bf57643f5cf66bb432b6930267504283a6546b217da89deb056dae  462864064 bytes

# 2. 解析分区并提取根文件系统（GPT，单一 EFI System 分区，FAT，起始 LBA 2048）
fdisk -l XJ380.img
printf 'drive x: file="%s/XJ380.img" offset=1048576\n' "$PWD" > mtoolsrc
MTOOLSRC=$PWD/mtoolsrc mcopy -s -n -Q x:/* imgx/     # mtools，无需 root、无需 vfat 内核模块

# 3. 三方对照：镜像 / 完整源码包 / 公开仓库
unzip -q XJ380.zip                                   # 得到 XJ380/（含 .git，1615 个提交）
git clone https://github.com/xingji-studio/OpenXJ380
```

对照口径：镜像 101 个常规文件的逐文件 SHA-256 见 **[evidence/image/FILELIST.sha256.tsv](./evidence/image/FILELIST.sha256.tsv)**，其中同时标注了每个文件在完整源码包中的同哈希路径、以及是否也存在于公开仓库。

**三个证据源的关系（已核实，非推测）：**

| 证据源 | 内容 | 与其他源的关系 |
|---|---|---|
| `XJ380.img` | 128 MiB GPT 磁盘镜像，FAT 根文件系统，101 个文件 | 99 个不同哈希中 **64 个与源码包内文件逐字节相同**；其余 35 个是编译产物（kernel.krl、各 ELF、BOOTX64.efi）与运行期文件 |
| `XJ380.zip` | 私有仓库 `xingji-studio/XJ380` 的完整工作树 + `.git`，HEAD = `08e49b98`（2026-07-29） | 与公开仓库 OpenXJ380 有 2820 个同名文件，**忽略 CRLF/LF 差异后 2733 个（96.9%）逐字节一致** |
| OpenXJ380 | 公开仓库，Apache-2.0，18 个提交，HEAD `4349e4d` | 即上述私有树的公开化版本（差异 87 个文件，主要为两次提交之间的演进 + 合规整改） |

也就是说：**公开仓库就是这棵私有树，镜像就是这棵私有树的编译产物**。这个对应关系是本文后续所有推论的地基，它由 64 个逐字节相同的文件与 2733 个内容一致的源文件共同支撑，不依赖任何一方的自述。

---

## 二、决定性事实：镜像内没有任何许可证文本

对镜像内 101 个文件做全文扫描：

```bash
find imgx -iname '*LICENS*' -o -iname '*COPYING*' -o -iname '*NOTICE*' -o -iname '*GPL*'
# 无输出
grep -ril -E "Permission is hereby granted|SIL OPEN FONT LICENSE|Apache License, Version 2.0|GNU GENERAL PUBLIC LICENSE|Redistribution and use in source and binary" imgx
# 仅 imgx/system/font/XJ380F.ttf —— 命中的是字体 name 表里的一行许可证"描述"，不是许可证正文
```

**镜像内不存在 `/system/licenses`、不存在任何 LICENSE/COPYING/NOTICE 文件、不存在任何第三方版权声明文档。**

这一点之所以是"决定性"的，是因为被审方自己的构建流水线本来就打算把它放进去：

- 公开仓库 `tools/gen_ninja.py:776-777` 定义了 `package_compliance` 规则，调用 `tools/package_third_party.py` 依据 `third_party/compliance-manifest.json` 生成 `out/compliance/third-party`；
- `tools/ninja_build.py:235`：`cp(ROOT / "out/compliance/third-party", root / "system/licenses/third-party")` —— 明确要把合规包装进镜像的 `/system/licenses/third-party`。

而在**镜像所对应的那棵私有树**（`08e49b98`）里，`tools/` 下**根本没有** `package_third_party.py`，`third_party/` 下**没有** `compliance-manifest.json`，`ninja_build.py` 里**没有**任何 `compliance`/`licenses` 字样。

据此可以给出一个不含推测成分的结论：**合规打包机制是在公开开源时才新建的，而现在流通中的这份官方镜像是在此之前构建的，它从来没有、也不可能带上任何许可证文本。** 这不是"忘了拷一个文件"，而是分发物层面的合规链条自始未接通。

被审方私有树自己的 `THIRD_PARTY_NOTICES.md` 对此有过明确自述（原文引用）：

> Binary distributions should reproduce the required notices for components that require attribution in documentation or other shipped materials.
> （lwIP 条目）Distribution note: binary redistribution must reproduce the upstream notice and disclaimer in documentation and/or other accompanying materials
> （`include/elf.h` 条目）Distribution note: ship the corresponding LGPL notice text with products that redistribute this header or binaries built from it

**用被审方自己写下的标准去衡量被审方自己发出的镜像，这份镜像不合格。** 这是本次审计给出的最强单点证据——它不需要任何外部法律解释，只需要把他们的文档和他们的产物放在一起看。

---

## 三、镜像内第三方组件与义务对照表

下表每一行都由镜像内的字节证据支撑（哈希、字符串、字体 name 表、二进制内嵌偏移量），最后一列是镜像现状：

| # | 组件 | 镜像内位置 | 判定依据（可复算） | 许可证 | 二进制再分发义务 | 镜像现状 |
|---|---|---|---|---|---|---|
| 1 | **BusyBox 1.31.1** | `/system/resources/apps/busybox`（3,125,520 B，sha256 `559dd743…`） | 二进制内 `BusyBox v1.31.1 (2020-02-24 14:41:50 +08)`、`Licensed under GPLv2` | GPL-2.0-only | §3：随附完整对应源码，或随附书面要约 | ❌ 镜像内既无源码也无要约；且**该二进制并非**被审方公布 CCS 所对应的那一个（见第四节） |
| 2 | **Maple Mono NF CN Light** | `/system/font/XJ380C.ttf`（5,448,380 B） | 字体 name[0]=`Copyright 2022 The Maple Mono Project Authors`、name[1]=`Maple Mono NF CN Light` | OFL-1.1 | §2：任何再分发必须随附本许可证副本 | ❌ 无 OFL 正文 |
| 3 | **Source Han Sans CN Normal（思源黑体）** | `/system/font/XJ380F.ttf`（10,807,764 B） | name[0]=`Copyright © 2014, 2015 Adobe Systems Incorporated…Reserved Font Name 'Source'`、name[8]=`Adobe Systems Incorporated` | OFL-1.1 | 同上 | ❌ 无 OFL 正文 |
| 4 | **MikanOS `hankaku` 点阵字体** | 编译进 `/system/kernel.krl`，**偏移 0x157000（1,404,928）起 4096 字节与源码树 `font/hankaku.bin` 逐字节一致** | `open('kernel.krl','rb').read().find(open('font/hankaku.bin','rb').read()) == 1404928` | Apache-2.0（被审方 2026-08-02 已在源码侧承认） | §4(a) 随附许可证副本、§4(d) 传递 NOTICE | ❌ 镜像内无 Apache-2.0 正文 —— 这是 Issue [#12](https://github.com/xingji-studio/OpenXJ380/issues/12) 在分发物层面的延伸 |
| 5 | **musl libc 1.2.6** | `/system/resources/musl/{libc.so, libc.musl-x86_64.so.1, ld-musl-x86_64.so.1}`（三份同哈希，各 670,312 B） | 内含 `musl libc (x86_64)`、`1.2.6` | MIT | 保留版权与许可声明 | ❌ |
| 6 | **libgcc_s.so.1** | `/system/resources/musl/libgcc_s.so.1`（98,320 B） | 符号版本 `GCC_3.0…GCC_13.0.0` | GPL-3.0-or-later **WITH** GCC-exception-3.1 | 运行库例外覆盖"用它编译出的程序"，但**单独分发这个库本身**仍需随附许可证并履行源码义务 | ❌（此项建议由法务复核后再定性，本文仅列事实） |
| 7 | **fastfetch 2.62.1** | `/system/resources/apps/fastfetch`（9,004,440 B） | 内含版本串 `2.62.1` | MIT | 保留版权与许可声明 | ❌ |
| 8 | **Mbed TLS** | 静态链接进 `/apps/builtin/browser.elf`（2521 处 `mbedtls` 符号）、`/apps/builtin/nut.elf`（2716 处，含 `Mbed TLS` 串） | 符号名统计 | Apache-2.0 | §4(a)+§4(d) | ❌ |
| 9 | **litehtml + Gumbo** | `/apps/builtin/browser.elf`（38,915 处 `litehtml`） | 同上 | BSD-3-Clause / Apache-2.0 | BSD-3 第 2 条明文要求：二进制再分发必须在随附材料中复制版权声明与免责声明 | ❌ |
| 10 | **libwebp** | `/apps/builtin/browser.elf`（62 处 `libwebp`、256 处 `WebP`） | 同上 | BSD-3-Clause + PATENTS | 同上（并涉 Issue [#23](https://github.com/xingji-studio/OpenXJ380/issues/23)） | ❌ |
| 11 | **lwIP** | `/mod/netserver.sys`（142 处 `lwip`） | 同上 | BSD-3-Clause | 同上 | ❌ |
| 12 | **Mozilla CA 证书包（121 张证书）** | `/etc/ssl/certs/ca-certificates.crt`（182,140 B） | PEM 计数 = 121 | MPL-2.0 | 随附许可证/声明 | ❌ |
| 13 | **ncurses terminfo** | `/usr/share/terminfo/{l/linux,v/vt100,x/xterm,x/xterm-256color}` | 与源码包 `Bf/terminfo/*` 逐字节相同 | ncurses（X11 风格） | 保留版权声明 | ❌ |

**同时如实记录做对的部分（对抗性审计不等于只挑毛病）：**

- ✅ **Font Awesome 图标的归属是完整的**：`/system/resources/svg/*.svg` 九个文件全部保留了 `<!--!Font Awesome Free v7.2.0 by @fontawesome … Copyright 2026 Fonticons, Inc.-->` 内嵌声明，同目录 `readme.md` 亦写明来源与"在其 LICENSE 要求下使用"。这是镜像内**唯一**做到位的第三方归属，应当承认。
- ✅ **FatFs（编译进 kernel.krl）**：ChaN 的许可证只对"源码再分发"设定保留声明的条件，二进制再分发无附加义务。本文不将其计入缺口。
- ✅ **BusyBox 的源码材料在公开仓库里是齐的**（上游归档 + `LICENSE` + `.config` + 补丁 + 构建脚本 + 哈希断言）。问题只出在"这套材料对应的不是镜像里那个二进制"（下节）。

---

## 四、BusyBox：公布的"对应源码"与镜像里的二进制不是同一个

被审方在 `THIRD_PARTY_NOTICES.md` 中写道：

> The two shipped BusyBox paths are built from that recorded material and must remain byte-identical.

把三处 BusyBox 放在一起比对：

| 来源 | SHA-256 | 字节数 | 二进制内构建标记 |
|---|---|---:|---|
| **镜像** `/system/resources/apps/busybox` | `559dd743bf2f8841405fb9025cba1079966294ab9bbce80678935bce4770d54d` | 3,125,520 | `BusyBox v1.31.1 (2020-02-24 14:41:50 +08)` |
| 私有源码树 `resources/apps/busybox` | 同上（**与镜像逐字节相同**） | 3,125,520 | 同上 |
| 公开仓库 `third_party/busybox-prebuilt/busybox_amd64` | `0bf09330ec7410eb7e136dadf822a52fd8b5b6cf8ef375722a4b64ea4157567a` | 2,485,536 | `BusyBox v1.31.1 ()`（构建时间戳被刻意置空——正是"可复现构建"的特征） |

三项独立指标（哈希、体积差 640 KB、构建时间戳）一致指向同一结论：

1. **在流通镜像里的 BusyBox，是一个 2020-02-24 由第三方构建的预编译二进制**，不是被审方构建系统的产物。Git 考古佐证：它由提交 `8ab45ec1`（2026-05-06，"✨ feat: fastfetch支持"）连同 `bash`、`opkg`、`fastfetch` 一起以纯二进制形式塞进仓库，无任何源码。
2. **被审方后来补齐的 GPL 对应源码（CCS），对应的是他们自己重建的那个 2,485,536 字节的新二进制，而不是镜像里这个。** 对镜像里这个 2020 年的二进制而言，其确切的 `.config`、补丁集与工具链**至今没有任何人提供过**——按 GPL-2.0 §3，这正是"完整对应源码"的定义要件。

**准确的定性：** 公开仓库的 BusyBox 合规材料是真实有效的（本文与 [REPORT.md 更新记录](./REPORT.md) 均已承认），但它**无法追认已经分发出去的镜像**。要闭合这个缺口，只有两条路：重建镜像改用他们自己编译的 BusyBox，或为 2020 版二进制补出真正的 CCS。前者显然更现实。

---

## 五、源码考古：名为 "No GPL！" 的提交，与本文对它的双向核查

这是完整源码包（含 `.git`，1615 个提交）解锁的、此前未被任何公开报告提及的线索。

### 5.1 事实链（全部可用 `git show` 复核）

| 时间 | 提交 | 事件 |
|---|---|---|
| 2025-11-16 | `b2fc0116` "SB16?" | 引入 `driver/dma.cpp` / `include/dma.h`，文件头为：`2025/1/9 By MicroFish` / `Based on GPL-3.0 open source agreement` / `Copyright © 2020 ViudiraTech, based on the GPLv3 agreement.` |
| 2026-01-18 | `ebada3ae` "net初步" | 引入 `kmod/netserver/arch/sys_arch.cpp` / `utils.cpp`，文件内为：`// lwip glue code for cavOS` / `// Copyright (C) 2024 Panagiotis` |
| **2026-04-04** | **`89ac965f`（作者 wcjbr，提交信息全文：`No GPL！`）** | **删除上述全部上游版权署名**，改写四个文件，并新建 `THIRD_PARTY_NOTICES.md`，在其中把它们列为"rewritten in-tree to remove ambiguous inherited provenance…intended to be treated as project-local implementations"（在树内改写以消除含糊的继承来源，视为项目自有实现） |

上游身份已独立核实，不采信文件头自述：

- `ViudiraTech / MicroFish` → [ViudiraTech/Uinxed-Kernel](https://github.com/ViudiraTech/Uinxed-Kernel) 的 `kernel/chipset/dma.c`、`include/chipset/dma.h`。该项目 **2025-10-29（提交 `16d9536c`）之前为 GPL-3.0，之后改为 Apache-2.0**。XJ380 拷入的副本头部写的是 GPL-3.0，说明取自改协议之前的快照。
- `cavOS / Panagiotis` → [malwarepad/cavOS](https://github.com/malwarepad/cavOS)，**GPL-3.0**，对应文件为 `src/kernel/networking/lwip/sys_arch.c` 与 `src/kernel/utilities/data_structures/linked_list.c`。

### 5.2 相似度量化（去注释、去空白、行级最长公共子序列）

| 比对 | 相似度 | 连续相同代码行 |
|---|---:|---|
| Uinxed `dma.c` ↔ XJ380 `dma.cpp`（改写**前**） | **0.753** | 29 / 39 |
| Uinxed `dma.c` ↔ XJ380 `dma.cpp`（改写**后**） | 0.163 | 11 |
| cavOS `linked_list.c` ↔ XJ380 `utils.cpp`（改写**前**） | **0.494** | 44 / 113 |
| cavOS `linked_list.c` ↔ XJ380 `utils.cpp`（改写**后**） | 0.149 | 15 |
| cavOS `sys_arch.c` ↔ XJ380 `sys_arch.cpp`（改写**前**） | **0.304** | 78 |
| cavOS `sys_arch.c` ↔ XJ380 `sys_arch.cpp`（改写**后**） | 0.088 | 28 |

### 5.3 对被审方有利的核查结论（必须写进来）

对"改写后"的版本与上游做连续块比对，**长度 ≥3 行的连续相同代码块数量为 0**；残余的相似度全部来自零散单行（lwIP 移植层强制的函数签名、硬件端口常量表等事实性内容，不具独创性）。

**因此，本文明确认定：这次改写是实质性的重写，不是"只删版权头、代码照旧"的洗白。当前镜像中 `kernel.krl` 与 `netserver.sys` 里的这部分代码，大概率已不构成上游的派生作品。** 这一点对被审方有利，本文不做任何弱化。

### 5.4 仍然成立的问题（三条，逐条独立）

1. **删除署名这一动作本身，在任一许可证下都不成立。** 即使按对被审方最有利的读法——上游已于 2025-10-29 改为 Apache-2.0，他们完全可以按 Apache-2.0 使用——Apache-2.0 §4(c) 同样明文要求保留派生作品中的版权、专利、商标与归属声明。删掉 `Copyright © 2020 ViudiraTech` 与 `Copyright (C) 2024 Panagiotis`，在 GPL-3.0 与 Apache-2.0 两条路径下都是违规。
2. **2025-11-16 至 2026-04-04 的近五个月间，含 GPL-3.0 代码的构建物处于分发状态而未附源码与许可证。** 这段历史无法被后来的重写追溯性抹除。
3. **公开的 `THIRD_PARTY_NOTICES.md` 至今称这些文件为"project-local implementations"，未披露其 GPL-3.0 前身。** 对下游使用者（尤其是要评估法律风险的商业使用者）而言，这是一个实质性的信息遗漏——重写是否彻底，本应由下游依据披露事实自行判断，而不是由重写者单方面宣告。

---

## 六、镜像内一个许可证状态不明的模块：`mod/e1000.sys`

`/mod/e1000.sys`（39,104 字节）由源码 `kmod/e1000/e1000.cpp` 编译而来，该文件**第一行**是：

```cpp
// Copyright (C) 2025  lihanrui2913
```

核查结果：

- 该版权行**在公开仓库 OpenXJ380 中仍然原样存在**（`kmod/e1000/e1000.cpp:1`）；
- `third_party/compliance-manifest.json` 与 `THIRD_PARTY_NOTICES.md` 中**均无** e1000 或 lihanrui2913 的任何条目；
- 该文件由 `luxizhneg` 于 2026-03-18（`e1af880f`）提交，而非由版权人本人提交；
- GitHub 全网代码检索未找到公开上游（命中的只有 OpenXJ380 自身与 xhdndmm 的镜像仓库）。

**这是一个"有版权主张、无许可授予记录"的组合。** 无论真相是"该开发者以贡献者身份加入项目"还是"代码来自他处"，结果都一样：**镜像中 `mod/e1000.sys` 这个二进制的许可状态目前无法确定**，而整个仓库对外声明的许可证是 Apache-2.0。这既是被审方需要澄清的事项，也是任何要在生产环境使用该镜像的第三方必须先解决的问题。

本文不臆测其性质，仅指出：**在一个 Apache-2.0 项目里，携带第三方个人版权声明却没有任何书面授权记录的文件，本身就是一个待关闭的合规缺口。**

---

## 七、`include/elf.h`：本次核查中被审方获得澄清的一项

`REPORT.md` 及 xhdndmm 的 `review.md` 都记载了 `include/elf.h` 源自 glibc（LGPL-2.1-or-later）。私有树的 `THIRD_PARTY_NOTICES.md` 亦自认如此。本文对公开仓库的当前版本做了独立比对（去注释后行级相似度）：

| 比对 | 相似度 |
|---|---:|
| 公开仓库当前 `include/elf.h` ↔ **musl** `include/elf.h` | **0.9806** |
| 公开仓库当前 `include/elf.h` ↔ glibc 2.12 `elf/elf.h` | 0.2747 |
| 私有树（`08e49b98`）`include/elf.h` ↔ glibc（保留完整 LGPL 头） | 内含 glibc 原版 LGPL 声明全文 |

**结论：被审方是真的用 musl 的 MIT 版本替换了整个文件，不是把 glibc 的文件改个标签了事。** 这一项应当从"合规缺口"里划掉。需要留意的只有两点：公开仓库 `licenses/glibc-elf-h.txt` 仍是替换前的历史残留（建议清理或改写为历史说明）；以及**镜像里的 `kernel.krl`/`BOOTX64.efi` 是用替换前的 glibc 版本编译的**——考虑到 `elf.h` 的实质内容是 ELF 规范定义的常量与结构体（事实性内容，独创性极低），本文认为该项在分发物层面的风险很低，**不将其列为镜像缺口**。

---

## 八、可执行的整改清单（按成本从低到高）

1. **重建并重新发布镜像**——这一步就能同时关闭第二节与第三节的绝大部分缺口：公开仓库的 `ninja vdisk` 已经会把 `out/compliance/third-party` 装进 `/system/licenses/third-party`（`tools/ninja_build.py:235`）。**镜像不重建，源码侧的一切整改都到不了用户手里。**
2. **把镜像里的 BusyBox 换成他们自己按 `third_party/busybox-source/build.sh` 重建的那一个**，使已公布的 CCS 与实际分发的二进制对齐（第四节）。
3. **补齐 `compliance-manifest.json`**：目前 `components` 仍是 16 项，缺 MikanOS hankaku、两个字体、musl libc/libgcc、fastfetch、CA 证书包、terminfo、Font Awesome、e1000。manifest 是发行合规包的唯一生成源，漏在这里就等于漏在最终产物里。
4. **在 `THIRD_PARTY_NOTICES.md` 中如实记载 `dma.*` 与 `netserver/arch/*` 的 GPL-3.0 前身**（第五节）。既然重写是实质性的，如实披露对被审方只有好处——它把"是否已脱离派生"这个判断交给可验证的事实，而不是单方面宣告。
5. **澄清 `kmod/e1000` 的授权来源**：若为贡献者代码，补一条 CLA/授权记录或让版权人本人确认以 Apache-2.0 贡献；若来自他处，补上游与许可证（第六节）。
6. 清理 `licenses/glibc-elf-h.txt` 这一历史残留（第七节）。

---

## 九、本审计的局限与自我反驳

对抗性审计必须先对自己下手。以下是本文结论的全部薄弱环节，逐条列出：

1. **证据链的起点不在官方渠道。** 镜像与源码包取自第三方仓库 [xhdndmm/xj380os-full-report](https://github.com/xhdndmm/xj380os-full-report)，本文**无法证明**它与被审方从官方渠道发出的镜像逐字节相同。本文所有关于"分发物"的结论，严格限定于**这一份正在公开流通、且被广泛引用的镜像**。若被审方能出示官方渠道镜像的哈希与之不符，本文相关结论应当作废——本文欢迎这种反驳，并会如实更新。
   - 但需同时指出：该镜像内 64 个文件与被审方私有源码树逐字节相同、`kernel.krl` 内嵌的 hankaku 字体与源码树 `font/hankaku.bin` 逐字节相同、内含的 `/etc/os-release` 与私有树 `Bf/` 资源一致——伪造这样一份镜像的成本远高于其收益。
2. **未做可复现构建验证。** 本文没有从源码重建 `kernel.krl` 与各 ELF 去证明镜像确由该源码产出，因此"镜像 = 私有树的编译产物"这一判断建立在 64 个逐字节相同的数据文件与内嵌字体证据之上，属于**强证据但非数学证明**。
3. **第三节中"某组件被静态链接进某 ELF"的判定依据是符号名与字符串统计**，不是完整的目标文件溯源。对 mbedTLS（2521 处符号）、litehtml（38915 处）、lwIP（142 处）这种量级，误判概率可忽略；但严格来说这是概率性证据。
4. **法律定性不是本文的产出。** 本文只做两件事：确认某组件在镜像中存在、并引述该组件许可证对二进制再分发写明的条件。是否构成违约或侵权、后果如何，须由具备资质的法律人士判断。尤其是第 6 项（libgcc 运行库例外）本身在业界即存在解释空间，本文已标注待法务复核。
5. **本文使用了一份泄露的私有仓库快照。** 需要坦白说明：该快照标注"XINGJI 工作室 A 级机密"，其公开并非被审方本意。本文的处理原则是——① 素材完全取自已公开的第三方仓库，未接触任何非公开系统；② 仅将其用于许可证合规与代码溯源这一目的，不转载、不再分发其源代码；③ 引用范围严格限制在版权头、许可证声明、提交元数据这类**确定合规争议所必需的最小片段**。若认为某处引用超出必要范围，请提出，本文会删改。
6. **本文未采信 xhdndmm `review.md` 的任何结论作为自身论据。** 该报告中与本文重叠的部分（elf.h 的 glibc 血统、第三方 vendored 清单）均已独立复算；本文第五、六节的发现不在该报告中，系本次审计独立取得。

---

## 十、来源与致谢

- **镜像与完整源码包来源：[xhdndmm/xj380os-full-report](https://github.com/xhdndmm/xj380os-full-report) —— "XJ380OS的完整分析+源代码+磁盘镜像"**，Release `commit-08e49b98…`，另有 [archive.org 永久存档](https://archive.org/details/xj-380)。其 `review.md` 与 `README.md` 以 CC0 发布，两篇博客以 CC BY 4.0 发布。若无这份公开的镜像，分发物层面的审计无从谈起。
- 被审方源码仓库：[xingji-studio/OpenXJ380](https://github.com/xingji-studio/OpenXJ380)（Apache-2.0）。
- 上游被引用项目：[ViudiraTech/Uinxed-Kernel](https://github.com/ViudiraTech/Uinxed-Kernel)、[malwarepad/cavOS](https://github.com/malwarepad/cavOS)、[uchan-nos/mikanos](https://github.com/uchan-nos/mikanos)、[subframe7536/maple-font](https://github.com/subframe7536/maple-font)、[adobe-fonts/source-han-sans](https://github.com/adobe-fonts/source-han-sans)、musl、BusyBox、Font Awesome。

**本报告欢迎以证据反驳。** 反驳只需要做一件事：给出一条能被独立复算的哈希、偏移量或行级比对，指出本文哪一条对不上。
