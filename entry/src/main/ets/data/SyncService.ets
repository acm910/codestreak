import { MapperResult, SyncSubmission } from '../model/SyncModels';
import { DateUtil } from '../utils/DateUtil';
import { RetryEntry, RetryQueue } from '../domain/RetryQueue';
import { DatabaseHelper } from './db/DatabaseHelper';
import { AtCoderAdapter } from './remote/AtCoderAdapter';
import { AtCoderMapper } from './remote/AtCoderMapper';
import { CodeforcesAdapter } from './remote/CodeforcesAdapter';
import { LeetCodeAdapter } from './remote/LeetCodeAdapter';
import { LuoguAdapter } from './remote/LuoguAdapter';

/** 一次同步的结果，供 UI 提示与埋点 */
export interface SyncOutcome {
  ok: boolean;
  message: string;
  fetched: number;
  inserted: number;
  dailyAc: number;
}

/**
 * 同步编排（docs/04-技术设计/04 §同步流程）
 * 拉取 → 幂等落库 → 当日 AC 聚合 → 记录 sync_job → 更新上次同步时间。
 */
export class SyncService {
  static readonly CF_HANDLE_KEY: string = 'cf_handle';
  static readonly AC_HANDLE_KEY: string = 'ac_handle';
  static readonly AC_CURSOR_KEY: string = 'ac_cursor';
  static readonly LG_UID_KEY: string = 'luogu_uid';
  static readonly LC_HANDLE_KEY: string = 'lc_handle';
  static readonly LAST_SYNC_KEY: string = 'last_sync_at';
  static readonly RETRY_KEY: string = 'sync_retry';

  private static async finish(status: string, fetched: number, inserted: number,
    dailyAc: number, startedAt: number): Promise<SyncOutcome> {
    await DatabaseHelper.saveSetting(
      SyncService.LAST_SYNC_KEY, `今天 ${DateUtil.hhmm(new Date())}`
    );
    const outcome: SyncOutcome = {
      ok: status === 'success',
      message: '',
      fetched: fetched,
      inserted: inserted,
      dailyAc: dailyAc
    };
    return outcome;
  }

  static async syncCodeforces(handle: string): Promise<SyncOutcome> {
    const startedAt: number = Date.now();
    const result: MapperResult = await CodeforcesAdapter.fetchUserStatus(handle, 100);
    if (!result.ok) {
      await DatabaseHelper.logSyncJob('CF', 'failed', 0, 0, result.message, startedAt);
      const failed: SyncOutcome = { ok: false, message: result.message, fetched: 0, inserted: 0, dailyAc: 0 };
      return failed;
    }
    const submissions: SyncSubmission[] = result.submissions;
    const inserted: number = await DatabaseHelper.upsertSubmissions(submissions);
    const dailyAc: number = await DatabaseHelper.countDailyAc(DateUtil.todayKey());
    await DatabaseHelper.logSyncJob('CF', 'success', submissions.length, inserted, '', startedAt);
    const outcome: SyncOutcome = await SyncService.finish('success', submissions.length, inserted, dailyAc, startedAt);
    outcome.message = `CF：拉取 ${submissions.length} 条，新增 ${inserted} 条`;
    return outcome;
  }

  static async syncAtCoder(handle: string): Promise<SyncOutcome> {
    const startedAt: number = Date.now();
    const cursorText: string = await DatabaseHelper.loadSetting(SyncService.AC_CURSOR_KEY);
    const cursor: number = cursorText.length === 0 ? 0 : Number(cursorText);
    const fromSecond: number = Number.isNaN(cursor) ? 0 : cursor;

    const result: MapperResult = await AtCoderAdapter.fetchSubmissions(handle, fromSecond);
    if (!result.ok) {
      await DatabaseHelper.logSyncJob('AC', 'failed', 0, 0, result.message, startedAt);
      const failed: SyncOutcome = { ok: false, message: result.message, fetched: 0, inserted: 0, dailyAc: 0 };
      return failed;
    }
    const submissions: SyncSubmission[] = result.submissions;
    const inserted: number = await DatabaseHelper.upsertSubmissions(submissions);
    const maxEpoch: number = AtCoderMapper.maxEpochSecond(submissions);
    const nextCursor: number = maxEpoch > fromSecond ? maxEpoch : (fromSecond > 0 ? fromSecond : Math.floor(Date.now() / 1000));
    await DatabaseHelper.saveSetting(SyncService.AC_CURSOR_KEY, `${nextCursor}`);
    const dailyAc: number = await DatabaseHelper.countDailyAc(DateUtil.todayKey());
    await DatabaseHelper.logSyncJob('AC', 'success', submissions.length, inserted, '', startedAt);
    const outcome: SyncOutcome = await SyncService.finish('success', submissions.length, inserted, dailyAc, startedAt);
    outcome.message = `AtCoder：拉取 ${submissions.length} 条，新增 ${inserted} 条`;
    return outcome;
  }

  static async syncLuogu(uid: string): Promise<SyncOutcome> {
    const startedAt: number = Date.now();
    const collected: SyncSubmission[] = [];
    let failureMessage: string = '';
    for (let page = 1; page <= 2; page++) {
      const result: MapperResult = await LuoguAdapter.fetchRecords(uid, page);
      if (!result.ok) {
        failureMessage = result.message;
        break;
      }
      for (const item of result.submissions) {
        collected.push(item);
      }
      if (result.submissions.length === 0) {
        break;
      }
    }
    if (failureMessage.length > 0 && collected.length === 0) {
      await DatabaseHelper.logSyncJob('LG', 'failed', 0, 0, failureMessage, startedAt);
      const failed: SyncOutcome = { ok: false, message: failureMessage, fetched: 0, inserted: 0, dailyAc: 0 };
      return failed;
    }
    const inserted: number = await DatabaseHelper.upsertSubmissions(collected);
    const dailyAc: number = await DatabaseHelper.countDailyAc(DateUtil.todayKey());
    await DatabaseHelper.logSyncJob('LG', 'success', collected.length, inserted, failureMessage, startedAt);
    const outcome: SyncOutcome = await SyncService.finish('success', collected.length, inserted, dailyAc, startedAt);
    outcome.message = `洛谷：拉取 ${collected.length} 条，新增 ${inserted} 条`;
    return outcome;
  }

  static async syncLeetCode(handle: string): Promise<SyncOutcome> {
    const startedAt: number = Date.now();
    const result: MapperResult = await LeetCodeAdapter.fetchRecentAc(handle);
    if (!result.ok) {
      await DatabaseHelper.logSyncJob('LC', 'failed', 0, 0, result.message, startedAt);
      const failed: SyncOutcome = { ok: false, message: result.message, fetched: 0, inserted: 0, dailyAc: 0 };
      return failed;
    }
    const submissions: SyncSubmission[] = result.submissions;
    const inserted: number = await DatabaseHelper.upsertSubmissions(submissions);
    const dailyAc: number = await DatabaseHelper.countDailyAc(DateUtil.todayKey());
    await DatabaseHelper.logSyncJob('LC', 'success', submissions.length, inserted, '', startedAt);
    const outcome: SyncOutcome = await SyncService.finish('success', submissions.length, inserted, dailyAc, startedAt);
    outcome.message = `LeetCode：拉取 ${submissions.length} 条，新增 ${inserted} 条`;
    return outcome;
  }

  static async loadHandle(): Promise<string> {
    return DatabaseHelper.loadSetting(SyncService.CF_HANDLE_KEY);
  }
  static async saveHandle(handle: string): Promise<void> {
    await DatabaseHelper.saveSetting(SyncService.CF_HANDLE_KEY, handle.trim());
  }

  /** 失败后登记一次重试（1 分钟后；后续按 5/15 分钟退避） */
  static async scheduleRetry(platform: string, target: string): Promise<void> {
    const entry: RetryEntry | null = RetryQueue.afterFailure(platform, target, 0, Date.now());
    if (entry !== null) {
      await DatabaseHelper.saveSetting(SyncService.RETRY_KEY, RetryQueue.encode(entry));
    }
  }

  static async clearRetry(): Promise<void> {
    await DatabaseHelper.saveSetting(SyncService.RETRY_KEY, '');
  }

  /** 启动时消费到期重试；返回可展示的提示（无动作返回空串） */
  static async retryIfDue(): Promise<string> {
    const raw: string = await DatabaseHelper.loadSetting(SyncService.RETRY_KEY);
    const entry: RetryEntry | null = RetryQueue.decode(raw);
    if (entry === null) {
      if (raw.length > 0) {
        await SyncService.clearRetry();
      }
      return '';
    }
    if (!RetryQueue.isDue(entry, Date.now())) {
      return '';
    }
    let outcome: SyncOutcome = { ok: false, message: '', fetched: 0, inserted: 0, dailyAc: 0 };
    if (entry.platform === 'CF') {
      outcome = await SyncService.syncCodeforces(entry.target);
    } else if (entry.platform === 'AC') {
      outcome = await SyncService.syncAtCoder(entry.target);
    } else if (entry.platform === 'LG') {
      outcome = await SyncService.syncLuogu(entry.target);
    } else if (entry.platform === 'LC') {
      outcome = await SyncService.syncLeetCode(entry.target);
    } else {
      await SyncService.clearRetry();
      return '';
    }
    if (outcome.ok) {
      await SyncService.clearRetry();
      return `自动重试成功：${outcome.message}`;
    }
    const next: RetryEntry | null = RetryQueue.afterFailure(entry.platform, entry.target, entry.attempt, Date.now());
    if (next === null) {
      await SyncService.clearRetry();
      return '自动重试 3 次仍失败，已降级为手动模式';
    }
    await DatabaseHelper.saveSetting(SyncService.RETRY_KEY, RetryQueue.encode(next));
    return '';
  }

  static async loadLuoguUid(): Promise<string> {
    return DatabaseHelper.loadSetting(SyncService.LG_UID_KEY);
  }

  static async loadLeetCodeHandle(): Promise<string> {
    return DatabaseHelper.loadSetting(SyncService.LC_HANDLE_KEY);
  }

  static async saveLeetCodeHandle(handle: string): Promise<void> {
    await DatabaseHelper.saveSetting(SyncService.LC_HANDLE_KEY, handle.trim());
  }
  static async saveLuoguUid(uid: string): Promise<void> {
    await DatabaseHelper.saveSetting(SyncService.LG_UID_KEY, uid.trim());
  }

  static async loadAtCoderHandle(): Promise<string> {
    return DatabaseHelper.loadSetting(SyncService.AC_HANDLE_KEY);
  }

  static async saveAtCoderHandle(handle: string): Promise<void> {
    await DatabaseHelper.saveSetting(SyncService.AC_HANDLE_KEY, handle.trim());
  }

  /** 上次同步展示文案（如「今天 21:35」），未同步过返回空串 */
  static async loadLastSync(): Promise<string> {
    return DatabaseHelper.loadSetting(SyncService.LAST_SYNC_KEY);
  }
}
