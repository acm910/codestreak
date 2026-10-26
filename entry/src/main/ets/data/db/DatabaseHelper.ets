import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DateUtil } from '../../utils/DateUtil';
import { DbSchema } from './DbSchema';

const DOMAIN: number = 0x0001;
const TAG: string = 'CS-DB';

/** 当日打卡记录（对应 check_in 表） */
export interface CheckInRecord {
  date: string;
  goal: number;
  targetProgress: number;
  dailyAcCount: number;
  status: string;
}

/** 用户聚合记录（对应 user 表） */
export interface UserRecord {
  streakCurrent: number;
  streakLongest: number;
  totalAc: number;
  totalDays: number;
  repairCards: number;
}

/**
 * 本地库入口：单例 + 幂等初始化。
 * 只在 UI 线程调用，所有方法内部吞掉异常并记录日志，保证数据库故障不阻塞页面。
 */
export class DatabaseHelper {
  private static store: relationalStore.RdbStore | null = null;
  private static initializing: Promise<void> | null = null;

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (DatabaseHelper.store !== null) {
      return;
    }
    if (DatabaseHelper.initializing !== null) {
      await DatabaseHelper.initializing;
      return;
    }
    DatabaseHelper.initializing = DatabaseHelper.doInit(context);
    try {
      await DatabaseHelper.initializing;
    } finally {
      DatabaseHelper.initializing = null;
    }
  }

  static isReady(): boolean {
    return DatabaseHelper.store !== null;
  }

  private static async doInit(context: common.UIAbilityContext): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DbSchema.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    const store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, config);
    for (const sql of DbSchema.TABLES) {
      await store.executeSql(sql);
    }
    if (store.version < DbSchema.VERSION) {
      store.version = DbSchema.VERSION;
    }
    DatabaseHelper.store = store;
    await DatabaseHelper.seedIfEmpty(store);
    hilog.info(DOMAIN, TAG, 'database ready, version=%{public}d', store.version);
  }

  private static async seedIfEmpty(store: relationalStore.RdbStore): Promise<void> {
    const resultSet: relationalStore.ResultSet = await store.querySql('SELECT COUNT(1) AS c FROM user');
    let count: number = 0;
    if (resultSet.goToFirstRow()) {
      count = resultSet.getLong(resultSet.getColumnIndex('c'));
    }
    resultSet.close();
    if (count > 0) {
      return;
    }

    const now: number = Date.now();
    const user: relationalStore.ValuesBucket = {
      id: 1,
      nickname: 'AlgoMaster_Lin',
      streak_current: 28,
      streak_longest: 64,
      total_ac: 384,
      total_days: 152,
      repair_cards: 2,
      updated_at: now
    };
    await store.insert('user', user);

    const checkIn: relationalStore.ValuesBucket = {
      checkin_date: DateUtil.todayKey(),
      goal: 2,
      target_progress: 1,
      daily_ac_count: 3,
      status: 'pending',
      source: 'seed',
      updated_at: now
    };
    await store.insert('check_in', checkIn);

    const problems: relationalStore.ValuesBucket[] = [
      {
        id: 'p-lc-15', platform: 'LC', code: 'LC-15', title: '三数之和 (3Sum)',
        title_en: '3Sum', difficulty_norm: 3.0, native_label: 'Medium',
        status: 'solved', source_text: '', updated_at: now
      },
      {
        id: 'p-cf-1352c', platform: 'CF', code: 'CF-1352C', title: 'K-th Not Divisible by n',
        title_en: 'K-th Not Divisible by n', difficulty_norm: 2.0, native_label: '(1200)',
        status: 'doing', source_text: 'Round #640 (Div. 4)', updated_at: now
      },
      {
        id: 'p-lg-p3372', platform: 'LG', code: 'LG-P3372', title: '【模板】线段树 1',
        title_en: 'Segment Tree 1', difficulty_norm: 3.0, native_label: '普及+/提高',
        status: 'todo', source_text: '', updated_at: now
      }
    ];
    for (const item of problems) {
      await store.insert('problem', item);
    }
    hilog.info(DOMAIN, TAG, 'seed data inserted');
  }

  static async loadCheckIn(date: string): Promise<CheckInRecord | null> {
    const store: relationalStore.RdbStore | null = DatabaseHelper.store;
    if (store === null) {
      return null;
    }
    try {
      const resultSet: relationalStore.ResultSet = await store.querySql(
        'SELECT goal, target_progress, daily_ac_count, status FROM check_in WHERE checkin_date = ?', [date]
      );
      let record: CheckInRecord | null = null;
      if (resultSet.goToFirstRow()) {
        record = {
          date: date,
          goal: resultSet.getLong(resultSet.getColumnIndex('goal')),
          targetProgress: resultSet.getLong(resultSet.getColumnIndex('target_progress')),
          dailyAcCount: resultSet.getLong(resultSet.getColumnIndex('daily_ac_count')),
          status: resultSet.getString(resultSet.getColumnIndex('status'))
        };
      }
      resultSet.close();
      return record;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'loadCheckIn failed: %{public}s', JSON.stringify(err));
      return null;
    }
  }

  static async loadUser(): Promise<UserRecord | null> {
    const store: relationalStore.RdbStore | null = DatabaseHelper.store;
    if (store === null) {
      return null;
    }
    try {
      const resultSet: relationalStore.ResultSet = await store.querySql(
        'SELECT streak_current, streak_longest, total_ac, total_days, repair_cards FROM user WHERE id = 1'
      );
      let record: UserRecord | null = null;
      if (resultSet.goToFirstRow()) {
        record = {
          streakCurrent: resultSet.getLong(resultSet.getColumnIndex('streak_current')),
          streakLongest: resultSet.getLong(resultSet.getColumnIndex('streak_longest')),
          totalAc: resultSet.getLong(resultSet.getColumnIndex('total_ac')),
          totalDays: resultSet.getLong(resultSet.getColumnIndex('total_days')),
          repairCards: resultSet.getLong(resultSet.getColumnIndex('repair_cards'))
        };
      }
      resultSet.close();
      return record;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'loadUser failed: %{public}s', JSON.stringify(err));
      return null;
    }
  }

  static async saveCheckIn(record: CheckInRecord, streakCurrent: number, streakLongest: number): Promise<void> {
    const store: relationalStore.RdbStore | null = DatabaseHelper.store;
    if (store === null) {
      return;
    }
    const now: number = Date.now();
    try {
      const checkIn: relationalStore.ValuesBucket = {
        checkin_date: record.date,
        goal: record.goal,
        target_progress: record.targetProgress,
        daily_ac_count: record.dailyAcCount,
        status: record.status,
        source: 'manual',
        updated_at: now
      };
      await store.insert('check_in', checkIn, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE);

      const user: relationalStore.ValuesBucket = {
        streak_current: streakCurrent,
        streak_longest: streakLongest,
        updated_at: now
      };
      const predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('user');
      predicates.equalTo('id', 1);
      await store.update(user, predicates);
      hilog.info(DOMAIN, TAG, 'check-in persisted: %{public}s', record.date);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'saveCheckIn failed: %{public}s', JSON.stringify(err));
    }
  }
}
