/**
 * 本地库 Schema（v2）
 * 对应 docs/04-技术设计/03-数据模型设计.md；v2 新增 submission 表以支撑同步落库与当日 AC 聚合。
 * 迁移策略：全部语句均为 IF NOT EXISTS，升级不删旧表、不改列，保证已有安装数据不丢。
 */
export class DbSchema {
  static readonly DB_NAME: string = 'codestreak.db';
  static readonly VERSION: number = 2;

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
    `CREATE TABLE IF NOT EXISTS submission (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      platform TEXT NOT NULL,
      external_id TEXT NOT NULL,
      problem_key TEXT NOT NULL,
      title TEXT NOT NULL DEFAULT '',
      difficulty_norm REAL NOT NULL DEFAULT 3.0,
      verdict TEXT NOT NULL,
      is_ac INTEGER NOT NULL DEFAULT 0,
      epoch_second INTEGER NOT NULL DEFAULT 0,
      local_day TEXT NOT NULL DEFAULT '',
      created_at INTEGER NOT NULL,
      UNIQUE(platform, external_id)
    )`,
    `CREATE TABLE IF NOT EXISTS sync_job (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      platform TEXT NOT NULL,
      status TEXT NOT NULL,
      fetched INTEGER NOT NULL DEFAULT 0,
      inserted INTEGER NOT NULL DEFAULT 0,
      message TEXT NOT NULL DEFAULT '',
      started_at INTEGER NOT NULL,
      finished_at INTEGER NOT NULL DEFAULT 0
    )`,
    `CREATE INDEX IF NOT EXISTS idx_check_in_date ON check_in(checkin_date)`,
    `CREATE INDEX IF NOT EXISTS idx_problem_platform ON problem(platform, code)`,
    `CREATE INDEX IF NOT EXISTS idx_contest_start ON contest(start_at)`,
    `CREATE INDEX IF NOT EXISTS idx_submission_day ON submission(local_day, is_ac)`,
    `CREATE INDEX IF NOT EXISTS idx_submission_problem ON submission(platform, problem_key)`
  ];
}
