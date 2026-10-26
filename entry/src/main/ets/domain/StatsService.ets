import { CsColor } from '../constants/DesignTokens';
import { AcStats, BadgeItem, DifficultyRow, WeekCell, WeekStripDay } from '../model/Entities';
import { DateUtil } from '../utils/DateUtil';

export interface StreakResult {
  current: number;
  longest: number;
}

/**
 * 统计口径（docs/06-附录/01 D-07~D-12）
 * 全部基于真实打卡与提交记录计算；无数据即 0，不构造示例值。
 */
export class StatsService {
  /** 连续打卡与生涯最长（achievedDates 为达标日期，YYYY-MM-DD） */
  static streaks(achievedDates: string[], todayKey: string): StreakResult {
    const set: Set<string> = new Set<string>();
    for (const day of achievedDates) {
      set.add(day);
    }
    let cursor: string = set.has(todayKey) ? todayKey : DateUtil.shiftKey(todayKey, -1);
    let current: number = 0;
    while (set.has(cursor)) {
      current = current + 1;
      cursor = DateUtil.shiftKey(cursor, -1);
    }

    const sorted: string[] = Array.from(set).sort();
    let longest: number = 0;
    let run: number = 0;
    let previous: string = '';
    for (const day of sorted) {
      if (previous.length === 0 || DateUtil.shiftKey(previous, 1) === day) {
        run = run + 1;
      } else {
        run = 1;
      }
      if (run > longest) {
        longest = run;
      }
      previous = day;
    }
    const result: StreakResult = { current: current, longest: longest };
    return result;
  }

  /** 本周打卡矩阵（周一为首列） */
  static weekCells(achievedDates: string[], today: Date): WeekCell[] {
    const set: Set<string> = new Set<string>(achievedDates);
    const todayKey: string = DateUtil.dateKey(today);
    const weekdayFromMonday: number = (today.getDay() + 6) % 7;
    const monday: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate() - weekdayFromMonday);
    const labels: string[] = ['一', '二', '三', '四', '五', '六', '日'];
    const cells: WeekCell[] = [];
    for (let i = 0; i < 7; i++) {
      const day: Date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i);
      const key: string = DateUtil.dateKey(day);
      let state: 'done' | 'today' | 'future' = 'future';
      if (key === todayKey) {
        state = 'today';
      } else if (key < todayKey && set.has(key)) {
        state = 'done';
      }
      const cell: WeekCell = { label: labels[i], state: state };
      cells.push(cell);
    }
    return cells;
  }

  /** 比赛页周条（本周一至周日） */
  static weekStrip(achievedDates: string[], today: Date): WeekStripDay[] {
    const set: Set<string> = new Set<string>(achievedDates);
    const weekdayFromMonday: number = (today.getDay() + 6) % 7;
    const monday: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate() - weekdayFromMonday);
    const todayKey: string = DateUtil.dateKey(today);
    const days: WeekStripDay[] = [];
    for (let i = 0; i < 7; i++) {
      const day: Date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i);
      const key: string = DateUtil.dateKey(day);
      const active: boolean = set.has(key);
      let dot: string = '';
      if (key === todayKey) {
        dot = CsColor.PRIMARY_CONTAINER;
      } else if (active) {
        dot = CsColor.SECONDARY;
      }
      const item: WeekStripDay = {
        label: DateUtil.weekdayLabel(day),
        date: DateUtil.pad2(day.getDate()),
        active: active,
        dotColor: dot
      };
      days.push(item);
    }
    return days;
  }

  /** 难度分布（真实 AC 题数） */
  static difficultyRows(counts: number[]): DifficultyRow[] {
    const names: string[] = ['★1 入门', '★2 基础', '★3 进阶', '★4 困难', '★5 挑战'];
    const topics: string[] = ['语法与模拟', '基础数据结构', '动态规划与图论', '高级算法与数论', '竞赛压轴与黑题'];
    let total: number = 0;
    for (const count of counts) {
      total = total + count;
    }
    const rows: DifficultyRow[] = [];
    for (let i = 0; i < 5; i++) {
      const count: number = i < counts.length ? counts[i] : 0;
      const percent: number = total === 0 ? 0 : Math.round(count * 1000 / total) / 10;
      const row: DifficultyRow = {
        star: i + 1,
        name: names[i],
        topic: topics[i],
        count: count,
        percent: percent
      };
      rows.push(row);
    }
    return rows;
  }

  /** 徽章：只展示可计算的条件，未接入的保持未解锁 */
  static badges(stats: StreakResult, ac: AcStats): BadgeItem[] {
    const streakText: string = stats.current >= 30 ? '已解锁' : `进行中 ${stats.current}/30`;
    const streakState: 'locked' | 'in_progress' | 'unlocked' = stats.current >= 30 ? 'unlocked' : 'in_progress';
    const platformState: 'locked' | 'in_progress' | 'unlocked' =
      ac.platforms >= 3 ? 'unlocked' : (ac.platforms > 0 ? 'in_progress' : 'locked');
    const platformText: string = ac.platforms >= 3 ? '已解锁' : `${ac.platforms}/3 平台`;
    const hundredState: 'locked' | 'in_progress' | 'unlocked' =
      ac.solved >= 100 ? 'unlocked' : (ac.solved > 0 ? 'in_progress' : 'locked');

    const list: BadgeItem[] = [
      { id: 'b1', name: '打卡30天', state: streakState, stateText: streakText, glyph: '◷' },
      { id: 'b2', name: '百题斩', state: hundredState, stateText: ac.solved >= 100 ? '已解锁' : `${ac.solved}/100`, glyph: '★' },
      { id: 'b3', name: '跨平台全能', state: platformState, stateText: platformText, glyph: '◈' }
    ];
    return list;
  }
}
