import { describe, expect, it } from '@ohos/hypium';
import { CodeforcesMapper } from '../main/ets/data/remote/CodeforcesMapper';
import { MapperResult } from '../main/ets/model/SyncModels';

const OK_RESPONSE: string = `{
  "status": "OK",
  "result": [
    {
      "id": 268001,
      "creationTimeSeconds": 1730000000,
      "verdict": "OK",
      "problem": { "contestId": 1899, "index": "A", "name": "Game with Integers", "rating": 900, "tags": ["math", "games"] }
    },
    {
      "id": 268002,
      "creationTimeSeconds": 1730000100,
      "verdict": "WRONG_ANSWER",
      "problem": { "contestId": 1352, "index": "C", "name": "K-th Not Divisible by n", "rating": 1200, "tags": ["binary search"] }
    },
    {
      "id": 268003,
      "creationTimeSeconds": 1730000200,
      "verdict": "OK",
      "problem": { "contestId": 1899, "index": "A", "name": "Game with Integers", "rating": 900, "tags": ["math"] }
    }
  ]
}`;

const FAILED_RESPONSE: string = `{ "status": "FAILED", "comment": "handle: User with handle nobody not found" }`;

export default function codeforcesMapperTest() {
  describe('CodeforcesMapper', () => {
    it('maps_ok_response_to_submissions', 0, () => {
      const result: MapperResult = CodeforcesMapper.mapStatus(OK_RESPONSE);
      expect(result.ok).assertTrue();
      expect(result.submissions.length).assertEqual(3);
      expect(result.submissions[0].problemKey).assertEqual('CF-1899A');
      expect(result.submissions[0].difficultyNorm).assertEqual(1.0);
      expect(result.submissions[0].isAc).assertTrue();
      expect(result.submissions[1].verdict).assertEqual('WRONG_ANSWER');
      expect(result.submissions[1].isAc).assertFalse();
      expect(result.submissions[1].difficultyNorm).assertEqual(2.0);
    });

    it('counts_ac_without_duplicates', 0, () => {
      const result: MapperResult = CodeforcesMapper.mapStatus(OK_RESPONSE);
      expect(CodeforcesMapper.countAccepted(result.submissions)).assertEqual(1);
    });

    it('reports_failed_status_with_comment', 0, () => {
      const result: MapperResult = CodeforcesMapper.mapStatus(FAILED_RESPONSE);
      expect(result.ok).assertFalse();
      expect(result.message).assertContain('not found');
      expect(result.submissions.length).assertEqual(0);
    });

    it('handles_invalid_json', 0, () => {
      const result: MapperResult = CodeforcesMapper.mapStatus('not-json');
      expect(result.ok).assertFalse();
      expect(result.submissions.length).assertEqual(0);
    });

    it('missing_rating_falls_back_to_3_0', 0, () => {
      const raw: string = `{ "status": "OK", "result": [ { "id": 1, "verdict": "OK",
        "problem": { "contestId": 1, "index": "A", "name": "NoRating" } } ] }`;
      const result: MapperResult = CodeforcesMapper.mapStatus(raw);
      expect(result.submissions[0].difficultyNorm).assertEqual(3.0);
      expect(result.submissions[0].nativeDifficulty).assertEqual('');
    });

    it('maps_user_rating', 0, () => {
      const raw: string = `{ "status": "OK", "result": [ { "handle": "tourist", "rating": 3800 } ] }`;
      expect(CodeforcesMapper.mapUserRating(raw)).assertEqual(3800);
      expect(CodeforcesMapper.mapUserRating('bad-json')).assertEqual(0);
    });
  });
}
