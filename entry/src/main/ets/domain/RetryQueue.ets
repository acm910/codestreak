import { SyncPolicy } from './SyncPolicy';

/** 一条失败重试记录 */
export interface RetryEntry {
  platform: string;
  target: string;
  /** 已失败次数（1 表示第一次失败后待重试） */
  attempt: number;
  /** 下次可重试时间（epoch ms） */
  nextAt: number;
}

/**
 * 失败重试队列（docs/04-技术设计/04 §失败与降级）
 * 纯函数：负责序列化、到期判断与下一次退避；实际调度由 SyncService 落库并驱动。
 */
export class RetryQueue {
  static readonly MAX_ATTEMPTS: number = 3;

  static encode(entry: RetryEntry): string {
    return `${entry.platform}|${entry.target}|${entry.attempt}|${entry.nextAt}`;
  }

  static decode(raw: string): RetryEntry | null {
    if (raw.length === 0) {
      return null;
    }
    const parts: string[] = raw.split('|');
    if (parts.length !== 4) {
      return null;
    }
    const attempt: number = Number(parts[2]);
    const nextAt: number = Number(parts[3]);
    if (Number.isNaN(attempt) || Number.isNaN(nextAt)) {
      return null;
    }
    const entry: RetryEntry = {
      platform: parts[0],
      target: parts[1],
      attempt: attempt,
      nextAt: nextAt
    };
    return entry;
  }

  static isDue(entry: RetryEntry, now: number): boolean {
    return now >= entry.nextAt;
  }

  /** 失败一次后生成下一条待重试记录；达到上限返回 null（降级手动） */
  static afterFailure(platform: string, target: string, failedAttempts: number, now: number): RetryEntry | null {
    if (failedAttempts >= RetryQueue.MAX_ATTEMPTS) {
      return null;
    }
    const nextAttempt: number = failedAttempts + 1;
    const entry: RetryEntry = {
      platform: platform,
      target: target,
      attempt: nextAttempt,
      nextAt: now + SyncPolicy.retryDelayMs(nextAttempt)
    };
    return entry;
  }
}
