import { CsColor, CsRadius, CsSpace } from '../constants/DesignTokens';
import { CheckInStatus } from '../model/Enums';
import { ChallengeCardData, TargetCardData, TodaySnapshot, WeekCell } from '../model/Entities';
import { CsDailyReport } from '../components/Visuals';
import { CsSectionHeader } from '../components/Common';
import { CsChallengeCard, CsStreakHero, CsTargetCard } from '../components/Cards';

/** P-01 今日打卡页 */
@ComponentV2
export struct TodayView {
  @Param snapshot: TodaySnapshot = {
    status: CheckInStatus.PENDING,
    targetProgress: 1,
    dailyTarget: 2,
    streakDays: 28,
    longestStreak: 64,
    todayAcCount: 3,
    focusMinutes: 42,
    beatPercent: 89.4,
    weekNumber: 42
  };
  @Require @Param target: TargetCardData;
  @Require @Param challenge: ChallengeCardData;
  @Param cells: WeekCell[] = [];
  @Param targetSolved: boolean = false;
  @Param challengeSolved: boolean = false;
  @Event onCompleteTarget: () => void = () => {
  };
  @Event onCompleteChallenge: () => void = () => {
  };
  @Event onOpenTarget: () => void = () => {
  };
  @Event onOpenChallenge: () => void = () => {
  };

  build() {
    Scroll() {
      Column({ space: CsSpace.LG }) {
        CsStreakHero({
          variant: 'hero',
          streak: this.snapshot.streakDays,
          longest: this.snapshot.longestStreak,
          targetProgress: this.snapshot.targetProgress,
          target: this.snapshot.dailyTarget,
          weekNumber: this.snapshot.weekNumber,
          beatPercent: this.snapshot.beatPercent,
          cells: this.cells
        })

        CsSectionHeader({ title: '今日核心推荐', meta: 'PRIMARY TARGET' })

        CsTargetCard({
          data: this.target,
          solved: this.targetSolved,
          onComplete: () => this.onCompleteTarget(),
          onOpen: () => this.onOpenTarget()
        })

        CsSectionHeader({ title: '竞赛挑战 · 二选一', meta: 'RATING: 900', accent: CsColor.TERTIARY })

        CsChallengeCard({
          problem: this.challenge.problem,
          solved: this.challengeSolved,
          onComplete: () => this.onCompleteChallenge(),
          onOpen: () => this.onOpenChallenge()
        })

        CsDailyReport({
          focusMinutes: this.snapshot.focusMinutes,
          solvedCount: this.snapshot.targetProgress,
          target: this.snapshot.dailyTarget
        })
      }
      .width('100%')
      .padding({ left: CsSpace.GUTTER, right: CsSpace.GUTTER, top: CsSpace.SM, bottom: CsSpace.XL })
      .borderRadius(CsRadius.XL)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
}
