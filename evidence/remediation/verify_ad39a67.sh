#!/usr/bin/env bash
# 复核被审方对 Issue #12/#23/#24/#26 的整改状态（2026-08-03，公开仓库 commit ad39a67）
# 用法：bash verify_ad39a67.sh [OpenXJ380 仓库路径]
# 依赖：git, python3(+fonttools), curl, coreutils
# 原则：只读仓库内的字节，不采信 Issue 回复中的说法。
set -euo pipefail

REPO="${1:-$PWD}"
cd "$REPO"
echo "== 复核对象 =="
git log --oneline -1

echo
echo "== #12-1  manifest 是否登记三项新声明，且 license_files 是否真实存在 =="
python3 - <<'PY'
import json, os
d = json.load(open("third_party/compliance-manifest.json"))
comps = d["components"]
print("components 数量:", len(comps), "(整改前为 16)")
want = {"MikanOS hankaku font", "maple-font", "Source Han Sans font"}
have = {c["name"] for c in comps}
print("三项新声明是否在册:", {w: (w in have) for w in sorted(want)})
missing = [(c["name"], f) for c in comps for f in c.get("license_files", []) if not os.path.exists(f)]
print("license_files 缺失项:", missing if missing else "无")
PY

echo
echo "== #12-2  MikanOS Apache-2.0 全文与源材料 =="
ls -1 licenses/
wc -l licenses/mikanos.txt
grep -c "APPENDIX: How to apply the Apache License" licenses/mikanos.txt
ls -1 third_party/mikanos-hankaku/
sha256sum font/hankaku.bin third_party/mikanos-hankaku/hankaku.txt third_party/mikanos-hankaku/LICENSE
echo "-- SOURCE.md 记录的哈希"
grep -A5 'Recorded hashes' third_party/mikanos-hankaku/SOURCE.md || true

echo
echo "== #12-2b 与上游 b5f7740c 逐字节比对（解释 SOURCE.md 的哈希偏差）=="
UP=$(mktemp -d)
curl -sL -o "$UP/hankaku.txt" https://raw.githubusercontent.com/uchan-nos/mikanos/b5f7740c04002e67a95af16a5c6e073b664bf3f5/kernel/hankaku.txt
curl -sL -o "$UP/LICENSE"    https://raw.githubusercontent.com/uchan-nos/mikanos/b5f7740c04002e67a95af16a5c6e073b664bf3f5/LICENSE
UP="$UP" python3 - <<'PY'
import os
up = os.environ["UP"]
for name, repo in (("hankaku.txt", "third_party/mikanos-hankaku/hankaku.txt"),
                   ("LICENSE",     "third_party/mikanos-hankaku/LICENSE")):
    a = open(os.path.join(up, name), "rb").read()
    b = open(repo, "rb").read()
    print(f"{name}: 上游 {len(a)} B / 入库 {len(b)} B | 入库 == 上游去掉行尾空白: {b == a.rstrip()}")
PY

echo
echo "== #12-3  派生文件的来源归属注释 =="
head -1 include/efi/fbc.h include/graphics/GOP.hpp

echo
echo "== #12-4  测试是否校验 SOURCE.md 记录的哈希（预期：否）=="
sed -n '/def test_mikanos_hankaku_source_material_is_complete/,/def test_third_party_manifest/p' tests/test_license_compliance.py

echo
echo "== #23  libwebp 上游许可证材料（预期：仍缺）=="
ls -1 user/browser/third_party/libwebp/
for f in COPYING PATENTS AUTHORS; do
  [ -e "user/browser/third_party/libwebp/$f" ] && echo "存在: $f" || echo "缺失: $f"
done

echo
echo "== #26  OVMF.fd 是否被申报（预期：0 次提及）=="
ls -l OVMF.fd
grep -ci ovmf third_party/compliance-manifest.json THIRD_PARTY_NOTICES.md || true

echo
echo "== #24  xiaolai.ttf 仍在分发，且 manifest 未登记；对照 RapidJSON 先例 =="
sha256sum frameworks/StardustUI/fonts/xiaolai.ttf
python3 - <<'PY'
from fontTools.ttLib import TTFont
n = TTFont("frameworks/StardustUI/fonts/xiaolai.ttf", lazy=True)["name"]
for i in (0, 1, 9, 13):
    print(i, "|", (n.getDebugName(i) or "")[:110])
PY
grep -ci "xiaolai\|小赖" third_party/compliance-manifest.json THIRD_PARTY_NOTICES.md || true
echo "-- RapidJSON 先例：StardustUI 内的第三方资产照样登记在 OpenXJ380 的 manifest 中"
python3 -c "
import json
for c in json.load(open('third_party/compliance-manifest.json'))['components']:
    if c['name'] in ('RapidJSON','StardustUI'): print(c['name'],'->',c.get('license_files'))"
echo "-- StardustUI 是独立仓库（上游当修这一点成立）"
cat .gitmodules
