import { describe, expect, it } from '@ohos/hypium';
import { ReminderPlan, ReminderPlanBuilder } from '../main/ets/domain/ReminderPlan';

export default function reminderPlanTest() {
  describe('ReminderPlan', () => {
    it('daily_plan_is_21_30_every_day', 0, () => {
      const plan: ReminderPlan = ReminderPlanBuilder.daily();
      expect(plan.hour).assertEqual(21);
      expect(plan.minute).assertEqual(30);
      expect(plan.daysOfWeek.length).assertEqual(7);
      expect(plan.daysOfWeek[0]).assertEqual(1);
      expect(plan.daysOfWeek[6]).assertEqual(7);
      expect(plan.title).assertContain('打卡');
      expect(plan.notificationId).assertEqual(1001);
    });

    it('content_reflects_remaining', 0, () => {
      expect(ReminderPlanBuilder.contentFor(1)).assertContain('还差 1 题');
      expect(ReminderPlanBuilder.contentFor(0)).assertContain('已达标');
      expect(ReminderPlanBuilder.contentFor(-1)).assertContain('已达标');
    });
  });
}
