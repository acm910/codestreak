import { MapperResult, SyncSubmission } from '../../model/SyncModels';

/** LeetCode 中国站 GraphQL 查询（docs/04-技术设计/07 §6.4） */
export const LC_RECENT_QUERY: string =
  'query recentAcSubmissions($username: String!, $limit: Int!) { ' +
    'recentAcSubmissionList(username: $username, limit: $limit) { id title titleSlug timestamp } }';

interface LcSubmission {
  id?: string;
  title?: string;
  titleSlug?: string;
  timestamp?: string;
}

interface LcData {
  recentAcSubmissionList?: LcSubmission[];
}

interface LcError {
  message?: string;
}

interface LcResponse {
  data?: LcData;
  errors?: LcError[];
}

/**
 * LeetCode 响应映射
 * 只返回 AC 记录，单次上限约 20 条；难度需额外查询，本版先以 3.0 兜底（DEV-15）。
 */
export class LeetCodeMapper {
  static mapRecentAc(raw: string): MapperResult {
    let parsed: LcResponse;
    try {
      parsed = JSON.parse(raw) as LcResponse;
    } catch (err) {
      return { ok: false, message: 'LeetCode 响应不是合法 JSON，可能需要登录', submissions: [] };
    }
    const errors: LcError[] = parsed.errors === undefined ? [] : parsed.errors;
    if (errors.length > 0) {
      const reason: string = errors[0].message === undefined ? 'GraphQL 返回错误' : errors[0].message;
      return { ok: false, message: reason, submissions: [] };
    }
    if (parsed.data === undefined || parsed.data.recentAcSubmissionList === undefined) {
      return { ok: false, message: 'LeetCode 响应缺少 AC 列表，可能需要登录', submissions: [] };
    }
    const list: LcSubmission[] = parsed.data.recentAcSubmissionList;
    if (!Array.isArray(list)) {
      return { ok: false, message: 'LeetCode 列表结构异常', submissions: [] };
    }
    const submissions: SyncSubmission[] = [];
    for (const item of list) {
      const slug: string = item.titleSlug === undefined ? '' : item.titleSlug;
      if (slug.length === 0) {
        continue;
      }
      const id: string = item.id === undefined ? slug : item.id;
      const timestamp: number = item.timestamp === undefined ? 0 : Number(item.timestamp);
      submissions.push({
        platform: 'LC',
        externalId: id,
        problemKey: `LC-${slug}`,
        title: item.title === undefined ? slug : item.title,
        nativeDifficulty: '',
        difficultyNorm: 3.0,
        verdict: 'AC',
        epochSecond: Number.isNaN(timestamp) ? 0 : timestamp,
        isAc: true,
        tags: []
      });
    }
    return { ok: true, message: '', submissions: submissions };
  }
}
