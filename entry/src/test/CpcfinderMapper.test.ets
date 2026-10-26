import { describe, expect, it } from '@ohos/hypium';
import { CpcfinderMapper } from '../main/ets/data/remote/CpcfinderMapper';
import { ContestFeedResult } from '../main/ets/model/ContestFeed';

const FEED: string = `{
  "data": [
    { "contestId": 90, "name": "第 12 届 CCPC 中国大学生程序设计竞赛厦门站", "place": "厦门",
      "date": "2026-11-22", "dataStatus": "PENDING_CONTEST",
      "links": [ { "name": "榜单", "url": "https://board.xcpcio.com" } ] },
    { "contestId": 86, "name": "第 51 届 ICPC 国际大学生程序设计竞赛东亚区决赛", "place": "杭州",
      "date": "2027-01-28", "dataStatus": "PENDING_CONTEST",
      "links": [ { "name": "榜单", "url": "https://board.xcpcio.com" } ] },
    { "contestId": 80, "name": "第 51 届 ICPC 国际大学生程序设计竞赛亚洲区域赛成都站", "place": "成都",
      "date": "2026-10-25", "dataStatus": "OK",
      "links": [ { "name": "榜单", "url": "https://board.xcpcio.com/icpc/51st/chengdu" } ] }
  ],
  "pagination": { "current": 1, "pageSize": 20, "total": 3, "pages": 1 }
}`;

export default function cpcfinderMapperTest() {
  describe('CpcfinderMapper', () => {
    it('maps_feed_items', 0, () => {
      const result: ContestFeedResult = CpcfinderMapper.mapContests(FEED);
      expect(result.ok).assertTrue();
      expect(result.items.length).assertEqual(3);
      expect(result.items[0].id).assertEqual('cpcf-90');
      expect(result.items[0].boardUrl).assertEqual('https://board.xcpcio.com');
      expect(result.items[0].isPending).assertTrue();
      expect(result.items[2].isPending).assertFalse();
    });

    it('group_labels', 0, () => {
      expect(CpcfinderMapper.groupLabel('第 51 届 ICPC 亚洲区域赛成都站')).assertEqual('ICPC 区域赛');
      expect(CpcfinderMapper.groupLabel('第 51 届 ICPC 东亚区决赛')).assertEqual('ICPC 决赛');
      expect(CpcfinderMapper.groupLabel('第 12 届 CCPC 分站赛厦门站')).assertEqual('CCPC 分站赛');
      expect(CpcfinderMapper.groupLabel('第十届 CCPC 总决赛')).assertEqual('CCPC 总决赛');
      expect(CpcfinderMapper.groupLabel('其他赛事')).assertEqual('高校赛事');
    });

    it('filters_past_and_limits', 0, () => {
      const result: ContestFeedResult = CpcfinderMapper.mapContests(FEED);
      const upcoming = CpcfinderMapper.upcoming(result.items, '2026-10-26', 2);
      expect(upcoming.length).assertEqual(2);
      expect(upcoming[0].date).assertEqual('2026-11-22');
      expect(upcoming[1].date).assertEqual('2027-01-28');
    });

    it('handles_invalid_json', 0, () => {
      const result: ContestFeedResult = CpcfinderMapper.mapContests('not-json');
      expect(result.ok).assertFalse();
      expect(result.items.length).assertEqual(0);
    });

    it('handles_missing_data_field', 0, () => {
      const result: ContestFeedResult = CpcfinderMapper.mapContests('{"pagination":{}}');
      expect(result.ok).assertTrue();
      expect(result.items.length).assertEqual(0);
    });
  });
}
