import { common, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0005;
const TAG: string = 'CS-LINK';

/**
 * 外部链接跳转（题目、榜单、报名页）
 * 使用系统 viewData，由浏览器/对应应用接管；失败返回 false，由调用方提示。
 */
export class LinkService {
  static async open(context: common.UIAbilityContext, url: string): Promise<boolean> {
    const target: string = url.trim();
    if (target.length === 0) {
      return false;
    }
    const want: Want = {
      action: 'ohos.want.action.viewData',
      uri: target
    };
    try {
      await context.startAbility(want);
      hilog.info(DOMAIN, TAG, 'open url success: %{public}s', target);
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'open url failed: %{public}s', JSON.stringify(err));
      return false;
    }
  }
}
