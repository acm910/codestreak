import { describe, expect, it } from '@ohos/hypium';
import { LC_RECENT_QUERY, LeetCodeMapper } from '../main/ets/data/remote/LeetCodeMapper';
import { MapperResult } from '../main/ets/model/SyncModels';

const RESPONSE: string = `{
  "data": {
    "recentAcSubmissionList": [
      { "id": "123", "title": "反转链表", "titleSlug": "reverse-linked-list", "timestamp": "1730000000" },
      { "id": "124", "title": "三数之和", "titleSlug": "3sum", "timestamp": "1730000100" }
    ]
  }
}`;

export default function leetCodeMapperTest() {
  describe('LeetCodeMapper', () => {
    it('maps_recent_ac_list', 0, () => {
      const result: MapperResult = LeetCodeMapper.mapRecentAc(RESPONSE);
      expect(result.ok).assertTrue();
      expect(result.submissions.length).assertEqual(2);
      expect(result.submissions[0].problemKey).assertEqual('LC-reverse-linked-list');
      expect(result.submissions[0].title).assertEqual('反转链表');
      expect(result.submissions[0].epochSecond).assertEqual(1730000000);
      expect(result.submissions[0].isAc).assertTrue();
    });

    it('query_contains_recent_ac_fields', 0, () => {
      expect(LC_RECENT_QUERY).assertContain('recentAcSubmissionList');
      expect(LC_RECENT_QUERY).assertContain('titleSlug');
      expect(LC_RECENT_QUERY).assertContain('timestamp');
    });

    it('graphql_error_is_reported', 0, () => {
      const result: MapperResult = LeetCodeMapper.mapRecentAc('{"errors":[{"message":"user does not exist"}]}');
      expect(result.ok).assertFalse();
      expect(result.message).assertContain('user does not exist');
    });

    it('missing_data_means_login_required', 0, () => {
      const result: MapperResult = LeetCodeMapper.mapRecentAc('{"data":{}}');
      expect(result.ok).assertFalse();
      expect(result.message).assertContain('登录');
    });

    it('invalid_json', 0, () => {
      const result: MapperResult = LeetCodeMapper.mapRecentAc('<html>403</html>');
      expect(result.ok).assertFalse();
    });
  });
}
