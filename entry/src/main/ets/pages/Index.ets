import { common } from '@kit.AbilityKit';
import { Glyph, TabSpec } from '../constants/AppConfig';
import { CsColor, CsFont, CsRadius, CsSpace, withAlpha } from '../constants/DesignTokens';
import { SeedData } from '../data/SeedData';
import { DatabaseHelper } from '../data/db/DatabaseHelper';
import { SyncOutcome, SyncService } from '../data/SyncService';
import { CheckInResult, CheckInService } from '../domain/CheckInService';
import { DateUtil } from '../utils/DateUtil';
import {
  BadgeItem, ChallengeCardData, CollectionCard, ContestItem, DifficultyRow, LeaderRow, Problem,
  SettingRow, TargetCardData, TodaySnapshot, UpsolveTask, WeekCell, WeekStripDay
} from '../model/Entities';
import { CheckInStatus, TabIndex } from '../model/Enums';
import { CsAppBar } from '../components/Common';
import { TodayView } from '../views/TodayView';
import { MatrixView } from '../views/MatrixView';
import { ContestView } from '../views/ContestView';
import { StatsView } from '../views/StatsView';

@Entry
@ComponentV2
struct Index {
  @Local activeTab: number = TabIndex.TODAY;
  @Local snapshot: TodaySnapshot = SeedData.today();
  @Local targetSolved: boolean = false;
  @Local challengeSolved: boolean = false;
  @Local celebrated: boolean = false;
  @Local showCelebrate: boolean = false;
  @Local toast: string = '';
  @Local totalAc: number = 384;
  @Local totalDays: number = 152;
  @Local makeupCredits: number = 2;
  @Local cfHandle: string = '';
  @Local showBind: boolean = false;
  @Local handleDraft: string = '';

  private target: TargetCardData = SeedData.targetCard();
  private challenge: ChallengeCardData = SeedData.challengeCard();
  private cells: WeekCell[] = SeedData.weekCells();
  private collections: CollectionCard[] = SeedData.collections();
  private problems: Problem[] = SeedData.matrixProblems();
  private contests: ContestItem[] = SeedData.contests();
  private task: UpsolveTask = SeedData.upsolve();
  private weekDays: WeekStripDay[] = SeedData.weekStrip();
  private heatmap: number[] = SeedData.heatmap();
  private difficultyRows: DifficultyRow[] = SeedData.difficultyRows();
  private badges: BadgeItem[] = SeedData.badges();
  private leaders: LeaderRow[] = SeedData.leaderboard();
  private settings: SettingRow[] = SeedData.settings();

  aboutToAppear(): void {
    this.bootstrap();
  }

  private statusOf(value: string): CheckInStatus {
    if (value === 'achieved') {
      return CheckInStatus.ACHIEVED;
    }
    if (value === 'missed') {
      return CheckInStatus.MISSED;
    }
    if (value === 'makeup') {
      return CheckInStatus.MAKEUP;
    }
    return CheckInStatus.PENDING;
  }

  private async bootstrap(): Promise<void> {
    try {
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      await DatabaseHelper.init(context);
      const user = await DatabaseHelper.loadUser();
      const row = await DatabaseHelper.loadCheckIn(DateUtil.todayKey());
      const base: TodaySnapshot = this.snapshot;
      const merged: TodaySnapshot = {
        status: row === null ? base.status : this.statusOf(row.status),
        targetProgress: row === null ? base.targetProgress : row.targetProgress,
        dailyTarget: row === null ? base.dailyTarget : row.goal,
        streakDays: user === null ? base.streakDays : user.streakCurrent,
        longestStreak: user === null ? base.longestStreak : user.streakLongest,
        todayAcCount: row === null ? base.todayAcCount : row.dailyAcCount,
        focusMinutes: base.focusMinutes,
        beatPercent: base.beatPercent,
        weekNumber: base.weekNumber
      };
      this.snapshot = merged;
      if (user !== null) {
        this.totalAc = user.totalAc;
        this.totalDays = user.totalDays;
        this.makeupCredits = user.repairCards;
      }
      if (row !== null) {
        this.targetSolved = row.targetProgress >= 1;
        this.challengeSolved = row.targetProgress >= 2;
        this.celebrated = row.targetProgress >= row.goal;
      }
      this.cfHandle = await SyncService.loadHandle();
    } catch (err) {
      console.error(`Database bootstrap failed: ${JSON.stringify(err)}`);
    }
  }

  private async syncNow(): Promise<void> {
    if (this.cfHandle.length === 0) {
      this.handleDraft = '';
      this.showBind = true;
      this.showToast('请先绑定 Codeforces 账号');
      return;
    }
    this.showToast('正在同步 Codeforces 数据…');
    const outcome: SyncOutcome = await SyncService.syncCodeforces(this.cfHandle);
    this.showToast(outcome.message);
    if (outcome.ok && outcome.dailyAc > 0) {
      const next: TodaySnapshot = {
        status: this.snapshot.status,
        targetProgress: this.snapshot.targetProgress,
        dailyTarget: this.snapshot.dailyTarget,
        streakDays: this.snapshot.streakDays,
        longestStreak: this.snapshot.longestStreak,
        todayAcCount: outcome.dailyAc,
        focusMinutes: this.snapshot.focusMinutes,
        beatPercent: this.snapshot.beatPercent,
        weekNumber: this.snapshot.weekNumber
      };
      this.snapshot = next;
      this.persistCheckIn();
    }
  }

  private async saveHandleAndSync(): Promise<void> {
    const handle: string = this.handleDraft.trim();
    if (handle.length === 0) {
      this.showToast('请输入 Codeforces handle');
      return;
    }
    await SyncService.saveHandle(handle);
    this.cfHandle = handle;
    this.showBind = false;
    await this.syncNow();
  }

  private persistCheckIn(): void {
    DatabaseHelper.saveCheckIn({
      date: DateUtil.todayKey(),
      goal: this.snapshot.dailyTarget,
      targetProgress: this.snapshot.targetProgress,
      dailyAcCount: this.snapshot.todayAcCount,
      status: this.snapshot.status === CheckInStatus.ACHIEVED ? 'achieved' : 'pending'
    }, this.snapshot.streakDays, this.snapshot.longestStreak);
  }

  private showToast(message: string): void {
    this.toast = message;
    setTimeout(() => {
      if (this.toast === message) {
        this.toast = '';
      }
    }, 2000);
  }

  private progressTo(): void {
    const result: CheckInResult = CheckInService.completeOne({
      target: this.snapshot.dailyTarget,
      targetProgress: this.snapshot.targetProgress,
      streakDays: this.snapshot.streakDays,
      longestStreak: this.snapshot.longestStreak,
      celebrated: this.celebrated
    });
    this.celebrated = result.celebrated;
    const next: TodaySnapshot = {
      status: result.status,
      targetProgress: result.targetProgress,
      dailyTarget: this.snapshot.dailyTarget,
      streakDays: result.streakDays,
      longestStreak: result.longestStreak,
      todayAcCount: this.snapshot.todayAcCount,
      focusMinutes: this.snapshot.focusMinutes,
      beatPercent: this.snapshot.beatPercent,
      weekNumber: this.snapshot.weekNumber
    };
    this.snapshot = next;
    this.persistCheckIn();
    if (result.achievedNow) {
      this.showCelebrate = true;
    }
  }

  private onCompleteTarget(): void {
    if (this.targetSolved) {
      return;
    }
    this.targetSolved = true;
    this.progressTo();
    if (!this.celebrated) {
      this.showToast('已记录 1 题，继续完成竞赛挑战');
    }
  }

  private onCompleteChallenge(): void {
    if (this.challengeSolved) {
      return;
    }
    this.challengeSolved = true;
    this.progressTo();
    if (!this.celebrated) {
      this.showToast('已记录 1 题');
    }
  }

  @Builder
  tabBarItem(index: number) {
    Column({ space: 2 }) {
      Text(TabSpec.ICONS[index])
        .fontSize(18)
        .fontColor(this.activeTab === index ? CsColor.PRIMARY_CONTAINER : CsColor.TEXT_SECONDARY)
      Text(TabSpec.LABELS[index])
        .fontSize(CsFont.LABEL_SM)
        .fontColor(this.activeTab === index ? CsColor.PRIMARY_CONTAINER : CsColor.TEXT_SECONDARY)
    }
    .width('100%')
    .height(64)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  celebration() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Text(Glyph.CHECK)
          .fontSize(28)
          .fontColor(CsColor.SECONDARY_ON)
      }
      .width(56).height(56)
      .borderRadius(CsRadius.FULL)
      .backgroundColor(CsColor.SECONDARY_CONTAINER)
      .justifyContent(FlexAlign.Center)

      Text('ACCEPTED! 连续达成')
        .fontSize(CsFont.LABEL_SM)
        .fontColor(CsColor.SECONDARY)
        .letterSpacing(1)
      Text('打卡成功，连胜延续！')
        .fontSize(CsFont.H3)
        .fontWeight(FontWeight.Bold)
        .fontColor(CsColor.TEXT_PRIMARY)
      Text('记录已同步至云端矩阵。今日完成度升级，坚持就是极客的力量！')
        .fontSize(CsFont.BODY_SM)
        .fontColor(CsColor.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)

      Row() {
        Column({ space: 2 }) {
          Text('连续天数').fontSize(CsFont.LABEL_SM).fontColor(CsColor.TEXT_TERTIARY)
          Text(`${this.snapshot.streakDays} DAYS`).fontSize(CsFont.LABEL_LG)
            .fontWeight(FontWeight.Bold).fontColor(CsColor.PRIMARY)
        }
        .alignItems(HorizontalAlign.Start)
        Column({ space: 2 }) {
          Text('获得积分').fontSize(CsFont.LABEL_SM).fontColor(CsColor.TEXT_TERTIARY)
          Text('+25 EXP').fontSize(CsFont.LABEL_LG)
            .fontWeight(FontWeight.Bold).fontColor(CsColor.SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(CsSpace.SM)
      .borderRadius(CsRadius.LG)
      .backgroundColor(CsColor.SURFACE_CONTAINER)
      .justifyContent(FlexAlign.SpaceBetween)

      Text('收到，继续冲刺')
        .fontSize(CsFont.LABEL)
        .fontWeight(FontWeight.Bold)
        .fontColor(CsColor.PRIMARY_ON)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height(40)
        .borderRadius(CsRadius.LG)
        .backgroundColor(CsColor.PRIMARY_CONTAINER)
        .onClick(() => {
          this.showCelebrate = false;
        })
    }
    .width('86%')
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  bindCard() {
    Column({ space: CsSpace.SM }) {
      Row() {
        Text('绑定 Codeforces 账号')
          .fontSize(CsFont.H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.TEXT_PRIMARY)
        Text(Glyph.CLOSE)
          .fontSize(CsFont.H3)
          .fontColor(CsColor.TEXT_TERTIARY)
          .onClick(() => {
            this.showBind = false;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text('仅读取你的公开提交记录，用于计算今日 AC 与难度分布，不写入、不代理登录。')
        .fontSize(CsFont.BODY_SM)
        .fontColor(CsColor.TEXT_SECONDARY)
        .width('100%')

      TextInput({ text: this.handleDraft, placeholder: 'handle，例如 tourist' })
        .fontSize(CsFont.LABEL)
        .fontColor(CsColor.TEXT_PRIMARY)
        .placeholderColor(CsColor.TEXT_GHOST)
        .height(44)
        .borderRadius(CsRadius.LG)
        .backgroundColor(CsColor.SURFACE_CONTAINER)
        .onChange((value: string) => {
          this.handleDraft = value;
        })

      Row({ space: CsSpace.SM }) {
        Text('取消')
          .fontSize(CsFont.LABEL)
          .fontColor(CsColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.SURFACE_CONTAINER)
          .onClick(() => {
            this.showBind = false;
          })
        Text('保存并同步')
          .fontSize(CsFont.LABEL)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.PRIMARY_ON)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .borderRadius(CsRadius.LG)
          .backgroundColor(CsColor.PRIMARY_CONTAINER)
          .onClick(() => {
            this.saveHandleAndSync();
          })
      }
      .width('100%')
    }
    .width('86%')
    .padding(CsSpace.GUTTER)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_HIGH)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        CsAppBar({
          title: TabSpec.TITLES[this.activeTab],
          onSync: () => {
            this.syncNow();
          },
          onAvatar: () => {
            this.activeTab = TabIndex.STATS;
          }
        })

        Tabs({ barPosition: BarPosition.End, index: this.activeTab }) {
          TabContent() {
            TodayView({
              snapshot: this.snapshot,
              target: this.target,
              challenge: this.challenge,
              cells: this.cells,
              targetSolved: this.targetSolved,
              challengeSolved: this.challengeSolved,
              onCompleteTarget: () => this.onCompleteTarget(),
              onCompleteChallenge: () => this.onCompleteChallenge(),
              onOpenTarget: () => this.showToast('正在唤起 LeetCode 题库…'),
              onOpenChallenge: () => this.showToast('正在唤起 Codeforces 题目…')
            })
          }
          .tabBar(this.tabBarItem(TabIndex.TODAY))

          TabContent() {
            MatrixView({ collections: this.collections, problems: this.problems })
          }
          .tabBar(this.tabBarItem(TabIndex.MATRIX))

          TabContent() {
            ContestView({ contests: this.contests, task: this.task, days: this.weekDays })
          }
          .tabBar(this.tabBarItem(TabIndex.CONTEST))

          TabContent() {
            StatsView({
              snapshot: this.snapshot,
              totalAc: this.totalAc,
              totalDays: this.totalDays,
              makeupCredits: this.makeupCredits,
              cells: this.heatmap,
              difficultyRows: this.difficultyRows,
              badges: this.badges,
              leaders: this.leaders,
              settings: this.settings,
              onBindPlatform: () => {
                this.handleDraft = this.cfHandle;
                this.showBind = true;
              }
            })
          }
          .tabBar(this.tabBarItem(TabIndex.STATS))
        }
        .barHeight(64)
        .barMode(BarMode.Fixed)
        .barBackgroundColor(CsColor.SURFACE_LOWEST)
        .scrollable(false)
        .animationDuration(0)
        .layoutWeight(1)
        .onChange((index: number) => {
          this.activeTab = index;
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(CsColor.SURFACE)

      if (this.toast.length > 0) {
        Column() {
          Text(this.toast)
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.TEXT_INVERSE)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .borderRadius(CsRadius.LG)
            .backgroundColor(CsColor.SURFACE_INVERSE)
        }
        .width('100%')
        .padding({ left: CsSpace.GUTTER, right: CsSpace.GUTTER })
        .position({ x: 0, y: 560 })
        .alignItems(HorizontalAlign.Center)
      }

      if (this.showCelebrate) {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
          }
          .width('100%')
          .height('100%')
          .backgroundColor(withAlpha(CsColor.SURFACE_LOWEST, 0.8))
          .onClick(() => {
            this.showCelebrate = false;
          })

          this.celebration()
        }
        .width('100%')
        .height('100%')
      }

      if (this.showBind) {
        Stack({ alignContent: Alignment.Center }) {
          Column() {
          }
          .width('100%')
          .height('100%')
          .backgroundColor(withAlpha(CsColor.SURFACE_LOWEST, 0.8))
          .onClick(() => {
            this.showBind = false;
          })

          this.bindCard()
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(CsColor.SURFACE)
  }
}
