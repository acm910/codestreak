import { CsColor } from '../constants/DesignTokens';
import { CheckInStatus, ContestStatus, PlatformCode, SolveStatus, UpsolveState } from '../model/Enums';
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
 * 自洽示例数据集 v1（docs/06-附录/01 第 6 节）
 * 连续 28 · 生涯最长 64 · 累计 152 · 总 AC 384 · 占比 22.1/29.2/33.9/11.7/3.1
 * 所有页面共用同一份数据，保证跨页口径一致。
 */
export class SeedData {
  static today(): TodaySnapshot {
    const snap: TodaySnapshot = {
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
      sourceText: ''
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
      sourceText: 'RATING: 900'
    };
    const data: ChallengeCardData = { problem: problem, ratingText: 'RATING: 900' };
    return data;
  }

  /** 本周打卡矩阵：周一至周五已完成，周六为今日，周日未到 */
  static weekCells(): WeekCell[] {
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
    const cells: WeekCell[] = [];
    for (let i = 0; i < labels.length; i++) {
      let state: 'done' | 'today' | 'future' = 'done';
      if (i === 5) {
        state = 'today';
      } else if (i === 6) {
        state = 'future';
      }
      const cell: WeekCell = { label: labels[i], state: state };
      cells.push(cell);
    }
    return cells;
  }

  /** P-02 官方精选题单（3 张） */
  static collections(): CollectionCard[] {
    const list: CollectionCard[] = [
      {
        id: 'c1', tag: '高频面试', title: '代码随想录 · 核心 60 题',
        desc: '经典数组、动态规划及单调栈体系化通关路线。',
        done: 42, total: 60, percent: 70
      },
      {
        id: 'c2', tag: '竞赛排位', title: 'CF 1200-1400 突破营',
        desc: '攻克 Div.3 C/D 与 Div.2 B/C 贪心与二分分水岭题目。',
        done: 15, total: 45, percent: 33
      },
      {
        id: 'c3', tag: '经典必刷', title: '剑指 Offer 经典必刷',
        desc: '国内大厂考察极高频的代码与数据结构模版题。',
        done: 67, total: 75, percent: 89
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
        tags: ['双指针', '排序'], status: SolveStatus.SOLVED, sourceText: ''
      },
      {
        id: 'p-cf-1352c', platform: PlatformCode.CF, platformName: 'Codeforces', code: 'CF-1352C',
        title: 'K-th Not Divisible by n', titleEn: '', difficulty: 2, nativeLabel: '(1200)',
        tags: ['二分查找', '数学'], status: SolveStatus.DOING, sourceText: 'Round #640 (Div. 4)'
      },
      {
        id: 'p-lg-p3372', platform: PlatformCode.LG, platformName: '洛谷', code: 'LG-P3372',
        title: '【模板】线段树 1', titleEn: '', difficulty: 3,
        nativeLabel: '普及+/提高',
        tags: ['数据结构', '线段树'], status: SolveStatus.TODO, sourceText: ''
      }
    ];
    return list;
  }

  /** P-03 赛事（6 张，含 ICPC / CCPC） */
  static contests(): ContestItem[] {
    const list: ContestItem[] = [
      {
        id: 'ct-icpc', platform: PlatformCode.LC, platformLabel: 'ICPC 区域赛',
        name: '2024 ICPC 亚洲区域赛网络预选赛（第一场）',
        timeText: '周日 09:00 - 14:00', durationText: '300分钟',
        status: ContestStatus.REGISTERING, statusText: '报名中',
        accent: CsColor.PRIMARY_CONTAINER, footerText: '队伍状态：主力队已绑定 (3/3人)',
        actionText: '报名详情', secondaryText: '一键提醒队友', pulsing: true
      },
      {
        id: 'ct-ccpc', platform: PlatformCode.AC, platformLabel: 'CCPC 分站赛',
        name: '第十届 CCPC 中国大学生程序设计竞赛分站赛',
        timeText: '06-11 09:00', durationText: '300分钟',
        status: ContestStatus.PREPARING, statusText: '备赛中',
        accent: CsColor.SECONDARY_CONTAINER, footerText: '规则：ICPC 赛制 • 封榜 60 分钟',
        actionText: '竞赛官网', secondaryText: '同步日程', pulsing: false
      },
      {
        id: 'ct-lc', platform: PlatformCode.LC, platformLabel: 'LeetCode',
        name: 'LeetCode 第 398 场周赛',
        timeText: '周日 10:30 - 12:00', durationText: '90分钟',
        status: ContestStatus.UPCOMING, statusText: '未开始',
        accent: '', footerText: '已有 14,290 名选手报名',
        actionText: '报名链接', secondaryText: '', pulsing: false
      },
      {
        id: 'ct-cf', platform: PlatformCode.CF, platformLabel: 'Codeforces',
        name: 'Codeforces Round 951 (Div. 2)',
        timeText: '下周二 22:35', durationText: '120分钟',
        status: ContestStatus.UPCOMING, statusText: '未开始',
        accent: '', footerText: '距离注册通道关闭还有 2 天',
        actionText: '前往CF', secondaryText: '', pulsing: false
      },
      {
        id: 'ct-ac', platform: PlatformCode.AC, platformLabel: 'AtCoder',
        name: 'AtCoder Beginner Contest 356',
        timeText: '今日 20:00', durationText: '100分钟',
        status: ContestStatus.UPCOMING, statusText: '未开始',
        accent: '', footerText: 'Rated for ≤ 1999',
        actionText: '报名竞赛', secondaryText: '', pulsing: false
      },
      {
        id: 'ct-lg', platform: PlatformCode.LG, platformLabel: '洛谷',
        name: '「LGR-188」洛谷 6 月月赛 I & Code+',
        timeText: '周日 14:00', durationText: '240分钟',
        status: ContestStatus.UPCOMING, statusText: '未开始',
        accent: '', footerText: '难度跨度 普及+/提高至省选',
        actionText: '进入比赛', secondaryText: '', pulsing: false
      }
    ];
    return list;
  }

  /** P-03 周条（06-05 ~ 06-11） */
  static weekStrip(): WeekStripDay[] {
    const labels: string[] = ['四', '五', '六', '日', '一', '二', '三'];
    const dates: string[] = ['05', '06', '07', '08', '09', '10', '11'];
    const days: WeekStripDay[] = [];
    for (let i = 0; i < labels.length; i++) {
      const active: boolean = i === 2 || i === 3 || i === 5;
      let dot: string = '';
      if (i === 2) {
        dot = CsColor.PRIMARY_CONTAINER;
      } else if (i === 3) {
        dot = CsColor.TERTIARY;
      } else if (i === 5) {
        dot = CsColor.SECONDARY;
      }
      const day: WeekStripDay = { label: labels[i], date: dates[i], active: active, dotColor: dot };
      days.push(day);
    }
    return days;
  }

  static countdown(): CountdownState {
    const c: CountdownState = { days: '01', hours: '04', minutes: '20', seconds: '10' };
    return c;
  }

  /** 赛后补题任务：3 AC + 1 待补 */
  static upsolve(): UpsolveTask {
    const task: UpsolveTask = {
      contestName: 'Codeforces Round 949 (Div. 3)',
      resultText: '比赛已结束 • 当前赛后战果：3 AC / 1 待补题',
      percent: 75,
      problems: [
        {
          letter: 'A', title: 'Turtle and Piggy Are Playing a Game',
          difficultyText: '★1 签到题 • 贪心/位运算',
          state: UpsolveState.AC_IN_CONTEST, stateText: 'AC (赛中通过)', focused: false
        },
        {
          letter: 'B', title: 'Turtle and an Infinite Sequence',
          difficultyText: '★2 构造/位运算分析',
          state: UpsolveState.AC_IN_CONTEST, stateText: 'AC (赛中通过)', focused: false
        },
        {
          letter: 'C', title: 'Turtle and an Incomplete Sequence',
          difficultyText: '★2.5 二叉树/LCA/构造',
          state: UpsolveState.AC_AFTER, stateText: 'AC (赛后补题已录入)', focused: false
        },
        {
          letter: 'D', title: 'Turtle and a MEX Problem',
          difficultyText: '★3 难度 • 图论/MEX/有向图DP',
          state: UpsolveState.PENDING, stateText: '待补题', focused: true
        }
      ]
    };
    return task;
  }

  /** 热力图：16 周 × 7 天，取值 0–4（确定性生成，保证每次渲染一致） */
  static heatmap(): number[] {
    const cells: number[] = [];
    for (let i = 0; i < 112; i++) {
      const base: number = (i * 37 + 11) % 7;
      let level: number = 0;
      if (base === 0) {
        level = 0;
      } else if (base <= 2) {
        level = 1;
      } else if (base <= 4) {
        level = 2;
      } else if (base === 5) {
        level = 3;
      } else {
        level = 4;
      }
      // 近 4 周整体更活跃（贴合原型"近期持续打卡"）
      if (i > 84 && level < 2) {
        level = 2;
      }
      cells.push(level);
    }
    return cells;
  }

  /** 难度分布：85 / 112 / 130 / 45 / 12 = 384 */
  static difficultyRows(): DifficultyRow[] {
    const rows: DifficultyRow[] = [
      { star: 1, name: '★1 入门', topic: '语法与模拟', count: 85, percent: 22.1 },
      { star: 2, name: '★2 基础', topic: '基础数据结构', count: 112, percent: 29.2 },
      { star: 3, name: '★3 进阶', topic: '动态规划与图论', count: 130, percent: 33.9 },
      { star: 4, name: '★4 困难', topic: '高级算法与数论', count: 45, percent: 11.7 },
      { star: 5, name: '★5 挑战', topic: '竞赛压轴与黑题', count: 12, percent: 3.1 }
    ];
    return rows;
  }

  static badges(): BadgeItem[] {
    const list: BadgeItem[] = [
      { id: 'b1', name: '打卡30天', state: 'in_progress', stateText: '进行中 28/30', glyph: '◷' },
      { id: 'b2', name: '周赛全A', state: 'unlocked', stateText: '已解锁', glyph: '★' },
      { id: 'b3', name: '跨平台全能', state: 'unlocked', stateText: '已解锁', glyph: '◈' }
    ];
    return list;
  }

  static leaderboard(): LeaderRow[] {
    const rows: LeaderRow[] = [
      { rank: 1, name: 'ACM_Kimi', subtitle: 'Codeforces Grandmaster', days: 45, isYou: false },
      { rank: 2, name: 'EchoByte_Dev', subtitle: 'LeetCode 2380+', days: 34, isYou: false },
      { rank: 3, name: 'AlgoMaster_Lin', subtitle: '保持冲刺，距前一名仅差 6 天', days: 28, isYou: true }
    ];
    return rows;
  }

  static settings(): SettingRow[] {
    const rows: SettingRow[] = [
      {
        id: 's1', title: 'OJ 元数据同步管理', subtitle: '上次同步: 今天 19:42 · 自动轮询已开启',
        glyph: '⟳', kind: 'link', enabled: true
      },
      {
        id: 's2', title: '每日打卡催促通知', subtitle: '每晚 21:30 强提醒 · 避免断签',
        glyph: '◷', kind: 'toggle', enabled: true
      },
      {
        id: 's3', title: '刷题日志数据导出', subtitle: '支持导出 JSON / Markdown 题解索引',
        glyph: '↓', kind: 'link', enabled: true
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
