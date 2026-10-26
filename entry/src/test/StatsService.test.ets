import { describe, expect, it } from '@ohos/hypium';
import { StatsService } from '../main/ets/domain/StatsService';
import { AcStats, DifficultyRow, WeekCell } from '../main/ets/model/Entities';
import { DateUtil } from '../main/ets/utils/DateUtil';

function acStats(solved: number, platforms: number, difficulty: number[]): AcStats {
  const stats: AcStats = { solved: solved, platforms: platforms, difficulty: difficulty };
  return stats;
}

export default function statsServiceTest() {
  describe('StatsService', () => {
    it('streak_counts_backwards_from_today', 0, () => {
      const today: string = DateUtil.todayKey();
      const dates: string[] = [today, DateUtil.shiftKey(today, -1), DateUtil.shiftKey(today, -2)];
      const result = StatsService.streaks(dates, today);
      expect(result.current).assertEqual(3);
      expect(result.longest).assertEqual(3);
    });

    it('streak_allows_today_pending', 0, () => {
      const today: string = DateUtil.todayKey();
      const dates: string[] = [DateUtil.shiftKey(today, -1), DateUtil.shiftKey(today, -2)];
      const result = StatsService.streaks(dates, today);
      expect(result.current).assertEqual(2);
    });

    it('streak_breaks_on_gap', 0, () => {
      const today: string = DateUtil.todayKey();
      const dates: string[] = [today, DateUtil.shiftKey(today, -1), DateUtil.shiftKey(today, -3)];
      const result = StatsService.streaks(dates, today);
      expect(result.current).assertEqual(2);
      expect(result.longest).assertEqual(2);
    });

    it('week_cells_marks_done_and_today', 0, () => {
      const today: Date = new Date(2026, 9, 28);
      const dates: string[] = ['2026-10-26', '2026-10-27'];
      const cells: WeekCell[] = StatsService.weekCells(dates, today);
      expect(cells.length).assertEqual(7);
      expect(cells[0].state).assertEqual('done');
      expect(cells[1].state).assertEqual('done');
      expect(cells[2].state).assertEqual('today');
      expect(cells[3].state).assertEqual('future');
    });

    it('difficulty_rows_from_real_counts', 0, () => {
      const rows: DifficultyRow[] = StatsService.difficultyRows([1, 1, 2, 0, 0]);
      expect(rows.length).assertEqual(5);
      expect(rows[2].count).assertEqual(2);
      expect(rows[2].percent).assertEqual(50);
      expect(rows[0].percent).assertEqual(25);
    });

    it('difficulty_rows_empty_is_zero', 0, () => {
      const rows: DifficultyRow[] = StatsService.difficultyRows([0, 0, 0, 0, 0]);
      expect(rows[0].percent).assertEqual(0);
      expect(rows[4].count).assertEqual(0);
    });

    it('badges_reflect_real_stats', 0, () => {
      const today: string = DateUtil.todayKey();
      const streak = StatsService.streaks([today], today);
      const badges = StatsService.badges(streak, acStats(5, 2, [1, 1, 1, 1, 1]));
      expect(badges[0].state).assertEqual('in_progress');
      expect(badges[1].state).assertEqual('in_progress');
      expect(badges[2].state).assertEqual('in_progress');
      expect(badges[2].stateText).assertEqual('2/3 平台');
    });

    it('week_strip_has_seven_days', 0, () => {
      const today: Date = new Date(2026, 9, 28);
      const strip = StatsService.weekStrip(['2026-10-28'], today);
      expect(strip.length).assertEqual(7);
      expect(strip[2].active).assertTrue();
      expect(strip[2].dotColor.length > 0).assertTrue();
    });

    it('badges_unlock_at_thresholds', 0, () => {
      const today: string = DateUtil.todayKey();
      const dates: string[] = [];
      for (let i = 0; i < 30; i++) {
        dates.push(DateUtil.shiftKey(today, -i));
      }
      const streak = StatsService.streaks(dates, today);
      const badges = StatsService.badges(streak, acStats(120, 3, [1, 1, 1, 1, 1]));
      expect(badges[0].state).assertEqual('unlocked');
      expect(badges[1].state).assertEqual('unlocked');
      expect(badges[2].state).assertEqual('unlocked');
    });
  });
}
