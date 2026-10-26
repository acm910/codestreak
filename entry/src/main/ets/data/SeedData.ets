import { CsColor } from '../constants/DesignTokens';
import { CheckInStatus, ContestStatus, PlatformCode, SolveStatus } from '../model/Enums';
import { DateUtil } from '../utils/DateUtil';
import {
  BadgeItem,
  ChallengeCardData,
  CollectionCard,
  ContestItem,
  CountdownState,
  DifficultyRow,
  LeaderRow,
  Problem,
  SettingRow,
  TargetCardData,
  TodaySnapshot,
  UpsolveTask,
  WeekCell,
  WeekStripDay
} from '../model/Entities';

/**
 * 静态目录数据（题目、题单标题、设置文案）。
 * 用户相关数据（连续天数、总 AC、热力图、徽章、榜单）一律从本地库计算，
 * 无数据即空/0，不再构造示例数字（docs/06-附录/01 D-07~D-12）。
 */
export class SeedData {
  static today(): TodaySnapshot {
    const snap: TodaySnapshot = {
      status: CheckInStatus.PENDING,
      targetProgress: 0,
      dailyTarget: 2,
      streakDays: 0,
      longestStreak: 0,
      todayAcCount: 0,
      focusMinutes: 0,
      beatPercent: 0,
      weekNumber: DateUtil.isoWeek(new Date())
    };
    return snap;
  }

  static targetCard(): TargetCardData {
    const problem: Problem = {
      id: 'p-lc-206',
      platform: PlatformCode.LC,
      platformName: 'LeetCode',
      code: 'LC-206',
      title: '反转链表',
      titleEn: 'Reverse Linked List',
      difficulty: 3,
      nativeLabel: 'Medium',
      tags: ['链表', '双指针', '高频面试 TOP100'],
      status: SolveStatus.TODO,
      sourceText: '',
      url: 'https://leetcode.cn/problems/reverse-linked-list/'
    };
    const data: TargetCardData = { problem: problem, rewardText: '+25 EXP' };
    return data;
  }

  static challengeCard(): ChallengeCardData {
    const problem: Problem = {
      id: 'p-cf-1899a',
      platform: PlatformCode.CF,
      platformName: 'Codeforces',
      code: 'CF-1899A',
      title: 'Game with Integers',
      titleEn: '博弈论 / 数学 / Codeforces Round 909 (Div. 3)',
      difficulty: 1,
      nativeLabel: 'Easy',
      tags: ['math', 'games', 'Div.3 A题'],
      status: SolveStatus.TODO,
      sourceText: 'RATING: 800',
      url: 'https://codeforces.com/problemset/problem/1899/A'
    };
    const data: ChallengeCardData = { problem: problem, ratingText: 'RATING: 800' };
    return data;
  }

  /** 本周打卡矩阵（真实状态由 Index 按打卡记录覆盖） */
  static weekCells(): WeekCell[] {
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
    const weekdayFromMonday: number = (new Date().getDay() + 6) % 7;
    const cells: WeekCell[] = [];
    for (let i = 0; i < labels.length; i++) {
      const state: 'done' | 'today' | 'future' = i === weekdayFromMonday ? 'today' : 'future';
      const cell: WeekCell = { label: labels[i], state: state };
      cells.push(cell);
    }
    return cells;
  }

  /** 官方精选题单目录（完成度从 0 起算，订阅进度尚未接入） */
  static collections(): CollectionCard[] {
    const list: CollectionCard[] = [
      {
        id: 'c1', tag: '高频面试', title: '代码随想录 · 核心 60 题',
        desc: '经典数组、动态规划及单调栈体系化通关路线。',
        done: 0, total: 60, percent: 0
      },
      {
        id: 'c2', tag: '竞赛排位', title: 'CF 1200-1400 突破营',
        desc: '攻克 Div.3 C/D 与 Div.2 B/C 贪心与二分分水岭题目。',
        done: 0, total: 45, percent: 0
      },
      {
        id: 'c3', tag: '经典必刷', title: '剑指 Offer 经典必刷',
        desc: '国内大厂考察极高频的代码与数据结构模版题。',
        done: 0, total: 75, percent: 0
      }
    ];
    return list;
  }

  /** P-02 题单矩阵库（3 行） */
  static matrixProblems(): Problem[] {
    const list: Problem[] = [
      {
        id: 'p-lc-15', platform: PlatformCode.LC, platformName: 'LeetCode', code: 'LC-15',
        title: '三数之和 (3Sum)', titleEn: '', difficulty: 3, nativeLabel: 'Medium',
        tags: ['双指针', '排序'], status: SolveStatus.SOLVED, sourceText: '',
        url: 'https://leetcode.cn/problems/3sum/'
      },
      {
        id: 'p-cf-1352c', platform: PlatformCode.CF, platformName: 'Codeforces', code: 'CF-1352C',
        title: 'K-th Not Divisible by n', titleEn: '', difficulty: 2, nativeLabel: '(1200)',
        tags: ['二分查找', '数学'], status: SolveStatus.DOING, sourceText: 'Round #640 (Div. 4)',
        url: 'https://codeforces.com/problemset/problem/1352/C'
      },
      {
        id: 'p-lg-p3372', platform: PlatformCode.LG, platformName: '洛谷', code: 'LG-P3372',
        title: '【模板】线段树 1', titleEn: '', difficulty: 3,
        nativeLabel: '普及+/提高',
        tags: ['数据结构', '线段树'], status: SolveStatus.TODO, sourceText: '',
        url: 'https://www.luogu.com.cn/problem/P3372'
      }
    ];
    return list;
  }

  /** P-03 赛事：仅展示真实数据源（CPC Finder 等），无数据为空 */
  static contests(): ContestItem[] {
    const list: ContestItem[] = [];
    return list;
  }

  /** P-03 周条（真实状态由 Index 按打卡记录覆盖） */
  static weekStrip(): WeekStripDay[] {
    const today: Date = new Date();
    const weekdayFromMonday: number = (today.getDay() + 6) % 7;
    const monday: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate() - weekdayFromMonday);
    const days: WeekStripDay[] = [];
    for (let i = 0; i < 7; i++) {
      const day: Date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i);
      const item: WeekStripDay = {
        label: DateUtil.weekdayLabel(day),
        date: DateUtil.pad2(day.getDate()),
        active: false,
        dotColor: ''
      };
      days.push(item);
    }
    return days;
  }

  static countdown(): CountdownState {
    const c: CountdownState = { days: '00', hours: '00', minutes: '00', seconds: '00' };
    return c;
  }

  /** 赛后补题任务：无真实赛果来源时为空 */
  static upsolve(): UpsolveTask {
    const task: UpsolveTask = {
      contestName: '',
      resultText: '',
      percent: 0,
      problems: []
    };
    return task;
  }

  /** 热力图：真实数据由 DatabaseHelper 聚合；空数据全 0 */
  static heatmap(): number[] {
    const cells: number[] = [];
    for (let i = 0; i < 112; i++) {
      cells.push(0);
    }
    return cells;
  }

  /** 难度分布：真实数据由 StatsService 计算；空数据全 0 */
  static difficultyRows(): DifficultyRow[] {
    const rows: DifficultyRow[] = [
      { star: 1, name: '★1 入门', topic: '语法与模拟', count: 0, percent: 0 },
      { star: 2, name: '★2 基础', topic: '基础数据结构', count: 0, percent: 0 },
      { star: 3, name: '★3 进阶', topic: '动态规划与图论', count: 0, percent: 0 },
      { star: 4, name: '★4 困难', topic: '高级算法与数论', count: 0, percent: 0 },
      { star: 5, name: '★5 挑战', topic: '竞赛压轴与黑题', count: 0, percent: 0 }
    ];
    return rows;
  }

  /** 徽章：由 StatsService 按真实数据计算；此处为初始锁定态 */
  static badges(): BadgeItem[] {
    const list: BadgeItem[] = [
      { id: 'b1', name: '打卡30天', state: 'locked', stateText: '0/30', glyph: '◷' },
      { id: 'b2', name: '百题斩', state: 'locked', stateText: '0/100', glyph: '★' },
      { id: 'b3', name: '跨平台全能', state: 'locked', stateText: '0/3 平台', glyph: '◈' }
    ];
    return list;
  }

  /** 好友榜：暂无好友数据源，保持为空 */
  static leaderboard(): LeaderRow[] {
    const rows: LeaderRow[] = [];
    return rows;
  }

  static settings(): SettingRow[] {
    const rows: SettingRow[] = [
      {
        id: 's1', title: 'OJ 元数据同步管理', subtitle: '尚未同步',
        glyph: '⟳', kind: 'link', enabled: true
      },
      {
        id: 's2', title: '每日打卡催促通知', subtitle: '每晚 21:30 强提醒 · 避免断签',
        glyph: '◷', kind: 'toggle', enabled: false
      },
      {
        id: 's3', title: '刷题日志数据导出', subtitle: '暂未开放（v1.1）',
        glyph: '↓', kind: 'link', enabled: false
      }
    ];
    return rows;
  }

  /** 难度分布进度条颜色（难度色阶） */
  static difficultyBarColors(): string[] {
    return [CsColor.SECONDARY_CONTAINER, CsColor.SECONDARY, CsColor.PRIMARY_CONTAINER,
      CsColor.PRIMARY_FIXED_DIM, CsColor.ERROR];
  }
}
