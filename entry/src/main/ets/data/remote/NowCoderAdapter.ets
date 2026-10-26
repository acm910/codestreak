import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MapperResult } from '../../model/SyncModels';
import { CredentialStore } from '../CredentialStore';
import { NowCoderMapper } from './NowCoderMapper';

const DOMAIN: number = 0x000A;
const TAG: string = 'CS-SYNC-NC';
const BASE_URL: string = 'https://ac.nowcoder.com/acm/contest/profile';

/**
 * 牛客适配器：登录态 + 练习页 HTML 解析。
 * 需要 Cookie（nowcoder_cookie），由内置登录页获取；缺失时直接提示登录。
 */
export class NowCoderAdapter {
  private static lastCallAt: number = 0;
  private static failures: number = 0;

  private static delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private static async get(url: string, cookie: string): Promise<string> {
    const elapsed: number = Date.now() - NowCoderAdapter.lastCallAt;
    if (NowCoderAdapter.lastCallAt > 0 && elapsed < 1500) {
      await NowCoderAdapter.delay(1500 - elapsed);
    }
    NowCoderAdapter.lastCallAt = Date.now();
    const client: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await client.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Accept': 'text/html,application/xhtml+xml',
          'Cookie': cookie,
          'Referer': 'https://ac.nowcoder.com/'
        },
        connectTimeout: 10000,
        readTimeout: 15000,
        expectDataType: http.HttpDataType.STRING
      });
      if (response.responseCode === 401 || response.responseCode === 403) {
        throw new Error('牛客登录态失效，请重新登录');
      }
      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}`);
      }
      return response.result as string;
    } finally {
      client.destroy();
    }
  }

  static async fetchPractice(uid: string): Promise<MapperResult> {
    const trimmed: string = uid.trim();
    if (trimmed.length === 0) {
      return { ok: false, message: '请先绑定牛客 UID', submissions: [] };
    }
    const cookie: string = await CredentialStore.loadCookie('NC');
    if (cookie.length === 0) {
      return { ok: false, message: '牛客需要登录：请在绑定弹层点「登录获取授权」', submissions: [] };
    }
    if (NowCoderAdapter.failures >= 3) {
      return { ok: false, message: '牛客已降级为手动模式，请稍后重试', submissions: [] };
    }
    const url: string = `${BASE_URL}/${encodeURIComponent(trimmed)}/practice-coding?page=1&pageSize=100&statusType=AC`;
    try {
      const body: string = await NowCoderAdapter.get(url, cookie);
      NowCoderAdapter.failures = 0;
      return NowCoderMapper.parsePracticePage(body);
    } catch (err) {
      NowCoderAdapter.failures = NowCoderAdapter.failures + 1;
      hilog.warn(DOMAIN, TAG, 'nowcoder sync failed, failures=%{public}d', NowCoderAdapter.failures);
      return { ok: false, message: `牛客请求失败：${String(err)}`, submissions: [] };
    }
  }

  static failureCount(): number {
    return NowCoderAdapter.failures;
  }
}
