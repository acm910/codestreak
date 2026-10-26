/** 应用级常量（来自 docs/02-设计规范 与 01-产品设计） */
export class AppConfig {
  static readonly APP_NAME: string = 'CodeStreak';
  static readonly BRAND_EYEBROW: string = 'CODESTREAK // CLI';
  /** 每日目标题数：两张目标卡各计 1 */
  static readonly DAILY_TARGET: number = 2;
  /** 热力图周数（16 周 × 7 天） */
  static readonly HEATMAP_WEEKS: number = 16;
  /** 每日提醒时间 */
  static readonly REMINDER_TIME: string = '21:30';
}

/** 四个一级 Tab 的文案与图标字符（v1.0 用字符图标，后续替换为 SymbolGlyph） */
export class TabSpec {
  static readonly TODAY: number = 0;
  static readonly MATRIX: number = 1;
  static readonly CONTEST: number = 2;
  static readonly STATS: number = 3;

  static readonly LABELS: string[] = ['今日打卡', '题单矩阵', '比赛日历', '统计榜单'];
  static readonly ICONS: string[] = ['🔥', '{}', '▤', '▥'];
  static readonly TITLES: string[] = ['Today', 'Problem Sets', 'Contests', 'Stats'];
}

/** 通用文本图标（避免引入图标字体后被平台差异影响） */
export class Glyph {
  static readonly CHECK: string = '✓';
  static readonly STAR: string = '★';
  static readonly STAR_EMPTY: string = '☆';
  static readonly PLUS: string = '＋';
  static readonly ARROW: string = '→';
  static readonly CHEVRON: string = '›';
  static readonly SYNC: string = '⟳';
  static readonly PERSON: string = '◉';
  static readonly TIMER: string = '◷';
  static readonly FLAG: string = '⚑';
  static readonly FLAME: string = '🔥';
  static readonly CODE: string = '</>';
  static readonly DOT: string = '●';
  static readonly HOLLOW_DOT: string = '○';
  static readonly CLOSE: string = '×';
  static readonly BOLT: string = '⚡';
}
