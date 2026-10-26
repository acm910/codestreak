import { CheckInStatus } from '../model/Enums';

/** 打卡推进的输入快照 */
export interface CheckInInput {
  /** 每日目标题数（两张目标卡） */
  target: number;
  /** 已完成的目标卡数 */
  targetProgress: number;
  streakDays: number;
  longestStreak: number;
  /** 当日是否已经触发过庆祝（保证连胜只 +1 一次） */
  celebrated: boolean;
}

/** 打卡推进的结果 */
export interface CheckInResult {
  targetProgress: number;
  status: CheckInStatus;
  streakDays: number;
  longestStreak: number;
  achievedNow: boolean;
  celebrated: boolean;
}

/**
 * 打卡状态机（docs/03-页面设计/02 §交互规格、docs/07-测试与质量/02 TC-TOD-03/04/05）
 * 纯函数：不读写存储、不依赖 UI，便于单元测试。
 */
export class CheckInService {
  /**
   * 完成一张目标卡后的状态推进。
   * - 进度封顶于 target；
   * - 仅在「首次达标」时连胜 +1，重复完成不会重复加；
   * - 历史最长随之更新。
   */
  static completeOne(input: CheckInInput): CheckInResult {
    const target: number = Math.max(1, input.target);
    const progress: number = Math.min(target, input.targetProgress + 1);
    const achieved: boolean = progress >= target;
    const firstAchieve: boolean = achieved && !input.celebrated;
    const streak: number = firstAchieve ? input.streakDays + 1 : input.streakDays;
    const longest: number = Math.max(input.longestStreak, streak);
    const status: CheckInStatus = achieved ? CheckInStatus.ACHIEVED : CheckInStatus.PENDING;
    return {
      targetProgress: progress,
      status: status,
      streakDays: streak,
      longestStreak: longest,
      achievedNow: firstAchieve,
      celebrated: input.celebrated || firstAchieve
    };
  }

  /** 进度文案：待完成 x/2 或 今日已拉满 2/2（D-17） */
  static progressText(progress: number, target: number): string {
    if (progress >= target) {
      return `今日已拉满 ${target}/${target}`;
    }
    return `待完成 ${target - progress}/${target}`;
  }

  /** 是否满足当日达标 */
  static isAchieved(progress: number, target: number): boolean {
    return progress >= target;
  }
}
