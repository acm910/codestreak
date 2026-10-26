import { CsColor } from '../constants/DesignTokens';
import { CommunityContest } from '../model/ContestFeed';
import { ContestItem } from '../model/Entities';
import { ContestStatus, PlatformCode } from '../model/Enums';
import { DateUtil } from '../utils/DateUtil';
import { CpcfinderAdapter } from './remote/CpcfinderAdapter';
import { CpcfinderMapper } from './remote/CpcfinderMapper';

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
        isCollegiate: true
      };
      result.push(item2);
    }
    return result;
  }
}
