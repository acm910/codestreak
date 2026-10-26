import { describe, expect, it } from '@ohos/hypium';
import { PlatformContestMapper } from '../main/ets/data/remote/PlatformContestMapper';
import { ContestItem } from '../main/ets/model/Entities';

const CF_RESPONSE: string = `{
  "status": "OK",
  "result": [
    { "id": 3, "name": "Codeforces Round 999 (Div. 2)", "startTimeSeconds": 2000, "durationSeconds": 7200, "phase": "BEFORE" },
    { "id": 2, "name": "Codeforces Round 998 (Div. 3)", "startTimeSeconds": 1500, "durationSeconds": 7200, "phase": "BEFORE" },
    { "id": 1, "name": "Codeforces Round 997", "startTimeSeconds": 900, "durationSeconds": 7200, "phase": "FINISHED" }
  ]
}`;

const AC_RESPONSE: string = `[
  { "id": "abc400", "title": "AtCoder Beginner Contest 400", "start_epoch": 4000, "duration_seconds": 6000, "rate_change": "All" },
  { "id": "abc399", "title": "AtCoder Beginner Contest 399", "start_epoch": 3000, "duration_seconds": 6000, "rate_change": "All" },
  { "id": "abc398", "title": "AtCoder Beginner Contest 398", "start_epoch": 2000, "duration_seconds": 6000, "rate_change": "All" }
]`;

export default function platformContestMapperTest() {
  describe('PlatformContestMapper', () => {
    it('codeforces_filters_past_and_sorts', 0, () => {
      const items: ContestItem[] = PlatformContestMapper.mapCodeforces(CF_RESPONSE, 1000, 3);
      expect(items.length).assertEqual(2);
      expect(items[0].id).assertEqual('cf-2');
      expect(items[1].id).assertEqual('cf-3');
      expect(items[0].url).assertEqual('https://codeforces.com/contest/2');
      expect(items[0].durationText).assertEqual('120分钟');
    });

    it('codeforces_respects_limit', 0, () => {
      const items: ContestItem[] = PlatformContestMapper.mapCodeforces(CF_RESPONSE, 1000, 1);
      expect(items.length).assertEqual(1);
      expect(items[0].id).assertEqual('cf-2');
    });

    it('atcoder_maps_and_sorts', 0, () => {
      const items: ContestItem[] = PlatformContestMapper.mapAtCoder(AC_RESPONSE, 2500, 2);
      expect(items.length).assertEqual(2);
      expect(items[0].id).assertEqual('ac-abc399');
      expect(items[0].url).assertEqual('https://atcoder.jp/contests/abc399');
      expect(items[0].footerText).assertContain('AtCoder Problems');
    });

    it('invalid_payloads_return_empty', 0, () => {
      expect(PlatformContestMapper.mapCodeforces('oops', 1000, 3).length).assertEqual(0);
      expect(PlatformContestMapper.mapAtCoder('{"status":"OK"}', 1000, 3).length).assertEqual(0);
    });
  });
}
