import { MapperResult, SyncSubmission } from '../../model/SyncModels';
import { Difficulty } from '../../utils/Difficulty';

/** 洛谷 Lens 结构（仅声明本项目使用的字段） */
interface LgProblem {
  pid?: string;
  title?: string;
  /** 0–7，0 表示暂无评定 */
  difficulty?: number;
}

interface LgRecord {
  id?: number;
  /** 12=AC，6=WA，5=TLE，4=MLE，7=RE，2=CE */
  status?: number;
  submitTime?: number;
  problem?: LgProblem;
}

interface LgRecords {
  result?: LgRecord[];
}

interface LgCurrentData {
  records?: LgRecords;
}

interface LgResponse {
  currentData?: LgCurrentData;
}

/**
 * 洛谷记录映射（docs/04-技术设计/07 §6.3）
 * 走公开记录接口 `record/list`，Lens 结构 currentData.records.result。
 */
export class LuoguMapper {
  /** 洛谷 status → 判定文案 */
  static verdictOf(status: number): string {
    if (status === 12) {
      return 'AC';
    }
    if (status === 6) {
      return 'WA';
    }
    if (status === 5) {
      return 'TLE';
    }
    if (status === 4) {
      return 'MLE';
    }
    if (status === 7) {
      return 'RE';
    }
    if (status === 2) {
      return 'CE';
    }
    if (status === 3) {
      return 'OLE';
    }
    if (status === 1) {
      return 'JUDGING';
    }
    if (status === 0) {
      return 'PENDING';
    }
    return 'UNKNOWN';
  }

  static mapRecords(raw: string): MapperResult {
    let parsed: LgResponse;
    try {
      parsed = JSON.parse(raw) as LgResponse;
    } catch (err) {
      return { ok: false, message: '洛谷响应不是合法 JSON，可能需要登录', submissions: [] };
    }
    if (parsed.currentData === undefined || parsed.currentData.records === undefined) {
      return { ok: false, message: '洛谷响应缺少记录字段，可能需要登录', submissions: [] };
    }
    const records: LgRecord[] = parsed.currentData.records.result === undefined
      ? [] : parsed.currentData.records.result;
    if (!Array.isArray(records)) {
      return { ok: false, message: '洛谷记录结构异常', submissions: [] };
    }
    const submissions: SyncSubmission[] = [];
    for (const item of records) {
      const problem: LgProblem | undefined = item.problem;
      if (problem === undefined || problem.pid === undefined || item.id === undefined) {
        continue;
      }
      const status: number = item.status === undefined ? -1 : item.status;
      const nativeDifficulty: number = problem.difficulty === undefined ? 0 : problem.difficulty;
      submissions.push({
        platform: 'LG',
        externalId: `${item.id}`,
        problemKey: `LG-${problem.pid}`,
        title: problem.title === undefined ? problem.pid : problem.title,
        nativeDifficulty: nativeDifficulty > 0 ? `${nativeDifficulty}` : '',
        difficultyNorm: Difficulty.fromLuogu(nativeDifficulty),
        verdict: LuoguMapper.verdictOf(status),
        epochSecond: item.submitTime === undefined ? 0 : item.submitTime,
        isAc: status === 12,
        tags: []
      });
    }
    return { ok: true, message: '', submissions: submissions };
  }
}
