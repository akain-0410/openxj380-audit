# OpenXJ380 对抗性审计报告

**审计对象：** https://github.com/xingji-studio/OpenXJ380（commit `037617b`，克隆于 2026-08-01）
**审计立场：** 对抗性审计——默认不信任任何宣称，一切结论以仓库内可复现的字节级证据为准。
**宣称口径：** 本报告所审查的宣称仅限三个可公开查验的来源——① 官网 xingjisoft.com（"完全自主研发"等）；② 其 B 站视频简介；③ 仓库自身文件。至于传闻中的身份、年龄等仓库外不可核实的信息，不作为审查对象。
**审计方法：** Git 历史取证、全仓库行数量化统计、许可证/版权头扫描、与已知开源项目的字节级比对、代码风格审阅。
**报告存档：** https://github.com/akain-0410/openxj380-audit （本报告的公开可引用版本；证据复现步骤见文末附录）

---

## 更新记录（2026-08-02）

本报告正文保持审计时（commit `037617b`）的原貌不改写，被审方此后的整改动作以本节追记，避免报告与现实脱节，也避免以既成结论掩盖对方已经做出的修正。

- 审计发现被提交为 Issue [#12](https://github.com/xingji-studio/OpenXJ380/issues/12)（MikanOS 字体）后，被审方在 24 小时内响应并于 commit [`c6bcfb3`](https://github.com/xingji-studio/OpenXJ380/commit/c6bcfb33e9b3a4341fd73bd30e62759d12552eeb) 作出修改：`THIRD_PARTY_NOTICES.md` 增加 MikanOS hankaku.bin、maple-font、Source Han Sans 三项声明；新增 `font/ttf/LICENSES.md`（两份 OFL-1.1 全文含各自版权行）；删除 `include/efi/efi.h`、`include/efi/fbc.h`、`include/graphics/GOP.hpp` 上的"版权所有©XINGJI Studios…保留所有权利"。**第三节与第四节中"未声明"「被加盖自家版权」的状态就此三项而言已不再成立**，响应速度应予肯定。
- 在 commit [`4349e4d`](https://github.com/xingji-studio/OpenXJ380/commit/4349e4d546406d11fc4bd0b4bcfa628ad2eef81f) 上复核，整改尚不完整：三项新声明未同步进 `third_party/compliance-manifest.json`（`components` 仍为 16 项），而该 manifest 是 `out/compliance/third-party` 发行合规包的生成源，故**分发物层面的合规状态尚未改变**；MikanOS 的 Apache-2.0 全文未随仓库提供（`licenses/` 下无对应文件，与 §4(a) 不符）；两个派生头文件只删版权行、未补来源归属。
- 另在同一 commit 上新发现三处未申报材料，已分别提交为 Issue [#23](https://github.com/xingji-studio/OpenXJ380/issues/23)（libwebp 缺 `COPYING`/`PATENTS`/`AUTHORS`）、[#24](https://github.com/xingji-studio/OpenXJ380/issues/24)（`frameworks/StardustUI/fonts/xiaolai.ttf`，小赖字体 SC，OFL-1.1，仓库内零声明）、[#26](https://github.com/xingji-studio/OpenXJ380/issues/26)（`OVMF.fd`，edk2-stable202011 预编译固件，无来源与许可证记录）。
- 需同时更正报告第四节的一处口径：**BusyBox 的 GPL-2.0 材料是完整的**（`third_party/busybox-source/` 含上游归档、`LICENSE`、`.config`、编译补丁与构建说明，且 `tests/test_license_compliance.py` 有哈希断言），这一项不应被计入合规缺口，报告原文亦未将其列为问题，此处明确记录以免读者误读。
- 全部 Issue 的发布时原文与 Wayback 第三方时间戳见 [issues/](./issues/)。

### 再次复核（2026-08-03，公开仓库 commit [`ad39a67`](https://github.com/xingji-studio/OpenXJ380/commit/ad39a67)）

- **上一条列出的三项残留已全部真实闭合**（逐项实测，不采信回复中的说法）：`compliance-manifest.json` 的 `components` 从 16 项补到 **21 项**，MikanOS hankaku、maple-font、Source Han Sans 均已登记，且脚本遍历校验全部 `license_files` 路径**无一缺失**；新增 `licenses/mikanos.txt`（Apache-2.0 全文 200 行）与 `third_party/mikanos-hankaku/{LICENSE,SOURCE.md,hankaku.txt}`，其中 `SOURCE.md` 记录了上游 commit `b5f7740c`、源文件路径与哈希，使 `font/hankaku.bin` **可脱网独立验证**（`sha256 317e04a7…` 与记录一致）——这比原 Issue 要求的做法更完整；`include/efi/fbc.h` 与 `include/graphics/GOP.hpp` 首行均已补 `// Portions derived from MikanOS (…), Apache-2.0.`。另额外补入 `talc allocator`、`libutf` 条目，并把 `licenses/glibc-elf-h.txt` 换成 `musllibc-elf-h.txt`（与上条第 29 行的更正一致）。**就 MikanOS 一项而言，本报告第三节的合规结论已由被审方的整改解决，仅历史事实部分（该字体确非自研）保持不变。**
- 唯一残留是一个不影响关闭的记录性偏差：`third_party/mikanos-hankaku/SOURCE.md` 记录的 `hankaku.txt`/`LICENSE` 哈希是**上游真值**（已从 `b5f7740c` 拉取复算吻合），而入库副本的行尾换行符少了一个字节（38776→38775、11357→11356），除此一字节外逐字节相同；`tests/test_license_compliance.py::test_mikanos_hankaku_source_material_is_complete` 只断言文件存在与 manifest 字段、不校验这两个哈希，故该偏差是静默的。
- #23（libwebp）与 #26（`OVMF.fd`）在该 commit 上**仍无任何变化**：`user/browser/third_party/libwebp/` 下只有 `src`，无 `COPYING`/`PATENTS`/`AUTHORS`，manifest 条目仍指向 `types.h`；`OVMF.fd` 在 manifest 与 `THIRD_PARTY_NOTICES.md` 中仍为 0 次提及。
- #24 被审方主动关闭，理由为"应该在 StardustUI 库进行修改"。**该理由部分成立**——StardustUI 确为独立仓库（`.gitmodules` 可证），上游当修。但 OpenXJ380 的工作树里仍实际分发着同一个 25 MB 字体（`frameworks/StardustUI/fonts/xiaolai.ttf`，`sha256 69f8f50a…`），而其 manifest 已有 `RapidJSON`（`license_files` 指向 `frameworks/StardustUI/includes/rapidjson/rapidjson.h`）这一"StardustUI 内第三方资产照样登记"的先例，同类资产两种口径。顺该线索复核 StardustUI 仓库另发现一处更严重问题：其根 `LICENSE` 为 `MIT License / Copyright (c) 2026 XINGJI Studios` 且字面覆盖全仓，而仓内即放着该 OFL-1.1 字体、无任何范围排除说明（`README.md` 检索 `font`/`licen`/`OFL` 均无命中）——OFL 字体不可被重新许可为 MIT。此项已按对方建议移往 StardustUI 仓库跟进。

### 追加：分发物层面的独立审计（2026-08-02，另见 [IMAGE_AUDIT.md](./IMAGE_AUDIT.md)）

本报告审的是公开源码仓库。第三方仓库 [xhdndmm/xj380os-full-report](https://github.com/xhdndmm/xj380os-full-report)（"XJ380OS的完整分析+源代码+磁盘镜像"）公开了**官方磁盘镜像 `XJ380.img` 与含 `.git` 的完整源码快照**，使得对**实际分发物**的审计成为可能。已实际下载、解包、逐文件核算，结论另立报告 [IMAGE_AUDIT.md](./IMAGE_AUDIT.md)，要点：

- 镜像内 101 个文件中**没有任何许可证/声明/版权文本**，而其中至少 13 个第三方组件在二进制再分发时负有声明义务；被审方私有树自己的 `THIRD_PARTY_NOTICES.md` 明文写着"binary redistribution must reproduce the upstream notice"。合规打包机制（`tools/package_third_party.py` → 镜像 `/system/licenses`）是开源时才新建的，流通中的镜像早于它。
- 本报告第三节的 MikanOS 结论在分发物层面同样成立：`hankaku.bin` 的 4096 字节在镜像 `system/kernel.krl` 偏移 0x157000 处逐字节存在。
- 镜像内 BusyBox 与被审方公布的 GPL 对应源码不是同一个二进制（哈希/体积/构建时间戳三项均不符）。
- 新发现 GPL-3.0 血统（Uinxed-Kernel、cavOS）与提交 `89ac965f`"No GPL！"的署名删除；但改写经量化核查属实质性重写，如实认定对被审方有利的部分。
- **更正本报告一处口径**：`include/elf.h` 现已被真正替换为 musl 的 MIT 版本（行级相似度 0.9806，glibc 仅 0.2747），不再是 glibc LGPL 头文件，该项应从合规缺口中划掉；仅 `licenses/glibc-elf-h.txt` 为历史残留。

---

## 一、核心结论（TL;DR）

**"全自研"的宣称不成立，但也不是纯粹的空壳骗局。** 事实介于两者之间：

1. **按源码物理行数统计，约 92.6% 的代码来自第三方开源项目**（约 126.5 万行 / 总计 136.6 万行），真正可归为第一方的代码约 10 万行（7.4%）。
2. **确凿的字节级证据表明，内核图形/字体基础层直接源自日本教科书项目 MikanOS**（《ゼロからのOS自作入門》配套项目，Apache-2.0 协议），**未作任何声明，且在其派生文件上加盖了"版权所有©XINGJI Studios 保留所有权利"**。这是本次审计发现的最严重问题。
3. 与"完全隐瞒开源"这一常见指控不同，该仓库对**大部分**第三方组件（lwIP、FatFs、litehtml、mbedTLS、lexbor、libwebp、stb 系列、BusyBox 等）**是有书面声明的**（`THIRD_PARTY_NOTICES.md`、`LICENSES.md`），但声明存在多处遗漏和合规缺口（详见第四节）。
4. 剩余约 10 万行第一方代码（内核启动、调度器、VFS 胶水、窗口管理、XAPI 运行时、Linux 兼容层）**确实存在、并非空壳**，其中带有大量口语化中文注释和拼写错误，呈现真实的人工长期开发痕迹，同时部分新代码有 AI/自动化辅助重构的特征。

**一句话定性：这是一个"以大量开源组件为骨架 + 教科书代码为地基 + 一定量真实自写胶水与子系统"的组装型项目。称其为"全自研操作系统"属于严重夸大宣传；称其为"纯噱头零代码"也不符合事实。**

---

## 二、量化统计：92.6% 的代码不是他们写的

按源码扩展名（.c/.cc/.cpp/.h/.hpp/.S/.asm/.rs/.inc）统计，共 2,035 个源文件、1,366,076 行：

| 分类 | 行数 | 占比 |
|---|---:|---:|
| `third_party/`（lexbor、mbedTLS、litehtml、libvterm、busybox 源码包等） | 990,503 | 72.5% |
| `kmod/netserver/lwip/`（lwIP 网络栈整体搬入） | 108,376 | 7.9% |
| `user/browser/third_party/`（libwebp、nanosvg 等） | 84,299 | 6.2% |
| `frameworks/StardustUI/`（含 RapidJSON） | 28,526 | 2.1% |
| `driver/fs/fatfs/`（ChaN 的 FatFs） | 26,450 | 1.9% |
| 其他嵌入式第三方（stb 系列、dr_mp3、musl elf.h、SVG 实现等） | 27,286 | 2.0% |
| **第三方合计** | **1,265,440** | **92.6%** |
| **剩余第一方/未归类** | **100,636** | **7.4%** |

补充说明：

- 以上尚未计入非源码的外部资产：预编译二进制 `liballoc-x86_64.a`（Rust alloc/compiler_builtins）、`OVMF.fd`（TianoCore EDK2 固件，字符串中含 `edk2-stable202011` 构建路径，SHA-256 `6ffb11f9…`）、BusyBox 预编译产物、以及多个外部字体文件。按仓库体积算第三方占比会更高。
- 该项目的两大"卖点"能力——**浏览器**（litehtml + gumbo + lexbor + mbedTLS + libwebp）和**网络栈**（lwIP）——核心引擎全部为第三方，第一方部分是移植胶水（browser 目录 8.86 万行中第一方约 4,300 行）。
- 命令行生态直接依赖 **BusyBox**（GPL-2.0），`kernel/main.cpp` 中硬编码了 busybox applet 别名表。

---

## 三、决定性证据：未声明的 MikanOS 血统

这是对抗性审计中最有力的发现，属于**字节级实锤**，不依赖任何主观判断：

### 3.1 `font/hankaku.bin` 与 MikanOS 字体逐字节完全一致

将 MikanOS 仓库（uchan-nos/mikanos）中的 `kernel/hankaku.txt` 按其官方工具的规则编译为二进制后，与 OpenXJ380 的 `font/hankaku.bin` 比对：

- 两者均为 4,096 字节（256 字符 × 8×16 点阵）；
- **256 个字形全部逐字节一致，文件整体 identical: True**。

`hankaku` 字体源自川合秀实《30日でできる！OS自作入門》，经 MikanOS 传承。一个"全自研"项目的内核字体与日本教科书项目的字体 4096 字节完全相同，不存在巧合的可能。该字体在 `THIRD_PARTY_NOTICES.md`、`LICENSES.md` 中**均无任何声明**。

### 3.2 图形基础层结构与 MikanOS 同构，且被加盖自家版权

`include/efi/fbc.h`（文件头标注"版权所有©XINGJI Studios 2017-2026 保留所有权利"）：

```c
struct FrameBufferConfig {
    uint8_t  *frame_buffer;
    uint32_t  pixels_per_scan_line;
    uint32_t  horizontal_resolution;
    uint32_t  vertical_resolution;
    enum PixelFormat pixel_format;
};
```

这与 MikanOS `frame_buffer_config.hpp` 的结构体**字段名、字段顺序完全一致**。枚举值 `kRGBR/kBGRR` 对应 MikanOS 的 `kPixelRGBResv8BitPerColor/kPixelBGRResv8BitPerColor`，且注释自我暴露："`带k表示内核会用到`"——`k` 前缀正是 MikanOS 遵循的 Google C++ 风格常量命名，作者只是照搬后为其编造了一个解释。`GOP.hpp` 中的 `PixelColor{r,g,b}`、`PixelAt()`、`WriteRGBR/WriteBGRR` 与 MikanOS 第 3~5 章的 `PixelWriter` 体系一一对应；`WriteRGBR` 处注释"`注意：这里实际上是RGB，但类名可能是为了某种特定格式`"表明写注释的人**自己都不理解这个命名的来历**——这是"复制他人代码的人"而非"原作者"的典型痕迹。内核入口 `KernelMain`、控制台按 16 字节 glyph 索引 hankaku 的渲染方式（`kernel/console.cpp`）也与 MikanOS 同构。

### 3.3 法律与诚信层面的定性

MikanOS 采用 **Apache-2.0** 协议——允许使用和修改，但**要求保留版权声明和 LICENSE**。OpenXJ380 的做法是：

1. 不作任何声明；
2. 在派生文件上加盖"版权所有©XINGJI Studios 2017-2026 **保留所有权利**"。

这不仅是许可证违规（违反 Apache-2.0 §4），更是**主动的著作权误标（copyright misattribution）**，性质比"忘了标注"严重得多。另外 `include/pctable/idt.h:76` 直接引用了 OSDev Wiki 链接，进一步印证该项目的"内核自研"部分大量依赖公开教程范式。

---

## 四、已声明第三方组件的合规缺口

即便是已声明的部分，以最严格标准衡量仍有明确缺陷：

| 问题 | 证据 | 严重度 |
|---|---|---|
| `liballoc-x86_64.a` 预编译二进制无许可证 | `licenses/liballoc.txt` 原文承认："The archive is an external binary input and **its license is not present in this repository**"，仅为占位文本；仓库无对应源码 | 高 |
| libwebp 缺少上游必备材料 | 源文件头引用 "found in the **COPYING** file"，但 vendored 目录中无 COPYING/**PATENTS**/AUTHORS（libwebp 的 BSD 授权与专利授权绑定，缺 PATENTS 文件风险明确） | 高 |
| 字体全面失守 | `font/ttf/XJ380F.ttf` 内部元数据是 **Adobe 思源黑体（Source Han Sans CN）**，被改名为 XJ380F 冒充自家字体，OFL-1.1 来源未在声明中列出；`xiaolai.ttf`、`XJ380C.ttf` 无任何来源材料；`hankaku.bin` 见第三节 | 高 |
| lwIP/FatFs 无独立 LICENSE 文件 | 仅依赖源文件内嵌版权头 | 低 |
| OVMF.fd 未记录来源 | EDK2 固件（QEMU 运行用，属正常用途），但发行材料未记录 | 低 |

**规律总结：凡是"藏在源文件头里、不声明也很难被发现"的组件（字体、二进制、教科书代码），声明就缺失；凡是"一眼就能看出是搬来的大目录"，声明就齐全。** 这个模式与其说是疏忽，不如说是"声明成本-暴露风险"的权衡结果，对"诚信自研"的宣称构成实质性削弱。

---

## 五、Git 历史取证：历史被抹除

- 全仓库仅约 16 个提交，**2,850 个文件、1,768,020 行在 2026-08-01（即审计当天）的一个 "first commit" 中一次性倒入**；此后的提交全部只是往 CONTRIBUTOR.md 加名字。
- 仓库和 GitHub 组织显示：repo 创建于 2026-08-01；但 `AGENTS.md`（AI 编码代理知识库文件）头部写着 "**Generated: 2026-05-22, Commit: e5affb6d**"——该 commit 不存在于本仓库，证明**存在一个更早的私有开发仓库，完整开发历史（谁写的、何时写的、从哪拷的）被刻意切断**。
- 后果：外界无法验证"学生团队自主完成"（官网自述）中"谁完成"这一核心命题。对抗性视角下，抹除历史 + 一次性代码倾倒是掩盖代码来源时间线的标准手法，应作负面推定。
- `AGENTS.md` 本身是为 AI 编码代理准备的详尽项目说明书，结合部分代码中高度模板化的 Doxygen 注释与重构风格，可作出**开发流程中系统性使用了 AI 编码工具**的高置信推断（此为推断而非字节级实锤，详见第八节复检）。"AI 辅助"本身无可厚非，但与官网"完全自主研发"及 B 站"4月份前我们一直在手搓"的宣传叠加时，构成第二重夸大。

---

## 六、第一方代码的真实性评估（给他们该得的公道）

对抗性审计也必须承认对被审方有利的证据：

- `kernel/`（2.6 万行）、`driver/` 胶水、`graphics/` 窗口系统、`user/xapi/` 运行时中存在大量**无法在公开项目中找到对应物**的项目专属逻辑：启动序列、EEVDF 风格调度器、VFS/procfs/pty、窗口管理器、系统调用层、Linux 兼容层（procfs 伪装 "Linux version 6.6.30"、brk/tty 语义注释）。
- 代码中充满真实开发痕迹：口语化中文注释（"`因为懒得写内存管理，属于是另辟蹊径了……`"、"`暴力枚举这一块，好像只能这么做了`"）、拼写错误（`Interacitve`、`proccess`、`offest`）、GBK/UTF-8 乱码注释、风格严重不统一——这些是长期人工迭代的特征，不是一键生成或整体抄袭能伪造的。
- `tests/` 下有 5 个真实的构建/合规单元测试（其中 `test_license_compliance.py` 说明团队具备合规意识——这反过来使 MikanOS 与字体的"漏报"更难用无知开脱）。

因此"零技术含量的纯噱头"这一指控**不成立**。以学生团队（GitHub 组织与官网自述"由中国的一群学生们组建"，本审计不对成员年龄作任何认定）而言，完成 10 万行量级的胶水与子系统开发并跑通整套 UEFI→内核→GUI→浏览器链路，工程整合能力是真实且可观的。

---

## 七、沙盒实证：公开仓库无法构建出可运行系统

为回答"它到底能不能跑"，审计在干净的 Ubuntu 沙盒中严格按其 README 流程进行了实际部署：

1. 安装 README 列出的全部依赖（另需 README 未提及的 `gcc-mingw-w64-x86-64`、`xorriso` 和 Rust target `x86_64-unknown-none`——文档与实际依赖已不符）。
2. `tools/gen_ninja.py` 生成构建图，`check.tools` 工具链检查**全部通过**——排除了"审计环境配错"的解释。
3. UEFI 引导程序 `out/BOOTX64.efi` **构建成功**；将其装入 FAT 镜像后用 QEMU（OVMF 固件、无头串口模式）启动，串口确实打出 `XJ380 Operating System - Serial Log / EFI Initialize Success ... system not found`——**bootloader 是真实可运行的**。
4. 但 `ninja all` 在**内核链接阶段失败**：`printk`、`pr_info/pr_err`、`write_serial_*`、`snprintf/sprintf` 等最基础的内核日志/格式化符号 **undefined reference**。全仓库检索确认：这些符号被 `kernel/`、`driver/` 下数十个文件调用，但**内核侧实现文件根本不存在于公开仓库中**（仅 bootloader 内部有一份同名私有实现）。
5. 因此正式镜像 `XJ380.img` 无法生成，`ninja vdisk` 同样失败。

**定性：** 这不是环境问题，而是公开快照本身缺文件。GitHub 仓库描述也自认是删减版（"without the desktop environment"），但缺的不只是桌面——连内核都链接不出来。结论：**公开仓库不构成一个可复现、可验证的操作系统；任何人无法凭这份代码证实其演示视频/截图中的系统即由此代码构建。** 结合第五节的历史抹除，项目的可验证性为零。

（公允提示：不能据此断言他们内部没有能跑的完整版本——bootloader 真实可用、内核代码大量引用这些缺失符号，说明完整实现大概率存在于私有仓库。但"开源自证"的举证责任在宣称方，公开的这份不合格。）

---

## 八、对结论本身的对抗性复检（第一性原则）

按对抗性审计要求，以下把本报告每条关键结论当作攻击目标，主动寻找最强反例，并区分**事实**与**推断**：

| 结论 | 最强反驳 | 复检结果 |
|---|---|---|
| "92.6% 第三方" | ① 按行数统计天然放大 vendored 大库的权重；② vendoring 依赖本身是合法常规做法，Linux 发行版第三方占比也极高 | 反驳①成立一半：该数字衡量的是"仓库里谁写的代码"，不衡量"工程难度贡献"，报告不据此否认整合工作量。反驳②不影响结论——问题从来不是"用了开源"，而是**宣称"全自研"**。占比数字本身是可复现事实，维持 |
| "源自 MikanOS" | 也许只是"都看了同类教程/OSDev"，命名撞车？ | 结构体同构、`k` 前缀命名可以辩解为巧合；**但 4096 字节字体逐字节一致不能**——这是本结论的承重墙，属字节级事实。命名证据仅作旁证。结论维持，但报告已明确：代码部分是"高度同构+字体实锤"的组合推断，字体部分是事实 |
| "版权误标/许可证违规" | 也许 `fbc.h` 是他们看懂后重写的，加自家版权头不算违规？ | 若仅结构体或可如此辩解；但同仓库同时存在未声明的逐字节 MikanOS 字体，使"独立重写"辩解在整体上不可信。且无论 MikanOS 问题如何，**liballoc 无许可证（其自己的 licenses 文件承认）、思源黑体改名 XJ380F、libwebp 缺 PATENTS** 三项独立成立。结论维持 |
| "使用了 AI 工具" | AGENTS.md 可能只是准备给贡献者用，未必真用了 | 复检后**降级表述**：AGENTS.md 的存在与格式（Generated 时间戳、commit 指针）是事实，"开发流程中系统性使用 AI"是高置信推断而非实锤；且这一点不影响任何核心裁定，仅关乎"人设宣传"。已在报告中标注为推断 |
| "历史被抹除" | 也许只是团队习惯：开发在私库、发布时 squash？ | 动机无法证明，报告不主张"必为掩盖"；但**后果是客观的**：无法验证"谁写的、何时写的"，可验证性为零。结论限定在后果层面，维持 |
| "不是纯噱头" | 10 万行"第一方"里会不会还有未识别的抄袭？沙盒都构建失败了，凭什么说有真东西？ | 承认残余风险：10 万行未做全网逐段比对，只做了项目名/版权头/命名扫描，**可能仍有未发现的搬运**（报告结论对此开放）。但口语化注释、拼写错误、乱码、bootloader 实测可运行等痕迹表明存在真实开发活动；构建失败证明的是"公开版不完整"，不是"代码全为伪造"。维持，附不确定性声明 |
| "学生团队身份" | 审计是否该采信"学生团队"自述？ | GitHub 组织与官网均自述"由中国的一群学生们组建"，这是可引用的公开自述；但成员真实身份、年龄均无法从仓库/官网核实，本审计**只引用其自述、不作任何年龄/身份认定** |

**复检后的最终结论（含置信度）：**

- 事实级（可字节复现）："全自研"不成立；存在未声明的 MikanOS 字体与冒名的思源黑体；liballoc/libwebp 合规缺失；公开仓库缺文件、无法构建出内核；历史不可验证。
- 高置信推断：图形基础层代码派生自 MikanOS 谱系；开发使用了 AI 辅助。
- 开放问题：10 万行第一方代码中是否还有未识别搬运；私有完整版是否真实可运行；团队成员真实身份（仅有其"学生团队"自述可引，无法独立核实）。

---

## 九、场外宣传核查：官网与 B 站话术

应委托方要求，将官网（https://www.xingjisoft.com ，已实际访问）与其 B 站视频简介纳入审计范围，逐条对抗性核验：

### 9.1 官网宣称 vs 仓库事实

| 官网原话（实地抓取） | 审计事实 | 裁定 |
|---|---|---|
| "XJ380操作系统，**完全自主研发**"（首页）；"采用**完全由我们自主开发**的 XSK2.1 内核，技术先进"（产品页） | 本报告第二、三节：92.6% 源码为第三方；图形/字体地基为未声明 MikanOS 代码；网络栈为 lwIP、浏览器引擎为 litehtml/lexbor/mbedTLS、命令行为 BusyBox | **虚假宣传成立**。这是比"全自研"更强的书面承诺（"完全"二字出现在两处），与仓库字节级证据直接冲突 |
| 版权脚注 "© XINGJI Interactive Software **2017** - 2026" | GitHub 组织创建于 2023-04，仓库内无任何 2023 年之前的可追溯产物；官网自述为学生团队 | 2017 起始年份无任何可验证依据支撑，高度可疑，最可能是模仿大厂版权格式的装点。它同时被盖在 MikanOS 派生文件上，构成双重失实 |
| "**ULTRA版本**（抢先体验版）需要您提供合理范围内的**赞助**方可获取" | 即：以夸大的"完全自研"宣称为卖点**收取赞助费**发放闭源抢先版 | 性质升级：夸大宣传一旦与收费挂钩，就从"学生吹牛"变为**面向公众的有偿失实陈述**，法律与舆论风险显著提高 |
| "XINGJI 大模型助力日常生活 AI 化"、"星际云"（已宣布关停）、鹊桥引擎、游戏 | 一个学生团队同时宣称拥有自研 OS、自研大模型、云服务、游戏引擎 | 与其真实产能（公开仓库连内核都链接不出）对照，整体呈"公司化人设包装"模式：用成熟企业的话术框架包装学生项目 |

### 9.2 B 站视频简介逐条核验

| 简介原话 | 对抗性核验 |
|---|---|
| "项目不是纯AI的！4月份前我们一直在手搓" | 本报告从未主张"纯 AI"（第八节已把 AI 使用降级为高置信推断）。但这句自辩**反向确认**了两个事实：① 团队承认 2026 年 4 月之后开发模式发生了变化（与 AGENTS.md "Generated: 2026-05-22" 的时间线吻合——AI 代理化开发始于 4-5 月）；② "手搓"期的产物恰恰无法验证，因为历史被抹除（第五节）。**自辩的举证方式应当是公开私库完整提交历史，而不是口头声明** |
| "中国第三，世界第四……目前我们查询到的有: AsterinasOS anonymOS NAOS XJ3800S" | 该排名**在方法论上不成立**：① 未定义比较维度（按什么排？代码量？其中 92.6% 还是别人的）；② 样本荒谬——中国活跃的自研/教学 OS 项目数以百计（仅举例：清华 rCore/zCore、龙蜥、openKylin、HarmonyOS 内核、以及 OSDev 社区大量个人项目），"查询到 4 个"只能说明检索未做；③ 与 Asterinas（蚂蚁集团参与、发表论文的生产级 Rust framekernel）并列比较是错位碰瓷。该排名是典型的**不可证伪营销话术**，作者也自知心虚（"仅为个人统计数据"） |
| "交流群里有**阉割版**" | 与本报告第七节实证吻合并**由其自认**：公开/群发版本是删减版。这印证了"公开仓库缺文件、不可复现"不是审计误判，而是发布策略 |
| "正式版很快就会和大家见面"、抽奖、求三联 | 流量运营话术，本身无可指摘；但注意其宣传闭环：**用不可验证的"完全自研"叙事换取流量与赞助，同时只发布无法复现该叙事的删减代码**——三者互为因果，构成完整的营销结构 |

### 9.3 对本节结论的自我对抗

- 最强反驳："官网/视频是中学生的浮夸文案，不应按商业标准苛责。"——部分接受：若无收费环节，本节大部分问题可归为年少轻狂；但 **ULTRA 版收赞助**这一事实使"按公众陈述标准审查"成为正当，且"完全自主研发"是他们自己选择的书面用语。
- 事实/推断区分：官网文字、ULTRA 收费条款、B 站简介内容为**实地抓取的事实**；"2017 为装点""4 月后转向 AI 开发"为**高置信推断**；"手搓期是否真实存在"为**开放问题**（可由其公开私库历史一举证伪或证实本报告）。

---

## 十、最终裁定

| 命题 | 裁定 | 依据 |
|---|---|---|
| "全自研操作系统"（官网原话："完全自主研发"） | **不成立（虚假宣传）** | 92.6% 源码为第三方；图形/字体地基为未声明的 MikanOS 教科书代码；且与 ULTRA 版收赞助挂钩（第九节） |
| "中国第三、世界第四" | **不成立（无方法论的营销话术）** | 无比较维度、样本仅 4 个、与生产级项目错位对标（第九节 9.2） |
| "用了开源项目且没标注"（用户的怀疑） | **部分成立** | 大部分组件有声明，但 MikanOS 血统、思源黑体、liballoc、libwebp PATENTS 等关键项未声明或声明失实 |
| "纯噱头" | **不成立** | 约 10 万行真实第一方代码，含内核、调度、VFS、窗口系统、兼容层；bootloader 实测可在 QEMU 运行 |
| 公开仓库可复现性 | **不合格** | 按其 README 无法完成内核链接（printk/serial 实现缺失），无法生成系统镜像，宣称的完整系统无法由公开代码验证 |
| 许可证合规 | **不合格** | Apache-2.0（MikanOS）违规 + 版权误标；OFL 字体冒名；GPL-2.0（BusyBox）材料齐全是唯一亮点 |
| 开发历史透明度 | **零** | 历史抹除 + 170 万行单次倾倒，"学生团队自主完成"（其自述）不可验证 |

审计给被审方的可证伪出路：公开 2026 年 4 月前"手搓期"的完整 Git 提交历史、补齐公开仓库缺失文件使其可构建、声明 MikanOS 血统并修正版权头、将宣传用词从"完全自主研发"改为"基于开源组件的自研整合"。四项任意一项都能实质性提升可信度；四项都不做，则维持本报告裁定。

**公允的描述应当是："一群学生在 AI 工具辅助下，以 MikanOS 教科书代码为起点、集成十余个成熟开源组件、并自写约 10 万行整合与子系统代码的组装型 hobby OS。"** 这本身是值得肯定的学习成果；问题在于将其包装为"全自研"，并对最能暴露血统的组件（教科书代码、字体）恰好不作声明、反而加盖自家版权——这使得夸大从"营销话术"滑向了"系统性误导"。

---

### 附：证据可复现清单

1. 行数统计：对仓库按扩展名 wc -l 并按目录归类（第二节表格）。
2. hankaku 比对：`uchan-nos/mikanos` 的 `kernel/hankaku.txt` 按 8 位点阵编译后与 `font/hankaku.bin` 做逐字节 diff → 4096/4096 字节一致。
3. 结构体比对：`include/efi/fbc.h` vs MikanOS `frame_buffer_config.hpp`。
4. 思源黑体：`font/ttf/XJ380F.ttf` 内部 name 表含 "Source Han Sans CN" 与 OFL-1.1 全文。
5. liballoc 自认缺失：`licenses/liballoc.txt` 原文。
6. 历史断层：`git log` 全部提交于 2026-08-01；`AGENTS.md` 头部引用不存在的 commit `e5affb6d`（2026-05-22）。
7. 构建实证：干净 Ubuntu 环境按 README 安装依赖后 `ninja -f build.ninja all` 于 `out/kernel.krl` 链接步骤失败（`undefined reference to printk/write_serial_string/...`）；`grep` 全仓库确认无内核侧实现；bootloader-only FAT 镜像 + `qemu-system-x86_64 -bios OVMF.fd -display none -serial stdio` 串口输出 XJ380 横幅。
