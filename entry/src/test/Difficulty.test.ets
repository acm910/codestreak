import { describe, expect, it } from '@ohos/hypium';
import { Difficulty } from '../main/ets/utils/Difficulty';

export default function difficultyTest() {
  describe('DifficultyNormalize', () => {
    it('cf_900_is_1_0', 0, () => {
      expect(Difficulty.fromRating(900)).assertEqual(1.0);
    });

    it('cf_1200_is_2_0', 0, () => {
      expect(Difficulty.fromRating(1200)).assertEqual(2.0);
    });

    it('cf_1400_is_2_5', 0, () => {
      expect(Difficulty.fromRating(1400)).assertEqual(2.5);
    });

    it('cf_2100_is_4_0', 0, () => {
      expect(Difficulty.fromRating(2100)).assertEqual(4.0);
    });

    it('cf_3000_is_5_0', 0, () => {
      expect(Difficulty.fromRating(3000)).assertEqual(5.0);
    });

    it('cf_clamped_low_and_high', 0, () => {
      expect(Difficulty.fromRating(100)).assertEqual(1.0);
      expect(Difficulty.fromRating(9999)).assertEqual(5.0);
    });

    it('unknown_rating_falls_back', 0, () => {
      expect(Difficulty.fromRating(0)).assertEqual(3.0);
    });

    it('leetcode_mapping', 0, () => {
      expect(Difficulty.fromLeetCode('Easy')).assertEqual(2.0);
      expect(Difficulty.fromLeetCode('Medium')).assertEqual(3.0);
      expect(Difficulty.fromLeetCode('Hard')).assertEqual(4.5);
      expect(Difficulty.fromLeetCode('Unknown')).assertEqual(3.0);
    });

    it('luogu_seven_levels', 0, () => {
      expect(Difficulty.fromLuogu(1)).assertEqual(1.0);
      expect(Difficulty.fromLuogu(2)).assertEqual(1.5);
      expect(Difficulty.fromLuogu(3)).assertEqual(2.0);
      expect(Difficulty.fromLuogu(4)).assertEqual(3.0);
      expect(Difficulty.fromLuogu(5)).assertEqual(4.0);
      expect(Difficulty.fromLuogu(6)).assertEqual(4.5);
      expect(Difficulty.fromLuogu(7)).assertEqual(5.0);
    });

    it('star_text', 0, () => {
      expect(Difficulty.starText(3)).assertEqual('★3');
      expect(Difficulty.starText(2.5)).assertEqual('★2.5');
    });
  });
}
