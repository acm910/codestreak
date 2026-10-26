/**
 * 本地库 Schema（v1）
 * 对应 docs/04-技术设计/03-数据模型设计.md；当前先落 5 张核心表，
 * 其余表（problem_set / contest_registration / upsolve_* / badge 等）在接入同步时按同一迁移机制追加。
 */
export class DbSchema {
  static readonly DB_NAME: string = 'codestreak.db';
  static readonly VERSION: number = 1;

  static readonly TABLES: string[] = [
    `CREATE TABLE IF NOT EXISTS user (
      id INTEGER PRIMARY KEY,
      nickname TEXT NOT NULL,
      streak_current INTEGER NOT NULL DEFAULT 0,
      streak_longest INTEGER NOT NULL DEFAULT 0,
      total_ac INTEGER NOT NULL DEFAULT 0,
      total_days INTEGER NOT NULL DEFAULT 0,
      repair_cards INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS check_in (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      checkin_date TEXT NOT NULL UNIQUE,
      goal INTEGER NOT NULL,
      target_progress INTEGER NOT NULL,
      daily_ac_count INTEGER NOT NULL,
      status TEXT NOT NULL,
      source TEXT NOT NULL DEFAULT 'manual',
      updated_at INTEGER NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS problem (
      id TEXT PRIMARY KEY,
      platform TEXT NOT NULL,
      code TEXT NOT NULL,
      title TEXT NOT NULL,
      title_en TEXT NOT NULL DEFAULT '',
      difficulty_norm REAL NOT NULL DEFAULT 3.0,
      native_label TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL DEFAULT 'todo',
      source_text TEXT NOT NULL DEFAULT '',
      updated_at INTEGER NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS contest (
      id TEXT PRIMARY KEY,
      platform TEXT NOT NULL,
      name TEXT NOT NULL,
      start_at INTEGER NOT NULL DEFAULT 0,
      duration_minutes INTEGER NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'upcoming',
      updated_at INTEGER NOT NULL
    )`,
    `CREATE TABLE IF NOT EXISTS app_setting (
      setting_key TEXT PRIMARY KEY,
      setting_value TEXT NOT NULL,
      updated_at INTEGER NOT NULL
    )`,
    `CREATE INDEX IF NOT EXISTS idx_check_in_date ON check_in(checkin_date)`,
    `CREATE INDEX IF NOT EXISTS idx_problem_platform ON problem(platform, code)`,
    `CREATE INDEX IF NOT EXISTS idx_contest_start ON contest(start_at)`
  ];
}
