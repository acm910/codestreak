---
name: harmony-arkts-delivery
description: Deliver and maintain a HarmonyOS ArkTS/ArkUI app end-to-end — docs-driven increments, hvigor build and hypium tests with coverage, HDC device verification and screenshots, release preparation (layered icons, privacy, self-test, tags), and Markdown+Word report generation. Use for CodeStreak or any similar HarmonyOS project.
---

# HarmonyOS ArkTS delivery

A repeatable loop for taking a HarmonyOS app from a document-backed feature to a tested, committed, release-ready increment. It encodes the working style proven on CodeStreak: **docs first, real data only, every increment tested, device-verified, documented and committed**.

## 1. When to use

- Adding or fixing a feature in a HarmonyOS / ArkTS / ArkUI project.
- Running builds, unit tests, coverage, or device verification (HDC).
- Preparing an app for release: icons, permissions, privacy note, self-test report, RC tag.
- Writing a training / release report that needs real screenshots and diagrams.

## 2. Non-negotiables

1. **Read the project's own docs first.** For CodeStreak the progress source of truth is `docs/04-技术设计/08-实现进度与代码映射.md`; rulings live in `docs/06-附录/01-原型差异与设计裁决.md`. Do not invent architecture when a documented decision exists.
2. **Real data only.** Never ship demo numbers, fabricated users, or hard-coded progress (e.g. `93%`). If a data source is missing, show an empty state. "If it can't be real, leave it empty."
3. **Every increment has four parts:** code + tests + docs + commit. A commit must be buildable on its own.
4. **UI claims need device evidence.** If you cannot verify on a device, say so explicitly instead of claiming it works.

## 3. Delivery loop

### Step 0 — Discover the project

```powershell
Get-Content AppScope/app.json5
Get-Content entry/src/main/module.json5
Get-Content docs/04-技术设计/08-实现进度与代码映射.md -TotalCount 80
```

Record: `bundleName`, `versionName` / `versionCode`, compatible/target SDK, pages, permissions, current milestone and known deviations.

### Step 1 — Plan one vertical slice

Pick one user-visible outcome (e.g. "tap a collection card opens the official list"). Define:

- entry point and expected behaviour;
- data source (real API / local DB / empty state);
- 3–5 acceptance checks (one of them a persistence or failure path);
- the unit tests you will add.

### Step 2 — Implement (ArkTS)

- Prefer pure services (`domain/*.ets`) for logic so it can be unit-tested without UI.
- Keep UI reactive: `@Local` for mutable fields, `@Param` for inputs, `@Require` when non-null.
- Read `references/arkts-pitfalls.md` before touching `@Builder`, `ForEach`, `Tabs`, JSON parsing or `http` headers.
- Persist through `DatabaseHelper` (RDB) and keep migrations additive (`CREATE TABLE IF NOT EXISTS`, bump `DbSchema.VERSION`).

### Step 3 — Build and test

Run from the project root. `<skill>` is this `SKILL.md`'s folder (the skill tool prints it as the base directory):

```powershell
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/harmony-build.ps1" -Task build -RepoRoot .
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/harmony-build.ps1" -Task test -RepoRoot .
```

The script locates the SDK from `$env:DEVECO_SDK_HOME` or common install paths, runs `hvigorw` with the bundled Node, and prints test/coverage paths. Minimum bar:

- `BUILD SUCCESSFUL`;
- `Tests run: N, Failure: 0, Error: 0`;
- line coverage ≥ 70 % (core domain ≥ 85 %);
- report the exact numbers, not "all tests pass".

### Step 4 — Verify on device (HDC)

```powershell
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/hdc-verify.ps1" -Action list -RepoRoot .
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/hdc-verify.ps1" -Action shot -Name home -RepoRoot .
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/hdc-verify.ps1" -Action tap -X 715 -Y 1447 -RepoRoot .
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/hdc-verify.ps1" -Action swipe -FromX 500 -FromY 1700 -ToX 500 -ToY 1000 -RepoRoot .
powershell -ExecutionPolicy Bypass -File "<skill>/scripts/hdc-verify.ps1" -Action restart -Bundle com.example.app -RepoRoot .
```

- `snapshot_display -f /data/local/tmp/<name>.jpeg` then `file recv` into `artifacts/` (git-ignored).
- `uitest uiInput click x y` (not `tap`), `swipe`, `keyEvent Back`.
- Verify persistence with `aa force-stop` + `aa start`; assert the UI still shows the saved state.
- Use `snapshot_display` before/after each user action; don't only capture the final screen.

### Step 5 — Update docs

For CodeStreak, update:

- `docs/04-技术设计/08-实现进度与代码映射.md`: §3 status, §4 interactions, §5 evidence (test count, coverage, HAP size, commit count), §6 deviations, changelog;
- root `README.md`: status table, limitations, test count;
- `docs/README.md` if a new document/category is added.

State the real numbers from Step 3/4. Record anything unverified as a deviation, not as done.

### Step 6 — Commit

```powershell
git add <code> <tests> <docs>
git commit -m "feat(scope): <what the user can now do>"
git branch -f develop main
```

- Conventional Commits; one logical change per commit.
- If `Index.ets` is a hub touched by two features, combine them into one buildable commit and say so in the body — never leave a commit that fails to compile.
- Keep `artifacts/`, build outputs and signing material out of git.

## 4. Build commands (manual fallback)

```powershell
$env:DEVECO_SDK_HOME = 'D:\develop\harmony\DevEco Studio\sdk'
$node   = 'D:\develop\harmony\DevEco Studio\tools\node\node.exe'
$hvigor = 'D:\develop\harmony\DevEco Studio\tools\hvigor\bin\hvigorw.js'

& $node $hvigor --no-daemon assembleHap -p product=default -p buildMode=debug
& $node $hvigor --no-daemon test -p product=default
```

Artifacts: `entry/build/default/outputs/default/entry-default-unsigned.hap`;
test result: `entry/.test/default/intermediates/test/coverage_data/test_result.txt`;
coverage: `entry/.test/default/outputs/test/reports/coverageReport.json`.

## 5. Release preparation

Read `references/release-and-report.md` for the full checklist. Summary:

- **Icon**: layered `background.png` (1024) + `foreground.png` (1024, transparent safe zone) + `layered_image.json`, plus `startIcon.png` for the splash; verify the HAP contains them.
- **Permissions**: only what is used (`INTERNET`, `PUBLISH_AGENT_REMINDER`); explain each in the privacy note.
- **Privacy**: data inventory table, third-party endpoints, deletion path, Cookie storage statement.
- **Self-test report**: build/test evidence, device walkthrough, defects fixed, G0–G3 gate decision, blockers.
- **Version**: keep `versionName`/`versionCode` consistent with the tag; RC tag `vX.Y.Z-rc.N`; signing is a blocker until a certificate exists.

## 6. Report generation (MD + DOCX)

- Write one content model and generate both formats (Python `python-docx` for DOCX), so they never diverge.
- Format: A4, 3.17 cm side margins / 2.54 cm top-bottom, 宋体 小四 (12 pt), 1.5 line spacing, 黑体 headings, captions 五号 gray.
- Length: 1500–2000 Chinese characters, 4–6 pages, 4–6 key figures.
- Figures: architecture diagram, business/data-flow diagram, real device screenshots, defect before/after. Draw diagrams with Pillow/matplotlib when no design tool is available; keep them legible at 9–12 cm width.
- Render the DOCX to images with the LibreOffice kit and inspect: clipped tables, orphaned captions, cover line wrapping, page count. Keep each image and caption together (`keep_with_next` on the image paragraph).
- Cover: fill class/name/student-id placeholders; remind the user to rename to `姓名+班级+学号.docx`.

## 7. Definition of done

- [ ] `BUILD SUCCESSFUL` with the final code.
- [ ] Unit tests pass; coverage recorded; new logic has tests.
- [ ] Device walkthrough done (or explicitly listed as unverified).
- [ ] `04-08` + `README` updated with real numbers.
- [ ] Commit created; `develop` synced; worktree clean except ignored artifacts.
- [ ] No fabricated data, no silent fallbacks presented as success.

## 8. References

- `references/arkts-pitfalls.md` — ArkTS/ArkUI errors hit in this project and their fixes.
- `references/release-and-report.md` — icon/permissions/privacy/report templates and gates.
- `scripts/harmony-build.ps1` — portable build/test runner.
- `scripts/hdc-verify.ps1` — screenshot/tap/restart helper.
- Repository installer: `scripts/install-skills.ps1`.

## 9. Install / update

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-skills.ps1
```

This copies the canonical `skills/harmony-arkts-delivery` to `.dsh/skills`, `.claude/skills`, `~/.dsh/skills` and `~/.claude/skills`. Restart DSH / Claude Code to reload the skill catalog. The installed copies are git-ignored; edit the canonical copy under `skills/` only.
