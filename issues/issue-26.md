# Issue #26（发布时原文存档）

- 原始链接：https://github.com/xingji-studio/OpenXJ380/issues/26
- 标题：License: 根目录 OVMF.fd 为 edk2-stable202011 预编译固件，无来源/版本/许可证记录，也不在 compliance manifest 中
- 提出者：akain-0410
- 发布时间（GitHub API）：2026-08-02T09:12:47Z
- 抓取时间（UTC）：2026-08-02T09:15:46Z

> 正文为 GitHub API 抓取的发布时原文，未经改动。若原 Issue 被删除或正文被编辑，以本文件与其 Git 提交时间戳为准。

---

在 commit [`4349e4d`](https://github.com/xingji-studio/OpenXJ380/commit/4349e4d546406d11fc4bd0b4bcfa628ad2eef81f) 上核对。与 [#22](https://github.com/xingji-studio/OpenXJ380/issues/22) 第 6 项（`liballoc-x86_64.a` 来源记录冲突）属于同一类问题——随仓库分发但未记录来源的外部二进制输入——但 #22 未涵盖 `OVMF.fd`。

## 事实

仓库根目录随源码分发了一个 4 MiB 的预编译二进制 [`OVMF.fd`](https://github.com/xingji-studio/OpenXJ380/blob/4349e4d/OVMF.fd)：

```bash
ls -l OVMF.fd
# -rw-r--r-- 1 ... 4194304 OVMF.fd

sha256sum OVMF.fd
# 6ffb11f99506f27c30370d5051d89932c5db600fbe8a0d052f8aacacda3bcf17

strings -a OVMF.fd | grep -o 'edk2-stable[0-9]*' | sort -u
# edk2-stable202011
```

它是 [TianoCore EDK II](https://github.com/tianocore/edk2) 的 OVMF 固件构建产物，上游许可证为 [BSD-2-Clause-Patent](https://github.com/tianocore/edk2/blob/master/License.txt)。但仓库中没有任何记录：

```bash
grep -rIn -i 'ovmf\|edk2\|tianocore' --include='*.md' --include='*.json' . | grep -v '^./.git/'
# （无输出）
```

`THIRD_PARTY_NOTICES.md`、`LICENSES.md`、`third_party/compliance-manifest.json` 三处均无对应条目，也未记录来源发行版、构建版本、获取 URL 与哈希——因此无法核实它是否为未经修改的上游产物。

## 明确性质，避免误读

把 OVMF 作为 QEMU 运行固件使用完全正当，这不是"用了不该用的东西"的问题，而是**分发记录**问题：一个二进制随仓库分发，就需要可核实的来源与许可证材料。

判断标准可以直接用你们自己已经做到的那一套：[`third_party/busybox-source/`](https://github.com/xingji-studio/OpenXJ380/tree/4349e4d/third_party/busybox-source) 对 BusyBox 提供了上游归档、`LICENSE`、`.config`、编译补丁、`BUILDING.md` 与 `build.sh`，`tests/test_license_compliance.py` 里还有哈希断言。同一标准下，`OVMF.fd` 目前是缺位的。

## 建议（二选一）

1. **保留二进制**：新建 `third_party/ovmf/`，放入 `SOURCE.md`（上游发行版、版本、下载 URL、SHA-256）与 EDK II 的 `License.txt`，并在 `THIRD_PARTY_NOTICES.md` 与 `compliance-manifest.json` 各增一条；
2. **移除二进制**：从仓库删除 `OVMF.fd`，README 改为使用发行版自带的固件（Ubuntu 安装 `ovmf` 包后为 `/usr/share/OVMF/OVMF_CODE.fd`）。实测该路径可满足本项目的 QEMU 启动需求，同时能让仓库少 4 MiB 且不再需要维护固件的合规材料。


---

### 状态更新（抓取时间 2026-08-03T11:08:50Z）

- 当前状态：**open**
- 最后更新：2026-08-02T10:45:43Z
- 评论数：1

#### 全部评论原文

---

**Rainy101112** @ 2026-08-02T10:45:43Z

感谢你的Issue，我们已了解此问题，会尽快解决。
