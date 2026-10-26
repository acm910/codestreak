import { Glyph } from '../constants/AppConfig';
import { CsColor, CsFont, CsRadius, CsSize, CsSpace, withAlpha } from '../constants/DesignTokens';
import { BadgeItem, DifficultyRow, LeaderRow, WeekStripDay } from '../model/Entities';

/** C-28 周日历锚点 */
@ComponentV2
export struct CsWeekStrip {
  @Param days: WeekStripDay[] = [];
  @Param selected: number = 2;
  @Event onSelect: (index: number) => void = () => {
  };

  build() {
    Row() {
      ForEach(this.days, (day: WeekStripDay, index: number) => {
        Column({ space: 2 }) {
          Text(day.label)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(index === this.selected ? CsColor.PRIMARY : CsColor.TEXT_TERTIARY)
          Text(day.date)
            .fontSize(CsFont.LABEL_LG)
            .fontWeight(index === this.selected ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(index === this.selected ? CsColor.PRIMARY : CsColor.TEXT_SECONDARY)
          if (day.dotColor.length > 0) {
            Row()
              .width(4)
              .height(4)
              .borderRadius(CsRadius.FULL)
              .backgroundColor(day.dotColor)
          } else {
            Row().width(4).height(4)
          }
        }
        .layoutWeight(1)
        .padding({ top: 6, bottom: 6 })
        .borderRadius(CsRadius.MD)
        .backgroundColor(index === this.selected ? CsColor.SURFACE_CONTAINER : CsColor.SURFACE_LOW)
        .onClick(() => this.onSelect(index))
      }, (day: WeekStripDay) => day.label + day.date)
    }
    .width('100%')
    .padding(4)
    .borderRadius(CsRadius.LG)
    .backgroundColor(CsColor.SURFACE_LOW)
  }
}

/** C-32 贡献热力矩阵：7 行 × 16 列，五档色（02-02 §8.1） */
@ComponentV2
export struct CsHeatmap {
  @Param cells: number[] = [];
  private rows: number = 7;
  private cols: number = 16;

  private cellColor(level: number): string {
    if (level <= 0) {
      return CsColor.SURFACE_LOWEST;
    }
    if (level === 1) {
      return CsColor.SECONDARY_CONTAINER;
    }
    if (level === 2) {
      return CsColor.SECONDARY;
    }
    return CsColor.SECONDARY_FIXED;
  }

  build() {
    Column({ space: CsSpace.SM }) {
      Column({ space: CsSize.HEATMAP_GAP }) {
        ForEach(this.range(this.rows), (rowIndex: number) => {
          Row({ space: CsSize.HEATMAP_GAP }) {
            ForEach(this.range(this.cols), (colIndex: number) => {
              Row()
                .width(CsSize.HEATMAP_CELL)
                .height(CsSize.HEATMAP_CELL)
                .borderRadius(CsRadius.XS)
                .backgroundColor(this.cellAt(colIndex * this.rows + rowIndex))
                .borderWidth(this.cellAt(colIndex * this.rows + rowIndex) === 4 ? 1 : 0)
                .borderColor(CsColor.SECONDARY_FIXED)
            }, (colIndex: number) => `c${colIndex}`)
          }
        }, (rowIndex: number) => `r${rowIndex}`)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Row() {
        Text('今天已打卡 3 题 (LeetCode 2 + CF 1)')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
        Row({ space: 3 }) {
          Text('少').fontSize(9).fontColor(CsColor.TEXT_TERTIARY)
          Row().width(8).height(8).borderRadius(1).backgroundColor(CsColor.SURFACE_LOWEST)
          Row().width(8).height(8).borderRadius(1).backgroundColor(CsColor.SECONDARY_CONTAINER)
          Row().width(8).height(8).borderRadius(1).backgroundColor(CsColor.SECONDARY)
          Row().width(8).height(8).borderRadius(1).backgroundColor(CsColor.SECONDARY_FIXED)
          Text('多').fontSize(9).fontColor(CsColor.TEXT_TERTIARY)
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_CONTAINER)
    .width('100%')
  }

  private range(count: number): number[] {
    const list: number[] = [];
    for (let i = 0; i < count; i++) {
      list.push(i);
    }
    return list;
  }

  private cellAt(index: number): number {
    if (index >= 0 && index < this.cells.length) {
      return this.cells[index];
    }
    return 0;
  }
}

/** C-33 难度分布：五条（数量 + 占比 + 难度色阶） */
@ComponentV2
export struct CsDifficultyBars {
  @Param rows: DifficultyRow[] = [];

  private barColor(star: number): string {
    if (star <= 2) {
      return CsColor.SECONDARY;
    }
    if (star === 3) {
      return CsColor.PRIMARY_CONTAINER;
    }
    if (star === 4) {
      return CsColor.PRIMARY_FIXED_DIM;
    }
    return CsColor.ERROR;
  }

  build() {
    Column({ space: 10 }) {
      ForEach(this.rows, (row: DifficultyRow) => {
        Column({ space: 4 }) {
          Row() {
            Row({ space: 4 }) {
              Text(row.name)
                .fontSize(CsFont.LABEL_SM)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.barColor(row.star))
              Text(`/ ${row.topic}`)
                .fontSize(CsFont.LABEL_SM)
                .fontColor(CsColor.TEXT_TERTIARY)
            }
            Row({ space: 4 }) {
              Text(`${row.count}`)
                .fontSize(CsFont.LABEL_SM)
                .fontWeight(FontWeight.Bold)
                .fontColor(CsColor.TEXT_PRIMARY)
              Text(`题 (${row.percent.toFixed(1)}%)`)
                .fontSize(CsFont.LABEL_SM)
                .fontColor(CsColor.TEXT_TERTIARY)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Stack({ alignContent: Alignment.Start }) {
            Row().width('100%').height(6).borderRadius(CsRadius.FULL).backgroundColor(CsColor.SURFACE_LOWEST)
            Row()
              .width(`${Math.max(row.percent, 1.5)}%`)
              .height(6)
              .borderRadius(CsRadius.FULL)
              .backgroundColor(this.barColor(row.star))
          }
          .width('100%')
          .height(6)
        }
      }, (row: DifficultyRow) => `${row.star}`)
    }
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_CONTAINER)
    .width('100%')
  }
}

/** C-34 徽章展柜：3 列三态 */
@ComponentV2
export struct CsBadgeShelf {
  @Param badges: BadgeItem[] = [];

  private badgeColor(item: BadgeItem): string {
    if (item.state === 'unlocked') {
      return CsColor.SECONDARY;
    }
    if (item.state === 'in_progress') {
      return CsColor.PRIMARY_CONTAINER;
    }
    return CsColor.TEXT_GHOST;
  }

  build() {
    Row({ space: CsSpace.XS }) {
      ForEach(this.badges, (item: BadgeItem) => {
        Column({ space: 4 }) {
          Row() {
            Text(item.glyph)
              .fontSize(22)
              .fontColor(this.badgeColor(item))
          }
          .width(48)
          .height(48)
          .borderRadius(CsRadius.FULL)
          .backgroundColor(CsColor.SURFACE_LOWEST)
          .justifyContent(FlexAlign.Center)

          Text(item.name)
            .fontSize(CsFont.LABEL_SM)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.TEXT_PRIMARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .textAlign(TextAlign.Center)
          Text(item.stateText)
            .fontSize(9)
            .fontColor(item.state === 'unlocked' ? CsColor.SECONDARY : CsColor.TEXT_TERTIARY)
            .maxLines(1)
        }
        .layoutWeight(1)
        .padding(CsSpace.SM)
        .borderRadius(CsRadius.XL)
        .backgroundColor(CsColor.SURFACE_HIGH)
        .alignItems(HorizontalAlign.Center)
        .opacity(item.state === 'locked' ? 0.6 : 1)
      }, (item: BadgeItem) => item.id)
    }
    .width('100%')
  }
}

/** C-35 排行榜：前三名，本人高亮左竖条 */
@ComponentV2
export struct CsLeaderboard {
  @Param rows: LeaderRow[] = [];

  private rankBg(rank: number): string {
    if (rank === 1) {
      return CsColor.PRIMARY_CONTAINER;
    }
    if (rank === 2) {
      return CsColor.SURFACE_BRIGHT;
    }
    return withAlpha(CsColor.PRIMARY, 0.2);
  }

  private rankTextColor(rank: number): string {
    if (rank === 1) {
      return CsColor.PRIMARY_ON;
    }
    if (rank === 2) {
      return CsColor.TEXT_PRIMARY;
    }
    return CsColor.PRIMARY;
  }

  build() {
    Column({ space: CsSpace.SM }) {
      ForEach(this.rows, (row: LeaderRow) => {
        Row({ space: CsSpace.SM }) {
          if (row.isYou) {
            Row()
              .width(2)
              .height(36)
              .borderRadius(CsRadius.FULL)
              .backgroundColor(CsColor.PRIMARY_CONTAINER)
          }
          Row() {
            Text(`${row.rank}`)
              .fontSize(CsFont.LABEL_SM)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.rankTextColor(row.rank))
          }
          .width(24)
          .height(24)
          .borderRadius(CsRadius.FULL)
          .backgroundColor(this.rankBg(row.rank))
          .justifyContent(FlexAlign.Center)

          Column({ space: 2 }) {
            Row({ space: 4 }) {
              Text(row.name)
                .fontSize(CsFont.BODY)
                .fontWeight(row.isYou ? FontWeight.Bold : FontWeight.Medium)
                .fontColor(row.isYou ? CsColor.PRIMARY : CsColor.TEXT_PRIMARY)
              if (row.isYou) {
                Text('YOU')
                  .fontSize(9)
                  .fontColor(CsColor.PRIMARY_ON)
                  .padding({ left: 3, right: 3, top: 1, bottom: 1 })
                  .borderRadius(CsRadius.XS)
                  .backgroundColor(CsColor.PRIMARY_CONTAINER)
              }
            }
            Text(row.subtitle)
              .fontSize(CsFont.LABEL_SM)
              .fontColor(row.isYou ? CsColor.TEXT_SECONDARY : CsColor.TEXT_TERTIARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row({ space: 4 }) {
            Text(`${row.days}`)
              .fontSize(CsFont.H3)
              .fontWeight(FontWeight.Bold)
              .fontColor(row.isYou ? CsColor.PRIMARY : CsColor.TEXT_PRIMARY)
            Text('天')
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.TEXT_TERTIARY)
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')
        .padding({ left: row.isYou ? 0 : 4, right: 8, top: 8, bottom: 8 })
        .borderRadius(CsRadius.LG)
        .backgroundColor(row.isYou ? CsColor.SURFACE_BRIGHT : CsColor.SURFACE_HIGH)
        .alignItems(VerticalAlign.Center)
      }, (row: LeaderRow) => `${row.rank}-${row.name}`)
    }
    .width('100%')
  }
}

/** C-40 骨架屏（简化） */
@ComponentV2
export struct CsSkeleton {
  @Param rows: number = 3;
  @Param blockHeight: number = 88;

  build() {
    Column({ space: CsSpace.SM }) {
      ForEach(this.list(), (item: number) => {
        Row()
          .width('100%')
          .height(this.blockHeight)
          .borderRadius(CsRadius.XL)
          .backgroundColor(CsColor.SURFACE_LOW)
      }, (item: number) => `sk-${item}`)
    }
    .width('100%')
  }

  private list(): number[] {
    const arr: number[] = [];
    for (let i = 0; i < this.rows; i++) {
      arr.push(i);
    }
    return arr;
  }
}

/** 今日战报卡（P-01 底部） */
@ComponentV2
export struct CsDailyReport {
  @Param focusMinutes: number = 42;
  @Param solvedCount: number = 1;
  @Param target: number = 2;

  build() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Row({ space: 6 }) {
          Text(Glyph.TIMER).fontSize(CsSize.ICON_MD).fontColor(CsColor.PRIMARY)
          Text('今日训练战报')
            .fontSize(CsFont.LABEL_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.TEXT_PRIMARY)
        }
        Text('状态平稳')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: CsSpace.SM }) {
        Column({ space: 2 }) {
          Text('今日沉浸时间').fontSize(CsFont.LABEL_SM).fontColor(CsColor.TEXT_TERTIARY)
          Row({ space: 3 }) {
            Text(`${this.focusMinutes}`).fontSize(CsFont.H3).fontWeight(FontWeight.Bold)
              .fontColor(CsColor.PRIMARY)
            Text('分钟').fontSize(CsFont.BODY_SM).fontColor(CsColor.TEXT_SECONDARY)
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .layoutWeight(1)
        .padding(CsSpace.SM)
        .borderRadius(CsRadius.LG)
        .backgroundColor(CsColor.SURFACE_CONTAINER)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 2 }) {
          Text('算法题库攻克').fontSize(CsFont.LABEL_SM).fontColor(CsColor.TEXT_TERTIARY)
          Row({ space: 3 }) {
            Text(`${this.solvedCount}`).fontSize(CsFont.H3).fontWeight(FontWeight.Bold)
              .fontColor(CsColor.SECONDARY)
            Text(`/ ${this.target} 题`).fontSize(CsFont.BODY_SM).fontColor(CsColor.TEXT_SECONDARY)
          }
          .alignItems(VerticalAlign.Bottom)
        }
        .layoutWeight(1)
        .padding(CsSpace.SM)
        .borderRadius(CsRadius.LG)
        .backgroundColor(CsColor.SURFACE_CONTAINER)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_LOW)
    .width('100%')
  }
}
