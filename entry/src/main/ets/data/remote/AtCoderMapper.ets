import { MapperResult, SyncSubmission } from '../../model/SyncModels';
import { Difficulty } from '../../utils/Difficulty';

/** kenkoooo AtCoder Problems 的提交结构（仅声明本项目使用的字段） */
interface AcSubmission {
  id?: number;
  epoch_second?: number;
  problem_id?: string;
  contest_id?: string;
  result?: string;
  language?: string;
}

/**
 * AtCoder 响应映射（docs/04-技术设计/07 §6.2）
 * 数据源为第三方公开 API（kenkoooo），返回的是数组而非 CF 的 {status,result} 包裹结构。
 * 难度：本版按题位字母估算（A→1.0 … G→5.0），接入 problem-models.json 前先保证可用（见 04-08 DEV-10）。
 */
export class AtCoderMapper {
  /** 题位字母 → 归一化难度 */
  static difficultyByLetter(problemId: string): number {
    if (problemId.length === 0) {
      return Difficulty.FALLBACK;
    }
    const letter: string = problemId.substring(problemId.length - 1).toLowerCase();
    if (letter === 'a') {
      return 1.0;
    }
    if (letter === 'b') {
      return 1.5;
    }
    if (letter === 'c') {
      return 2.5;
    }
    if (letter === 'd') {
      return 3.0;
    }
    if (letter === 'e') {
      return 4.0;
    }
    if (letter === 'f') {
      return 4.5;
    }
    if (letter === 'g' || letter === 'h') {
      return 5.0;
    }
    return Difficulty.FALLBACK;
  }

  /** user/submissions → 统一提交模型 */
  static mapSubmissions(raw: string): MapperResult {
    let parsed: AcSubmission[];
    try {
      parsed = JSON.parse(raw) as AcSubmission[];
    } catch (err) {
      return { ok: false, message: '响应不是合法 JSON 数组', submissions: [] };
    }
    if (!Array.isArray(parsed)) {
      return { ok: false, message: '响应结构不是数组', submissions: [] };
    }
    const submissions: SyncSubmission[] = [];
    for (const item of parsed) {
      const problemId: string = item.problem_id === undefined ? '' : item.problem_id;
      if (problemId.length === 0 || item.id === undefined) {
        continue;
      }
      const result: string = item.result === undefined ? 'UNKNOWN' : item.result;
      submissions.push({
        platform: 'AC',
        externalId: `${item.id}`,
        problemKey: `AC-${problemId}`,
        title: problemId,
        nativeDifficulty: problemId.substring(problemId.length - 1).toUpperCase(),
        difficultyNorm: AtCoderMapper.difficultyByLetter(problemId),
        verdict: result,
        epochSecond: item.epoch_second === undefined ? 0 : item.epoch_second,
        isAc: result === 'AC',
        tags: []
      });
    }
    return { ok: true, message: '', submissions: submissions };
  }

  /** 取这批提交里的最大时间戳，作为下一次增量水位 */
  static maxEpochSecond(submissions: SyncSubmission[]): number {
    let max: number = 0;
    for (const item of submissions) {
      if (item.epochSecond > max) {
        max = item.epochSecond;
      }
    }
    return max;
  }
}
