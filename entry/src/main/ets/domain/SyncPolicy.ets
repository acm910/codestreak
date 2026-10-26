/**
 * 同步节流与降级策略（docs/04-技术设计/04 §降级、04-07 §6.1）
 * 纯函数，便于单测；不依赖时间源之外的状态。
 */
export class SyncPolicy {
  /** Codeforces 官方要求 ≤1 次/2 秒 */
  static readonly MIN_GAP_MS: number = 2000;
  /** 连续失败多少次后降级为「仅手动」 */
  static readonly DEGRADE_THRESHOLD: number = 3;

  /** 距离下一次可请求还需等待的毫秒数 */
  static waitMs(lastCallAt: number, now: number): number {
    if (lastCallAt <= 0) {
      return 0;
    }
    const elapsed: number = now - lastCallAt;
    if (elapsed >= SyncPolicy.MIN_GAP_MS) {
      return 0;
    }
    return SyncPolicy.MIN_GAP_MS - elapsed;
  }

  /** 指数退避：1→1 分钟，2→5 分钟，≥3→15 分钟 */
  static retryDelayMs(attempt: number): number {
    if (attempt <= 1) {
      return 60000;
    }
    if (attempt === 2) {
      return 300000;
    }
    return 900000;
  }

  /** 是否应降级为手动模式 */
  static shouldDegrade(consecutiveFailures: number): boolean {
    return consecutiveFailures >= SyncPolicy.DEGRADE_THRESHOLD;
  }

  /** 是否为可重试的失败（网络类/限流），业务错误不重试 */
  static isRetryable(message: string): boolean {
    return message.indexOf('HTTP') >= 0 || message.indexOf('网络') >= 0 || message.indexOf('limit') >= 0;
  }
}
