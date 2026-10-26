import { SyncSubmission, MapperResult } from '../model/SyncModels';
import { DateUtil } from '../utils/DateUtil';
import { DatabaseHelper } from './db/DatabaseHelper';
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
 * 拉取 → 幂等落库 → 当日 AC 聚合 → 记录 sync_job。
 */
export class SyncService {
  /** app_setting 中的 Codeforces handle 键名 */
  static readonly CF_HANDLE_KEY: string = 'cf_handle';

  static async syncCodeforces(handle: string): Promise<SyncOutcome> {
    const startedAt: number = Date.now();
    const result: MapperResult = await CodeforcesAdapter.fetchUserStatus(handle, 100);
    if (!result.ok) {
      await DatabaseHelper.logSyncJob('CF', 'failed', 0, 0, result.message, startedAt);
      const failed: SyncOutcome = {
        ok: false, message: result.message, fetched: 0, inserted: 0, dailyAc: 0
      };
      return failed;
    }
    const submissions: SyncSubmission[] = result.submissions;
    const inserted: number = await DatabaseHelper.upsertSubmissions(submissions);
    const dailyAc: number = await DatabaseHelper.countDailyAc(DateUtil.todayKey());
    await DatabaseHelper.logSyncJob('CF', 'success', submissions.length, inserted, '', startedAt);
    const outcome: SyncOutcome = {
      ok: true,
      message: `同步完成：拉取 ${submissions.length} 条，新增 ${inserted} 条，今日 AC ${dailyAc} 题`,
      fetched: submissions.length,
      inserted: inserted,
      dailyAc: dailyAc
    };
    return outcome;
  }

  static async loadHandle(): Promise<string> {
    return DatabaseHelper.loadSetting(SyncService.CF_HANDLE_KEY);
  }

  static async saveHandle(handle: string): Promise<void> {
    await DatabaseHelper.saveSetting(SyncService.CF_HANDLE_KEY, handle.trim());
  }
}
