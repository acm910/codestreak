import { describe, expect, it } from '@ohos/hypium';
import { Heatmap } from '../main/ets/utils/Heatmap';
import { DailyAcCount } from '../main/ets/model/Entities';
import { DateUtil } from '../main/ets/utils/DateUtil';

export default function heatmapTest() {
  describe('Heatmap', () => {
    it('level_thresholds', 0, () => {
      expect(Heatmap.levelOf(0)).assertEqual(0);
      expect(Heatmap.levelOf(1)).assertEqual(1);
      expect(Heatmap.levelOf(2)).assertEqual(1);
      expect(Heatmap.levelOf(3)).assertEqual(2);
      expect(Heatmap.levelOf(5)).assertEqual(2);
      expect(Heatmap.levelOf(6)).assertEqual(3);
      expect(Heatmap.levelOf(8)).assertEqual(3);
      expect(Heatmap.levelOf(9)).assertEqual(4);
      expect(Heatmap.levelOf(20)).assertEqual(4);
    });

    it('grid_starts_on_monday_15_weeks_ago', 0, () => {
      const today: Date = new Date(2026, 9, 26);
      const start: Date = Heatmap.gridStart(today);
      expect(start.getDay()).assertEqual(1);
      expect(DateUtil.dateKey(start)).assertEqual('2026-07-13');
    });

    it('grid_from_wednesday_still_monday', 0, () => {
      const today: Date = new Date(2026, 9, 28);
      const start: Date = Heatmap.gridStart(today);
      expect(start.getDay()).assertEqual(1);
    });

    it('build_levels_maps_days_in_order', 0, () => {
      const start: Date = new Date(2026, 9, 19);
      const counts: DailyAcCount[] = [
        { day: '2026-10-19', count: 5 },
        { day: '2026-10-20', count: 9 },
        { day: '2026-10-21', count: 0 }
      ];
      const levels: number[] = Heatmap.buildLevels(start, counts);
      expect(levels.length).assertEqual(112);
      expect(levels[0]).assertEqual(2);
      expect(levels[1]).assertEqual(4);
      expect(levels[2]).assertEqual(0);
      expect(levels[3]).assertEqual(0);
    });

    it('build_levels_handles_empty_input', 0, () => {
      const levels: number[] = Heatmap.buildLevels(new Date(2026, 9, 19), []);
      expect(levels.length).assertEqual(112);
      expect(levels[100]).assertEqual(0);
    });
  });
}
