import { CommunityContest, ContestFeedResult } from '../../model/ContestFeed';

/** CPC Finder /api/contest 的响应结构（仅声明本项目使用的字段） */
interface CpcfLink {
  name?: string;
  url?: string;
}

interface CpcfContest {
  contestId?: number;
  name?: string;
  place?: string;
  date?: string;
  dataStatus?: string;
  links?: CpcfLink[];
}

interface CpcfResponse {
  data?: CpcfContest[];
}

/**
 * CPC Finder 赛事源映射（ICPC / CCPC）
 * 站点：https://cpcfinder.com/contest ；接口：GET /api/contest（公开 JSON）
 */
export class CpcfinderMapper {
  static mapContests(raw: string): ContestFeedResult {
    let parsed: CpcfResponse;
    try {
      parsed = JSON.parse(raw) as CpcfResponse;
    } catch (err) {
      return { ok: false, message: '赛事数据不是合法 JSON', items: [] };
    }
    const list: CpcfContest[] = parsed.data === undefined ? [] : parsed.data;
    if (!Array.isArray(list)) {
      return { ok: false, message: '赛事数据结构异常', items: [] };
    }
    const items: CommunityContest[] = [];
    for (const item of list) {
      if (item.contestId === undefined || item.name === undefined) {
        continue;
      }
      const links: CpcfLink[] = item.links === undefined ? [] : item.links;
      let boardUrl: string = '';
      if (links.length > 0 && links[0].url !== undefined) {
        boardUrl = links[0].url;
      }
      const status: string = item.dataStatus === undefined ? 'PENDING_CONTEST' : item.dataStatus;
      items.push({
        id: `cpcf-${item.contestId}`,
        name: item.name,
        place: item.place === undefined ? '' : item.place,
        date: item.date === undefined ? '' : item.date,
        dataStatus: status,
        boardUrl: boardUrl,
        isPending: status === 'PENDING_CONTEST'
      });
    }
    return { ok: true, message: '', items: items };
  }

  /** 名称 → 分组标签 */
  static groupLabel(name: string): string {
    if (name.indexOf('ICPC') >= 0) {
      if (name.indexOf('东亚区决赛') >= 0) {
        return 'ICPC 决赛';
      }
      return 'ICPC 区域赛';
    }
    if (name.indexOf('CCPC') >= 0) {
      if (name.indexOf('总决赛') >= 0) {
        return 'CCPC 总决赛';
      }
      return 'CCPC 分站赛';
    }
    return '高校赛事';
  }

  /** 过滤出「今天及以后」的赛事（日期字符串按 ISO 可直接比较） */
  static upcoming(items: CommunityContest[], today: string, limit: number): CommunityContest[] {
    const result: CommunityContest[] = [];
    for (const item of items) {
      if (item.date.length === 0) {
        continue;
      }
      if (item.date < today) {
        continue;
      }
      result.push(item);
      if (result.length >= limit) {
        break;
      }
    }
    return result;
  }
}
