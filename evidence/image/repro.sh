#!/usr/bin/env bash
# XJ380.img 分发物审计的完整复现脚本（IMAGE_AUDIT.md 的全部结论）
# 依赖：gh, unzip, mtools(mcopy/mdir), python3(fonttools), binutils(strings), git
# 证据来源：https://github.com/xhdndmm/xj380os-full-report
#
# 【重要变动（2026-08-03 核实）】上述第三方仓库已被其作者置为只读（archived），且 Release 中含 `.git`
# 的 `XJ380.zip`（完整源码包）资产已被撤下，目前仅剩 `XJ380.img`。因此：
#   · 第 1、2、3、4、5 步（镜像下载、提取、许可证缺失、字体身份、BusyBox 对比）仍可完整复算；
#   · 第 6 步依赖 `XJ380.zip` 中的 `font/hankaku.bin`，现已无法从该 Release 获取；本脚本已改为自动
#     回退到从上游 MikanOS 取同一字体（两者逐字节一致，该结论本身就是本报告的认定），因此
#     结论仍可独立验证，不依赖任何已下线的资产。
# 本仓库不转载该源码包（其中含非公开的提交历史与个人信息）。
set -euo pipefail

WORK="${1:-$PWD/xj380-audit-work}"
mkdir -p "$WORK" && cd "$WORK"

TAG=commit-08e49b98fea8903f3d9deddf067c68227e2ac932
REPO=xhdndmm/xj380os-full-report

echo "== 1. 下载镜像（来源：$REPO）"
gh release download "$TAG" -R "$REPO" -p 'XJ380.*' -D . || true
sha256sum XJ380.img
# 期望：
# 14daf0fe40cb8e1bbcd24803a2fbfda28cf18a6d96d5822d37bc8d5dafcbe45e  XJ380.img   (134217728 B)
#
# XJ380.zip 在 2026-08-02 之后已被发布方撤下；若你手上有当时的副本，其哈希应为：
# 22a9552345bf57643f5cf66bb432b6930267504283a6546b217da89deb056dae  XJ380.zip   (462864064 B)

echo "== 2. 提取镜像根文件系统（GPT，EFI System 分区起始 LBA 2048 → 偏移 1048576）"
fdisk -l XJ380.img
printf 'drive x: file="%s/XJ380.img" offset=1048576\n' "$PWD" > mtoolsrc
export MTOOLSRC="$PWD/mtoolsrc"
rm -rf imgx && mkdir -p imgx && mcopy -s -n -Q 'x:/*' imgx/
find imgx -type f | wc -l   # 期望 101

echo "== 3. 关键结论 A：镜像内不存在任何许可证/声明文本"
find imgx \( -iname '*LICENS*' -o -iname '*COPYING*' -o -iname '*NOTICE*' -o -iname '*GPL*' \) -print
grep -ril -E "Permission is hereby granted|SIL OPEN FONT LICENSE|Apache License, Version 2.0|GNU GENERAL PUBLIC LICENSE|Redistribution and use in source and binary" imgx || true
# 期望：第一条无输出；第二条仅命中 imgx/system/font/XJ380F.ttf 的 name 表描述行

echo "== 4. 关键结论 B：两款字体的真实身份"
python3 - <<'EOF'
from fontTools.ttLib import TTFont
for p in ('imgx/system/font/XJ380C.ttf','imgx/system/font/XJ380F.ttf'):
    n=TTFont(p,lazy=True)['name']
    print(p, '|', n.getDebugName(1), '|', n.getDebugName(0))
EOF
# 期望：Maple Mono NF CN Light / Copyright 2022 The Maple Mono Project Authors
#       Source Han Sans CN Normal / Copyright (c) 2014, 2015 Adobe Systems Incorporated

echo "== 5. 关键结论 C：BusyBox 二进制与被审方公布 CCS 不一致"
sha256sum imgx/system/resources/apps/busybox
strings -a imgx/system/resources/apps/busybox | grep -m1 -E 'BusyBox v[0-9].*\('
git clone -q https://github.com/xingji-studio/OpenXJ380 OpenXJ380 2>/dev/null || true
sha256sum OpenXJ380/third_party/busybox-prebuilt/busybox_amd64
strings -a OpenXJ380/third_party/busybox-prebuilt/busybox_amd64 | grep -m1 -E 'BusyBox v[0-9].*\('

echo "== 6. 关键结论 D：MikanOS hankaku 字体在 kernel.krl 内的字节偏移"
# 原本取自 XJ380.zip 内的 font/hankaku.bin；该资产已下线，故回退到上游 MikanOS 并就地生成同一字节串。
if [ -f XJ380.zip ]; then unzip -q -o XJ380.zip; fi
if [ ! -f XJ380/font/hankaku.bin ]; then
  mkdir -p XJ380/font
  curl -sL -o hankaku.txt https://raw.githubusercontent.com/uchan-nos/mikanos/b5f7740c04002e67a95af16a5c6e073b664bf3f5/kernel/hankaku.txt
  # 转换方式与被审方 third_party/mikanos-hankaku/SOURCE.md 记录一致：8 字符点阵行，'@'->1、'.'->0，一行一字节
  python3 - <<'EOF'
import re
px = [l.rstrip('\n') for l in open('hankaku.txt')]
px = [l for l in px if re.fullmatch(r'[.@]{8}', l)]        # 256 字形 × 16 行 = 4096
b = bytes(int(l.replace('.', '0').replace('@', '1'), 2) for l in px)
open('XJ380/font/hankaku.bin', 'wb').write(b)
print('从上游 MikanOS 重建 hankaku.bin:', len(b), 'bytes')   # 期望 4096
EOF
fi
sha256sum XJ380/font/hankaku.bin
# 期望 317e04a76e42f35eae509cd47dba86f36578cb4c479afd08363ea91ed397ce5f
# （与被审方 SOURCE.md 记录一致；亦与已下线的 XJ380.zip 内 font/hankaku.bin 逐字节相同）
python3 - <<'EOF'
h=open('XJ380/font/hankaku.bin','rb').read(); k=open('imgx/system/kernel.krl','rb').read()
print('hankaku.bin', len(h), 'bytes; offset in kernel.krl =', k.find(h))   # 期望 1404928 (0x157000)
EOF

echo "== 7. 关键结论 E：'No GPL！' 提交删除的上游署名"
git -C XJ380 show --stat --format='%H%n%ad%n%an%n%s' --date=iso 89ac965f | head -20
git -C XJ380 show 89ac965f -- include/dma.h driver/dma.cpp | grep -E '^[-+].*(opyright|GPL)'
git -C XJ380 show 89ac965f -- kmod/netserver/arch/utils.cpp | grep -E '^[-+].*(opyright|cavOS)'

echo "== 8. 关键结论 F：e1000 模块的第三方版权声明"
head -1 XJ380/kmod/e1000/e1000.cpp
grep -c -i 'e1000\|lihanrui' OpenXJ380/third_party/compliance-manifest.json || echo "manifest 中 0 处提及"

echo "== 完成。逐文件哈希清单见 FILELIST.sha256.tsv"
