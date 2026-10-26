import { DailyAcCount } from '../model/Entities';
import { DateUtil } from './DateUtil';

/**
 * 热力图计算（docs/02-设计规范/02 §8.1、03-页面设计/05 §4.3）
 * 16 周 × 7 天，周一为行首；五档：0 / 1–2 / 3–5 / 6–8 / ≥9。
 */
export class Heatmap {
  static readonly WEEKS: number = 16;
  static readonly DAYS: number = 112;

  /** 当日 AC 数 → 档位 0–4 */
  static levelOf(count: number): number {
    if (count <= 0) {
      return 0;
    }
    if (count <= 2) {
      return 1;
    }
    if (count <= 5) {
      return 2;
    }
    if (count <= 8) {
      return 3;
    }
    return 4;
  }

  /** 网格起点：15 周前的周一（第 16 周为本周） */
  static gridStart(today: Date): Date {
    const day: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const weekdayFromMonday: number = (day.getDay() + 6) % 7;
    day.setDate(day.getDate() - weekdayFromMonday - (Heatmap.WEEKS - 1) * 7);
    return day;
  }

  /** 用「日期 → AC 数」构造 112 格档位，缺失日期记 0 */
  static buildLevels(start: Date, counts: DailyAcCount[]): number[] {
    const lookup: Map<string, number> = new Map<string, number>();
    for (const item of counts) {
      lookup.set(item.day, item.count);
    }
    const levels: number[] = [];
    for (let i = 0; i < Heatmap.DAYS; i++) {
      const day: Date = new Date(start.getFullYear(), start.getMonth(), start.getDate() + i);
      const key: string = DateUtil.dateKey(day);
      const count: number | undefined = lookup.get(key);
      levels.push(Heatmap.levelOf(count === undefined ? 0 : count));
    }
    return levels;
  }
}
