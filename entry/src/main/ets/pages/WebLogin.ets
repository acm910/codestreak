import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { CsColor, CsFont, CsRadius, CsSpace } from '../constants/DesignTokens';
import { CredentialStore } from '../data/CredentialStore';

interface LoginParams {
  platform?: string;
}

/** 登录平台配置 */
interface LoginTarget {
  platform: string;
  title: string;
  url: string;
}

function targetOf(platform: string): LoginTarget {
  if (platform === 'LG') {
    return { platform: 'LG', title: '登录洛谷', url: 'https://www.luogu.com.cn/auth/login' };
  }
  if (platform === 'NC') {
    return { platform: 'NC', title: '登录牛客', url: 'https://www.nowcoder.com/login' };
  }
  return { platform: 'LC', title: '登录 LeetCode', url: 'https://leetcode.cn/accounts/login/' };
}

function loginPlatform(): string {
  const params: LoginParams = router.getParams() as LoginParams;
  const platform: string = params === undefined || params.platform === undefined ? 'LG' : params.platform;
  return platform;
}

/**
 * 内置登录页：加载平台登录页，登录成功后抓取 Cookie 并保存。
 * 入口：连接账号弹层的「登录获取授权」按钮。
 */
@Entry
@ComponentV2
struct WebLogin {
  @Local title: string = '登录';
  @Local status: string = '请在下方完成登录，成功后会自动获取登录态';
  private target: LoginTarget = targetOf(loginPlatform());
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    this.title = this.target.title;
  }

  private async capture(): Promise<void> {
    try {
      const cookie: string = await webview.WebCookieManager.fetchCookie(this.target.url);
      if (cookie.length === 0) {
        this.status = '尚未获取到登录态，请确认已登录成功';
        return;
      }
      await CredentialStore.saveCookie(this.target.platform, cookie);
      this.status = '登录态已保存，可返回继续导入';
      setTimeout(() => {
        router.back();
      }, 600);
    } catch (err) {
      this.status = '获取登录态失败，请重试';
    }
  }

  build() {
    Column({ space: CsSpace.SM }) {
      Row({ space: CsSpace.SM }) {
        Text('‹')
          .fontSize(26)
          .fontColor(CsColor.TEXT_PRIMARY)
          .width(32)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })
        Text(this.title)
          .fontSize(CsFont.H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.TEXT_PRIMARY)
          .layoutWeight(1)
        Text('完成')
          .fontSize(CsFont.LABEL)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.PRIMARY_ON)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.PRIMARY_CONTAINER)
          .onClick(() => {
            this.capture();
          })
      }
      .width('100%')
      .padding({ left: CsSpace.SM, right: CsSpace.SM, top: CsSpace.SM, bottom: 4 })
      .alignItems(VerticalAlign.Center)

      Text(this.status)
        .fontSize(CsFont.LABEL_SM)
        .fontColor(CsColor.TEXT_TERTIARY)
        .width('100%')
        .padding({ left: CsSpace.MD, right: CsSpace.MD })

      Web({ src: this.target.url, controller: this.controller })
        .width('100%')
        .layoutWeight(1)
        .onPageEnd(() => {
          this.status = '登录完成后点右上角「完成」保存登录态';
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CsColor.SURFACE)
  }
}
