# Release and report playbook

## 1. Release gates

| Gate | What must be true |
| --- | --- |
| G0 smoke | App launches, four tabs reachable |
| G1 feature | P0 flow walked on device: check-in, matrix filters, contests, stats |
| G2 internal | Build + unit tests + coverage pass; P0/P1 defects fixed or recorded |
| G3 submit | Signed package, privacy/support info, four-platform login verified, store assets ready |

Do not claim G3 without a **signed** HAP. Unsigned output is a blocker, not a detail.

## 2. Layered icon

HarmonyOS layered icon = `background` + `foreground` + `layered_image.json`:

```json
{
  "layered-image": {
    "background": "$media:background",
    "foreground": "$media:foreground"
  }
}
```

- background: 1024×1024, opaque, full-bleed; foreground: 1024×1024 RGBA, content inside a ~66 % safe zone.
- Put the same assets in `AppScope/resources/base/media` and `entry/src/main/resources/base/media`; `app.json5` and `module.json5` reference `$media:layered_image`.
- `startWindowIcon` uses a separate `startIcon.png` (e.g. 152×152) composited on the splash background.
- Verify: unzip the HAP and confirm `resources/base/media/{background,foreground,layered_image,startIcon}` are present.

A quick Pillow recipe that produced an acceptable first version:

- dark radial gradient + faint grid background;
- amber flame silhouette with a dark check mark and a small emerald accent;
- supersample 4× then downscale for clean edges.

## 3. Permissions and privacy

- Keep only permissions actually used: `ohos.permission.INTERNET` and `ohos.permission.PUBLISH_AGENT_REMINDER` in this app.
- Privacy note must contain: data inventory (what/where/why/leaves device?), third-party endpoints, permission table with refusal impact, deletion path (uninstall), Cookie storage and security status.
- Replace developer entity/contact placeholders before submission; a placeholder privacy policy fails review.

## 4. Self-test report

Structure that passed internal review:

1. environment and method (SDK, device, commands);
2. build/test/coverage evidence with exact numbers;
3. device walkthrough table (step / expected / actual / evidence);
4. defects found and fixed (symptom → root cause → fix → status);
5. functional coverage by test domain (P-01…, sync, notifications, release);
6. blockers and risks by priority (P0/P1/P2);
7. release checklist and G0–G3 conclusion.

If a fix is not reinstalled on the device, write "fixed, UI retest pending" — never claim it was visually verified.

## 5. Training report (MD + DOCX)

- Single content model → Markdown + `python-docx`; do not hand-edit one and forget the other.
- Format: A4; side margins 3.17 cm, top/bottom 2.54 cm; 宋体 小四 12 pt; 1.5 line spacing; 黑体 headings; captions 10.5 pt centered gray.
- Length: 1500–2000 Chinese characters, 4–6 pages, 4–6 key figures.
- Cover: app name, class/name/student-id placeholders, group, date, DevEco/SDK/emulator. Remind the user to rename to `姓名+班级+学号.docx`.
- Figures needed: architecture, one business/data flow, 2–3 real screenshots, defect before/after. Draw diagrams with Pillow (boxes, arrows, legend) when no design tool is available.
- Keep each image and its caption on the same page: set `keep_with_next` on the image paragraph; check for orphan captions during render.
- Table columns: set explicit widths and 9 pt font for the 5-column validation table; otherwise it eats a page.
- Validate by rendering the DOCX with LibreOffice Kit to images and reading each page: cover wrapping, code-block overflow, table wrapping, caption orphans, final page count.

## 6. Versioning

- `versionName` / `versionCode` and tag must agree (`versionCode = major*1_000_000 + minor*1_000 + patch`).
- RC tag: `v1.0.0-rc.1`, annotated, message says "unsigned, release candidate".
- Release/self-test docs are part of the tag; commit them before tagging.
- Ignore `artifacts/`, build outputs, signing material and locally installed skill copies.
