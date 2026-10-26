---
doc-id: 05-05
title: Git版本管理规范
category: 项目规范
status: 生效
version: v1.0
updated: 2026-10-26
related: [05-02, 05-03, 04-08, 05-01]
---

# Git 版本管理规范

## 1. 目的与范围

本文规定 CodeStreak 仓库的**分支模型、提交信息、标签与发布、合并评审、敏感内容边界、文档同步义务**，是日常提交与发布的唯一操作依据。

- 与 [代码与工程规范](02-代码与工程规范.md) §9 的关系：§9 是摘要，本文是完整规范；两者冲突时以本文为准，并回改 §9。
- 适用范围：仓库内全部受控文件（代码、资源、文档、构建配置）。
- 不适用：DevEco 本机缓存（`.idea/`）、构建产物与签名材料（见 §8）。

## 2. 仓库模型

| 项 | 规定 |
| --- | --- |
| 仓库形态 | **单仓（monorepo）**：应用代码、资源、文档、测试同仓管理 |
| 主目录 | 仓库根＝工程根（`build-profile.json5` 所在目录） |
| 受控内容 | `AppScope/`、`entry/src/`、`docs/`、根级构建与规范配置（`*.json5`、`hvigorfile.ts`、`.gitignore`、`.gitattributes`、`README.md`） |
| 不入库 | 见 §8「禁止入库清单」 |
| 依赖锁定 | `oh-package.json5` + `oh-package-lock.json5` **必须提交**，保证可复现构建 |
| 大文件 | 单文件 >5MB 需评审；文档用 Markdown + 截图，不提交设计源文件（`.fig`、`.psd`） |

## 3. 分支模型

```text
main ─────●────────────●──────────●────▶  仅发布（tag）
           ╲          ╱ ╲        ╱
develop ────●──●──●──●───●──●──●────▶  集成（日常合入目标）
             ╲╱  ╲╱      ╲╱
        feature/* fix/* docs/* chore/*  （短生命周期，合并后删除）
```

| 分支 | 用途 | 命名 | 生命周期 | 保护 |
| --- | --- | --- | --- | --- |
| `main` | 可发布分支，每次提交都有 tag | `main` | 常驻 | 禁止直推；仅接受 `release/*` 或 `hotfix/*` 合并 |
| `develop` | 集成分支，日常合入目标 | `develop` | 常驻 | 禁止直推；仅接受 PR（squash） |
| `feature/*` | 新功能 | `feature/today-checkin` | 合并后删除 | — |
| `fix/*` | 缺陷修复 | `fix/streak-reset` | 合并后删除 | — |
| `docs/*` | 文档变更 | `docs/git-spec` | 合并后删除 | — |
| `chore/*` | 构建、依赖、脚手架 | `chore/bundle-name` | 合并后删除 | — |
| `release/x.y` | 发布准备（仅版本号与发布说明） | `release/1.0` | 发布后删除 | — |
| `hotfix/*` | 线上紧急修复 | `hotfix/crash-rdb` | 合并后删除 | 从 `main` 拉出，修完合并回 `main` 与 `develop` |

规则：

1. 分支名全小写、用 `-` 连接，不含中文与日期；一个分支只做一件事。
2. 单人仓库也遵守同样的分支与提交粒度，保证历史可回溯。
3. 从 `develop` 拉功能分支；合并前先 `git rebase develop`，保持线性历史。

## 4. 提交规范

### 4.1 格式

```text
<type>(<scope>): <subject>

<body 可选：为什么改、改了什么、影响范围>

<footer 可选：关联 FR/P/D 编号、BREAKING CHANGE>
```

- `subject` 用中文，动词开头，**≤ 50 字符**，不以句号结尾；
- 一行一义；禁止 `update`、`fix bug`、`修改` 这类无信息提交；
- 一个提交只做一件事：代码与对应测试同提交；文档与代码同提交或紧随其后。

### 4.2 type

| type | 含义 | 示例 |
| --- | --- | --- |
| `feat` | 新功能 | `feat(today): 打卡成功后弹出庆祝弹层` |
| `fix` | 缺陷修复 | `fix(sync): 修复 Codeforces 分页丢题` |
| `docs` | 文档 | `docs(git): 补充分支保护与发布流程` |
| `refactor` | 重构（不改行为） | `refactor(data): 抽出 RDB 迁移器` |
| `perf` | 性能 | `perf(matrix): 题单矩阵改用 LazyForEach` |
| `test` | 测试 | `test(domain): 补打卡状态机边界用例` |
| `style` | 格式（不改逻辑） | `style(ui): 统一缩进与引号` |
| `build` | 构建/依赖 | `build(deps): 锁定 hypium 1.0.25` |
| `chore` | 杂务/脚手架 | `chore(repo): 初始化工程与忽略规则` |
| `revert` | 回滚 | `revert: 回滚 4f2c1a9 的同步改造` |

### 4.3 scope

| scope | 范围 |
| --- | --- |
| `ui` | 页面与组件 |
| `domain` | 领域服务（打卡/难度/连击） |
| `data` | RDB、仓储、种子数据 |
| `sync` | 平台适配器与同步 |
| `design` | 设计令牌与资源 |
| `repo` | 构建、脚手架、工具链 |
| `docs` | 文档体系 |
| `test` | 测试工程 |
| `05`/`03` 等 | 指向文档编号，用于纯文档提交 |

### 4.4 反例

| 反例 | 问题 |
| --- | --- |
| `update code` | 无 type、无范围、无信息 |
| `fix: 修复了昨天那个问题` | 指向不明确，无法检索 |
| 一个提交同时改 UI、RDB、文档三件事 | 无法 review、无法单独回滚 |
| `feat(ui): 四个页面`（实际混入构建配置） | 提交与描述不符 |

## 5. 标签与版本

| 项 | 规定 |
| --- | --- |
| 版本语义 | SemVer：`MAJOR.MINOR.PATCH`，v1.0.0 为首个可发布版本 |
| 标签格式 | `v<MAJOR>.<MINOR>.<PATCH>`，**注释标签**（`git tag -a`），说明本次变更 |
| versionCode | `MAJOR*1000000 + MINOR*1000 + PATCH`（1.0.0 → 1000000），与 `AppScope/app.json5` 保持一致 |
| 发布提交 | `release/x.y` 上只允许改版本号与 `CHANGELOG`，合并到 `main` 后打 tag |
| 预发布 | `v0.1.0-m2` 这类里程碑标签可用，但**不得**发布到应用市场 |
| 一致性校验 | tag、`app.json5` 的 `versionName`/`versionCode`、README 版本表三处必须一致 |

发布说明模板：

```markdown
## v1.0.0 (2026-10-26)
### 新增
- 四个一级页与打卡闭环（P-01~P-04）
### 修复
- 冷启动闪白（D-23）
### 已知问题
- 未接平台同步，数据来自本地种子库
```

## 6. 合并与评审

| 环节 | 要求 |
| --- | --- |
| 发起 | PR 标题同提交规范；描述含「变更点 / 影响范围 / 验证方式 / 关联 FR 或 P 编号」 |
| 合并策略 | **squash merge** 到 `develop`，一个需求一个提交；`release` → `main` 用 merge commit 保留版本节点 |
| 评审 | 至少 1 名非作者通过；单人仓库需自评清单留痕（PR 描述勾选） |
| 门禁 | `hvigorw assembleHap` 成功、`hvigorw test` 全绿、`code-linter` 零 error、文档链接校验通过 |
| 禁止 | 直接 push `main`/`develop`；force push 已推送分支；把构建产物塞进提交 |

## 7. 提交前自检

```text
[ ] 变更只做一件事，提交信息符合 §4
[ ] 新增/修改逻辑有对应单测（或说明为何不需要）
[ ] hvigorw assembleHap 成功
[ ] hvigorw test 全绿
[ ] 文档已同步（见 §9）
[ ] git status 无未跟踪的产物/敏感文件
```

建议本地安装 pre-commit 钩子（可选，非强制）：提交前执行 `git diff --check` 与敏感文件名扫描。

## 8. 禁止入库清单

| 类别 | 具体文件 |
| --- | --- |
| 本机配置 | `local.properties`、`.idea/`、`.hvigor/`、`oh_modules/`、`.test/`、`node_modules/` |
| 构建产物 | `**/build/`、`*.hap`、`*.app`、`*.hsp`、`*.har`、`*.map` |
| 签名材料 | `*.p12`、`*.cer`、`*.p7b`、`*.csr`、`signature/` |
| 凭据 | 平台 Cookie、token、账号密码、`*.keystore`、`.env*` |
| 临时文件 | `.DS_Store`、`Thumbs.db`、`*.log`、`_draft/` |

`git status` 出现上述文件时，先修 `.gitignore` 再提交；已误提交的用 `git rm --cached` 移出并清理历史（见 §10）。

## 9. 与文档同步（完成定义 DoD）

一个任务只有同时满足以下四条才算完成：

1. 代码可编译、测试通过；
2. 受影响的规范文档已更新（如令牌变更改 02-02、接口变更改 04-07）；
3. [实现进度与代码映射](../04-技术设计/08-实现进度与代码映射.md) 已更新（模块状态、验证证据、偏差登记）；
4. 提交信息与变更范围一致，必要时同提交更新 `README.md`。

> 只改代码不改文档的提交，评审时应被要求补充；文档与代码分开提交时，文档提交必须紧邻代码提交并互相引用。

## 10. 冲突、回滚与历史

| 场景 | 做法 |
| --- | --- |
| 分支落后 | `git rebase develop`（未推送分支）；已推送用 `git merge develop` 避免改写历史 |
| 回滚已发布提交 | `git revert <sha>`，禁止 `reset --hard` 已推送分支 |
| 误提交敏感文件 | 立即轮换凭据 → `git rm --cached` → 用 `git filter-repo` 清理历史 → 强制推送并通知协作者 |
| 提交信息写错（未推送） | `git commit --amend` |
| 提交信息写错（已推送） | 不改写历史，追加 `docs` 提交说明更正 |

## 11. 常用命令速查

```bash
# 日常
git switch develop && git pull --rebase
git switch -c feature/today-checkin
git add -p && git commit -m "feat(today): 打卡链路接入 RDB"
git fetch origin && git rebase origin/develop

# 发布
git switch -c release/1.0 develop
# 改 versionName/versionCode + CHANGELOG
git commit -m "build(release): 发布 v1.0.0"
git switch main && git merge --no-ff release/1.0
git tag -a v1.0.0 -m "CodeStreak v1.0.0"
git push origin main --tags

# 排障
git log --oneline --graph --decorate -20
git status --short
git reflog
```

## 12. 首次导入记录

仓库首次纳管时按「一事一提交」拆分为以下节点，作为历史基线：

| # | 提交信息 | 主要内容 |
| --- | --- | --- |
| 1 | `chore(repo): 初始化 HarmonyOS 工程骨架与忽略规则` | 根级构建配置、AppScope、模块配置与资源、Ability 骨架、`.gitignore`/`.gitattributes` |
| 2 | `feat(design): 落地设计令牌与应用常量` | `DesignTokens.ets`、`AppConfig.ets` |
| 3 | `feat(domain): 打卡状态机、难度归一化与日期工具` | `domain/`、`utils/` |
| 4 | `feat(data): 本地 RDB 结构与种子数据` | `data/db/`、`SeedData.ets`、`model/` |
| 5 | `feat(ui): 四个一级页与组件库` | `components/`、`views/`、`pages/Index.ets` |
| 6 | `test: 补充难度、日期与打卡状态机单测` | `entry/src/test/` |
| 7 | `docs: 建立设计文档体系与 Git 规范` | `docs/` 全部文档、`README.md` |
| 8 | `chore(repo): 补齐模块级忽略与 ohosTest 脚手架` | `entry/.gitignore`、`entry/src/mock/`、`entry/src/ohosTest/` |

> 首次提交后创建 `develop` 分支并打 `v0.1.0` 里程碑标签（M2 四页闭环）；标签随后续补提交移动至最新的纳管状态。

## 13. 变更记录

| 版本 | 日期 | 变更 | 作者 |
| --- | --- | --- | --- |
| v1.0 | 2026-10-26 | 首版：仓库模型、分支与保护、提交规范、标签版本、合并评审、禁止入库清单、文档同步 DoD、回滚策略、首次导入记录 | 项目管理组 |
