import { CheckInStatus, ContestStatus, PlatformCode, SolveStatus, TrackType, UpsolveState } from './Enums';

/** 题目（列表行与目标卡共用） */
export interface Problem {
  id: string;
  platform: PlatformCode;
  /** 平台展示名，如 LeetCode */
  platformName: string;
  /** 全局题号，如 LC-15 / CF-1352C / LG-P3372 */
  code: string;
  title: string;
  titleEn: string;
  /** 归一化难度 1.0–5.0，0.5 粒度 */
  difficulty: number;
  /** 平台原生难度文案，如 "Medium" / "(1200)" / "普及+/提高" */
  nativeLabel: string;
  tags: string[];
  status: SolveStatus;
  /** 附加说明：题目来源比赛等 */
  sourceText: string;
  /** 题目外链（跳转题库用） */
  url: string;
  /** 所属赛道：求职高频 / 算法竞赛 */
  track: TrackType;
}

/** 官方精选题单卡（C-23） */
export interface CollectionCard {
  id: string;
  tag: string;
  title: string;
  desc: string;
  done: number;
  total: number;
  percent: number;
  /** 所属赛道 */
  track: TrackType;
  /** 题单官方入口 */
  url: string;
  /** 成员题号（用于真实完成度；空数组表示暂无成员清单） */
  problemKeys: string[];
}

/** 比赛（C-29） */
export interface ContestItem {
  id: string;
  platform: PlatformCode;
  platformLabel: string;
  name: string;
  timeText: string;
  durationText: string;
  status: ContestStatus;
  statusText: string;
  /** 左侧状态竖条颜色（空字符串表示无） */
  accent: string;
  /** 页脚说明 */
  footerText: string;
  /** 主操作文案 */
  actionText: string;
  /** 副操作文案，空则不显示 */
  secondaryText: string;
  /** 是否带脉冲点（进行中/报名中） */
  pulsing: boolean;
  /** 赛事外链（报名/榜单/官网） */
  url: string;
  /** 是否高校赛（ICPC/CCPC），用于筛选分组 */
  isCollegiate: boolean;
  /** 排序用开始时间（epoch 秒），0 表示未知 */
  sortEpoch: number;
}

/** 补题题目行（C-30） */
export interface UpsolveProblem {
  letter: string;
  title: string;
  difficultyText: string;
  state: UpsolveState;
  stateText: string;
  focused: boolean;
}

/** 补题任务（C-30） */
export interface UpsolveTask {
  contestName: string;
  resultText: string;
  percent: number;
  problems: UpsolveProblem[];
}

/** 徽章（C-34） */
export interface BadgeItem {
  id: string;
  name: string;
  state: 'locked' | 'in_progress' | 'unlocked';
  stateText: string;
  glyph: string;
}

/** 排行榜行（C-35） */
export interface LeaderRow {
  rank: number;
  name: string;
  subtitle: string;
  days: number;
  isYou: boolean;
}

/** 设置行（C-36） */
export interface SettingRow {
  id: string;
  title: string;
  subtitle: string;
  glyph: string;
  kind: 'toggle' | 'link';
  enabled: boolean;
}

/** 周矩阵单元（C-05） */
export interface WeekCell {
  /** 一二三四五六日 */
  label: string;
  state: 'done' | 'today' | 'future';
}

/** 周日历条目（C-28） */
export interface WeekStripDay {
  label: string;
  date: string;
  active: boolean;
  dotColor: string;
}

/** 难度分布行（C-33） */
export interface DifficultyRow {
  star: number;
  name: string;
  topic: string;
  count: number;
  percent: number;
}

/** 比赛倒计时 */
export interface CountdownState {
  days: string;
  hours: string;
  minutes: string;
  seconds: string;
}

/** 今日核心推荐卡（C-06） */
export interface TargetCardData {
  problem: Problem;
  rewardText: string;
}

/** 竞赛挑战卡（C-07） */
export interface ChallengeCardData {
  problem: Problem;
  ratingText: string;
}

/** 某日 AC 聚合（热力图数据源） */
export interface DailyAcCount {
  /** YYYY-MM-DD */
  day: string;
  count: number;
}

/** 提交聚合（真实统计口径） */
export interface AcStats {
  /** 去重 AC 题数 */
  solved: number;
  /** 有 AC 的平台数 */
  platforms: number;
  /** 五个难度档的题数，索引 0 对应 ★1 */
  difficulty: number[];
}

/** 页面级统计快照 */
export interface TodaySnapshot {
  status: CheckInStatus;
  targetProgress: number;
  dailyTarget: number;
  streakDays: number;
  longestStreak: number;
  todayAcCount: number;
  focusMinutes: number;
  beatPercent: number;
  weekNumber: number;
}
