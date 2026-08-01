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
