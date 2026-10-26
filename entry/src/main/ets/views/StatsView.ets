import { CsColor, CsFont, CsRadius, CsSpace, withAlpha } from '../constants/DesignTokens';
import { CheckInStatus } from '../model/Enums';
import { BadgeItem, DifficultyRow, LeaderRow, SettingRow, TodaySnapshot } from '../model/Entities';
import { CsSectionHeader } from '../components/Common';
import { CsProfileCard, CsSettingsRow, CsStreakHero } from '../components/Cards';
import { CsBadgeShelf, CsDifficultyBars, CsHeatmap, CsLeaderboard } from '../components/Visuals';

/** P-04 统计榜单页 */
@ComponentV2
export struct StatsView {
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
  @Param totalAc: number = 384;
  @Param totalDays: number = 152;
  @Param makeupCredits: number = 2;
  @Param cells: number[] = [];
  @Param difficultyRows: DifficultyRow[] = [];
  @Param badges: BadgeItem[] = [];
  @Param leaders: LeaderRow[] = [];
  @Param settings: SettingRow[] = [];
  @Event onBindPlatform: () => void = () => {
  };
  @Event onReminderToggle: (enabled: boolean) => void = () => {
  };

  @Local leaderTab: number = 0;
  @Local hint: string = '';

  @Builder
  miniMetric(label: string, value: string, unit: string, note: string, icon: string) {
    Column({ space: 4 }) {
      Row() {
        Text(label).fontSize(CsFont.LABEL_SM).fontColor(CsColor.TEXT_TERTIARY)
        Text(icon).fontSize(12).fontColor(CsColor.TEXT_TERTIARY)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Row({ space: 4 }) {
        Text(value)
          .fontSize(CsFont.H3)
          .fontWeight(FontWeight.Bold)
          .fontColor(CsColor.TEXT_PRIMARY)
        Text(unit)
          .fontSize(CsFont.LABEL_SM)
          .fontColor(CsColor.TEXT_TERTIARY)
      }
      .alignItems(VerticalAlign.Bottom)
      Text(note)
        .fontSize(CsFont.LABEL_SM)
        .fontColor(CsColor.TEXT_TERTIARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding(CsSpace.MD)
    .borderRadius(CsRadius.XL)
    .backgroundColor(CsColor.SURFACE_CONTAINER)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  leaderTabs() {
    Row({ space: 2 }) {
      Text('周榜')
        .fontSize(CsFont.LABEL_SM)
        .fontWeight(this.leaderTab === 0 ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.leaderTab === 0 ? CsColor.PRIMARY : CsColor.TEXT_TERTIARY)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .borderRadius(CsRadius.SM)
        .backgroundColor(this.leaderTab === 0 ? CsColor.SURFACE_HIGH : withAlpha(CsColor.SURFACE_LOWEST, 0))
        .onClick(() => {
          this.leaderTab = 0;
        })
      Text('月榜')
        .fontSize(CsFont.LABEL_SM)
        .fontWeight(this.leaderTab === 1 ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.leaderTab === 1 ? CsColor.PRIMARY : CsColor.TEXT_TERTIARY)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .borderRadius(CsRadius.SM)
        .backgroundColor(this.leaderTab === 1 ? CsColor.SURFACE_HIGH : withAlpha(CsColor.SURFACE_LOWEST, 0))
        .onClick(() => {
          this.leaderTab = 1;
        })
    }
    .padding(2)
    .borderRadius(CsRadius.LG)
    .backgroundColor(CsColor.SURFACE_LOWEST)
  }

  build() {
    Scroll() {
      Column({ space: CsSpace.LG }) {
        CsProfileCard({
          totalAc: this.totalAc,
          onSync: () => {
            this.hint = '已触发同步，正在拉取四个平台记录';
          }
        })

        CsStreakHero({
          variant: 'hud',
          streak: this.snapshot.streakDays,
          longest: this.snapshot.longestStreak,
          targetProgress: this.snapshot.targetProgress,
          target: this.snapshot.dailyTarget
        })

        Row({ space: CsSpace.SM }) {
          this.miniMetric('历史最长记录', `${this.snapshot.longestStreak}`, '天', '2024.Q1 极客远征', '★')
          this.miniMetric('累计打卡天数', `${this.totalDays}`, '天', `击败了 ${this.snapshot.beatPercent}% 选手`, '◷')
        }
        .width('100%')

        Row({ space: CsSpace.SM }) {
          Row() {
            Text('◈').fontSize(CsFont.BODY_LG).fontColor(CsColor.PRIMARY_FIXED_DIM)
          }
          .width(32).height(32)
          .borderRadius(CsRadius.MD)
          .backgroundColor(CsColor.SURFACE_CONTAINER)
          .justifyContent(FlexAlign.Center)

          Column({ space: 2 }) {
            Text('打卡保全策略')
              .fontSize(CsFont.LABEL_LG)
              .fontColor(CsColor.TEXT_PRIMARY)
            Row({ space: 4 }) {
              Text('补签卡余额：').fontSize(CsFont.BODY_SM).fontColor(CsColor.TEXT_SECONDARY)
              Text(`${this.makeupCredits} 张`).fontSize(CsFont.BODY_SM)
                .fontWeight(FontWeight.Bold).fontColor(CsColor.PRIMARY)
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text('获取道具 ＋')
            .fontSize(CsFont.LABEL_SM)
            .fontColor(CsColor.PRIMARY)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .borderRadius(CsRadius.LG)
            .backgroundColor(CsColor.SURFACE_HIGH)
            .onClick(() => {
              this.hint = '补签卡仅可通过连续打卡里程碑获得';
            })
        }
        .width('100%')
        .padding(CsSpace.MD)
        .borderRadius(CsRadius.XL)
        .backgroundColor(CsColor.SURFACE_LOW)

        CsSectionHeader({ title: '提交活跃度矩阵', meta: '近 16 周活跃', accent: CsColor.SECONDARY })
        CsHeatmap({ cells: this.cells })

        CsSectionHeader({ title: '难度分布矩阵', meta: 'DIFFICULTY_NORM [1-5★]' })
        CsDifficultyBars({ rows: this.difficultyRows })

        Row() {
          CsSectionHeader({ title: '荣誉徽章展柜', meta: '已解锁 3/12' })
        }
        .width('100%')
        CsBadgeShelf({ badges: this.badges })

        Row() {
          Text('连续打卡好友榜')
            .fontSize(CsFont.H3)
            .fontWeight(FontWeight.Bold)
            .fontColor(CsColor.TEXT_PRIMARY)
          this.leaderTabs()
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        CsLeaderboard({ rows: this.leaders })

        CsSectionHeader({ title: '系统设置与偏好', meta: '', accent: CsColor.TEXT_TERTIARY })
        Column({ space: CsSpace.SM }) {
          ForEach(this.settings, (row: SettingRow) => {
            CsSettingsRow({
              row: row,
              onToggle: (id: string, enabled: boolean) => {
                if (id === 's2') {
                  this.onReminderToggle(enabled);
                } else {
                  this.hint = enabled ? '已开启' : '已关闭';
                }
              },
              onTap: (id: string) => {
                if (id === 's1') {
                  this.onBindPlatform();
                } else {
                  this.hint = '该能力将在 v1.1 开放';
                }
              }
            })
          }, (row: SettingRow) => row.id)
        }
        .width('100%')

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
