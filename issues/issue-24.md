# Issue #24（发布时原文存档）

- 原始链接：https://github.com/xingji-studio/OpenXJ380/issues/24
- 标题：License: frameworks/StardustUI/fonts/xiaolai.ttf 为 OFL-1.1 的「小赖字体 SC」，仓库内无任何声明
- 提出者：akain-0410
- 发布时间（GitHub API）：2026-08-02T09:12:28Z
- 抓取时间（UTC）：2026-08-02T09:15:46Z

> 正文为 GitHub API 抓取的发布时原文，未经改动。若原 Issue 被删除或正文被编辑，以本文件与其 Git 提交时间戳为准。

---

在 commit [`4349e4d`](https://github.com/xingji-studio/OpenXJ380/commit/4349e4d546406d11fc4bd0b4bcfa628ad2eef81f) 上核对。与 [#13](https://github.com/xingji-studio/OpenXJ380/issues/13) 性质相同但文件不同：#13 讨论的是 `font/ttf/` 下的 `XJ380F.ttf` 与 `XJ380C.ttf`，这两个已在 commit [`c6bcfb3`](https://github.com/xingji-studio/OpenXJ380/commit/c6bcfb33e9b3a4341fd73bd30e62759d12552eeb) 中通过新增 [`font/ttf/LICENSES.md`](https://github.com/xingji-studio/OpenXJ380/blob/4349e4d/font/ttf/LICENSES.md) 补齐；而 `frameworks/StardustUI/fonts/` 下还有第三个字体被漏掉了。

## 事实

[`frameworks/StardustUI/fonts/xiaolai.ttf`](https://github.com/xingji-studio/OpenXJ380/blob/4349e4d/frameworks/StardustUI/fonts/xiaolai.ttf) 的 TTF `name` 表内容：

| name ID | 内容 |
|---|---|
| 0（版权） | `Copyright © 2020 LXGW` |
| 1 / 4（族名） | `Xiaolai SC` / `小赖字体 SC` |
| 5（版本） | `Version 3.00;June 18, 2020` |
| 13（许可证） | `This Font Software is licensed under the SIL Open Font License, Version 1.1.` |
| 14 | `http://scripts.sil.org/OFL` |

复现（无额外依赖，直接读 TTF 的 name 表）：

```bash
python3 - <<'EOF'
import struct
d=open('frameworks/StardustUI/fonts/xiaolai.ttf','rb').read()
n=struct.unpack('>H',d[4:6])[0]
for i in range(n):
    off=12+16*i
    if d[off:off+4]==b'name':
        o,_=struct.unpack('>II',d[off+8:off+16])
        _,cnt,so=struct.unpack('>HHH',d[o:o+6])
        for j in range(cnt):
            pid,eid,lid,nid,ln,noff=struct.unpack('>HHHHHH',d[o+6+12*j:o+6+12*j+12])
            if nid in (0,1,13):
                s=d[o+so+noff:o+so+noff+ln]
                print(nid, (s.decode('utf-16-be') if pid==3 else s.decode('latin1'))[:80])
EOF
```

仓库内对它没有任何记录：

```bash
grep -rIn -i 'xiaolai\|小赖' --include='*.md' --include='*.json' . | grep -v '^./.git/'
# （无输出）
```

即 `THIRD_PARTY_NOTICES.md`、`LICENSES.md`、`third_party/compliance-manifest.json` 与新增的 `font/ttf/LICENSES.md` 四处均未提及。

## 依据

OFL-1.1 第 2 条：字体软件（原版或修改版）与软件一同分发时，每一份拷贝都必须附带上述版权声明与本许可证，可以是独立文本文件、可读的文件头，或二进制文件中用户易于查看的元数据字段。

此处 `name` ID 13/14 虽在文件内标明了 OFL，但版权声明与许可证全文未随仓库提供，也未进入任何声明清单。

## 建议

1. 在 `font/ttf/LICENSES.md` 追加小赖字体的版权行与 OFL-1.1 全文（或新建 `frameworks/StardustUI/fonts/LICENSES.md`）；
2. 在 `THIRD_PARTY_NOTICES.md` 组件表增加一行；
3. 在 `third_party/compliance-manifest.json` 增加一条对应条目，使其进入 `out/compliance/third-party` 发行包。

上游：[lxgw/kose-font](https://github.com/lxgw/kose-font)（小赖字体 / LXGW Kose）。


---

### 状态更新（抓取时间 2026-08-03T11:08:50Z）

- 当前状态：**closed**（关闭时间 2026-08-02T12:37:06Z，关闭者 Rainy101112）
- 最后更新：2026-08-02T12:37:06Z
- 评论数：2

#### 全部评论原文

---

**Rainy101112** @ 2026-08-02T10:37:03Z

感谢你的Issue，我们已悉知此问题，会尽快补充许可证信息。

---

**Rainy101112** @ 2026-08-02T12:36:58Z

这个应该在StardustUI库进行修改，因为StardustUI库也是XJ380的一个第三方引用，你可以考虑移步https://github.com/xingji-studio/StardustUI
