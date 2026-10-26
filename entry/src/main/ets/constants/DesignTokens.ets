/**
 * 设计令牌 · 颜色 / 间距 / 圆角 / 字号
 * 权威来源：docs/02-设计规范/02-设计令牌规范.md（v1.0）
 * 约束：业务代码不得出现裸 HEX，一律引用本文件常量或 withAlpha()。
 */
export class CsColor {
  // 表面（由深到浅）
  static readonly SURFACE: string = '#10141A';
  static readonly SURFACE_LOWEST: string = '#0A0E14';
  static readonly SURFACE_LOW: string = '#181C22';
  static readonly SURFACE_CONTAINER: string = '#1C2026';
  static readonly SURFACE_HIGH: string = '#262A31';
  static readonly SURFACE_HIGHEST: string = '#31353C';
  static readonly SURFACE_BRIGHT: string = '#353940';

  // 文本
  static readonly TEXT_PRIMARY: string = '#DFE2EB';
  static readonly TEXT_SECONDARY: string = '#D9C3AD';
  static readonly TEXT_TERTIARY: string = '#A18D7A';
  static readonly TEXT_GHOST: string = '#544434';
  static readonly BORDER_SUBTLE: string = '#544434';
  static readonly BORDER_STRONG: string = '#31353C';
  static readonly SURFACE_INVERSE: string = '#DFE2EB';
  static readonly TEXT_INVERSE: string = '#2D3137';

  // 主色 · 竞赛琥珀
  static readonly PRIMARY: string = '#FFC78B';
  static readonly PRIMARY_CONTAINER: string = '#FFA116';
  static readonly PRIMARY_ON: string = '#482900';
  static readonly PRIMARY_ON_ALT: string = '#683E00';
  static readonly PRIMARY_FIXED: string = '#FFDDBA';
  static readonly PRIMARY_FIXED_DIM: string = '#FFB867';

  // 次色 · AC 翡翠
  static readonly SECONDARY: string = '#4EDEA3';
  static readonly SECONDARY_CONTAINER: string = '#00A572';
  static readonly SECONDARY_ON: string = '#00311F';
  static readonly SECONDARY_ON_SOLID: string = '#003824';
  static readonly SECONDARY_FIXED: string = '#6FFBBE';

  // 三色 · 执行天蓝
  static readonly TERTIARY: string = '#BFD2FF';
  static readonly TERTIARY_CONTAINER: string = '#94B6FF';
  static readonly TERTIARY_ON: string = '#004496';
  static readonly TERTIARY_ON_SOLID: string = '#002E6A';

  // 语义 · 错误
  static readonly ERROR: string = '#FFB4AB';
  static readonly ERROR_CONTAINER: string = '#93000A';
  static readonly ERROR_ON: string = '#FFDAD6';
  static readonly ERROR_ON_SOLID: string = '#690005';

  // 难度色阶（★1..★5）
  static readonly DIFFICULTY_1: string = '#4EDEA3';
  static readonly DIFFICULTY_2: string = '#4EDEA3';
  static readonly DIFFICULTY_3: string = '#FFA116';
  static readonly DIFFICULTY_4: string = '#FFB867';
  static readonly DIFFICULTY_5: string = '#FFB4AB';
}

/** 间距令牌（8pt 系统 + 4vp 半档） */
export class CsSpace {
  static readonly XS: number = 4;
  static readonly SM: number = 8;
  static readonly MD: number = 12;
  static readonly LG: number = 20;
  static readonly XL: number = 28;
  static readonly GUTTER: number = 16;
}

/** 圆角令牌：热力块 2 / 标签 4 / 控件 6 / 按钮与图标块 8 / 卡片 12 / 胶囊 999 */
export class CsRadius {
  static readonly XS: number = 2;
  static readonly SM: number = 4;
  static readonly MD: number = 6;
  static readonly LG: number = 8;
  static readonly XL: number = 12;
  static readonly FULL: number = 999;
}

/** 字号令牌（单位 fp） */
export class CsFont {
  static readonly H1: number = 40;
  static readonly H1_MOBILE: number = 32;
  static readonly H2: number = 28;
  static readonly H3: number = 20;
  static readonly BODY_LG: number = 16;
  static readonly BODY: number = 14;
  static readonly BODY_SM: number = 12;
  static readonly LABEL_LG: number = 14;
  static readonly LABEL: number = 12;
  static readonly LABEL_SM: number = 10;
}

/** 尺寸令牌 */
export class CsSize {
  static readonly APP_BAR: number = 64;
  static readonly TAB_BAR: number = 64;
  static readonly TOUCH_MIN: number = 44;
  static readonly HEATMAP_CELL: number = 10;
  static readonly HEATMAP_GAP: number = 2;
  static readonly WEEK_CELL: number = 28;
  static readonly ICON_SM: number = 14;
  static readonly ICON_MD: number = 18;
  static readonly ICON_LG: number = 22;
}

/** 把 #RRGGBB 叠加为带透明度的 #AARRGGBB */
export function withAlpha(hex: string, alpha: number): string {
  const a: number = Math.round(Math.min(1, Math.max(0, alpha)) * 255);
  const hexPart: string = hex.replace('#', '').toUpperCase();
  return `#${a.toString(16).padStart(2, '0').toUpperCase()}${hexPart}`;
}

/** 难度色：0.5 星粒度取较低星级颜色 */
export function difficultyColor(norm: number): string {
  if (norm < 3) {
    return CsColor.DIFFICULTY_1;
  }
  if (norm < 4) {
    return CsColor.DIFFICULTY_3;
  }
  if (norm < 5) {
    return CsColor.DIFFICULTY_4;
  }
  return CsColor.DIFFICULTY_5;
}

/** 平台主色：LC 琥珀 / CF 天蓝 / AtCoder 翡翠 / 洛谷 红（D-09 裁决） */
export function platformColor(code: string): string {
  if (code === 'LC') {
    return CsColor.PRIMARY_CONTAINER;
  }
  if (code === 'CF') {
    return CsColor.TERTIARY;
  }
  if (code === 'AC') {
    return CsColor.SECONDARY;
  }
  return CsColor.ERROR;
}

/** 平台实心徽标上的文本色（D-40：solid 必须用对应 on-solid） */
export function platformOnColor(code: string): string {
  if (code === 'LC') {
    return CsColor.PRIMARY_ON;
  }
  if (code === 'CF') {
    return CsColor.TERTIARY_ON_SOLID;
  }
  if (code === 'AC') {
    return CsColor.SECONDARY_ON_SOLID;
  }
  return CsColor.ERROR_ON_SOLID;
}
