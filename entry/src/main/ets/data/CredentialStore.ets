import { DatabaseHelper } from '../data/db/DatabaseHelper';

/**
 * 登录凭据存取（洛谷 / 牛客 / LeetCode）
 * 当前落地：加密能力待接入 Asset Store，先按平台存 app_setting，仅本机可读（DEV-20）。
 */
export class CredentialStore {
  static cookieKey(platform: string): string {
    if (platform === 'LG') {
      return 'luogu_cookie';
    }
    if (platform === 'NC') {
      return 'nowcoder_cookie';
    }
    if (platform === 'LC') {
      return 'lc_cookie';
    }
    return '';
  }

  static async saveCookie(platform: string, cookie: string): Promise<void> {
    const key: string = CredentialStore.cookieKey(platform);
    if (key.length === 0) {
      return;
    }
    await DatabaseHelper.saveSetting(key, cookie.trim());
  }

  static async loadCookie(platform: string): Promise<string> {
    const key: string = CredentialStore.cookieKey(platform);
    if (key.length === 0) {
      return '';
    }
    return DatabaseHelper.loadSetting(key);
  }

  static async clearCookie(platform: string): Promise<void> {
    const key: string = CredentialStore.cookieKey(platform);
    if (key.length === 0) {
      return;
    }
    await DatabaseHelper.saveSetting(key, '');
  }
}
