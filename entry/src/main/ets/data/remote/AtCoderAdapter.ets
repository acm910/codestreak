import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MapperResult } from '../../model/SyncModels';
import { AtCoderMapper } from './AtCoderMapper';

const DOMAIN: number = 0x0003;
const TAG: string = 'CS-SYNC-AC';
const BASE_URL: string = 'https://kenkoooo.com/atcoder/atcoder-api/v3';
/** 第三方 API 要求访问间隔 ≥1 秒 */
const MIN_GAP_MS: number = 1000;

/**
 * AtCoder 适配器（第三方公开 API：kenkoooo AtCoder Problems）
 * 只读、无鉴权；单次最多返回 500 条，用 from_second 做增量。
 */
export class AtCoderAdapter {
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
    const now: number = Date.now();
    const elapsed: number = AtCoderAdapter.lastCallAt <= 0 ? MIN_GAP_MS : now - AtCoderAdapter.lastCallAt;
    if (elapsed < MIN_GAP_MS) {
      await AtCoderAdapter.delay(MIN_GAP_MS - elapsed);
    }
    AtCoderAdapter.lastCallAt = Date.now();

    const client: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await client.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Accept': 'application/json' },
        connectTimeout: 10000,
        readTimeout: 15000,
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

  /** 拉取 fromSecond 之后的提交（最多 500 条） */
  static async fetchSubmissions(user: string, fromSecond: number): Promise<MapperResult> {
    const trimmed: string = user.trim();
    if (trimmed.length === 0) {
      return { ok: false, message: '请先绑定 AtCoder 账号', submissions: [] };
    }
    if (AtCoderAdapter.consecutiveFailures >= 3) {
      return { ok: false, message: '该平台已降级为手动模式，请稍后重试', submissions: [] };
    }
    const url: string = `${BASE_URL}/user/submissions?user=${encodeURIComponent(trimmed)}&from_second=${fromSecond}`;
    try {
      const body: string = await AtCoderAdapter.get(url);
      AtCoderAdapter.consecutiveFailures = 0;
      return AtCoderMapper.mapSubmissions(body);
    } catch (err) {
      AtCoderAdapter.consecutiveFailures = AtCoderAdapter.consecutiveFailures + 1;
      hilog.warn(DOMAIN, TAG, 'atcoder sync failed, failures=%{public}d', AtCoderAdapter.consecutiveFailures);
      return { ok: false, message: `网络请求失败：${JSON.stringify(err)}`, submissions: [] };
    }
  }

  static failureCount(): number {
    return AtCoderAdapter.consecutiveFailures;
  }
}
