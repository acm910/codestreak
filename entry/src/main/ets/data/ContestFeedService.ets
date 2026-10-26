import { CsColor } from '../constants/DesignTokens';
import { CommunityContest } from '../model/ContestFeed';
import { ContestItem } from '../model/Entities';
import { ContestStatus, PlatformCode } from '../model/Enums';
import { DateUtil } from '../utils/DateUtil';
import { CpcfinderAdapter } from './remote/CpcfinderAdapter';
import { CpcfinderMapper } from './remote/CpcfinderMapper';
import { PlatformContestAdapter } from './remote/PlatformContestAdapter';

/**
 * ICPC / CCPC 赛程源（数据来自 https://cpcfinder.com/contest 的公开 JSON）
 * 拉取失败时返回空数组，页面继续展示本地种子赛事，不阻塞其它内容。
 */
export class ContestFeedService {
  static readonly FALLBACK_URL: string = 'https://cpcfinder.com/contest';

  static async loadUpcoming(limit: number): Promise<ContestItem[]> {
    const feed = await CpcfinderAdapter.fetchContests();
    if (!feed.ok || feed.items.length === 0) {
      return [];
    }
    const upcoming: CommunityContest[] = CpcfinderMapper.upcoming(feed.items, DateUtil.todayKey(), limit);
    const result: ContestItem[] = [];
    for (const item of upcoming) {
      const isIcpc: boolean = item.name.indexOf('ICPC') >= 0;
      const startEpoch: number = Math.floor(DateUtil.parseKey(item.date).getTime() / 1000);
      const item2: ContestItem = {
        id: item.id,
        platform: isIcpc ? PlatformCode.LC : PlatformCode.AC,
        platformLabel: CpcfinderMapper.groupLabel(item.name),
        name: item.name,
        timeText: item.date,
        durationText: '时长待定',
        status: ContestStatus.UPCOMING,
        statusText: item.isPending ? '未开始' : '已完赛',
        accent: isIcpc ? CsColor.PRIMARY_CONTAINER : CsColor.SECONDARY_CONTAINER,
        footerText: item.place.length > 0 ? `地点：${item.place} · 数据源 CPC Finder` : '数据源 CPC Finder',
        actionText: '查看榜单',
        secondaryText: '',
        pulsing: false,
        url: item.boardUrl.length > 0 ? item.boardUrl : ContestFeedService.FALLBACK_URL,
        isCollegiate: true,
        sortEpoch: startEpoch
      };
      result.push(item2);
    }
    return result;
  }

  /** 合并高校赛（CPC Finder）与平台赛程（CF / AtCoder），按开始时间升序 */
  static async loadAll(limitPerSource: number): Promise<ContestItem[]> {
    const merged: ContestItem[] = [];
    const collegiate: ContestItem[] = await ContestFeedService.loadUpcoming(limitPerSource);
    for (const item of collegiate) {
      merged.push(item);
    }
    const cf: ContestItem[] = await PlatformContestAdapter.fetchCodeforces(3);
    for (const item of cf) {
      merged.push(item);
    }
    const ac: ContestItem[] = await PlatformContestAdapter.fetchAtCoder(3);
    for (const item of ac) {
      merged.push(item);
    }
    merged.sort((a: ContestItem, b: ContestItem) => a.sortEpoch - b.sortEpoch);
    return merged;
  }
}
