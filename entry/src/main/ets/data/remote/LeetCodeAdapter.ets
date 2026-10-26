import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { MapperResult } from '../../model/SyncModels';
import { CredentialStore } from '../CredentialStore';
import { LC_RECENT_QUERY, LeetCodeMapper } from './LeetCodeMapper';

const DOMAIN: number = 0x0008;
const TAG: string = 'CS-SYNC-LC';
const GRAPHQL_URL: string = 'https://leetcode.cn/graphql/';
/** 单次上限约 20 条（社区一致） */
const LIMIT: number = 20;

/** GraphQL 请求体 */
interface LcVariables {
  username: string;
  limit: number;
}

interface LcPayload {
  query: string;
  variables: LcVariables;
}

/**
 * LeetCode 中国站适配器（GraphQL）
 * - 需要登录态：Cookie（LEETCODE_SESSION + csrftoken）
 * - 本版从设置项 lc_cookie 读取，若缺失则返回“需要登录”（DEV-15，后续改为 WebView 授权）
 */
export class LeetCodeAdapter {
  private static lastCallAt: number = 0;
  private static failures: number = 0;

  private static delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private static csrfOf(cookie: string): string {
    const parts: string[] = cookie.split(';');
    for (const part of parts) {
      const token: string = part.trim();
      if (token.startsWith('csrftoken=')) {
        return token.substring('csrftoken='.length);
      }
    }
    return '';
  }

  private static async post(payload: string, cookie: string): Promise<string> {
    const elapsed: number = Date.now() - LeetCodeAdapter.lastCallAt;
    if (LeetCodeAdapter.lastCallAt > 0 && elapsed < 1000) {
      await LeetCodeAdapter.delay(1000 - elapsed);
    }
    LeetCodeAdapter.lastCallAt = Date.now();

    const options: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Referer': 'https://leetcode.cn/'
      },
      extraData: payload,
      connectTimeout: 10000,
      readTimeout: 12000,
      expectDataType: http.HttpDataType.STRING
    };
    if (cookie.length > 0) {
      const csrf: string = LeetCodeAdapter.csrfOf(cookie);
      options.header = {
        'Content-Type': 'application/json',
        'Referer': 'https://leetcode.cn/',
        'Cookie': cookie,
        'x-csrftoken': csrf
      };
    }
    const client: http.HttpRequest = http.createHttp();
    try {
      const response: http.HttpResponse = await client.request(GRAPHQL_URL, options);
      if (response.responseCode === 401 || response.responseCode === 403) {
        throw new Error('需要登录 LeetCode 账号');
      }
      if (response.responseCode === 429) {
        throw new Error('LeetCode 限流，请稍后再试');
      }
      if (response.responseCode !== 200) {
        throw new Error(`HTTP ${response.responseCode}`);
      }
      return response.result as string;
    } finally {
      client.destroy();
    }
  }

  static async fetchRecentAc(username: string): Promise<MapperResult> {
    const trimmed: string = username.trim();
    if (trimmed.length === 0) {
      return { ok: false, message: '请先绑定 LeetCode 账号', submissions: [] };
    }
    if (LeetCodeAdapter.failures >= 3) {
      return { ok: false, message: 'LeetCode 已降级为手动模式，请稍后重试', submissions: [] };
    }
    const cookie: string = await CredentialStore.loadCookie('LC');
    if (cookie.length === 0) {
      return { ok: false, message: 'LeetCode 需要登录：请在绑定弹层点「登录获取授权」', submissions: [] };
    }
    const variables: LcVariables = { username: trimmed, limit: LIMIT };
    const payload: LcPayload = { query: LC_RECENT_QUERY, variables: variables };
    const bodyText: string = JSON.stringify(payload);
    try {
      const body: string = await LeetCodeAdapter.post(bodyText, cookie);
      LeetCodeAdapter.failures = 0;
      return LeetCodeMapper.mapRecentAc(body);
    } catch (err) {
      LeetCodeAdapter.failures = LeetCodeAdapter.failures + 1;
      hilog.warn(DOMAIN, TAG, 'leetcode sync failed, failures=%{public}d', LeetCodeAdapter.failures);
      return { ok: false, message: `LeetCode 请求失败：${String(err)}`, submissions: [] };
    }
  }

  static failureCount(): number {
    return LeetCodeAdapter.failures;
  }
}
