import { CsColor, CsFont, CsRadius, CsSpace } from '../constants/DesignTokens';
import { ContestItem, CountdownState, UpsolveTask, WeekStripDay } from '../model/Entities';
import { ContestStatus, PlatformCode } from '../model/Enums';
import { CsPill, CsSectionHeader } from '../components/Common';
import { CsContestCard, CsCountdownHud, CsUpsolveCard, CsUpsolveGauge } from '../components/Cards';
import { CsWeekStrip } from '../components/Visuals';

/** P-03 比赛日历页 */
@ComponentV2
export struct ContestView {
  @Param contests: ContestItem[] = [];
  @Require @Param task: UpsolveTask;
  @Param days: WeekStripDay[] = [];

  @Local filterIndex: number = 0;
  @Local percent: number = 75;
  @Local solved: number = 15;
  @Local pending: number = 5;
  @Local markedD: boolean = false;
  @Local selectedDay: number = 2;
  @Local hint: string = '';
  @Local countdownDays: string = '01';
  @Local countdownHours: string = '04';
  @Local countdownMinutes: string = '20';
  @Local countdownSeconds: string = '10';

  private totalSeconds: number = 1 * 86400 + 4 * 3600 + 20 * 60 + 10;
  private timerId: number = -1;
  private filters: string[] = ['全部 (10)', 'ICPC / CCPC 高校赛', 'Codeforces', 'LeetCode', 'AtCoder', '洛谷'];

  aboutToAppear(): void {
    this.timerId = setInterval(() => {
      if (this.totalSeconds > 0) {
        this.totalSeconds = this.totalSeconds - 1;
      }
      this.refreshCountdown();
    }, 1000);
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private pad(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  private refreshCountdown(): void {
    const total: number = Math.max(0, this.totalSeconds);
    const d: number = Math.floor(total / 86400);
    const h: number = Math.floor((total % 86400) / 3600);
    const m: number = Math.floor((total % 3600) / 60);
    const s: number = total % 60;
    this.countdownDays = this.pad(d);
    this.countdownHours = this.pad(h);
    this.countdownMinutes = this.pad(m);
    this.countdownSeconds = this.pad(s);
  }

  private countdownState(): CountdownState {
    const state: CountdownState = {
      days: this.countdownDays,
      hours: this.countdownHours,
      minutes: this.countdownMinutes,
      seconds: this.countdownSeconds
    };
    return state;
  }

  private filteredContests(): ContestItem[] {
    if (this.filterIndex === 0) {
      return this.contests;
    }
    const result: ContestItem[] = [];
    for (const item of this.contests) {
      if (this.filterIndex === 1 && (item.id === 'ct-icpc' || item.id === 'ct-ccpc')) {
        result.push(item);
      } else if (this.filterIndex === 2 && item.platform === PlatformCode.CF) {
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
    if (this.markedD) {
      return;
    }
    this.markedD = true;
    this.percent = 80;
    this.solved = 16;
    this.pending = 4;
    this.hint = '已记录 D 题补题，完成率升至 80%';
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
        CsCountdownHud({
          state: this.countdownState(),
          onRemind: () => {
            this.hint = '已开启赛前 15 分钟推送提醒';
          },
          onTeam: () => {
            this.hint = '已向队友发出赛程确认';
          },
          onExport: () => {
            this.hint = '已将赛事日历同步为 .ics';
          }
        })

        CsUpsolveGauge({
          percent: this.percent,
          solved: this.solved,
          pending: this.pending
        })

        CsSectionHeader({ title: '跨平台比赛日历', meta: 'W23 • 2025', accent: CsColor.TERTIARY })
        CsWeekStrip({
          days: this.days,
          selected: this.selectedDay,
          onSelect: (index: number) => {
            this.selectedDay = index;
          }
        })
        this.filterChips()

        ForEach(this.filteredContests(), (item: ContestItem) => {
          CsContestCard({
            contest: item,
            onPrimary: () => {
              this.hint = item.status === ContestStatus.REGISTERING ? '已提交报名确认' : '已打开赛事页面';
            },
            onSecondary: () => {
              this.hint = '已同步赛程至系统日历';
            }
          })
        }, (item: ContestItem) => item.id)

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
          CsPill({ text: 'CF Div.3 回溯追踪', textColor: CsColor.PRIMARY, bgColor: CsColor.SURFACE_CONTAINER })
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
