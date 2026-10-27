import { ContestItem } from '../../model/Entities';
import { ContestStatus, PlatformCode } from '../../model/Enums';
import { DateUtil } from '../../utils/DateUtil';

/** Codeforces contest.list 响应 */
interface CfContest {
  id?: number;
  name?: string;
  startTimeSeconds?: number;
  durationSeconds?: number;
  phase?: string;
}

interface CfResponse {
  status?: string;
  result?: CfContest[];
}

/** kenkoooo contests.json 条目 */
interface AcContest {
  id?: string;
  title?: string;
  start_epoch?: number;
  duration_seconds?: number;
  rate_change?: string;
}

/**
 * 平台赛程映射（CF / AtCoder）
 * 只保留未开始的比赛，按开始时间升序，最多 limit 场。
 */
export class PlatformContestMapper {
  private static timeText(epochSecond: number): string {
    const day: Date = new Date(epochSecond * 1000);
    return `${DateUtil.pad2(day.getMonth() + 1)}-${DateUtil.pad2(day.getDate())} ` +
      `${DateUtil.pad2(day.getHours())}:${DateUtil.pad2(day.getMinutes())}`;
  }

  private static durationText(seconds: number): string {
    if (seconds <= 0) {
      return '时长待定';
    }
    return `${Math.round(seconds / 60)}分钟`;
  }

  static mapCodeforces(raw: string, nowSecond: number, limit: number): ContestItem[] {
    let parsed: CfResponse;
    try {
      parsed = JSON.parse(raw) as CfResponse;
    } catch (err) {
      return [];
    }
    if (parsed.result === undefined || !Array.isArray(parsed.result)) {
      return [];
    }
    const upcoming: CfContest[] = [];
    for (const item of parsed.result) {
      if (item.id === undefined || item.startTimeSeconds === undefined) {
        continue;
      }
      if (item.startTimeSeconds <= nowSecond) {
        continue;
      }
      // 过滤超长赛程（如 14 天的 ICPC Online Challenge），避免日历出现异常时长
      if (item.durationSeconds !== undefined && item.durationSeconds > 86400) {
        continue;
      }
      upcoming.push(item);
    }
    upcoming.sort((a: CfContest, b: CfContest) => (a.startTimeSeconds as number) - (b.startTimeSeconds as number));
    const items: ContestItem[] = [];
    for (const item of upcoming) {
      if (items.length >= limit) {
        break;
      }
      const start: number = item.startTimeSeconds as number;
      const contest: ContestItem = {
        id: `cf-${item.id}`,
        platform: PlatformCode.CF,
        platformLabel: 'Codeforces',
        name: item.name === undefined ? `Codeforces Contest ${item.id}` : item.name,
        timeText: PlatformContestMapper.timeText(start),
        durationText: PlatformContestMapper.durationText(item.durationSeconds === undefined ? 0 : item.durationSeconds),
        status: ContestStatus.UPCOMING,
        statusText: '未开始',
        accent: '',
        footerText: '数据源 Codeforces API',
        actionText: '前往比赛',
        secondaryText: '',
        pulsing: false,
        url: `https://codeforces.com/contest/${item.id}`,
        isCollegiate: false,
        sortEpoch: start
      };
      items.push(contest);
    }
    return items;
  }

  static mapAtCoder(raw: string, nowSecond: number, limit: number): ContestItem[] {
    let parsed: AcContest[];
    try {
      parsed = JSON.parse(raw) as AcContest[];
    } catch (err) {
      return [];
    }
    if (!Array.isArray(parsed)) {
      return [];
    }
    const upcoming: AcContest[] = [];
    for (const item of parsed) {
      if (item.id === undefined || item.start_epoch === undefined) {
        continue;
      }
      if (item.start_epoch <= nowSecond) {
        continue;
      }
      upcoming.push(item);
    }
    upcoming.sort((a: AcContest, b: AcContest) => (a.start_epoch as number) - (b.start_epoch as number));
    const items: ContestItem[] = [];
    for (const item of upcoming) {
      if (items.length >= limit) {
        break;
      }
      const start: number = item.start_epoch as number;
      const contest: ContestItem = {
        id: `ac-${item.id}`,
        platform: PlatformCode.AC,
        platformLabel: 'AtCoder',
        name: item.title === undefined ? `AtCoder ${item.id}` : item.title,
        timeText: PlatformContestMapper.timeText(start),
        durationText: PlatformContestMapper.durationText(item.duration_seconds === undefined ? 0 : item.duration_seconds),
        status: ContestStatus.UPCOMING,
        statusText: '未开始',
        accent: '',
        footerText: `数据源 AtCoder Problems${item.rate_change === undefined ? '' : ` · ${item.rate_change}`}`,
        actionText: '查看详情',
        secondaryText: '',
        pulsing: false,
        url: `https://atcoder.jp/contests/${item.id}`,
        isCollegiate: false,
        sortEpoch: start
      };
      items.push(contest);
    }
    return items;
  }
}
