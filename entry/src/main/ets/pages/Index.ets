import { common } from '@kit.AbilityKit';
import { Glyph, TabSpec } from '../constants/AppConfig';
import { CsColor, CsFont, CsRadius, CsSpace, withAlpha } from '../constants/DesignTokens';
import { SeedData } from '../data/SeedData';
import { DatabaseHelper } from '../data/db/DatabaseHelper';
import { SyncOutcome, SyncService } from '../data/SyncService';
import { ContestFeedService } from '../data/ContestFeedService';
import { CheckInResult, CheckInService } from '../domain/CheckInService';
import { DateUtil } from '../utils/DateUtil';
import { LinkService } from '../utils/LinkService';
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
  @Local acHandle: string = '';
  @Local showBind: boolean = false;
  @Local handleDraft: string = '';
  @Local bindPlatform: string = 'CF';
  @Local lastSyncText: string = '';

  private target: TargetCardData = SeedData.targetCard();
  private challenge: ChallengeCardData = SeedData.challengeCard();
  private cells: WeekCell[] = SeedData.weekCells();
  private collections: CollectionCard[] = SeedData.collections();
  private problems: Problem[] = SeedData.matrixProblems();
  private task: UpsolveTask = SeedData.upsolve();
  private weekDays: WeekStripDay[] = SeedData.weekStrip();
  private heatmap: number[] = SeedData.heatmap();
  private difficultyRows: DifficultyRow[] = SeedData.difficultyRows();
  private badges: BadgeItem[] = SeedData.badges();
  private leaders: LeaderRow[] = SeedData.leaderboard();
  @Local settings: SettingRow[] = SeedData.settings();
  @Local contests: ContestItem[] = SeedData.contests();

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
      this.acHandle = await SyncService.loadAtCoderHandle();
      this.lastSyncText = await SyncService.loadLastSync();
      this.refreshSettingsSubtitle();
      await this.loadContestFeed();
    } catch (err) {
      console.error(`Database bootstrap failed: ${JSON.stringify(err)}`);
    }
  }

  private async loadContestFeed(): Promise<void> {
    try {
      const feed: ContestItem[] = await ContestFeedService.loadUpcoming(4);
      if (feed.length === 0) {
        return;
      }
      const merged: ContestItem[] = [];
      for (const item of feed) {
        merged.push(item);
      }
      for (const item of SeedData.contests()) {
        if (!item.isCollegiate) {
          merged.push(item);
        }
      }
      this.contests = merged;
    } catch (err) {
      console.error(`Contest feed failed: ${JSON.stringify(err)}`);
    }
  }

  private async openUrl(url: string): Promise<void> {
    if (url.length === 0) {
      this.showToast('该条目暂未配置链接');
      return;
    }
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const opened: boolean = await LinkService.open(context, url);
    if (!opened) {
      this.showToast('无法打开链接，请检查网络或浏览器');
    }
  }

  private refreshSettingsSubtitle(): void {
    const next: SettingRow[] = [];
    for (const row of this.settings) {
      if (row.id === 's1') {
        const subtitle: string = this.lastSyncText.length > 0
          ? `上次同步: ${this.lastSyncText} · 手动触发`
          : row.subtitle;
        const updated: SettingRow = {
          id: row.id, title: row.title, subtitle: subtitle,
          glyph: row.glyph, kind: row.kind, enabled: row.enabled
        };
        next.push(updated);
      } else {
        next.push(row);
      }
    }
    this.settings = next;
  }

  private async syncNow(): Promise<void> {
    if (this.cfHandle.length === 0 && this.acHandle.length === 0) {
      this.handleDraft = '';
      this.bindPlatform = 'CF';
      this.showBind = true;
      this.showToast('请先绑定 Codeforces 或 AtCoder 账号');
      return;
    }
    this.showToast('正在同步…');
    const messages: string[] = [];
    let dailyAc: number = 0;

    if (this.cfHandle.length > 0) {
      const cf: SyncOutcome = await SyncService.syncCodeforces(this.cfHandle);
      messages.push(cf.ok ? cf.message : `CF 失败：${cf.message}`);
      if (cf.ok) {
        dailyAc = cf.dailyAc;
      }
    }
    if (this.acHandle.length > 0) {
      const ac: SyncOutcome = await SyncService.syncAtCoder(this.acHandle);
      messages.push(ac.ok ? ac.message : `AtCoder 失败：${ac.message}`);
      if (ac.ok && ac.dailyAc > 0) {
        dailyAc = ac.dailyAc;
      }
    }
    this.lastSyncText = await SyncService.loadLastSync();
    this.refreshSettingsSubtitle();
    this.showToast(messages.join('；'));

    if (dailyAc > 0) {
      const next: TodaySnapshot = {
        status: this.snapshot.status,
        targetProgress: this.snapshot.targetProgress,
        dailyTarget: this.snapshot.dailyTarget,
        streakDays: this.snapshot.streakDays,
        longestStreak: this.snapshot.longestStreak,
        todayAcCount: dailyAc,
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
      this.showToast(this.bindPlatform === 'CF' ? '请输入 Codeforces handle' : '请输入 AtCoder 用户名');
      return;
    }
    if (this.bindPlatform === 'CF') {
      await SyncService.saveHandle(handle);
      this.cfHandle = handle;
    } else {
      await SyncService.saveAtCoderHandle(handle);
      this.acHandle = handle;
    }
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
        Text(this.bindPlatform === 'CF' ? '绑定 Codeforces 账号' : '绑定 AtCoder 账号')
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

      Row({ space: 6 }) {
        Text('Codeforces')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(this.bindPlatform === 'CF' ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .fontWeight(this.bindPlatform === 'CF' ? FontWeight.Bold : FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(32)
          .borderRadius(CsRadius.LG)
          .backgroundColor(this.bindPlatform === 'CF' ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_CONTAINER)
          .onClick(() => {
            this.bindPlatform = 'CF';
            this.handleDraft = this.cfHandle;
          })
        Text('AtCoder')
          .fontSize(CsFont.LABEL_SM)
          .fontColor(this.bindPlatform === 'AC' ? CsColor.PRIMARY_ON : CsColor.TEXT_SECONDARY)
          .fontWeight(this.bindPlatform === 'AC' ? FontWeight.Bold : FontWeight.Normal)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(32)
          .borderRadius(CsRadius.LG)
          .backgroundColor(this.bindPlatform === 'AC' ? CsColor.PRIMARY_CONTAINER : CsColor.SURFACE_CONTAINER)
          .onClick(() => {
            this.bindPlatform = 'AC';
            this.handleDraft = this.acHandle;
          })
      }
      .width('100%')

      Text('仅读取你的公开提交记录，用于计算今日 AC 与难度分布，不写入、不代理登录。')
        .fontSize(CsFont.BODY_SM)
        .fontColor(CsColor.TEXT_SECONDARY)
        .width('100%')

      TextInput({
        text: this.handleDraft,
        placeholder: this.bindPlatform === 'CF' ? 'handle，例如 tourist' : '用户名，例如 chokudai'
      })
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
              onOpenTarget: () => {
                this.openUrl(this.target.problem.url);
              },
              onOpenChallenge: () => {
                this.openUrl(this.challenge.problem.url);
              }
            })
          }
          .tabBar(this.tabBarItem(TabIndex.TODAY))

          TabContent() {
            MatrixView({
              collections: this.collections,
              problems: this.problems,
              onOpenProblem: (url: string) => {
                this.openUrl(url);
              },
              onComingSoon: (label: string) => {
                this.showToast(`${label}将在 v1.1 开放`);
              }
            })
          }
          .tabBar(this.tabBarItem(TabIndex.MATRIX))

          TabContent() {
            ContestView({
              contests: this.contests,
              task: this.task,
              days: this.weekDays,
              onOpenUrl: (url: string) => {
                this.openUrl(url);
              }
            })
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
                this.bindPlatform = this.cfHandle.length === 0 ? 'CF' : (this.acHandle.length === 0 ? 'AC' : 'CF');
                this.handleDraft = this.bindPlatform === 'CF' ? this.cfHandle : this.acHandle;
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
