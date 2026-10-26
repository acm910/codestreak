import { common } from '@kit.AbilityKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DatabaseHelper } from '../data/db/DatabaseHelper';
import { ReminderPlan, ReminderPlanBuilder } from '../domain/ReminderPlan';

const DOMAIN: number = 0x0006;
const TAG: string = 'CS-NOTIFY';
const REMINDER_ID_KEY: string = 'daily_reminder_id';

/**
 * 提醒服务（docs/04-技术设计/07 §8）
 * 每日 21:30 通过 reminderAgentManager 发系统代理提醒；需通知授权与 PUBLISH_AGENT_REMINDER 权限。
 */
export class NotificationService {
  static async requestPermission(context: common.UIAbilityContext): Promise<boolean> {
    try {
      await notificationManager.requestEnableNotification(context);
      return true;
    } catch (err) {
      hilog.warn(DOMAIN, TAG, 'notification permission denied');
      return false;
    }
  }

  static async enableDaily(context: common.UIAbilityContext, remaining: number): Promise<boolean> {
    const granted: boolean = await NotificationService.requestPermission(context);
    if (!granted) {
      return false;
    }
    const plan: ReminderPlan = ReminderPlanBuilder.daily();
    const request: reminderAgentManager.ReminderRequestAlarm = {
      reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
      hour: plan.hour,
      minute: plan.minute,
      daysOfWeek: plan.daysOfWeek,
      title: plan.title,
      content: ReminderPlanBuilder.contentFor(remaining),
      notificationId: plan.notificationId,
      slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      wantAgent: {
        pkgName: 'com.codestreak.app',
        abilityName: 'EntryAbility'
      }
    };
    try {
      const reminderId: number = await reminderAgentManager.publishReminder(request);
      await DatabaseHelper.saveSetting(REMINDER_ID_KEY, `${reminderId}`);
      hilog.info(DOMAIN, TAG, 'daily reminder published: %{public}d', reminderId);
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'publishReminder failed: %{public}s', JSON.stringify(err));
      return false;
    }
  }

  static async disableDaily(): Promise<void> {
    const stored: string = await DatabaseHelper.loadSetting(REMINDER_ID_KEY);
    if (stored.length === 0) {
      return;
    }
    const reminderId: number = Number(stored);
    if (Number.isNaN(reminderId)) {
      return;
    }
    try {
      await reminderAgentManager.cancelReminder(reminderId);
      await DatabaseHelper.saveSetting(REMINDER_ID_KEY, '');
      hilog.info(DOMAIN, TAG, 'daily reminder cancelled: %{public}d', reminderId);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'cancelReminder failed: %{public}s', JSON.stringify(err));
    }
  }
}
