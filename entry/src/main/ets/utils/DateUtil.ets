/** 日期与周数工具：统一按 Asia/Shanghai 口径展示 */
export class DateUtil {
  /** ISO 8601 周数（周一为周首） */
  static isoWeek(date: Date): number {
    const d: Date = new Date(date.getTime());
    const day: number = (d.getDay() + 6) % 7;
    d.setDate(d.getDate() - day + 3);
    const firstThursday: Date = new Date(d.getFullYear(), 0, 4);
    const firstDay: number = (firstThursday.getDay() + 6) % 7;
    firstThursday.setDate(firstThursday.getDate() - firstDay + 3);
    const diff: number = d.getTime() - firstThursday.getTime();
    return 1 + Math.round(diff / (7 * 24 * 3600 * 1000));
  }

  /** 周二三四五六日 一 */
  static weekdayLabel(date: Date): string {
    const labels: string[] = ['日', '一', '二', '三', '四', '五', '六'];
    return labels[date.getDay()];
  }

  /** 两位补零 */
  static pad2(value: number): string {
    return value < 10 ? `0${value}` : `${value}`;
  }

  /** HH:mm */
  static hhmm(date: Date): string {
    return `${DateUtil.pad2(date.getHours())}:${DateUtil.pad2(date.getMinutes())}`;
  }

  /** 本地日期键 YYYY-MM-DD（打卡去重与统计的日粒度） */
  static todayKey(): string {
    const now: Date = new Date();
    return `${now.getFullYear()}-${DateUtil.pad2(now.getMonth() + 1)}-${DateUtil.pad2(now.getDate())}`;
  }

  /** 指定日期的 key */
  static dateKey(date: Date): string {
    return `${date.getFullYear()}-${DateUtil.pad2(date.getMonth() + 1)}-${DateUtil.pad2(date.getDate())}`;
  }

  /** YYYY-MM-DD → 本地 Date */
  static parseKey(key: string): Date {
    const parts: string[] = key.split('-');
    if (parts.length !== 3) {
      return new Date();
    }
    return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  }

  /** 日期平移 n 天，返回 key */
  static shiftKey(key: string, days: number): string {
    const day: Date = DateUtil.parseKey(key);
    day.setDate(day.getDate() + days);
    return DateUtil.dateKey(day);
  }

  /** 相对日期文案：今天 / 明天 / 周X / 下周X / MM-DD */
  static relativeDay(target: Date, now: Date): string {
    const startOfToday: number = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    const startOfTarget: number = new Date(target.getFullYear(), target.getMonth(), target.getDate()).getTime();
    const diffDays: number = Math.round((startOfTarget - startOfToday) / 86400000);
    if (diffDays === 0) {
      return '今天';
    }
    if (diffDays === 1) {
      return '明天';
    }
    const weekNow: number = DateUtil.isoWeek(now);
    const weekTarget: number = DateUtil.isoWeek(target);
    const label: string = `周${DateUtil.weekdayLabel(target)}`;
    if (weekNow === weekTarget) {
      return label;
    }
    if (weekTarget === weekNow + 1) {
      return `下${label}`;
    }
    return `${DateUtil.pad2(target.getMonth() + 1)}-${DateUtil.pad2(target.getDate())}`;
  }
}
