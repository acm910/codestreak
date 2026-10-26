import { MapperResult, SyncSubmission } from '../model/SyncModels';
import { DateUtil } from '../utils/DateUtil';
import { DatabaseHelper } from './db/DatabaseHelper';
import { AtCoderAdapter } from './remote/AtCoderAdapter';
import { AtCoderMapper } from './remote/AtCoderMapper';
import { CodeforcesAdapter } from './remote/CodeforcesAdapter';

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
  static readonly LAST_SYNC_KEY: string = 'last_sync_at';

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

  static async loadHandle(): Promise<string> {
    return DatabaseHelper.loadSetting(SyncService.CF_HANDLE_KEY);
  }

  static async saveHandle(handle: string): Promise<void> {
    await DatabaseHelper.saveSetting(SyncService.CF_HANDLE_KEY, handle.trim());
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
