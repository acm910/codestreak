import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ContestItem } from '../../model/Entities';
import { PlatformContestMapper } from './PlatformContestMapper';

const DOMAIN: number = 0x0009;
const TAG: string = 'CS-CONTEST-PLATFORM';
const CF_URL: string = 'https://codeforces.com/api/contest.list?gym=false';
const AC_URL: string = 'https://kenkoooo.com/atcoder/resources/contests.json';

/**
 * 平台赛程源（CF 官方 API / AtCoder Problems）
 * 只读公开数据、失败返回空数组，页面按空态处理。
 */
export class PlatformContestAdapter {
  private static lastCallAt: number = 0;

  private static delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private static async get(url: string): Promise<string> {
    const elapsed: number = Date.now() - PlatformContestAdapter.lastCallAt;
    if (PlatformContestAdapter.lastCallAt > 0 && elapsed < 1500) {
      await PlatformContestAdapter.delay(1500 - elapsed);
    }
    PlatformContestAdapter.lastCallAt = Date.now();
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

  static async fetchCodeforces(limit: number): Promise<ContestItem[]> {
    try {
      const body: string = await PlatformContestAdapter.get(CF_URL);
      return PlatformContestMapper.mapCodeforces(body, Math.floor(Date.now() / 1000), limit);
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'cf contest fetch failed');
      return [];
    }
  }

  static async fetchAtCoder(limit: number): Promise<ContestItem[]> {
    try {
      const body: string = await PlatformContestAdapter.get(AC_URL);
      return PlatformContestMapper.mapAtCoder(body, Math.floor(Date.now() / 1000), limit);
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'atcoder contest fetch failed');
      return [];
    }
  }
}
