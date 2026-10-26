import { describe, expect, it } from '@ohos/hypium';
import { CheckInResult, CheckInService } from '../main/ets/domain/CheckInService';
import { CheckInStatus } from '../main/ets/model/Enums';

export default function checkInServiceTest() {
  describe('CheckInService', () => {
    it('first_card_no_streak_change', 0, () => {
      const result: CheckInResult = CheckInService.completeOne({
        target: 2, targetProgress: 0, streakDays: 28, longestStreak: 64, celebrated: false
      });
      expect(result.targetProgress).assertEqual(1);
      expect(result.status).assertEqual(CheckInStatus.PENDING);
      expect(result.streakDays).assertEqual(28);
      expect(result.achievedNow).assertEqual(false);
    });

    it('second_card_achieves_and_increments_streak', 0, () => {
      const result: CheckInResult = CheckInService.completeOne({
        target: 2, targetProgress: 1, streakDays: 28, longestStreak: 64, celebrated: false
      });
      expect(result.targetProgress).assertEqual(2);
      expect(result.status).assertEqual(CheckInStatus.ACHIEVED);
      expect(result.streakDays).assertEqual(29);
      expect(result.achievedNow).assertEqual(true);
      expect(result.celebrated).assertEqual(true);
    });

    it('duplicate_completion_does_not_increment_twice', 0, () => {
      const result: CheckInResult = CheckInService.completeOne({
        target: 2, targetProgress: 2, streakDays: 29, longestStreak: 64, celebrated: true
      });
      expect(result.targetProgress).assertEqual(2);
      expect(result.streakDays).assertEqual(29);
      expect(result.achievedNow).assertEqual(false);
    });

    it('progress_is_capped_at_target', 0, () => {
      const result: CheckInResult = CheckInService.completeOne({
        target: 2, targetProgress: 5, streakDays: 10, longestStreak: 10, celebrated: true
      });
      expect(result.targetProgress).assertEqual(2);
    });

    it('longest_streak_updates_when_exceeded', 0, () => {
      const result: CheckInResult = CheckInService.completeOne({
        target: 2, targetProgress: 1, streakDays: 64, longestStreak: 64, celebrated: false
      });
      expect(result.streakDays).assertEqual(65);
      expect(result.longestStreak).assertEqual(65);
    });

    it('progress_text_pending_and_full', 0, () => {
      expect(CheckInService.progressText(1, 2)).assertEqual('待完成 1/2');
      expect(CheckInService.progressText(2, 2)).assertEqual('今日已拉满 2/2');
    });

    it('is_achieved', 0, () => {
      expect(CheckInService.isAchieved(1, 2)).assertEqual(false);
      expect(CheckInService.isAchieved(2, 2)).assertEqual(true);
    });
  });
}
