import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ContestFeedResult } from '../../model/ContestFeed';
import { CpcfinderMapper } from './CpcfinderMapper';

const DOMAIN: number = 0x0004;
const TAG: string = 'CS-CONTEST-FEED';
const FEED_URL: string = 'https://cpcfinder.com/api/contest';

/**
 * CPC Finder 赛事源适配器（ICPC / CCPC 赛程）
 * 公开 JSON、无需鉴权；只读，1 秒节流，失败不影响本地种子赛事。
 */
export class CpcfinderAdapter {
  private static lastCallAt: number = 0;
  private static failures: number = 0;

  private static delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private static async get(): Promise<string> {
    const now: number = Date.now();
    if (CpcfinderAdapter.lastCallAt > 0 && now - CpcfinderAdapter.lastCallAt < 1000) {
      await CpcfinderAdapter.delay(1000 - (now - CpcfinderAdapter.lastCallAt));
    }
    CpcfinderAdapter.lastCallAt = Date.now();

    const client: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await client.request(FEED_URL, {
        method: http.RequestMethod.GET,
        header: { 'Accept': 'application/json' },
        connectTimeout: 8000,
        readTimeout: 12000,
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

  static async fetchContests(): Promise<ContestFeedResult> {
    if (CpcfinderAdapter.failures >= 3) {
      return { ok: false, message: '赛事源暂不可用，已展示本地赛程', items: [] };
    }
    try {
      const body: string = await CpcfinderAdapter.get();
      CpcfinderAdapter.failures = 0;
      return CpcfinderMapper.mapContests(body);
    } catch (err) {
      CpcfinderAdapter.failures = CpcfinderAdapter.failures + 1;
      hilog.warn(DOMAIN, TAG, 'contest feed failed, failures=%{public}d', CpcfinderAdapter.failures);
      return { ok: false, message: '赛事源请求失败，已展示本地赛程', items: [] };
    }
  }
}
