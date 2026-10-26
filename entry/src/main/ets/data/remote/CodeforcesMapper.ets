import { MapperResult, SyncSubmission } from '../../model/SyncModels';
import { Difficulty } from '../../utils/Difficulty';

/** CF 官方 API 返回结构（仅声明本项目使用的字段） */
interface CfProblem {
  contestId?: number;
  index?: string;
  name?: string;
  rating?: number;
  tags?: string[];
}

interface CfSubmission {
  id?: number;
  creationTimeSeconds?: number;
  verdict?: string;
  problem?: CfProblem;
}

interface CfStatusResponse {
  status?: string;
  comment?: string;
  result?: CfSubmission[];
}

interface CfUser {
  handle?: string;
  rating?: number;
  maxRating?: number;
  rank?: string;
}

interface CfUserResponse {
  status?: string;
  comment?: string;
  result?: CfUser[];
}

/**
 * Codeforces 响应映射（docs/04-技术设计/07 §6.1）
 * 纯函数、无网络依赖，便于用固定 fixture 做契约测试。
 */
export class CodeforcesMapper {
  /** user.status → 统一提交模型 */
  static mapStatus(raw: string): MapperResult {
    let parsed: CfStatusResponse;
    try {
      parsed = JSON.parse(raw) as CfStatusResponse;
    } catch (err) {
      return { ok: false, message: '响应不是合法 JSON', submissions: [] };
    }
    if (parsed.status !== 'OK') {
      const reason: string = parsed.comment === undefined ? '接口返回失败' : parsed.comment;
      return { ok: false, message: reason, submissions: [] };
    }
    const list: CfSubmission[] = parsed.result === undefined ? [] : parsed.result;
    const submissions: SyncSubmission[] = [];
    for (const item of list) {
      const problem: CfProblem | undefined = item.problem;
      if (problem === undefined || item.id === undefined) {
        continue;
      }
      const contestId: string = problem.contestId === undefined ? '0' : `${problem.contestId}`;
      const index: string = problem.index === undefined ? '' : problem.index;
      const rating: number = problem.rating === undefined ? 0 : problem.rating;
      const verdict: string = item.verdict === undefined ? 'UNKNOWN' : item.verdict;
      submissions.push({
        platform: 'CF',
        externalId: `${item.id}`,
        problemKey: `CF-${contestId}${index}`,
        title: problem.name === undefined ? '' : problem.name,
        nativeDifficulty: rating > 0 ? `${rating}` : '',
        difficultyNorm: Difficulty.fromRating(rating),
        verdict: verdict,
        epochSecond: item.creationTimeSeconds === undefined ? 0 : item.creationTimeSeconds,
        isAc: verdict === 'OK',
        tags: problem.tags === undefined ? [] : problem.tags
      });
    }
    return { ok: true, message: '', submissions: submissions };
  }

  /** user.info → rating（无 rating 时返回 0） */
  static mapUserRating(raw: string): number {
    let parsed: CfUserResponse;
    try {
      parsed = JSON.parse(raw) as CfUserResponse;
    } catch (err) {
      return 0;
    }
    const list: CfUser[] = parsed.result === undefined ? [] : parsed.result;
    if (list.length === 0) {
      return 0;
    }
    const rating: number | undefined = list[0].rating;
    return rating === undefined ? 0 : rating;
  }

  /** 统计 AC 题数（按 problemKey 去重） */
  static countAccepted(submissions: SyncSubmission[]): number {
    const seen: string[] = [];
    for (const item of submissions) {
      if (!item.isAc) {
        continue;
      }
      if (seen.indexOf(item.problemKey) < 0) {
        seen.push(item.problemKey);
      }
    }
    return seen.length;
  }
}
