import { AppConfig, Glyph } from '../constants/AppConfig';
import {
  CsColor, CsFont, CsRadius, CsSize, CsSpace, difficultyColor, platformColor, platformOnColor, withAlpha
} from '../constants/DesignTokens';
import { PlatformCode } from '../model/Enums';

/** C-01 AppBar：64vp 固定，左品牌 + 标题，右同步与头像 */
@ComponentV2
export struct CsAppBar {
  @Param title: string = '';
  @Event onSync: () => void = () => {
  };
  @Event onAvatar: () => void = () => {
  };

  build() {
    Row() {
      Row({ space: CsSpace.SM }) {
        Row() {
          Text(Glyph.CODE)
            .fontSize(12)
            .fontColor(CsColor.PRIMARY_CONTAINER)
            .fontWeight(FontWeight.Bold)
        }
        .width(36)
        .height(36)
        .borderRadius(CsRadius.XL)
        .backgroundColor(CsColor.SURFACE_HIGH)
        .justifyContent(FlexAlign.Center)

        Column({ space: 2 }) {
          Text(AppConfig.BRAND_EYEBROW)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
            .letterSpacing(1)
          Text(this.title)
            .fontSize(CsFont.H3)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.TEXT_PRIMARY)
        }
        .alignItems(HorizontalAlign.Start)
      }

      Row({ space: CsSpace.SM }) {
        Text(Glyph.SYNC)
          .fontSize(CsSize.ICON_LG)
          .fontColor(CsColor.TEXT_SECONDARY)
          .width(CsSize.TOUCH_MIN)
          .height(CsSize.TOUCH_MIN)
          .textAlign(TextAlign.Center)
          .onClick(() => this.onSync())

        Row() {
          Text(Glyph.PERSON)
            .fontSize(CsSize.ICON_MD)
            .fontColor(CsColor.PRIMARY_ON)
        }
        .width(28)
        .height(28)
        .borderRadius(CsRadius.FULL)
        .backgroundColor(CsColor.PRIMARY)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onAvatar())
      }
    }
    .width('100%')
    .height(CsSize.APP_BAR)
    .padding({ left: CsSpace.GUTTER, right: CsSpace.GUTTER })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(withAlpha(CsColor.SURFACE, 0.85))
    .backdropBlur(24)
  }
}

/** C-03 区块标题：左侧 2×16 琥珀竖条 + 标题，右侧等宽元信息 */
@ComponentV2
export struct CsSectionHeader {
  @Param title: string = '';
  @Param meta: string = '';
  @Param accent: string = CsColor.PRIMARY_CONTAINER;

  build() {
    Row() {
      Row({ space: CsSpace.SM }) {
        Row()
          .width(2)
          .height(16)
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.accent)
        Text(this.title)
          .fontSize(CsFont.H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.TEXT_PRIMARY)
      }

      if (this.meta.length > 0) {
        Text(this.meta)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
          .letterSpacing(0.5)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}

/** 通用胶囊标签 */
@ComponentV2
export struct CsPill {
  @Param text: string = '';
  @Param textColor: string = CsColor.TEXT_SECONDARY;
  @Param bgColor: string = CsColor.SURFACE_HIGHEST;
  @Param strokeColor: string = '';
  @Param textSize: number = CsFont.LABEL_SM;
  @Param bold: boolean = false;

  build() {
    Text(this.text)
      .fontSize(this.textSize)
      .fontWeight(this.bold ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.textColor)
      .padding({ left: 8, right: 8, top: 3, bottom: 3 })
      .borderRadius(CsRadius.FULL)
      .backgroundColor(this.bgColor)
      .borderWidth(this.strokeColor.length > 0 ? 1 : 0)
      .borderColor(this.strokeColor)
  }
}

/** C-15 进度条 */
@ComponentV2
export struct CsProgressBar {
  @Param value: number = 0;
  @Param color: string = CsColor.PRIMARY_CONTAINER;
  @Param trackColor: string = CsColor.SURFACE_LOWEST;
  @Param barHeight: number = 6;
  @Param radius: number = CsRadius.FULL;

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row()
        .width('100%')
        .height(this.barHeight)
        .borderRadius(this.radius)
        .backgroundColor(this.trackColor)
      Row()
        .width(`${Math.max(0, Math.min(100, this.value))}%`)
        .height(this.barHeight)
        .borderRadius(this.radius)
        .backgroundColor(this.color)
    }
    .width('100%')
    .height(this.barHeight)
  }
}

/** C-08 指标块 */
@ComponentV2
export struct CsStatTile {
  @Param label: string = '';
  @Param value: string = '';
  @Param unit: string = '';
  @Param valueColor: string = CsColor.TEXT_PRIMARY;
  @Param bgColor: string = CsColor.SURFACE_CONTAINER;

  build() {
    Column({ space: 4 }) {
      Text(this.label)
        .fontSize(CsFont.LABEL_SM)
        .fontColor(CsColor.TEXT_TERTIARY)
      Row({ space: 4 }) {
        Text(this.value)
          .fontSize(CsFont.H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.valueColor)
        if (this.unit.length > 0) {
          Text(this.unit)
            .fontSize(CsFont.BODY_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
        }
      }
      .alignItems(VerticalAlign.Bottom)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(CsSpace.SM)
    .borderRadius(CsRadius.LG)
    .backgroundColor(this.bgColor)
    .layoutWeight(1)
  }
}

/** C-13 平台徽标：solid 仅用于焦点卡首行（D-40） */
@ComponentV2
export struct CsPlatformBadge {
  @Param code: string = PlatformCode.LC;
  @Param label: string = 'LeetCode';
  @Param solid: boolean = false;

  build() {
    Text(this.label)
      .fontSize(CsFont.LABEL_SM)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.solid ? platformOnColor(this.code) : platformColor(this.code))
      .padding({ left: 7, right: 7, top: 3, bottom: 3 })
      .borderRadius(CsRadius.SM)
      .backgroundColor(this.solid ? platformColor(this.code) : withAlpha(platformColor(this.code), 0.2))
  }
}

/** C-14 难度徽标：颜色只表达难度（D-04），支持 0.5 星 */
@ComponentV2
export struct CsDifficultyBadge {
  @Param difficulty: number = 3;
  @Param nativeLabel: string = '';

  private starText(): string {
    const star: string = this.difficulty % 1 === 0 ? `${this.difficulty.toFixed(0)}` : this.difficulty.toFixed(1);
    const label: string = this.nativeLabel.length > 0 ? ` ${this.nativeLabel}` : '';
    return `★${star}${label}`;
  }

  build() {
    Text(this.starText())
      .fontSize(CsFont.LABEL_SM)
      .fontColor(difficultyColor(this.difficulty))
      .padding({ left: 7, right: 7, top: 3, bottom: 3 })
      .borderRadius(CsRadius.SM)
      .backgroundColor(withAlpha(difficultyColor(this.difficulty), 0.18))
  }
}

/** 空态（C-39 简化版） */
@ComponentV2
export struct CsEmptyState {
  @Param glyph: string = Glyph.HOLLOW_DOT;
  @Param title: string = '';
  @Param desc: string = '';
  @Param actionText: string = '';
  @Event onAction: () => void = () => {
  };

  build() {
    Column({ space: CsSpace.SM }) {
      Text(this.glyph)
        .fontSize(32)
        .fontColor(CsColor.TEXT_GHOST)
      Text(this.title)
        .fontSize(CsFont.BODY_LG)
        .fontColor(CsColor.TEXT_SECONDARY)
      if (this.desc.length > 0) {
        Text(this.desc)
          .fontSize(CsFont.BODY_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
      }
      if (this.actionText.length > 0) {
        Text(this.actionText)
          .fontSize(CsFont.LABEL_LG)
          .fontColor(CsColor.PRIMARY)
          .padding({ left: 14, right: 14, top: 7, bottom: 7 })
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.SURFACE_HIGH)
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .padding(CsSpace.XL)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_LOW)
  }
}
