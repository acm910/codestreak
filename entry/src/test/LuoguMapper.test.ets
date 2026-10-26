import { describe, expect, it } from '@ohos/hypium';
import { LuoguMapper } from '../main/ets/data/remote/LuoguMapper';
import { MapperResult } from '../main/ets/model/SyncModels';

const RECORDS: string = `{
  "currentData": {
    "records": {
      "result": [
        { "id": 9001, "status": 12, "submitTime": 1730000000,
          "problem": { "pid": "P3372", "title": "【模板】线段树 1", "difficulty": 4 } },
        { "id": 9002, "status": 6, "submitTime": 1730000100,
          "problem": { "pid": "P1177", "title": "【模板】快速排序", "difficulty": 2 } },
        { "id": 9003, "status": 5, "submitTime": 1730000200,
          "problem": { "pid": "P1001", "title": "A+B Problem" } }
      ]
    }
  }
}`;

export default function luoguMapperTest() {
  describe('LuoguMapper', () => {
    it('maps_lens_records', 0, () => {
      const result: MapperResult = LuoguMapper.mapRecords(RECORDS);
      expect(result.ok).assertTrue();
      expect(result.submissions.length).assertEqual(3);
      expect(result.submissions[0].problemKey).assertEqual('LG-P3372');
      expect(result.submissions[0].isAc).assertTrue();
      expect(result.submissions[1].verdict).assertEqual('WA');
      expect(result.submissions[2].verdict).assertEqual('TLE');
    });

    it('maps_luogu_difficulty', 0, () => {
      const result: MapperResult = LuoguMapper.mapRecords(RECORDS);
      expect(result.submissions[0].difficultyNorm).assertEqual(3.0);
      expect(result.submissions[1].difficultyNorm).assertEqual(1.5);
      expect(result.submissions[2].difficultyNorm).assertEqual(3.0);
    });

    it('verdict_enum_mapping', 0, () => {
      expect(LuoguMapper.verdictOf(12)).assertEqual('AC');
      expect(LuoguMapper.verdictOf(6)).assertEqual('WA');
      expect(LuoguMapper.verdictOf(5)).assertEqual('TLE');
      expect(LuoguMapper.verdictOf(4)).assertEqual('MLE');
      expect(LuoguMapper.verdictOf(7)).assertEqual('RE');
      expect(LuoguMapper.verdictOf(2)).assertEqual('CE');
      expect(LuoguMapper.verdictOf(99)).assertEqual('UNKNOWN');
    });

    it('login_required_when_structure_missing', 0, () => {
      const result: MapperResult = LuoguMapper.mapRecords('{"code":200}');
      expect(result.ok).assertFalse();
      expect(result.message).assertContain('登录');
    });

    it('invalid_json', 0, () => {
      const result: MapperResult = LuoguMapper.mapRecords('<html>');
      expect(result.ok).assertFalse();
    });
  });
}
