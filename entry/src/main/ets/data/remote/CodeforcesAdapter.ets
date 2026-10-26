import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SyncPolicy } from '../../domain/SyncPolicy';
import { MapperResult } from '../../model/SyncModels';
import { CodeforcesMapper } from './CodeforcesMapper';

const DOMAIN: number = 0x0002;
const TAG: string = 'CS-SYNC';
const BASE_URL: string = 'https://codeforces.com/api';

/**
 * Codeforces 官方 API 适配器（docs/04-技术设计/07 §6.1）
 * 只读公开数据、匿名访问；请求间隔受 SyncPolicy 限制，失败按退避策略处理。
 */
export class CodeforcesAdapter {
  private static lastCallAt: number = 0;
  private static consecutiveFailures: number = 0;

  private static delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private static async get(url: string): Promise<string> {
    const wait: number = SyncPolicy.waitMs(CodeforcesAdapter.lastCallAt, Date.now());
    if (wait > 0) {
      await CodeforcesAdapter.delay(wait);
    }
    CodeforcesAdapter.lastCallAt = Date.now();

    const client: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await client.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Accept': 'application/json' },
        connectTimeout: 10000,
        readTimeout: 10000,
        expectDataType: http.HttpDataType.STRING
      });
      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}`);
      }
      return response.result as string;
    } finally {
      client.destroy();
    }
  }

  /** 拉取最近提交；失败返回 ok=false 与可读原因 */
  static async fetchUserStatus(handle: string, count: number): Promise<MapperResult> {
    const trimmed: string = handle.trim();
    if (trimmed.length === 0) {
      return { ok: false, message: '请先绑定 Codeforces 账号', submissions: [] };
    }
    if (SyncPolicy.shouldDegrade(CodeforcesAdapter.consecutiveFailures)) {
      return { ok: false, message: '该平台已降级为手动模式，请稍后重试', submissions: [] };
    }
    const url: string = `${BASE_URL}/user.status?handle=${encodeURIComponent(trimmed)}&from=1&count=${count}`;
    try {
      const body: string = await CodeforcesAdapter.get(url);
      CodeforcesAdapter.consecutiveFailures = 0;
      return CodeforcesMapper.mapStatus(body);
    } catch (err) {
      CodeforcesAdapter.consecutiveFailures = CodeforcesAdapter.consecutiveFailures + 1;
      const message: string = `网络请求失败：${JSON.stringify(err)}`;
      hilog.warn(DOMAIN, TAG, 'cf sync failed, failures=%{public}d', CodeforcesAdapter.consecutiveFailures);
      return { ok: false, message: message, submissions: [] };
    }
  }

  /** 拉取用户 rating（失败返回 0） */
  static async fetchUserRating(handle: string): Promise<number> {
    const trimmed: string = handle.trim();
    if (trimmed.length === 0) {
      return 0;
    }
    try {
      const body: string = await CodeforcesAdapter.get(
        `${BASE_URL}/user.info?handles=${encodeURIComponent(trimmed)}&checkHistoricHandles=false`
      );
      return CodeforcesMapper.mapUserRating(body);
    } catch (err) {
      return 0;
    }
  }

  /** 当前连续失败次数（调试用） */
  static failureCount(): number {
    return CodeforcesAdapter.consecutiveFailures;
  }
}
