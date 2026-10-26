import { describe, expect, it } from '@ohos/hypium';
import { DateUtil } from '../main/ets/utils/DateUtil';

export default function dateUtilTest() {
  describe('DateUtil', () => {
    it('pad2', 0, () => {
      expect(DateUtil.pad2(3)).assertEqual('03');
      expect(DateUtil.pad2(12)).assertEqual('12');
    });

    it('date_key_format', 0, () => {
      const date: Date = new Date(2026, 9, 26);
      expect(DateUtil.dateKey(date)).assertEqual('2026-10-26');
    });

    it('relative_today_and_tomorrow', 0, () => {
      const now: Date = new Date(2026, 9, 26, 20, 0, 0);
      const today: Date = new Date(2026, 9, 26, 9, 0, 0);
      const tomorrow: Date = new Date(2026, 9, 27, 9, 0, 0);
      expect(DateUtil.relativeDay(today, now)).assertEqual('今天');
      expect(DateUtil.relativeDay(tomorrow, now)).assertEqual('明天');
    });

    it('iso_week_jan4_is_week1', 0, () => {
      const jan4: Date = new Date(2026, 0, 4);
      expect(DateUtil.isoWeek(jan4)).assertEqual(1);
    });

    it('iso_week_monotonic_within_month', 0, () => {
      const first: Date = new Date(2026, 9, 5);
      const second: Date = new Date(2026, 9, 12);
      expect(DateUtil.isoWeek(second) - DateUtil.isoWeek(first)).assertEqual(1);
    });

    it('weekday_label', 0, () => {
      const monday: Date = new Date(2026, 9, 26);
      expect(DateUtil.weekdayLabel(monday)).assertEqual('一');
    });
  });
}
