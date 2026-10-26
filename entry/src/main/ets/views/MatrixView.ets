import { Glyph } from '../constants/AppConfig';
import { CsColor, CsFont, CsRadius, CsSpace, platformColor, withAlpha } from '../constants/DesignTokens';
import { CollectionCard, Problem } from '../model/Entities';
import { PlatformCode, SolveStatus } from '../model/Enums';
import { CsDifficultyBadge, CsEmptyState, CsPlatformBadge, CsProgressBar, CsSectionHeader } from '../components/Common';

/** P-02 题单矩阵页 */
@ComponentV2
export struct MatrixView {
  @Param collections: CollectionCard[] = [];
  @Param problems: Problem[] = [];

  @Local track: number = 0;
  @Local difficultyFilter: number = -1;
  @Local searchText: string = '';
  @Local lcEnabled: boolean = true;
  @Local cfEnabled: boolean = true;
  @Local lgEnabled: boolean = true;
  @Local acEnabled: boolean = true;
  @Local sortLabel: string = '归一难度';

  private difficultyLabels: string[] = ['全部', '★1 入门', '★2 基础', '★3 进阶', '★4 困难', '★5 挑战'];

  private platformEnabled(code: string): boolean {
    if (code === PlatformCode.LC) {
      return this.lcEnabled;
    }
    if (code === PlatformCode.CF) {
      return this.cfEnabled;
    }
    if (code === PlatformCode.LG) {
      return this.lgEnabled;
    }
    return this.acEnabled;
  }

  private togglePlatform(code: string): void {
    if (code === PlatformCode.LC) {
      this.lcEnabled = !this.lcEnabled;
    } else if (code === PlatformCode.CF) {
      this.cfEnabled = !this.cfEnabled;
    } else if (code === PlatformCode.LG) {
      this.lgEnabled = !this.lgEnabled;
    } else {
      this.acEnabled = !this.acEnabled;
    }
  }

  private matchDifficulty(item: Problem): boolean {
    if (this.difficultyFilter < 0) {
      return true;
    }
    return Math.floor(item.difficulty) === this.difficultyFilter;
  }

  private matchSearch(item: Problem): boolean {
    const key: string = this.searchText.trim().toLowerCase();
    if (key.length === 0) {
      return true;
    }
    if (item.code.toLowerCase().indexOf(key) >= 0 || item.title.toLowerCase().indexOf(key) >= 0) {
      return true;
    }
    for (const tag of item.tags) {
      if (tag.toLowerCase().indexOf(key) >= 0) {
        return true;
      }
    }
    return false;
  }

  private filtered(): Problem[] {
    const result: Problem[] = [];
    for (const item of this.problems) {
      if (!this.platformEnabled(item.platform)) {
        continue;
      }
      if (!this.matchDifficulty(item)) {
        continue;
      }
      if (!this.matchSearch(item)) {
        continue;
      }
      result.push(item);
    }
    result.sort((a: Problem, b: Problem) => a.difficulty - b.difficulty);
    return result;
  }

  @Builder
  segmented() {
    Row({ space: 4 }) {
      Row() {
        Text('求职高频')
          .fontSize(CsFont.LABEL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.track === 0 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
      }
      .layoutWeight(1)
      .height(40)
      .borderRadius(CsRadius.LG)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.track === 0 ? CsColor.PRIMARY_CONTAINER : withAlpha(CsColor.SURFACE_HIGH, 0))
      .onClick(() => {
        this.track = 0;
      })

      Row() {
        Text('算法竞赛')
          .fontSize(CsFont.LABEL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.track === 1 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
      }
      .layoutWeight(1)
      .height(40)
      .borderRadius(CsRadius.LG)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.track === 1 ? CsColor.PRIMARY_CONTAINER : withAlpha(CsColor.SURFACE_HIGH, 0))
      .onClick(() => {
        this.track = 1;
      })
    }
    .width('100%')
    .padding(4)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
  }

  @Builder
  searchRow() {
    Row({ space: CsSpace.SM }) {
      Row({ space: 6 }) {
        Text('⌕').fontSize(CsFont.BODY_LG).fontColor(CsColor.TEXT_TERTIARY)
        TextInput({ text: this.searchText, placeholder: '搜索 key: LC-15 或 tag:双指针...' })
          .placeholderColor(CsColor.TEXT_GHOST)
          .fontSize(CsFont.LABEL)
          .fontColor(CsColor.TEXT_PRIMARY)
          .backgroundColor(withAlpha(CsColor.SURFACE_LOW, 0))
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => this.searchText = value)
      }
      .layoutWeight(1)
      .padding({ left: CsSpace.MD, right: CsSpace.MD })
      .height(44)
      .borderRadius(CsRadius.XL)
      .backgroundColor(CsColor.SURFACE_LOW)

      Row() {
        Text('新建题单')
          .fontSize(CsFont.LABEL)
          .fontColor(CsColor.PRIMARY)
      }
      .height(44)
      .padding({ left: CsSpace.MD, right: CsSpace.MD })
      .borderRadius(CsRadius.XL)
      .backgroundColor(CsColor.SURFACE_HIGH)
    }
    .width('100%')
  }

  @Builder
  difficultyRow() {
    Scroll() {
      Row({ space: 6 }) {
        ForEach(this.difficultyLabels, (label: string, index: number) => {
          Text(label)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(this.difficultyFilter === index - 1 || (index === 0 && this.difficultyFilter < 0)
              ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .borderRadius(CsRadius.FULL)
            .backgroundColor(index === 0 && this.difficultyFilter < 0
              ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
            .onClick(() => {
              this.difficultyFilter = index - 1;
            })
        }, (label: string) => label)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  platformRow() {
    Row({ space: 6 }) {
      this.platformPill(PlatformCode.LC, 'LeetCode', this.lcEnabled)
      this.platformPill(PlatformCode.CF, 'Codeforces', this.cfEnabled)
      this.platformPill(PlatformCode.LG, '洛谷', this.lgEnabled)
      this.platformPill(PlatformCode.AC, 'AtCoder', this.acEnabled)
    }
    .width('100%')
  }

  @Builder
  platformPill(code: string, label: string, enabled: boolean) {
    Row({ space: 4 }) {
      Text(enabled ? Glyph.CHECK : Glyph.HOLLOW_DOT)
        .fontSize(10)
        .fontColor(enabled ? platformColor(code) : CsColor.TEXT_GHOST)
      Text(label)
        .fontSize(CsFont.LABEL_SM)
        .fontColor(enabled ? platformColor(code) : CsColor.TEXT_TERTIARY)
    }
    .padding({ left: 8, right: 8, top: 5, bottom: 5 })
    .borderRadius(CsRadius.FULL)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .onClick(() => this.togglePlatform(code))
  }

  @Builder
  collectionCard(item: CollectionCard) {
    Column({ space: CsSpace.SM }) {
      Row() {
        Text(item.tag)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.PRIMARY_FIXED_DIM)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(withAlpha(CsColor.PRIMARY_CONTAINER, 0.2))
        Text(`${item.percent}% 已攻克`)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text(item.title)
        .fontSize(CsFont.BODY_LG)
        .fontWeight(FontWeight.Bold)
        .fontColor(CsColor.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      Text(item.desc)
        .fontSize(CsFont.BODY_SM)
        .fontColor(CsColor.TEXT_SECONDARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Column({ space: 4 }) {
        Row() {
          Text(`完成度 ${item.done}/${item.total}`)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
          Text(`${item.percent}%`)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        CsProgressBar({ value: item.percent, color: CsColor.SECONDARY, barHeight: 4 })
      }
      .width('100%')
    }
    .width(270)
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_LOW)
  }

  @Builder
  problemRow(item: Problem) {
    Column({ space: CsSpace.SM }) {
      Row({ space: CsSpace.SM }) {
        Column({ space: 4 }) {
          Row({ space: 6 }) {
            CsPlatformBadge({ code: item.platform, label: item.platformName, solid: false })
            Text(item.code)
              .fontSize(CsFont.LABEL)
              .fontColor(CsColor.TEXT_TERTIARY)
            CsDifficultyBadge({ difficulty: item.difficulty, nativeLabel: item.nativeLabel })
          }
          Text(item.title)
            .fontSize(CsFont.BODY_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (item.status === SolveStatus.SOLVED) {
          Text('已打卡')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.SECONDARY)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(CsRadius.FULL)
            .backgroundColor(withAlpha(CsColor.SECONDARY_CONTAINER, 0.2))
        } else if (item.status === SolveStatus.DOING) {
          Text('去打卡')
            .fontSize(CsFont.LABEL_SM)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.PRIMARY_ON)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(CsRadius.FULL)
            .backgroundColor(CsColor.PRIMARY_CONTAINER)
        } else {
          Text('待做')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(CsRadius.FULL)
            .backgroundColor(CsColor.SURFACE_HIGHEST)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row() {
        Row({ space: 6 }) {
          ForEach(item.tags, (tag: string) => {
            Text(tag)
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.TEXT_SECONDARY)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(CsRadius.SM)
              .backgroundColor(CsColor.SURFACE_HIGHEST)
          }, (tag: string) => tag)
        }
        Text('题解 →')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_LOW)
  }

  build() {
    Scroll() {
      Column({ space: CsSpace.MD }) {
        this.segmented()
        this.searchRow()
        this.difficultyRow()
        this.platformRow()

        CsSectionHeader({ title: '官方精选题单', meta: '已订阅 3 项' })
        Scroll() {
          Row({ space: CsSpace.MD }) {
            ForEach(this.collections, (item: CollectionCard) => {
              this.collectionCard(item)
            }, (item: CollectionCard) => item.id)
          }
          .padding({ right: CsSpace.GUTTER })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        Row() {
          Row({ space: CsSpace.SM }) {
            Row()
              .width(2)
              .height(16)
              .borderRadius(CsRadius.FULL)
              .backgroundColor(CsColor.PRIMARY_CONTAINER)
            Text('题单矩阵库')
              .fontSize(CsFont.H3)
              .fontWeight(FontWeight.Bold)
              .fontColor(CsColor.TEXT_PRIMARY)
          }
          Text(`排序: ${this.sortLabel} ⇅`)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        if (this.filtered().length === 0) {
          CsEmptyState({
            glyph: '◌',
            title: '没有匹配的题目',
            desc: '试试放宽难度或平台筛选',
            actionText: '重置筛选',
            onAction: () => {
              this.difficultyFilter = -1;
              this.searchText = '';
              this.lcEnabled = true;
              this.cfEnabled = true;
              this.lgEnabled = true;
              this.acEnabled = true;
            }
          })
        } else {
          ForEach(this.filtered(), (item: Problem) => {
            this.problemRow(item)
          }, (item: Problem) => item.id)
        }

        Row({ space: CsSpace.SM }) {
          Row() {
            Text('↗').fontSize(CsFont.BODY_LG).fontColor(CsColor.PRIMARY)
          }
          .width(40).height(40)
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.SURFACE_LOWEST)
          .justifyContent(FlexAlign.Center)

          Column({ space: 2 }) {
            Text('一键导入外站题单')
              .fontSize(CsFont.BODY)
              .fontWeight(FontWeight.Medium)
              .fontColor(CsColor.TEXT_PRIMARY)
            Text('粘贴 LeetCode/洛谷公开题单 URL')
              .fontSize(CsFont.BODY_SM)
              .fontColor(CsColor.TEXT_TERTIARY)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('立即解析')
            .fontSize(CsFont.LABEL)
            .fontColor(CsColor.PRIMARY)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .borderRadius(CsRadius.LG)
            .backgroundColor(CsColor.SURFACE_LOWEST)
        }
        .width('100%')
        .padding(CsSpace.MD)
        .borderRadius(CsRadius.XL)
        .backgroundColor(CsColor.SURFACE_HIGH)
      }
      .width('100%')
      .padding({ left: CsSpace.GUTTER, right: CsSpace.GUTTER, top: CsSpace.SM, bottom: CsSpace.XL })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}
