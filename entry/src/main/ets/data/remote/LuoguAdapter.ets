import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MapperResult } from '../../model/SyncModels';
import { CredentialStore } from '../CredentialStore';
import { LuoguMapper } from './LuoguMapper';

const DOMAIN: number = 0x0007;
const TAG: string = 'CS-SYNC-LG';
const BASE_URL: string = 'https://www.luogu.com.cn';

/**
 * 洛谷适配器（授权同步的降级实现）
 * - 公开记录接口：/record/list?user={uid}&page={n}
 * - 必需请求头：x-luogu-type / x-lentille-request: content-only
 * - 若本地存在 luogu_cookie 设置则一并携带（当前为过渡方案，后续迁入 Asset Store，见 04-08 DEV-13）
 */
export class LuoguAdapter {
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
    const elapsed: number = Date.now() - LuoguAdapter.lastCallAt;
    if (LuoguAdapter.lastCallAt > 0 && elapsed < 1500) {
      await LuoguAdapter.delay(1500 - elapsed);
    }
    LuoguAdapter.lastCallAt = Date.now();

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.GET,
      header: {
        'Accept': 'application/json',
        'x-luogu-type': 'content-only',
        'x-lentille-request': 'content-only'
      },
      connectTimeout: 10000,
      readTimeout: 12000,
      expectDataType: http.HttpDataType.STRING
    };
    if (cookie.length > 0) {
      options.header = {
        'Accept': 'application/json',
        'x-luogu-type': 'content-only',
        'x-lentille-request': 'content-only',
        'Cookie': cookie
      };
    }
    const client: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await client.request(url, options);
      if (response.responseCode === 401 || response.responseCode === 403) {
        throw new Error('需要登录才能读取洛谷记录');
      }
      if (response.responseCode === 429) {
        throw new Error('洛谷限流，请稍后再试');
      }
      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}`);
      }
      return response.result as string;
    } finally {
      client.destroy();
    }
  }

  static async fetchRecords(uid: string, page: number): Promise<MapperResult> {
    const trimmed: string = uid.trim();
    if (trimmed.length === 0) {
      return { ok: false, message: '请先绑定洛谷 UID', submissions: [] };
    }
    if (LuoguAdapter.failures >= 3) {
      return { ok: false, message: '洛谷已降级为手动模式，请稍后重试', submissions: [] };
    }
    const cookie: string = await CredentialStore.loadCookie('LG');
    if (cookie.length === 0) {
      return { ok: false, message: '洛谷需要登录：请在绑定弹层点「登录获取授权」', submissions: [] };
    }
    const url: string = `${BASE_URL}/record/list?user=${encodeURIComponent(trimmed)}&page=${page}`;
    try {
      const body: string = await LuoguAdapter.get(url, cookie);
      LuoguAdapter.failures = 0;
      return LuoguMapper.mapRecords(body);
    } catch (err) {
      LuoguAdapter.failures = LuoguAdapter.failures + 1;
      hilog.warn(DOMAIN, TAG, 'luogu sync failed, failures=%{public}d', LuoguAdapter.failures);
      return { ok: false, message: `洛谷请求失败：${String(err)}`, submissions: [] };
    }
  }

  static failureCount(): number {
    return LuoguAdapter.failures;
  }
}
