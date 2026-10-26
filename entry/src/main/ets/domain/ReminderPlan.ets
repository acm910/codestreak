/**
 * 提醒计划（纯数据，便于测试）
 * docs/03-页面设计/06、04-技术设计/07 §8：每日 21:30 强提醒。
 */
export interface ReminderPlan {
  hour: number;
  minute: number;
  /** ISO 周几：1=周一 … 7=周日 */
  daysOfWeek: number[];
  title: string;
  content: string;
  notificationId: number;
}

export class ReminderPlanBuilder {
  static readonly DAILY_HOUR: number = 21;
  static readonly DAILY_MINUTE: number = 30;
  static readonly NOTIFICATION_ID: number = 1001;

  static daily(): ReminderPlan {
    const plan: ReminderPlan = {
      hour: ReminderPlanBuilder.DAILY_HOUR,
      minute: ReminderPlanBuilder.DAILY_MINUTE,
      daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
      title: 'CodeStreak 打卡提醒',
      content: '今天还差 1 题，别断了连胜',
      notificationId: ReminderPlanBuilder.NOTIFICATION_ID
    };
    return plan;
  }

  /** 剩余题量文案（用于提醒内容） */
  static contentFor(remaining: number): string {
    if (remaining <= 0) {
      return '今日已达标，保持节奏';
    }
    return `今天还差 ${remaining} 题，别断了连胜`;
  }
}
