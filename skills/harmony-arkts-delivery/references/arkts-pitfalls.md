# ArkTS / ArkUI pitfalls hit in this project

Each item is an error or wrong behaviour that actually occurred on CodeStreak, with the fix that made it compile or behave correctly.

## 1. `build()` cannot start with statements

```ts
// ❌ compile error: statements before the UI root
build() {
  const x = 1;
  Column() { ... }
}

// ✅ move logic to a method or compute before the container
private label(): string { return `${this.count}`; }
build() {
  Column() { Text(this.label()) }
}
```

Also: the **root node cannot be `if` / `ForEach`**. Wrap them:

```ts
build() { Column() { if (cond) { ... } } }
```

## 2. `@Param` without a default needs `@Require`

```ts
@Require @Param task: UpsolveTask;
```

`@Event` callbacks need a default (`= () => {}`) unless marked required. Component props must not reuse common attribute names (`size`, `background`); rename to `textSize`, `bgColor`, etc.

## 3. `@Builder` value parameters are not reactive

Symptom: platform filter count changed to `1/4` but all pills stayed highlighted. Root cause: `@Builder platformPill(code, label, enabled)` received `enabled` **by value**, and `ForEach` did not re-evaluate it when `@Local` changed.

Fix: for small fixed filter groups, write **explicit nodes** whose attributes read state directly:

```ts
Row({ space: 4 }) {
  Text(this.lcEnabled ? Glyph.CHECK : Glyph.HOLLOW_DOT)
  Text('LC')
    .fontColor(this.lcEnabled ? platformOnColor('LC') : CsColor.TEXT_TERTIARY)
}
.backgroundColor(this.lcEnabled ? platformColor('LC') : CsColor.SURFACE_HIGH)
.onClick(() => { this.lcEnabled = !this.lcEnabled; })
```

General rule: don't rely on `@Builder` parameters or `ForEach` item builders for state that changes; use direct `this.*` reads or re-key the list.

## 4. Names that shadow ArkUI built-ins

`enum Tabs` + `Tabs()` component caused confusion; rename the model to `TabSpec`. The same risk exists for `Column`, `Row`, `Text`, `Image`, `List`, `Grid`.

## 5. No `any`; object literals need a typed context

```ts
// ❌ arkts-no-untyped-obj-literals
JSON.stringify({ query: q, variables: { username, limit } });

// ✅ declare interfaces
interface LcVariables { username: string; limit: number; }
interface LcPayload { query: string; variables: LcVariables; }
const variables: LcVariables = { username: user, limit: 20 };
const payload: LcPayload = { query: q, variables };
JSON.stringify(payload);
```

Empty fallback constants must include **every required field** — adding a field to an interface breaks all mock objects; update `EMPTY_*` constants and test fixtures.

## 6. Dynamic JSON keys are painful

`Record<string, T>` / index signatures / `obj[key]` are restricted. Strategies used:

- declare interfaces with the exact fields you need (`data`, `result`, `recentAcSubmissionList`);
- when a map is needed (e.g. AtCoder difficulty per problem), avoid keyed JSON and use a deterministic fallback (problem-letter → difficulty), documenting the trade-off as a deviation;
- convert `Map` only from explicit arrays, not from arbitrary object keys.

`JSON.parse` accepts a cast at the boundary: `const parsed = JSON.parse(raw) as LfResponse;` then validate arrays with `Array.isArray`.

## 7. `http` headers and options

`header` is `Object`, not a typed map. Build two typed literals instead of mutating a `Record`:

```ts
const options: http.HttpRequestOptions = {
  method: http.RequestMethod.GET,
  header: { 'Accept': 'application/json' },
  connectTimeout: 10000,
  readTimeout: 15000,
  expectDataType: http.HttpDataType.STRING
};
if (cookie.length > 0) {
  options.header = { 'Accept': 'application/json', 'Cookie': cookie };
}
```

Always `client.destroy()` in `finally`. Use `response.result as string` only with `expectDataType: STRING`.

## 8. Promise executor typing

`new Promise<void>((resolve) => ...)` can fail type-checking. Use an explicitly typed resolver:

```ts
private static delay(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => {
    setTimeout(() => { resolve(); }, ms);
  });
}
```

## 9. Number / date pitfalls

- Prefer `Number.isNaN(x)` over global `isNaN`.
- `epochSecond * 1000` before `new Date(...)`.
- Persist dates as `YYYY-MM-DD` keys; compare strings for day ranges.
- Keep `local_day` derived from the submission epoch, not the sync time, except when the source omits time (document it).

## 10. State and async

`@Local` fields mutated after `await` do re-render, but **private fields do not**. Any field assigned in `bootstrap()` and read by the UI must be `@Local`.

## 11. RDB

- Idempotent init: `CREATE TABLE IF NOT EXISTS` + `store.version`; bump `VERSION` and append statements.
- `querySql` results must be closed; iterate with `goToNextRow()` and read columns by name.
- Use `ON_CONFLICT_IGNORE` for idempotent sync writes, `ON_CONFLICT_REPLACE` for settings/check-in.
- Count distinct problems (`COUNT(DISTINCT problem_key)`) when computing "AC 题数".

## 12. Build environment

- Run hvigor with `DEVECO_SDK_HOME` set and the bundled Node; otherwise hvigor may pick the wrong SDK.
- Windows sandboxes can block writes to `.hvigor`, `entry/.test`, `.git`; run the build/test with full workspace access or from DevEco's terminal.
- DevEco launch error `10104001 ... com.example.project` = stale `.idea/.deveco/project.cache.json`; set `BUNDLE_NAME` to the real bundle id.
- The generated HAP is `entry-default-unsigned.hap`; signing needs a certificate + profile (a hard blocker for install/upload).

## 13. WebView login

- `webview.WebviewController` + `Web({ src, controller })`.
- Capture cookies with `webview.WebCookieManager.fetchCookie(url)` after the user logs in; save per platform.
- Never claim login works without a device test; cookie domains and 403 behaviour vary per platform.

## 14. HDC interaction

- Tap is `uitest uiInput click x y`, **not** `tap`.
- Screenshot: `shell snapshot_display -f /data/local/tmp/x.jpeg` then `file recv`.
- Coordinates are physical pixels; derive them from a real screenshot (e.g. 1008×2232), not from the preview.
- `aa force-stop <bundle>` + `aa start -a EntryAbility -b <bundle>` verifies persistence.
- `hilog -x | Select-String 'CS-DB|CS-SYNC'` for logs.
