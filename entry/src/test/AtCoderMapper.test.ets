import { describe, expect, it } from '@ohos/hypium';
import { AtCoderMapper } from '../main/ets/data/remote/AtCoderMapper';
import { MapperResult } from '../main/ets/model/SyncModels';

const OK_RESPONSE: string = `[
  { "id": 111, "epoch_second": 1730000000, "problem_id": "abc356_a", "contest_id": "abc356", "result": "AC" },
  { "id": 112, "epoch_second": 1730000100, "problem_id": "abc356_c", "contest_id": "abc356", "result": "WA" },
  { "id": 113, "epoch_second": 1730000200, "problem_id": "abc356_e", "contest_id": "abc356", "result": "AC" }
]`;

const EMPTY_RESPONSE: string = '[]';

export default function atCoderMapperTest() {
  describe('AtCoderMapper', () => {
    it('maps_array_response', 0, () => {
      const result: MapperResult = AtCoderMapper.mapSubmissions(OK_RESPONSE);
      expect(result.ok).assertTrue();
      expect(result.submissions.length).assertEqual(3);
      expect(result.submissions[0].problemKey).assertEqual('AC-abc356_a');
      expect(result.submissions[0].isAc).assertTrue();
      expect(result.submissions[1].isAc).assertFalse();
    });

    it('difficulty_by_problem_letter', 0, () => {
      expect(AtCoderMapper.difficultyByLetter('abc356_a')).assertEqual(1.0);
      expect(AtCoderMapper.difficultyByLetter('abc356_c')).assertEqual(2.5);
      expect(AtCoderMapper.difficultyByLetter('abc356_e')).assertEqual(4.0);
      expect(AtCoderMapper.difficultyByLetter('abc356_g')).assertEqual(5.0);
      expect(AtCoderMapper.difficultyByLetter('')).assertEqual(3.0);
    });

    it('max_epoch_is_incremental_cursor', 0, () => {
      const result: MapperResult = AtCoderMapper.mapSubmissions(OK_RESPONSE);
      expect(AtCoderMapper.maxEpochSecond(result.submissions)).assertEqual(1730000200);
    });

    it('empty_array_is_ok', 0, () => {
      const result: MapperResult = AtCoderMapper.mapSubmissions(EMPTY_RESPONSE);
      expect(result.ok).assertTrue();
      expect(result.submissions.length).assertEqual(0);
    });

    it('invalid_json_and_wrong_shape', 0, () => {
      const bad: MapperResult = AtCoderMapper.mapSubmissions('oops');
      expect(bad.ok).assertFalse();
      const wrong: MapperResult = AtCoderMapper.mapSubmissions('{"status":"OK"}');
      expect(wrong.ok).assertFalse();
    });
  });
}
