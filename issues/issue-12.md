# Issue #12（发布时原文存档）

- 原始链接：https://github.com/xingji-studio/OpenXJ380/issues/12
- 标题：License: `font/hankaku.bin` 与 MikanOS 字体逐字节一致（4096/4096），未声明来源且被标注 "XINGJI 保留所有权利"
- 提出者：akain-0410
- 发布时间（GitHub API）：2026-08-01T21:48:56Z
- 抓取时间（UTC）：2026-08-02T09:15:46Z

> 正文为 GitHub API 抓取的发布时原文，未经改动。若原 Issue 被删除或正文被编辑，以本文件与其 Git 提交时间戳为准。

---

## 概述

本仓库中存在与 [MikanOS](https://github.com/uchan-nos/mikanos)（[Apache-2.0](https://github.com/uchan-nos/mikanos/blob/master/LICENSE)，日本教材《ゼロからのOS自作入門》配套项目）逐字节一致的资产和高度同构的代码，但：

1. [`THIRD_PARTY_NOTICES.md`](https://github.com/xingji-studio/OpenXJ380/blob/main/THIRD_PARTY_NOTICES.md) 与 [`LICENSES.md`](https://github.com/xingji-studio/OpenXJ380/blob/main/LICENSES.md) 中均未声明 MikanOS 或该字体的来源；
2. 相关派生文件头部标注了 `版权所有©XINGJI Studios 2017-2026 保留所有权利`。

这与 Apache-2.0 第 4 条（再分发须保留版权声明与 LICENSE）不符，也与官网（xingjisoft.com）"完全自主研发"的表述不符。

## 证据 1：字体逐字节一致（可复现）

[`font/hankaku.bin`](https://github.com/xingji-studio/OpenXJ380/blob/main/font/hankaku.bin)（4096 字节，256 字符 × 8×16 点阵）与 MikanOS 的 [`kernel/hankaku.txt`](https://github.com/uchan-nos/mikanos/blob/master/kernel/hankaku.txt) 按其官方工具（[`tools/makefont.py`](https://github.com/uchan-nos/mikanos/blob/master/tools/makefont.py)）的规则（`@`=1，`.`=0，每 8 列一字节）编译出的二进制**完全一致，256/256 个字形全部逐字节相同**。

任何人可在本仓库根目录用以下脚本验证：

```bash
curl -sL -o /tmp/hankaku.txt https://raw.githubusercontent.com/uchan-nos/mikanos/master/kernel/hankaku.txt
python3 - <<'EOF'
data = bytearray()
for l in open('/tmp/hankaku.txt', encoding='utf-8'):
    l = l.rstrip('\n')
    if len(l) == 8 and set(l) <= set('.@'):
        b = 0
        for ch in l:
            b = (b << 1) | (ch == '@')
        data.append(b)
mine = open('font/hankaku.bin', 'rb').read()
print('mikan:', len(data), 'bytes; repo:', len(mine), 'bytes')
print('byte-identical:', bytes(data) == mine)
EOF
```

预期输出：`byte-identical: True`。

4096 字节完全一致不存在"独立实现巧合"的可能。该字体源自川合秀実《30日でできる！OS自作入門》，经 MikanOS 传承。

## 证据 2：图形基础层与 MikanOS 同构

[`include/efi/fbc.h`](https://github.com/xingji-studio/OpenXJ380/blob/main/include/efi/fbc.h)（文件头标注 XINGJI 版权）中：

```c
struct FrameBufferConfig {
    uint8_t  *frame_buffer;
    uint32_t  pixels_per_scan_line;
    uint32_t  horizontal_resolution;
    uint32_t  vertical_resolution;
    enum PixelFormat pixel_format;
};
```

与 MikanOS 的 [`kernel/frame_buffer_config.hpp`](https://github.com/uchan-nos/mikanos/blob/master/kernel/frame_buffer_config.hpp) 字段名、字段顺序完全一致。`PixelFormat` 枚举 `kRGBR/kBGRR` 对应 MikanOS 的 `kPixelRGBResv8BitPerColor/kPixelBGRResv8BitPerColor`（`k` 前缀是 MikanOS 遵循的 Google C++ 命名约定）。[`include/graphics/GOP.hpp`](https://github.com/xingji-studio/OpenXJ380/blob/main/include/graphics/GOP.hpp) 的 `PixelColor{r,g,b}`、`PixelAt()` 亦与 MikanOS 的 PixelWriter 体系一一对应，且 `WriteRGBR` 处注释写道"类名可能是为了某种特定格式"——说明注释者并不了解该命名的实际来历。

（相对证据 1，本条为强同构旁证；证据 1 本身已足以确立派生关系。）

## 请求的修复

1. 在 [`THIRD_PARTY_NOTICES.md`](https://github.com/xingji-studio/OpenXJ380/blob/main/THIRD_PARTY_NOTICES.md) / [`LICENSES.md`](https://github.com/xingji-studio/OpenXJ380/blob/main/LICENSES.md) 中如实声明 MikanOS / hankaku 字体来源，附 [Apache-2.0 文本](https://github.com/uchan-nos/mikanos/blob/master/LICENSE)；
2. 移除派生文件上的 "XINGJI Studios 保留所有权利" 版权头，或改为注明派生来源的合规表述；
3. 如认为上述文件为独立实现，请给出可验证的反证（例如 2026 年 4 月前的原始提交历史——当前仓库约 170 万行代码为 2026-08-01 单次 ["first commit"](https://github.com/xingji-studio/OpenXJ380/commit/4224bec) 倒入，无法追溯）。

完整审计报告（含全仓库第三方占比统计、其他许可证合规问题、构建可复现性实测）见：https://github.com/akain-0410/openxj380-audit

本 Issue 只陈述可复现事实，欢迎以证据回应。

---

## 评论（按时间顺序，抓取时刻状态）

### Rainy101112 · 2026-08-02T04:43:10Z

非常感谢你的Issue，开发组已知晓上述问题。我们会在第三方引用中添加相应的信息，也许会考虑将目前的点阵字体替换成其他字体（因为这个字体的确不太好看）。版权信息我们会进行修改，保障合规。在解决这些问题后我们会提醒你，并关闭此条Issue。

### Rainy101112 · 2026-08-02T05:35:13Z

已经添加许可证信息并移除相关不正确的版权信息，如果你认为问题已经解决，我们将关闭此条Issue

### akain-0410 · 2026-08-02T09:10:09Z

感谢这么快处理，`THIRD_PARTY_NOTICES.md` 的三行新增与 `font/ttf/LICENSES.md` 我都已确认（commit c6bcfb3）。

在最新的 4349e4d 上复核后，还有三点建议在关闭前一并处理——都是这次改动的"最后一公里"，补齐后我这边没有任何异议：

**1. 新增的声明没有同步到 `third_party/compliance-manifest.json`**

`THIRD_PARTY_NOTICES.md` 开头写明：

> The machine-readable inventory is `third_party/compliance-manifest.json`; the build generates a distributable bundle at `out/compliance/third-party`.

但 manifest 的 `components` 仍是 16 项：

```bash
python3 -c "import json;print([c['name'] for c in json.load(open('third_party/compliance-manifest.json'))['components']])"
# ['musl ELF definitions', 'lwIP', 'FatFs', 'stb libraries', 'dr_mp3', 'litehtml', 'Gumbo Parser',
#  'libvterm', 'libwebp', 'NanoSVG', 'Mbed TLS', 'Lexbor', 'StardustUI', 'RapidJSON',
#  'Rust alloc and compiler_builtins', 'BusyBox']
```

`MikanOS hankaku.bin`、`maple-font`、`Source Han Sans font` 三项都不在里面。按你们自己的设计，`out/compliance/third-party` 发行包是由 manifest 生成的，所以对最终分发物而言这次补充还没有生效。

**2. MikanOS 的 Apache-2.0 全文未随仓库提供**

```bash
ls licenses/
# fatfs.txt  glibc-elf-h.txt  liballoc.txt  lwip.txt
```

Apache-2.0 §4(a) 要求分发派生作品时附带 License 副本。建议加 `licenses/mikanos-apache-2.0.txt`（上游全文：https://github.com/uchan-nos/mikanos/blob/master/LICENSE ），并在 manifest 的对应条目里用 `license_files` 指向它。

**3. `include/efi/fbc.h`、`include/graphics/GOP.hpp` 目前只删了版权行，没有加来源归属**

两个文件现在首行都是 `// XJ380图像头文件`，既无原声明也无新的归属注释。删掉不准确的版权声明是对的，但派生自 Apache-2.0 作品的文件仍应写明来源（Apache-2.0 §4(b)(c)）。加一行即可，例如：

```c
// Portions derived from MikanOS (https://github.com/uchan-nos/mikanos), Apache-2.0.
```

**另外一条建议（防止今后再次漂移）**

`tests/test_license_compliance.py` 已经对 BusyBox bundle、mbedTLS 选择、`elf.h` 有断言，但没有"`THIRD_PARTY_NOTICES.md` 组件表 ↔ `compliance-manifest.json` 一致性"这一条，所以这次两边不同步是静默发生的、CI 不会报错。补一条双向断言（NOTICES 里的每个组件都能在 manifest 找到同名条目，反之亦然）可以一次性解决这类问题。

顺带说明：BusyBox 那边的材料是齐的（`third_party/busybox-source/` 有归档、`LICENSE`、`.config`、编译补丁、`BUILDING.md`，测试里还有哈希断言），这个标准很好，上面三点其实就是把同样的标准套用到 MikanOS 与字体上。

以上三点处理完就可以关闭本 Issue，谢谢。



---

### 状态更新（抓取时间 2026-08-03T11:08:50Z）

- 当前状态：**open**
- 最后更新：2026-08-03T11:08:35Z
- 评论数：6

#### 全部评论原文

---

**Rainy101112** @ 2026-08-02T04:43:10Z

非常感谢你的Issue，开发组已知晓上述问题。我们会在第三方引用中添加相应的信息，也许会考虑将目前的点阵字体替换成其他字体（因为这个字体的确不太好看）。版权信息我们会进行修改，保障合规。在解决这些问题后我们会提醒你，并关闭此条Issue。

---

**Rainy101112** @ 2026-08-02T05:35:13Z

已经添加许可证信息并移除相关不正确的版权信息，如果你认为问题已经解决，我们将关闭此条Issue

---

**akain-0410** @ 2026-08-02T09:10:09Z

感谢这么快处理，`THIRD_PARTY_NOTICES.md` 的三行新增与 `font/ttf/LICENSES.md` 我都已确认（commit c6bcfb3）。

在最新的 4349e4d 上复核后，还有三点建议在关闭前一并处理——都是这次改动的"最后一公里"，补齐后我这边没有任何异议：

**1. 新增的声明没有同步到 `third_party/compliance-manifest.json`**

`THIRD_PARTY_NOTICES.md` 开头写明：

> The machine-readable inventory is `third_party/compliance-manifest.json`; the build generates a distributable bundle at `out/compliance/third-party`.

但 manifest 的 `components` 仍是 16 项：

```bash
python3 -c "import json;print([c['name'] for c in json.load(open('third_party/compliance-manifest.json'))['components']])"
# ['musl ELF definitions', 'lwIP', 'FatFs', 'stb libraries', 'dr_mp3', 'litehtml', 'Gumbo Parser',
#  'libvterm', 'libwebp', 'NanoSVG', 'Mbed TLS', 'Lexbor', 'StardustUI', 'RapidJSON',
#  'Rust alloc and compiler_builtins', 'BusyBox']
```

`MikanOS hankaku.bin`、`maple-font`、`Source Han Sans font` 三项都不在里面。按你们自己的设计，`out/compliance/third-party` 发行包是由 manifest 生成的，所以对最终分发物而言这次补充还没有生效。

**2. MikanOS 的 Apache-2.0 全文未随仓库提供**

```bash
ls licenses/
# fatfs.txt  glibc-elf-h.txt  liballoc.txt  lwip.txt
```

Apache-2.0 §4(a) 要求分发派生作品时附带 License 副本。建议加 `licenses/mikanos-apache-2.0.txt`（上游全文：https://github.com/uchan-nos/mikanos/blob/master/LICENSE ），并在 manifest 的对应条目里用 `license_files` 指向它。

**3. `include/efi/fbc.h`、`include/graphics/GOP.hpp` 目前只删了版权行，没有加来源归属**

两个文件现在首行都是 `// XJ380图像头文件`，既无原声明也无新的归属注释。删掉不准确的版权声明是对的，但派生自 Apache-2.0 作品的文件仍应写明来源（Apache-2.0 §4(b)(c)）。加一行即可，例如：

```c
// Portions derived from MikanOS (https://github.com/uchan-nos/mikanos), Apache-2.0.
```

**另外一条建议（防止今后再次漂移）**

`tests/test_license_compliance.py` 已经对 BusyBox bundle、mbedTLS 选择、`elf.h` 有断言，但没有"`THIRD_PARTY_NOTICES.md` 组件表 ↔ `compliance-manifest.json` 一致性"这一条，所以这次两边不同步是静默发生的、CI 不会报错。补一条双向断言（NOTICES 里的每个组件都能在 manifest 找到同名条目，反之亦然）可以一次性解决这类问题。

顺带说明：BusyBox 那边的材料是齐的（`third_party/busybox-source/` 有归档、`LICENSE`、`.config`、编译补丁、`BUILDING.md`，测试里还有哈希断言），这个标准很好，上面三点其实就是把同样的标准套用到 MikanOS 与字体上。

以上三点处理完就可以关闭本 Issue，谢谢。

---

**Rainy101112** @ 2026-08-02T10:32:00Z

好的，已悉知，我们会立即处理

---

**Rainy101112** @ 2026-08-02T11:47:19Z

已经解决，你可以检查一下，如果没问题那么我就关闭这条Issue了

---

**akain-0410** @ 2026-08-03T11:08:35Z

已在 `ad39a67` 上逐条复核，**我提的三点全部闭合，本 Issue 可以关闭**。感谢处理，从 #12 提出到闭环不到一天。

**1. manifest 同步 ✅**

```bash
python3 -c "import json;d=json.load(open('third_party/compliance-manifest.json'));print(len(d['components']))"
# 21（原 16）
```

`MikanOS hankaku font` / `maple-font` / `Source Han Sans font` 三项都在，且 `license_files` 里每一个路径都实际存在（脚本遍历校验，缺失为 0）。顺带看到还补了 `talc allocator` 与 `libutf`、把 `licenses/glibc-elf-h.txt` 换成了 `musllibc-elf-h.txt`，这几项超出本 Issue 范围，一并致谢。

**2. Apache-2.0 全文与源材料 ✅**

```bash
wc -l licenses/mikanos.txt                    # 200，含 "APPENDIX: How to apply the Apache License"
ls third_party/mikanos-hankaku/               # LICENSE  SOURCE.md  hankaku.txt
```

`SOURCE.md` 记录了上游 commit `b5f7740c`、源文件路径、License URL 与哈希，比我建议的做法更完整——`font/hankaku.bin` 现在可以脱网独立验证。已复算：

```bash
sha256sum font/hankaku.bin
# 317e04a76e42f35eae509cd47dba86f36578cb4c479afd08363ea91ed397ce5f  ← 与 SOURCE.md 记录一致
```

**3. 派生文件的来源归属 ✅**

`include/efi/fbc.h`、`include/graphics/GOP.hpp` 首行均已加上：

```c
// Portions derived from MikanOS (https://github.com/uchan-nos/mikanos), Apache-2.0.
```

---

**关闭前不必处理的一个小 nit（不影响本 Issue 闭合，只是提醒免得日后误判）**

`SOURCE.md` 里记录的另两个哈希与入库副本对不上：

```bash
sha256sum third_party/mikanos-hankaku/hankaku.txt third_party/mikanos-hankaku/LICENSE
# 793c78bc2c6ba02c980558b4a8af5b2cbc9f528e783bbf7658cb45b46ddd220f  hankaku.txt
# 43070e2d4e532684de521b885f385d0841030efa2b1a20bafb76133a5e1379c1  LICENSE
# SOURCE.md 记录的是 826e59f4…（hankaku.txt）与 c71d239d…（LICENSE）
```

原因已查明，**不是文件内容被改动**：`SOURCE.md` 记录的是上游真值（我从 `b5f7740c` 拉取复算，完全吻合），而入库副本的**行尾换行符被去掉了一个字节**——除末尾这一个 `\n` 外与上游逐字节相同（38776→38775、11357→11356）。多半是编辑器或格式化钩子做的。

两种改法都行：把 `SOURCE.md` 的两个哈希改成入库副本的实际值，或把末尾换行补回来使其与上游一致（更推荐后者，上游 LICENSE 保持原样更利于比对）。

另外 `tests/test_license_compliance.py::test_mikanos_hankaku_source_material_is_complete` 目前只断言这三个文件存在与 manifest 字段，没有校验 `SOURCE.md` 里的哈希，所以上面这个偏差是静默的。BusyBox 那边已经有哈希断言了（`test_busybox_corresponding_source_bundle_is_complete`），把同样的写法套到 mikanos-hankaku 上即可，顺便也能覆盖我上次提的 `THIRD_PARTY_NOTICES.md` ↔ `compliance-manifest.json` 双向一致性。

**以上仅为建议，本 Issue 的三项要求已全部满足，请随时关闭。** 剩余的 #23（libwebp）与 #26（OVMF.fd）在 `ad39a67` 上复核仍未变化，继续在各自 Issue 下跟进即可。
