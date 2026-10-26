/**
 * 难度归一化（docs/04-技术设计/04-平台同步与难度归一化.md §6）
 * - CF / AtCoder：Elo 线性映射，半档向下取整
 * - LeetCode：Easy 2.0 / Medium 3.0 / Hard 4.5
 * - 洛谷：七级 → 1.0/1.5/2.0/3.0/4.0/4.5/5.0
 * - 未知：兜底 3.0
 */
export class Difficulty {
  static readonly FALLBACK: number = 3.0;

  /** CF 题目的官方 rating → 归一化难度 */
  static fromRating(rating: number): number {
    if (rating <= 0) {
      return Difficulty.FALLBACK;
    }
    const raw: number = 1 + (rating - 800) / 400;
    const clamped: number = Math.min(5, Math.max(1, raw));
    const half: number = Math.floor(clamped * 2 + 0.5 - 1e-9) / 2;
    return Math.min(5, Math.max(1, half));
  }

  /** LeetCode 原生难度 */
  static fromLeetCode(level: string): number {
    if (level === 'Easy') {
      return 2.0;
    }
    if (level === 'Medium') {
      return 3.0;
    }
    if (level === 'Hard') {
      return 4.5;
    }
    return Difficulty.FALLBACK;
  }

  /** 洛谷难度等级 0–6（0=暂无评定） */
  static fromLuogu(level: number): number {
    if (level <= 0) {
      return Difficulty.FALLBACK;
    }
    if (level === 1) {
      return 1.0;
    }
    if (level === 2) {
      return 1.5;
    }
    if (level === 3) {
      return 2.0;
    }
    if (level === 4) {
      return 3.0;
    }
    if (level === 5) {
      return 4.0;
    }
    if (level === 6) {
      return 4.5;
    }
    return 5.0;
  }

  /** 展示用：★3 / ★2.5 */
  static starText(norm: number): string {
    return norm % 1 === 0 ? `★${norm.toFixed(0)}` : `★${norm.toFixed(1)}`;
  }
}
