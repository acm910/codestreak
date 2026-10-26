---
name: Algorithmic Precision
colors:
  surface: '#10141a'
  surface-dim: '#10141a'
  surface-bright: '#353940'
  surface-container-lowest: '#0a0e14'
  surface-container-low: '#181c22'
  surface-container: '#1c2026'
  surface-container-high: '#262a31'
  surface-container-highest: '#31353c'
  on-surface: '#dfe2eb'
  on-surface-variant: '#d9c3ad'
  inverse-surface: '#dfe2eb'
  inverse-on-surface: '#2d3137'
  outline: '#a18d7a'
  outline-variant: '#544434'
  surface-tint: '#ffb867'
  primary: '#ffc78b'
  on-primary: '#482900'
  primary-container: '#ffa116'
  on-primary-container: '#683e00'
  inverse-primary: '#875200'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#bfd2ff'
  on-tertiary: '#002e6a'
  tertiary-container: '#94b6ff'
  on-tertiary-container: '#004496'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffddba'
  primary-fixed-dim: '#ffb867'
  on-primary-fixed: '#2b1700'
  on-primary-fixed-variant: '#673d00'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#d8e2ff'
  tertiary-fixed-dim: '#adc6ff'
  on-tertiary-fixed: '#001a42'
  on-tertiary-fixed-variant: '#004395'
  background: '#10141a'
  on-background: '#dfe2eb'
  surface-variant: '#31353c'
typography:
  headline-xl:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.03em
  headline-xl-mobile:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.03em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style
The design system positions itself as an unyielding, high-utility operational console for competitive programmers, interview candidates, and computer scientists. It rejects playful gamification in favor of purposeful momentum: disciplined, razor-sharp, and performance-driven. The interface channels the clarity of elite code editors (VS Code, Zed) fused with high-density financial terminals, creating an environment where consistency, latency-free tracking, and data integrity take precedence.

Visually, the style merges **Modern Dark Terminal Minimalist** aesthetics with subtle tactical instrumentation. Surfaces are constructed using deep, slate-tinted dark layers rather than hollow pure blacks, punctuated by razor-sharp borderlines, micro-status tags, and high-visibility algorithmic accent tones. The emotional tone evokes absolute focus, momentum, and technical mastery.

## Colors
The palette is calibrated for long sessions of intense problem-solving under low-light or workstation conditions.

- **Primary (`#FFA116` / Contest Amber):** The core heartbeat. Reserved exclusively for streak counters, active flames, target milestone callouts, and primary interaction triggers.
- **Secondary (`#10B981` / Accepted Emerald):** Represents completion, AC (Accepted) verdict states, positive submission deltas, and high-frequency heatmap cells.
- **Tertiary (`#3B82F6` / Execution Azure):** Serves analytical surfaces, platform sync indicators, Codeforces/AtCoder data integrations, and navigational tabs.
- **Neutral Base (`#0D1117` / Terminal Charcoal):** The deep canvas anchor. Elevated layers use `#161B22` (Container Base), `#21262D` (Card / Tile Elevated), and `#30363D` (Subtle Stroke). Text hierarchy spans `#F0F6FC` (Primary Text), `#8B949E` (Muted Label), and `#484F58` (Ghost Meta).
- **Semantic Verdicts:** `#EF4444` (Wrong Answer / Time Limit Exceeded) and `#F59E0B` (Runtime Warning / Partial Score).

## Typography
Typographic rhythm relies on a rigorous tri-font hierarchy:
1. **Space Grotesk** drives core numerical milestones and headline trackers, lending an engineered, structural geometry to days-solved metrics and dashboard titles.
2. **Geist** handles problem descriptions, solution notes, and body content with low cognitive friction and high cross-platform rendering precision.
3. **JetBrains Mono** powers all metadata tags, platform IDs (e.g., `LC-739`, `CF-1842C`), time complexity annotations (`O(N log N)`), and execution runtimes (`12ms`). Tabular numerals (`tnum`) must remain permanently active for streak counts and timer modules.

## Layout & Spacing
The layout adheres to an information-dense 4-column fluid mobile grid scaling to an 8-column layout on foldable devices and tablets. Outer margins sit tight at `1rem` (16px) on mobile viewports to maximize scanning breadth for problem lists and activity heatmaps.

Rhythm is maintained through an 8pt system, using a half-step `0.25rem` (4px) micro-spacing for tag clusters and meta badges. Component vertical stacking relies on `space-md` (12px) for related problem cards and `space-xl` (28px) between distinct workflow sections (e.g., Streak Hero into Heatmap Matrix into Dynamic Queue).

## Elevation & Depth
Elevation is achieved purely through layered surface values and low-contrast perimeter strokes rather than diffuse, muddy drop shadows. This avoids visual clutter and keeps rendering instantaneous.

- **Level 0 (Canvas Base):** `#0D1117` — The absolute foundation.
- **Level 1 (Section Shelves & Inactive Cards):** `#161B22` bounded by an inner hairline border (`1px solid #30363D`).
- **Level 2 (Active Problems & Focused Modals):** `#21262D` bounded by `1px solid rgba(255, 161, 22, 0.25)` or `#30363D` with an optional 12px ambient neon rim (`rgba(255, 161, 22, 0.08)`) reserved strictly for the primary Active Streak HUD.
- **Heatmap Tiers:** Multi-tiered emerald luminescence mapped across submission volume:
  - `0 solves`: `#161B22`
  - `1-2 solves`: `#0E4429`
  - `3-5 solves`: `#006D32`
  - `6-8 solves`: `#26A641`
  - `9+ solves`: `#39D353` with a subtle `box-shadow: 0 0 6px rgba(57, 211, 83, 0.35)`

## Shapes
A disciplined "Soft" curvature philosophy is applied across the entire system. Base interactive elements, problem list rows, and telemetry chips adopt a sharp `0.25rem` (4px) or `0.5rem` (8px) radius. Heatmap tiles use a compact `2px` corner radius to mirror GitHub/LeetCode commit graphs. Floating action sheets and full-bleed action panels cap at `0.75rem` (12px). Pill radii are strictly prohibited except for small status badges (`label-sm`).

## Components

- **Streak Hero Display:** Top-level instrumentation tile. Houses an oversized `headline-xl` numerical day count paired with an Amber flame glyph, flanked by a 7-day rolling week sparkline and platform-specific sync pings (LeetCode, CF, Luogu, AtCoder) formatted in `label-sm`.
- **Contribution Heatmap Matrix:** Horizontally scrolling micro-tile grid representing 52 weeks or a 90-day sprint. Each square is 10×10px with 2px gaps, featuring micro-tooltips on press revealing date, solve count, and platform breakdown.
- **Cross-Platform Problem Cards:** High-density horizontal card containing:
  - Platform pill (e.g., orange outline for LeetCode, cyan for Codeforces, red for Luogu).
  - Problem identifier + title in `body-md` weight 500.
  - Difficulty badge: Easy (`#10B981`), Medium (`#F59E0B`), Hard (`#EF4444`).
  - Right-aligned quick action: "Jump & Solve" secondary icon button, triggering an external webview/deep-link, with a floating "Mark Accepted" state upon app return.
- **Buttons:**
  - *Primary Action (Check-in / Sync):* Solid `#FFA116` background, `#0D1117` text, font `label-lg` semi-bold, with tactile depressed state (`transform: translateY(1px)`).
  - *Secondary / Platform Action:* `#21262D` background, `1px solid #30363D`, `#F0F6FC` text.
- **Tags & Metadata Chips:** Monospaced `label-md` enclosed in `rgba(255,255,255,0.06)` with 1px border. No filled backgrounds that compete with the problem title.
- **Inputs & Search Queries:** Dark surface `#161B22` with a flush border `#30363D`, focusing to `1px solid #FFA116`. Monospaced search support with tag triggers (e.g., `tag:dp diff:medium`).