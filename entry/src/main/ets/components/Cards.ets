import { Glyph } from '../constants/AppConfig';
import { CsColor, CsFont, CsRadius, CsSize, CsSpace, withAlpha } from '../constants/DesignTokens';
import {
  ContestItem, CountdownState, Problem, SettingRow, TargetCardData, UpsolveProblem, UpsolveTask, WeekCell
} from '../model/Entities';
import { ContestStatus, PlatformCode, SolveStatus, UpsolveState } from '../model/Enums';
import { CsDifficultyBadge, CsPlatformBadge, CsProgressBar } from './Common';

/** 兜底数据：组件参数始终非空，避免 build 根节点出现条件分支 */
const EMPTY_PROBLEM: Problem = {
  id: '', platform: PlatformCode.LC, platformName: '', code: '', title: '', titleEn: '',
  difficulty: 3, nativeLabel: '', tags: [], status: SolveStatus.TODO, sourceText: '', url: ''
};
const EMPTY_TARGET: TargetCardData = { problem: EMPTY_PROBLEM, rewardText: '' };
const EMPTY_CONTEST: ContestItem = {
  id: '', platform: PlatformCode.LC, platformLabel: '', name: '', timeText: '', durationText: '',
  status: ContestStatus.UPCOMING, statusText: '', accent: '', footerText: '', actionText: '',
  secondaryText: '', pulsing: false, url: '', isCollegiate: false
};
const EMPTY_TASK: UpsolveTask = { contestName: '', resultText: '', percent: 0, problems: [] };
const EMPTY_SETTING: SettingRow = {
  id: '', title: '', subtitle: '', glyph: '', kind: 'link', enabled: false
};

/** C-04 连续打卡主卡：hero（P-01）与 hud（P-04）两个变体（D-34） */
@ComponentV2
export struct CsStreakHero {
  @Param variant: string = 'hero';
  @Param streak: number = 28;
  @Param longest: number = 64;
  @Param targetProgress: number = 1;
  @Param target: number = 2;
  @Param weekNumber: number = 42;
  @Param beatPercent: number = 0;
  @Param cells: WeekCell[] = [];

  private statusText(): string {
    if (this.targetProgress >= this.target) {
      return `今日已拉满 ${this.target}/${this.target}`;
    }
    return `待完成 ${this.target - this.targetProgress}/${this.target}`;
  }

  @Builder
  weekMatrix() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Text(`本周打卡矩阵 (WEEK ${this.weekNumber})`)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
        if (this.beatPercent > 0) {
          Text(`击败 ${Math.round(this.beatPercent)}% 工程师`)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.SECONDARY)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        ForEach(this.cells, (cell: WeekCell) => {
          Column({ space: 4 }) {
            Text(cell.label)
              .fontSize(CsFont.LABEL_SM)
              .fontColor(cell.state === 'today' ? CsColor.PRIMARY : CsColor.TEXT_TERTIARY)
            if (cell.state === 'done') {
              Row() {
                Text(Glyph.CHECK).fontSize(14).fontColor(CsColor.SECONDARY_ON)
              }
              .width(CsSize.WEEK_CELL)
              .height(CsSize.WEEK_CELL)
              .borderRadius(CsRadius.MD)
              .backgroundColor(CsColor.SECONDARY_CONTAINER)
              .justifyContent(FlexAlign.Center)
            } else if (cell.state === 'today') {
              Row() {
                Text('今').fontSize(CsFont.LABEL_SM).fontWeight(FontWeight.Bold)
                  .fontColor(CsColor.PRIMARY_ON)
              }
              .width(CsSize.WEEK_CELL)
              .height(CsSize.WEEK_CELL)
              .borderRadius(CsRadius.MD)
              .backgroundColor(CsColor.PRIMARY_CONTAINER)
              .justifyContent(FlexAlign.Center)
            } else {
              Row() {
                Text(Glyph.DOT).fontSize(6).fontColor(CsColor.BORDER_SUBTLE)
              }
              .width(CsSize.WEEK_CELL)
              .height(CsSize.WEEK_CELL)
              .borderRadius(CsRadius.MD)
              .backgroundColor(CsColor.SURFACE_HIGHEST)
              .justifyContent(FlexAlign.Center)
            }
          }
          .layoutWeight(1)
        }, (cell: WeekCell) => cell.label)
      }
      .width('100%')
    }
    .padding(CsSpace.SM)
    .borderRadius(CsRadius.LG)
    .backgroundColor(CsColor.SURFACE_CONTAINER)
  }

  build() {
    Column({ space: CsSpace.MD }) {
      Row() {
        Row({ space: CsSpace.SM }) {
          if (this.variant === 'hero') {
            Row() {
              Text(Glyph.FLAME).fontSize(14).fontColor(CsColor.PRIMARY_CONTAINER)
            }
            .width(28)
            .height(28)
            .borderRadius(CsRadius.LG)
            .backgroundColor(CsColor.SURFACE_HIGHEST)
            .justifyContent(FlexAlign.Center)
          }
          Text(this.variant === 'hero' ? 'CURRENT MOMENTUM' : 'CURRENT ACTIVE STREAK')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
            .letterSpacing(1)
        }

        Row({ space: 6 }) {
          Text(Glyph.DOT).fontSize(6).fontColor(CsColor.PRIMARY_CONTAINER)
          Text(this.statusText())
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.PRIMARY)
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .borderRadius(CsRadius.FULL)
        .backgroundColor(CsColor.SURFACE_HIGHEST)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row({ space: 4 }) {
          Text(`${this.streak}`)
            .fontSize(CsFont.H1_MOBILE)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.TEXT_PRIMARY)
          Text('天连续打卡')
            .fontSize(CsFont.BODY)
            .fontColor(CsColor.TEXT_SECONDARY)
        }
        .alignItems(VerticalAlign.Bottom)

        Column({ space: 2 }) {
          Text(`历史最长: ${this.longest} 天`)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
          Text('今日未中断')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.SECONDARY)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.variant === 'hero') {
        this.weekMatrix()
      } else {
        Column({ space: 6 }) {
          Row() {
            Text('距离解锁【30天徽章】还差 2 天')
              .fontSize(CsFont.BODY_SM)
              .fontColor(CsColor.TEXT_SECONDARY)
            Text('93%')
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.SECONDARY)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          CsProgressBar({ value: 93.3, color: CsColor.SECONDARY, barHeight: 6 })
        }
      }
    }
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .width('100%')
  }
}

/** C-06 今日核心推荐卡 */
@ComponentV2
export struct CsTargetCard {
  @Param data: TargetCardData = EMPTY_TARGET;
  @Param solved: boolean = false;
  @Event onOpen: () => void = () => {
  };
  @Event onComplete: () => void = () => {
  };

  build() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Row({ space: 6 }) {
          CsPlatformBadge({ code: this.data.problem.platform, label: this.data.problem.platformName, solid: true })
          CsDifficultyBadge({
            difficulty: this.data.problem.difficulty,
            nativeLabel: this.data.problem.nativeLabel
          })
        }
        Text(`#${this.data.problem.code}`)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column({ space: 2 }) {
        Text(this.data.problem.title)
          .fontSize(CsFont.H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.TEXT_PRIMARY)
        Text(this.data.problem.titleEn)
          .fontSize(CsFont.BODY_SM)
          .fontColor(CsColor.TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.data.problem.tags, (tag: string) => {
          Text(tag)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
            .padding({ left: 7, right: 7, top: 3, bottom: 3 })
            .margin({ right: 6, bottom: 4 })
            .borderRadius(CsRadius.SM)
            .backgroundColor(CsColor.SURFACE_CONTAINER)
        }, (tag: string) => tag)
      }

      Row({ space: CsSpace.SM }) {
        Text('去题库做题')
          .fontSize(CsFont.LABEL)
          .fontColor(CsColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.SURFACE_CONTAINER)
          .onClick(() => this.onOpen())
        Text(this.solved ? '已打卡 AC' : '完成打卡')
          .fontSize(CsFont.LABEL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.solved ? CsColor.SECONDARY_ON : CsColor.PRIMARY_ON)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .borderRadius(CsRadius.LG)
          .backgroundColor(this.solved ? CsColor.SECONDARY_CONTAINER : CsColor.PRIMARY_CONTAINER)
          .enabled(!this.solved)
          .onClick(() => this.onComplete())
      }
      .width('100%')
    }
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .width('100%')
  }
}

/** C-07 竞赛挑战卡 */
@ComponentV2
export struct CsChallengeCard {
  @Param problem: Problem = EMPTY_PROBLEM;
  @Param solved: boolean = false;
  @Event onOpen: () => void = () => {
  };
  @Event onComplete: () => void = () => {
  };

  build() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Row({ space: 6 }) {
          CsPlatformBadge({ code: this.problem.platform, label: this.problem.platformName, solid: true })
          CsDifficultyBadge({ difficulty: this.problem.difficulty, nativeLabel: this.problem.nativeLabel })
        }
        Text(`#${this.problem.code}`)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column({ space: 2 }) {
        Text(this.problem.title)
          .fontSize(CsFont.H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.TEXT_PRIMARY)
        Text(this.problem.titleEn)
          .fontSize(CsFont.BODY_SM)
          .fontColor(CsColor.TEXT_SECONDARY)
      }
      .alignItems(HorizontalAlign.Start)

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.problem.tags, (tag: string) => {
          Text(tag)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
            .padding({ left: 7, right: 7, top: 3, bottom: 3 })
            .margin({ right: 6, bottom: 4 })
            .borderRadius(CsRadius.SM)
            .backgroundColor(CsColor.SURFACE_HIGHEST)
        }, (tag: string) => tag)
      }

      Row({ space: CsSpace.SM }) {
        Text('去 CF 做题')
          .fontSize(CsFont.LABEL)
          .fontColor(CsColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.SURFACE_HIGHEST)
          .onClick(() => this.onOpen())
        Text(this.solved ? '已打卡 AC' : '打卡收工')
          .fontSize(CsFont.LABEL)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.solved ? CsColor.SECONDARY_ON : CsColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .borderRadius(CsRadius.LG)
          .backgroundColor(this.solved ? CsColor.SECONDARY_CONTAINER : CsColor.SURFACE_HIGHEST)
          .enabled(!this.solved)
          .onClick(() => this.onComplete())
      }
      .width('100%')
    }
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_CONTAINER)
    .width('100%')
  }
}

/** C-26 赛事倒计时 HUD */
@ComponentV2
export struct CsCountdownHud {
  @Param state: CountdownState = { days: '01', hours: '04', minutes: '20', seconds: '10' };
  @Param title: string = '';
  @Param timeText: string = '';
  @Event onRemind: () => void = () => {
  };
  @Event onTeam: () => void = () => {
  };
  @Event onExport: () => void = () => {
  };

  @Builder
  cell(value: string, label: string, color: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontSize(CsFont.H3)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .fontFeature('"tnum" 1')
      Text(label)
        .fontSize(CsFont.LABEL_SM)
        .fontColor(CsColor.TEXT_TERTIARY)
        .letterSpacing(0.5)
    }
    .layoutWeight(1)
    .padding({ top: 6, bottom: 6 })
    .borderRadius(CsRadius.SM)
    .backgroundColor(CsColor.SURFACE_LOWEST)
  }

  build() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Row({ space: 6 }) {
          Text(Glyph.FLAG)
            .fontSize(12)
            .fontColor(CsColor.PRIMARY_ON)
            .width(18)
            .height(18)
            .textAlign(TextAlign.Center)
            .borderRadius(CsRadius.SM)
            .backgroundColor(CsColor.PRIMARY_CONTAINER)
          Text('NEXT DISPATCH // ICPC & CF 参赛倒计时')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.PRIMARY)
        }
        Row({ space: 6 }) {
          Text('三人组队已确认')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TERTIARY)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text(this.title)
        .fontSize(CsFont.H3)
        .fontWeight(FontWeight.Bold)
        .fontColor(CsColor.TEXT_PRIMARY)
        .width('100%')
        .textAlign(TextAlign.Start)
      Text(this.timeText)
        .fontSize(CsFont.BODY_SM)
        .fontColor(CsColor.TEXT_SECONDARY)
        .width('100%')

      Row({ space: 6 }) {
        this.cell(this.state.days, 'DAYS', CsColor.PRIMARY)
        this.cell(this.state.hours, 'HOURS', CsColor.PRIMARY)
        this.cell(this.state.minutes, 'MINS', CsColor.PRIMARY)
        this.cell(this.state.seconds, 'SECS', CsColor.SECONDARY)
      }
      .width('100%')

      Row({ space: 6 }) {
        Text('预约提醒')
          .fontSize(CsFont.LABEL)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.PRIMARY_ON)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(36)
          .borderRadius(CsRadius.SM)
          .backgroundColor(CsColor.PRIMARY_CONTAINER)
          .onClick(() => this.onRemind())
        Text('提醒队友')
          .fontSize(CsFont.LABEL)
          .fontColor(CsColor.TERTIARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(36)
          .borderRadius(CsRadius.SM)
          .backgroundColor(CsColor.SURFACE_HIGHEST)
          .onClick(() => this.onTeam())
        Text('日历.ICS')
          .fontSize(CsFont.LABEL)
          .fontColor(CsColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(36)
          .borderRadius(CsRadius.SM)
          .backgroundColor(CsColor.SURFACE_HIGHEST)
          .onClick(() => this.onExport())
      }
      .width('100%')
    }
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .width('100%')
  }
}

/** C-27 补题完成率 */
@ComponentV2
export struct CsUpsolveGauge {
  @Param percent: number = 75;
  @Param solved: number = 15;
  @Param pending: number = 5;
  @Param avgHours: string = '18.4h';

  @Builder
  miniStat(label: string, value: string, color: string) {
    Column({ space: 2 }) {
      Text(label).fontSize(CsFont.LABEL_SM).fontColor(CsColor.TEXT_TERTIARY)
      Text(value).fontSize(CsFont.LABEL_LG).fontWeight(FontWeight.Bold).fontColor(color)
    }
    .layoutWeight(1)
    .padding({ top: 6, bottom: 6 })
    .borderRadius(CsRadius.SM)
    .backgroundColor(CsColor.SURFACE_CONTAINER)
  }

  build() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Text('赛后补题完成率 // MONTHLY UPSOLVE')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_SECONDARY)
        Text('+12% 较上月')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.SECONDARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(`${this.percent.toFixed(0)}%`)
          .fontSize(CsFont.H1_MOBILE)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.PRIMARY)
        Column({ space: 2 }) {
          Text('TARGET 80% (15/20 题已解决)')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
          Text('赛后补题完成率')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)

      Stack({ alignContent: Alignment.Start }) {
        Row().width('100%').height(12).borderRadius(CsRadius.XS).backgroundColor(CsColor.SURFACE_LOWEST)
        Row() {
          Row().width(`${this.percent}%`).height(12).borderRadius(CsRadius.XS).backgroundColor(CsColor.SECONDARY)
          Row().width(`${Math.min(5, 100 - this.percent)}%`).height(12).backgroundColor(CsColor.PRIMARY_FIXED_DIM)
          Row().layoutWeight(1).height(12).backgroundColor(withAlpha(CsColor.PRIMARY, 0.2))
        }
        .width('100%')
      }
      .width('100%')
      .height(12)

      Row({ space: 6 }) {
        this.miniStat('已补题数', `${this.solved} 题`, CsColor.TEXT_PRIMARY)
        this.miniStat('待击破', `0${this.pending} 题`, CsColor.PRIMARY)
        this.miniStat('平均补题时差', this.avgHours, CsColor.TERTIARY)
      }
      .width('100%')
    }
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_LOW)
    .width('100%')
  }
}

/** C-29 比赛卡：左侧 2vp 状态竖条 */
@ComponentV2
export struct CsContestCard {
  @Param contest: ContestItem = EMPTY_CONTEST;
  @Event onPrimary: (url: string) => void = () => {
  };
  @Event onSecondary: () => void = () => {
  };

  build() {
    Row({ space: CsSpace.SM }) {
      Row()
        .width(2)
        .height(64)
        .borderRadius(CsRadius.FULL)
        .backgroundColor(this.contest.accent.length > 0 ? this.contest.accent : CsColor.SURFACE_HIGHEST)

      Column({ space: 6 }) {
        Row() {
          Row({ space: 6 }) {
            CsPlatformBadge({ code: this.contest.platform, label: this.contest.platformLabel, solid: false })
            Text(this.contest.timeText)
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.TEXT_TERTIARY)
            Text(this.contest.durationText)
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.TEXT_SECONDARY)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(CsRadius.SM)
              .backgroundColor(CsColor.SURFACE_LOWEST)
          }
          Text(this.contest.statusText)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(this.contest.status === ContestStatus.REGISTERING ? CsColor.PRIMARY : CsColor.TEXT_TERTIARY)
            .fontWeight(this.contest.status === ContestStatus.REGISTERING ? FontWeight.Bold : FontWeight.Normal)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Text(this.contest.name)
          .fontSize(CsFont.BODY_LG)
          .fontColor(CsColor.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          Text(this.contest.footerText)
            .fontSize(CsFont.BODY_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Row({ space: 6 }) {
            if (this.contest.secondaryText.length > 0) {
              Text(this.contest.secondaryText)
                .fontSize(CsFont.LABEL_SM)
                .fontColor(CsColor.TERTIARY)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(CsRadius.SM)
                .backgroundColor(CsColor.SURFACE_HIGHEST)
                .onClick(() => this.onSecondary())
            }
            Text(this.contest.actionText)
              .fontSize(CsFont.LABEL_SM)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.contest.status === ContestStatus.REGISTERING ? CsColor.PRIMARY_ON : CsColor.PRIMARY)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(CsRadius.SM)
              .backgroundColor(this.contest.status === ContestStatus.REGISTERING
                ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_HIGHEST)
              .onClick(() => this.onPrimary(this.contest.url))
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}

/** C-30 补题任务卡 */
@ComponentV2
export struct CsUpsolveCard {
  @Param task: UpsolveTask = EMPTY_TASK;
  @Event onMark: (letter: string) => void = () => {
  };
  @Event onOpen: (letter: string) => void = () => {
  };

  build() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Column({ space: 2 }) {
          Text(this.task.contestName.length > 0 ? this.task.contestName : '暂无待补题目')
            .fontSize(CsFont.BODY_LG)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.TEXT_PRIMARY)
          Text(this.task.resultText.length > 0 ? this.task.resultText
            : '完成比赛并同步赛果后，这里会自动生成补题清单')
            .fontSize(CsFont.BODY_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        if (this.task.problems.length > 0) {
          Text(`${this.task.percent}% 完成`)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.SECONDARY)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(CsRadius.SM)
            .backgroundColor(CsColor.SURFACE_CONTAINER)
        }
      }
      .width('100%')

      ForEach(this.task.problems, (item: UpsolveProblem) => {
        Row({ space: CsSpace.SM }) {
          if (item.focused) {
            Row()
              .width(3)
              .height(28)
              .borderRadius(CsRadius.FULL)
              .backgroundColor(CsColor.PRIMARY_CONTAINER)
          }
          Text(item.letter)
            .fontSize(CsFont.LABEL)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.state === UpsolveState.PENDING ? CsColor.PRIMARY_ON : CsColor.SECONDARY_ON)
            .width(24)
            .height(24)
            .textAlign(TextAlign.Center)
            .borderRadius(CsRadius.SM)
            .backgroundColor(item.state === UpsolveState.PENDING
              ? CsColor.PRIMARY_CONTAINER : CsColor.SECONDARY_CONTAINER)
          Column({ space: 2 }) {
            Text(item.title)
              .fontSize(CsFont.BODY)
              .fontColor(CsColor.TEXT_PRIMARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(item.difficultyText)
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.TEXT_TERTIARY)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          if (item.state === UpsolveState.PENDING) {
            Text(item.stateText)
              .fontSize(CsFont.LABEL_SM)
              .fontWeight(FontWeight.Bold)
              .fontColor(CsColor.PRIMARY)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(CsRadius.SM)
              .backgroundColor(withAlpha(CsColor.PRIMARY_CONTAINER, 0.2))
          } else {
            Text(item.stateText)
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.SECONDARY)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .borderRadius(CsRadius.SM)
              .backgroundColor(withAlpha(CsColor.SECONDARY_CONTAINER, 0.2))
          }
        }
        .width('100%')
        .padding(8)
        .borderRadius(CsRadius.SM)
        .backgroundColor(item.focused ? CsColor.SURFACE_HIGH : CsColor.SURFACE_CONTAINER)
      }, (item: UpsolveProblem) => item.letter)

      if (this.task.problems.length > 0) {
        Row({ space: 6 }) {
          Text('建议参考官方 Editorial 的 MEX 状态有向建图')
            .fontSize(CsFont.BODY_SM)
            .fontColor(CsColor.TEXT_SECONDARY)
            .layoutWeight(1)
          Text('去CF补题')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TERTIARY)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(CsRadius.SM)
            .backgroundColor(CsColor.SURFACE_HIGHEST)
            .onClick(() => this.onOpen('D'))
          Text('打卡AC')
            .fontSize(CsFont.LABEL_SM)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.PRIMARY_ON)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(CsRadius.SM)
            .backgroundColor(CsColor.PRIMARY_CONTAINER)
            .onClick(() => this.onMark('D'))
        }
        .width('100%')
      }
    }
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_LOW)
    .width('100%')
  }
}

/** C-31 用户卡 */
@ComponentV2
export struct CsProfileCard {
  @Param name: string = '我的账号';
  @Param uid: string = '';
  @Param totalAc: number = 0;
  @Param platforms: string[] = ['未绑定'];
  @Event onSync: () => void = () => {
  };

  build() {
    Column({ space: CsSpace.MD }) {
      Row() {
        Row({ space: CsSpace.SM }) {
          Row() {
            Text('◆').fontSize(22).fontColor(CsColor.PRIMARY_FIXED_DIM)
          }
          .width(56)
          .height(56)
          .borderRadius(CsRadius.XL)
          .backgroundColor(CsColor.SURFACE_CONTAINER)
          .justifyContent(FlexAlign.Center)

          Column({ space: 2 }) {
            Row({ space: 6 }) {
              Text(this.name)
                .fontSize(CsFont.H3)
                .fontWeight(FontWeight.Bold)
                .fontColor(CsColor.TEXT_PRIMARY)
            }
            Text('本地账号 · 数据仅存本机')
              .fontSize(CsFont.LABEL_SM)
              .fontColor(CsColor.TEXT_TERTIARY)
          }
          .alignItems(HorizontalAlign.Start)
        }

        Text(Glyph.SYNC)
          .fontSize(CsSize.ICON_MD)
          .fontColor(CsColor.TEXT_SECONDARY)
          .width(36)
          .height(36)
          .textAlign(TextAlign.Center)
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.SURFACE_CONTAINER)
          .onClick(() => this.onSync())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 6 }) {
        ForEach(this.platforms, (item: string) => {
          Text(item)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(item.indexOf('绑定') >= 0 ? CsColor.PRIMARY : CsColor.SECONDARY)
            .textAlign(TextAlign.Center)
            .layoutWeight(1)
            .padding({ top: 6, bottom: 6 })
            .borderRadius(CsRadius.SM)
            .backgroundColor(CsColor.SURFACE_LOW)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }, (item: string) => item)
      }
      .width('100%')

      Row() {
        Text('全平台总计完成题数')
          .fontSize(CsFont.BODY_SM)
          .fontColor(CsColor.TEXT_SECONDARY)
        Row({ space: 4 }) {
          Text(`${this.totalAc}`)
            .fontSize(CsFont.H3)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.PRIMARY)
          Text('AC')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_TERTIARY)
        }
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .padding(8)
      .borderRadius(CsRadius.LG)
      .backgroundColor(withAlpha(CsColor.SURFACE_LOWEST, 0.8))
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .width('100%')
  }
}

/** C-36 设置行 */
@ComponentV2
export struct CsSettingsRow {
  @Param row: SettingRow = EMPTY_SETTING;
  @Event onToggle: (id: string, enabled: boolean) => void = () => {
  };
  @Event onTap: (id: string) => void = () => {
  };

  build() {
    Row({ space: CsSpace.MD }) {
      Row() {
        Text(this.row.glyph).fontSize(CsSize.ICON_MD).fontColor(CsColor.TEXT_SECONDARY)
      }
      .width(36)
      .height(36)
      .borderRadius(CsRadius.LG)
      .backgroundColor(CsColor.SURFACE_CONTAINER)
      .justifyContent(FlexAlign.Center)

      Column({ space: 2 }) {
        Text(this.row.title)
          .fontSize(CsFont.BODY)
          .fontColor(CsColor.TEXT_PRIMARY)
        Text(this.row.subtitle)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.row.kind === 'toggle') {
        Toggle({ type: ToggleType.Switch, isOn: this.row.enabled })
          .selectedColor(CsColor.SECONDARY_CONTAINER)
          .switchPointColor(CsColor.TEXT_PRIMARY)
          .onChange((isOn: boolean) => this.onToggle(this.row.id, isOn))
      } else {
        Text(Glyph.CHEVRON)
          .fontSize(CsFont.H3)
          .fontColor(CsColor.TEXT_TERTIARY)
      }
    }
    .width('100%')
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.LG)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .onClick(() => {
      if (this.row.kind === 'link') {
        this.onTap(this.row.id);
      }
    })
  }
}
