import { CsColor, CsFont, CsRadius, CsSpace } from '../constants/DesignTokens';
import { ContestItem, UpsolveTask, WeekStripDay } from '../model/Entities';
import { PlatformCode } from '../model/Enums';
import { DateUtil } from '../utils/DateUtil';
import { CsPill, CsSectionHeader } from '../components/Common';
import { CsContestCard, CsUpsolveCard, CsUpsolveGauge } from '../components/Cards';
import { CsWeekStrip } from '../components/Visuals';

/** P-03 比赛日历页 */
@ComponentV2
export struct ContestView {
  @Param contests: ContestItem[] = [];
  @Require @Param task: UpsolveTask;
  @Param days: WeekStripDay[] = [];
  @Event onOpenUrl: (url: string) => void = () => {
  };

  @Local filterIndex: number = 0;
  @Local percent: number = 0;
  @Local solved: number = 0;
  @Local pending: number = 0;
  @Local markedD: boolean = false;
  @Local selectedDay: number = (new Date().getDay() + 6) % 7;
  @Local hint: string = '';

  private filters: string[] = ['全部', 'ICPC / CCPC 高校赛', 'Codeforces', 'LeetCode', 'AtCoder', '洛谷'];

  private filteredContests(): ContestItem[] {
    if (this.filterIndex === 0) {
      return this.contests;
    }
    const result: ContestItem[] = [];
    for (const item of this.contests) {
      if (this.filterIndex === 1) {
        if (item.isCollegiate) {
          result.push(item);
        }
        continue;
      }
      if (item.isCollegiate) {
        continue;
      }
      if (this.filterIndex === 2 && item.platform === PlatformCode.CF) {
        result.push(item);
      } else if (this.filterIndex === 3 && item.platform === PlatformCode.LC) {
        result.push(item);
      } else if (this.filterIndex === 4 && item.platform === PlatformCode.AC) {
        result.push(item);
      } else if (this.filterIndex === 5 && item.platform === PlatformCode.LG) {
        result.push(item);
      }
    }
    return result;
  }

  private markUpsolve(): void {
    this.hint = '暂无可补题目';
  }

  @Builder
  filterChips() {
    Row({ space: 6 }) {
      ForEach(this.filters, (label: string, index: number) => {
        Text(label)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(index === this.filterIndex ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .fontWeight(index === this.filterIndex ? FontWeight.Bold : FontWeight.Normal)
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .borderRadius(CsRadius.FULL)
          .backgroundColor(index === this.filterIndex ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGH)
          .onClick(() => {
            this.filterIndex = index;
          })
      }, (label: string) => label)
    }
    .width('100%')
  }

  build() {
    Scroll() {
      Column({ space: CsSpace.LG }) {
        if (this.task.problems.length > 0) {
          CsUpsolveGauge({
            percent: this.percent,
            solved: this.solved,
            pending: this.pending
          })
        }

        CsSectionHeader({
          title: '跨平台比赛日历',
          meta: `W${DateUtil.isoWeek(new Date())} • ${new Date().getFullYear()}`,
          accent: CsColor.TERTIARY
        })
        CsWeekStrip({
          days: this.days,
          selected: this.selectedDay,
          onSelect: (index: number) => {
            this.selectedDay = index;
          }
        })
        this.filterChips()

        if (this.filteredContests().length === 0) {
          Column({ space: 4 }) {
            Text('暂无可展示的赛事')
              .fontSize(CsFont.BODY)
              .fontColor(CsColor.TEXT_SECONDARY)
            Text('赛事数据来自公开赛程源，未获取到时不会展示示例赛程')
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.TEXT_TERTIARY)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: CsSpace.LG, bottom: CsSpace.LG })
          .alignItems(HorizontalAlign.Center)
        } else {
          ForEach(this.filteredContests(), (item: ContestItem) => {
            CsContestCard({
              contest: item,
              onPrimary: (url: string) => {
                this.onOpenUrl(url);
              },
              onSecondary: () => {
                this.hint = '已同步赛程至系统日历';
              }
            })
          }, (item: ContestItem) => item.id)
        }

        Row() {
          Row({ space: CsSpace.SM }) {
            Row()
              .width(2)
              .height(16)
              .borderRadius(CsRadius.FULL)
              .backgroundColor(CsColor.SECONDARY)
            Text('赛后补题专区 (Upsolving)')
              .fontSize(CsFont.H3)
              .fontWeight(FontWeight.Bold)
              .fontColor(CsColor.TEXT_PRIMARY)
          }
          if (this.task.problems.length > 0) {
            CsPill({ text: '赛后补题追踪', textColor: CsColor.PRIMARY, bgColor: CsColor.SURFACE_CONTAINER })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        CsUpsolveCard({
          task: this.task,
          onMark: (letter: string) => {
            if (letter === 'D') {
              this.markUpsolve();
            }
          },
          onOpen: () => {
            this.hint = '已打开 Codeforces 补题页面';
          }
        })

        if (this.hint.length > 0) {
          Text(this.hint)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_INVERSE)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(CsRadius.LG)
            .backgroundColor(CsColor.SURFACE_INVERSE)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .padding({ left: CsSpace.GUTTER, right: CsSpace.GUTTER, top: CsSpace.SM, bottom: CsSpace.XL })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}
