# CodeStreak

> 把刷题变成不可断的连胜。跨平台刷题打卡 + 赛训一体化 HarmonyOS 应用。

本仓库按 [`docs/`](docs/README.md) 中的设计文档实现。当前处于 **v1.0 开发中（M2 四页闭环）**：四个一级页与核心交互已完成并通过 ArkTS 编译，数据仍来自本地种子集，尚未接入 RDB 与真实同步。

## 快速开始

### 方式一：DevEco Studio（推荐）

1. 用 DevEco Studio 打开仓库根目录（`File → Open`）。
2. 等待 `ohpm install` 与 hvigor 同步完成（首次可能需要网络下载依赖）。
3. 选择 `entry` 模块，连接真机或启动模拟器，点击 Run。
4. 当前无签名配置，真机安装需在 `File → Project Structure → Signing Configs` 中自动签名。

### 方式二：命令行构建（本机已验证）

```powershell
$env:DEVECO_SDK_HOME = 'D:\develop\harmony\DevEco Studio\sdk'
$node   = 'D:\develop\harmony\DevEco Studio\tools\node\node.exe'
$hvigor = 'D:\develop\harmony\DevEco Studio\tools\hvigor\bin\hvigorw.js'

& $node $hvigor --no-daemon assembleHap -p product=default -p buildMode=debug
```

产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`（约 0.65 MB，未签名）。

> Windows 上若构建报 `EPERM: .hvigor\outputs\build-logs\build.log`，说明当前终端身份对该目录无写权限，需在可写环境（DevEco 终端或提权终端）执行。

## 当前实现范围

| 模块 | 状态 | 说明 |
| --- | --- | --- |
| 设计令牌 | ✅ | `constants/DesignTokens.ets` 与 `docs/02-设计规范/02` 一致（颜色/间距/圆角/字号） |
| 数据模型 | ✅ | 枚举 + 实体接口（`model/`），字段对齐 `docs/04-技术设计/03` |
| 种子数据 | ✅ | `data/SeedData.ets` 使用自洽数据集 v1（28/64/152/384、占比 22.1/29.2/33.9/11.7/3.1） |
| P-01 今日打卡 | ✅ | 连续打卡主卡、周矩阵、核心推荐与竞赛挑战、打卡链路、庆祝弹层 |
| P-02 题单矩阵 | ✅ | 双赛道、搜索、难度/平台筛选、精选题单横滑、题目行三态、导入条 |
| P-03 比赛日历 | ✅ | 倒计时 HUD（每秒刷新）、补题率、周条、赛事筛选与卡片、补题打卡联动 |
| P-04 统计榜单 | ✅ | 用户卡、热力图、难度分布、徽章、排行榜、设置行 |
| 全局框架 | ✅ | AppBar + 四 Tab（保留各页状态）、Toast、打卡庆祝遮罩 |
| RDB 持久化 | ✅ | `data/db`（v2）：7 张表（user / check_in / problem / contest / app_setting / submission / sync_job）、首启种子灌库、打卡与提交落库、当日 AC 聚合 |
| 单元测试 | ✅ | hypium 本地单测 **45 条全通过**（难度归一化 / 日期周数 / 打卡状态机 / CF、AtCoder、CPC Finder 映射 / 同步策略），行覆盖 82.75%、分支 74.65% |
| 平台同步 | 🟡 | **Codeforces（真机已验证）与 AtCoder（代码完成）端到端**：节流 → HTTP → 映射 → 幂等落库 → 当日 AC；洛谷/LC 待做（见 `docs/04-技术设计/07`） |
| 赛事与外链 | ✅ | ICPC/CCPC 赛程取自 [CPC Finder](https://cpcfinder.com/contest) 公开接口；题目与赛事按钮跳转系统浏览器 |
| 通知提醒 | ⏳ | 下一步：`reminderAgentManager` 21:30 与赛前 15 分钟 |

## 目录结构

```text
entry/src/main/ets/
├── entryability/          EntryAbility（强制暗色 + 加载 pages/Index）
├── pages/Index.ets        唯一 @Entry：AppBar + Tabs + 庆祝弹层 + Toast + 启动装载
├── views/                 四个一级页（Today / Matrix / Contest / Stats）
├── components/
│   ├── Common.ets         C-01 AppBar、C-03 区块标题、C-08 指标块、C-13/C-14 徽标、C-15 进度条、空态
│   ├── Cards.ets          C-04 连续打卡卡（hero/hud）、C-06/C-07 目标卡、C-26 倒计时、C-27 补题率、C-29 比赛卡、C-30 补题卡、C-31 用户卡、C-36 设置行
│   └── Visuals.ets        C-28 周条、C-32 热力图、C-33 难度分布、C-34 徽章、C-35 排行榜、C-40 骨架、今日战报
├── domain/                CheckInService（打卡状态机）、SyncPolicy（节流/退避/降级）
├── model/                 Enums、Entities、SyncModels
├── data/
│   ├── SeedData.ets       自洽数据集 v1
│   ├── SyncService.ets    同步编排（拉取 → 落库 → 当日 AC → sync_job）
│   ├── ContestFeedService.ets  ICPC/CCPC 赛程（CPC Finder → 比赛卡）
│   ├── db/                DbSchema（DDL v2）、DatabaseHelper（初始化/种子/读写/聚合/设置）
│   └── remote/            Codeforces / AtCoder / Cpcfinder 适配器与映射
├── constants/             DesignTokens、AppConfig（Tab 配置与图标字符）
└── utils/                 DateUtil（ISO 周数/相对日期）、Difficulty（难度归一化）、LinkService（外链跳转）

entry/src/test/            hypium 单测：Difficulty / DateUtil / CheckInService / CodeforcesMapper / AtCoderMapper / CpcfinderMapper / SyncPolicy
```

## 测试

```powershell
$env:DEVECO_SDK_HOME = 'D:\develop\harmony\DevEco Studio\sdk'
& 'D:\develop\harmony\DevEco Studio\tools\node\node.exe' `
  'D:\develop\harmony\DevEco Studio\tools\hvigor\bin\hvigorw.js' `
  --no-daemon test -p product=default
```

报告：`entry/.test/default/intermediates/test/coverage_data/test_result.txt`（逐条用例）与
`entry/.test/default/outputs/test/reports/index.html`（覆盖率）。

## 已知限制

1. **同步覆盖 CF 与 AtCoder**：设置 →「OJ 元数据同步管理」可分别绑定两个平台，AppBar 同步按钮串行拉取；洛谷/LC 尚未接入，页面其余数据仍来自种子库。
2. **同步需手动触发**：无定时/后台同步，失败仅提示，无重试队列。
3. **AtCoder 难度为估算值**：按题位字母映射（A→★1 … G→★5），未接 `problem-models.json`。
4. **ICPC/CCPC 赛程来自第三方**：`cpcfinder.com` 公开接口，仅取今天及以后前 4 场，缺时长与报名状态；源不可用时回退本地种子。
5. **外链跳转依赖系统浏览器**：题目/赛事按钮通过 `viewData` 打开链接，设备无浏览器或链接失效时会提示失败。
6. **图标为字符占位**：待替换为 `SymbolGlyph` 或字体图标（设计规范见 `docs/02-设计规范/05`）。
7. **真机回归未完成**：编译、打包、45 条单测、CF 同步与首次启动均已通过，但四页 UI、AtCoder 同步与赛程拉取尚未按用例逐条回归（对照 `docs/07-测试与质量/02`）。
8. **签名缺失**：命令行产物为 unsigned HAP，安装前需配置签名。

## 版本管理

仓库已按 [Git版本管理规范](docs/05-项目规范/05-Git版本管理规范.md) 纳管：

- 分支：`main`（发布）/ `develop`（集成）/ `feature/*`、`fix/*`、`docs/*`、`chore/*`（短生命周期）；
- 提交：Conventional Commits，`<type>(<scope>): <简述>`，一事一提交；
- 版本：SemVer + 注释标签 `vX.Y.Z`，`versionCode = 主*1000000 + 次*1000 + 修订`；
- 每次任务完成必须同步更新 [实现进度与代码映射](docs/04-技术设计/08-实现进度与代码映射.md)。

## 文档

从 [`docs/README.md`](docs/README.md) 进入文档中心：产品设计、设计规范、页面设计、技术设计、项目规范、附录裁决、测试与质量共 33 份分册。
