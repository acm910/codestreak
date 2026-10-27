import { Glyph } from '../constants/AppConfig';
import { CsColor, CsFont, CsRadius, CsSpace, platformColor, platformOnColor, withAlpha } from '../constants/DesignTokens';
import { TrackFilter } from '../domain/TrackFilter';
import { CollectionCard, Problem } from '../model/Entities';
import { PlatformCode, SolveStatus, TrackType } from '../model/Enums';
import { CsDifficultyBadge, CsEmptyState, CsPlatformBadge, CsProgressBar, CsSectionHeader } from '../components/Common';

/** P-02 题单矩阵页 */
@ComponentV2
export struct MatrixView {
  @Param collections: CollectionCard[] = [];
  @Param problems: Problem[] = [];
  @Event onOpenProblem: (url: string) => void = () => {
  };
  @Event onOpenCollection: (url: string) => void = () => {
  };
  @Event onComingSoon: (label: string) => void = () => {
  };

  @Local track: number = 0;
  @Local difficultyFilter: number = -1;
  @Local searchText: string = '';
  @Local lcEnabled: boolean = true;
  @Local cfEnabled: boolean = true;
  @Local lgEnabled: boolean = true;
  @Local acEnabled: boolean = true;
  @Local sortLabel: string = '归一难度';

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

  private enabledPlatformCount(): number {
    let count: number = 0;
    if (this.lcEnabled) {
      count = count + 1;
    }
    if (this.cfEnabled) {
      count = count + 1;
    }
    if (this.lgEnabled) {
      count = count + 1;
    }
    if (this.acEnabled) {
      count = count + 1;
    }
    return count;
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
    const scoped: Problem[] = TrackFilter.problems(
      this.problems, this.track === 0 ? TrackType.INTERVIEW : TrackType.CONTEST
    );
    const result: Problem[] = [];
    for (const item of scoped) {
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

  private collectionsForTrack(): CollectionCard[] {
    return TrackFilter.collections(
      this.collections, this.track === 0 ? TrackType.INTERVIEW : TrackType.CONTEST
    );
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
      .onClick(() => {
        this.onComingSoon('自建题单');
      })
    }
    .width('100%')
  }

  @Builder
  difficultyRow() {
    Scroll() {
      Row({ space: 6 }) {
        Text('全部')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.difficultyFilter < 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.difficultyFilter < 0 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.difficultyFilter < 0 ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
          .onClick(() => {
            this.difficultyFilter = -1;
          })
        Text('★1 入门')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.difficultyFilter === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.difficultyFilter === 0 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.difficultyFilter === 0 ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
          .onClick(() => {
            this.difficultyFilter = 0;
          })
        Text('★2 基础')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.difficultyFilter === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.difficultyFilter === 1 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.difficultyFilter === 1 ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
          .onClick(() => {
            this.difficultyFilter = 1;
          })
        Text('★3 进阶')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.difficultyFilter === 2 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.difficultyFilter === 2 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.difficultyFilter === 2 ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
          .onClick(() => {
            this.difficultyFilter = 2;
          })
        Text('★4 困难')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.difficultyFilter === 3 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.difficultyFilter === 3 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.difficultyFilter === 3 ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
          .onClick(() => {
            this.difficultyFilter = 3;
          })
        Text('★5 挑战')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.difficultyFilter === 4 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.difficultyFilter === 4 ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.difficultyFilter === 4 ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
          .onClick(() => {
            this.difficultyFilter = 4;
          })
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }

  @Builder
  platformRow() {
    Row({ space: 6 }) {
      Text(`平台 ${this.enabledPlatformCount()}/4`)
        .fontSize(CsFont.LABEL_SM)
        .fontColor(CsColor.TEXT_TERTIARY)
      Row({ space: 4 }) {
        Text(this.lcEnabled ? Glyph.CHECK : Glyph.HOLLOW_DOT)
          .fontSize(10)
          .fontColor(this.lcEnabled ? platformOnColor(PlatformCode.LC) : CsColor.TEXT_GHOST)
        Text('LC')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.lcEnabled ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.lcEnabled ? platformOnColor(PlatformCode.LC) : CsColor.TEXT_TERTIARY)
      }
      .padding({ left: 9, right: 9, top: 6, bottom: 6 })
      .borderRadius(CsRadius.FULL)
      .backgroundColor(this.lcEnabled ? platformColor(PlatformCode.LC) : CsColor.SURFACE_HIGH)
      .border({ width: 1, color: this.lcEnabled ? platformColor(PlatformCode.LC) : withAlpha(CsColor.TEXT_GHOST, 0.35) })
      .onClick(() => {
        this.lcEnabled = !this.lcEnabled;
      })

      Row({ space: 4 }) {
        Text(this.cfEnabled ? Glyph.CHECK : Glyph.HOLLOW_DOT)
          .fontSize(10)
          .fontColor(this.cfEnabled ? platformOnColor(PlatformCode.CF) : CsColor.TEXT_GHOST)
        Text('CF')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.cfEnabled ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.cfEnabled ? platformOnColor(PlatformCode.CF) : CsColor.TEXT_TERTIARY)
      }
      .padding({ left: 9, right: 9, top: 6, bottom: 6 })
      .borderRadius(CsRadius.FULL)
      .backgroundColor(this.cfEnabled ? platformColor(PlatformCode.CF) : CsColor.SURFACE_HIGH)
      .border({ width: 1, color: this.cfEnabled ? platformColor(PlatformCode.CF) : withAlpha(CsColor.TEXT_GHOST, 0.35) })
      .onClick(() => {
        this.cfEnabled = !this.cfEnabled;
      })

      Row({ space: 4 }) {
        Text(this.lgEnabled ? Glyph.CHECK : Glyph.HOLLOW_DOT)
          .fontSize(10)
          .fontColor(this.lgEnabled ? platformOnColor(PlatformCode.LG) : CsColor.TEXT_GHOST)
        Text('洛谷')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.lgEnabled ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.lgEnabled ? platformOnColor(PlatformCode.LG) : CsColor.TEXT_TERTIARY)
      }
      .padding({ left: 9, right: 9, top: 6, bottom: 6 })
      .borderRadius(CsRadius.FULL)
      .backgroundColor(this.lgEnabled ? platformColor(PlatformCode.LG) : CsColor.SURFACE_HIGH)
      .border({ width: 1, color: this.lgEnabled ? platformColor(PlatformCode.LG) : withAlpha(CsColor.TEXT_GHOST, 0.35) })
      .onClick(() => {
        this.lgEnabled = !this.lgEnabled;
      })

      Row({ space: 4 }) {
        Text(this.acEnabled ? Glyph.CHECK : Glyph.HOLLOW_DOT)
          .fontSize(10)
          .fontColor(this.acEnabled ? platformOnColor(PlatformCode.AC) : CsColor.TEXT_GHOST)
        Text('AtCoder')
          .fontSize(CsFont.LABEL_SM)
          .fontWeight(this.acEnabled ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.acEnabled ? platformOnColor(PlatformCode.AC) : CsColor.TEXT_TERTIARY)
      }
      .padding({ left: 9, right: 9, top: 6, bottom: 6 })
      .borderRadius(CsRadius.FULL)
      .backgroundColor(this.acEnabled ? platformColor(PlatformCode.AC) : CsColor.SURFACE_HIGH)
      .border({ width: 1, color: this.acEnabled ? platformColor(PlatformCode.AC) : withAlpha(CsColor.TEXT_GHOST, 0.35) })
      .onClick(() => {
        this.acEnabled = !this.acEnabled;
      })
    }
    .width('100%')
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
        Text(item.total > 0 ? `${item.percent}% 已攻克` : '查看题单')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(item.total > 0 ? CsColor.SECONDARY : CsColor.TEXT_TERTIARY)
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

      if (item.total > 0) {
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
      } else {
        Row({ space: 4 }) {
          Text('进入题单')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.PRIMARY)
          Text('→')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.PRIMARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
    }
    .width(270)
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_LOW)
    .onClick(() => {
      this.onOpenCollection(item.url);
    })
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
    .onClick(() => {
      this.onOpenProblem(item.url);
    })
  }

  build() {
    Scroll() {
      Column({ space: CsSpace.MD }) {
        this.segmented()
        this.searchRow()
        this.difficultyRow()
        this.platformRow()

        CsSectionHeader({
          title: this.track === 0 ? '求职精选题单' : '竞赛精选题单',
          meta: `已收录 ${this.collectionsForTrack().length} 项`
        })
        if (this.collectionsForTrack().length === 0) {
          Text('该赛道暂无题单')
            .fontSize(CsFont.BODY_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
            .width('100%')
            .padding({ top: CsSpace.SM, bottom: CsSpace.SM })
        } else {
          Scroll() {
            Row({ space: CsSpace.MD }) {
              ForEach(this.collectionsForTrack(), (item: CollectionCard) => {
                this.collectionCard(item)
              }, (item: CollectionCard) => item.id)
            }
            .padding({ right: CsSpace.GUTTER })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }

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
            .onClick(() => {
              this.onComingSoon('外站题单导入');
            })
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
