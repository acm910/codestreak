import { describe, expect, it } from '@ohos/hypium';
import { TrackFilter } from '../main/ets/domain/TrackFilter';
import { CollectionCard, Problem } from '../main/ets/model/Entities';
import { PlatformCode, SolveStatus, TrackType } from '../main/ets/model/Enums';

function problem(id: string, track: TrackType): Problem {
  const item: Problem = {
    id: id, platform: PlatformCode.LC, platformName: 'LeetCode', code: id,
    title: id, titleEn: '', difficulty: 3, nativeLabel: 'Medium', tags: [],
    status: SolveStatus.TODO, sourceText: '', url: '', track: track
  };
  return item;
}

function collection(id: string, track: TrackType): CollectionCard {
  const item: CollectionCard = {
    id: id, tag: '', title: id, desc: '', done: 0, total: 10, percent: 0, track: track,
    url: '', problemKeys: []
  };
  return item;
}

export default function trackFilterTest() {
  describe('TrackFilter', () => {
    const problems: Problem[] = [
      problem('LC-1', TrackType.INTERVIEW),
      problem('LC-15', TrackType.INTERVIEW),
      problem('CF-1352C', TrackType.CONTEST)
    ];
    const collections: CollectionCard[] = [
      collection('c1', TrackType.INTERVIEW),
      collection('c2', TrackType.CONTEST),
      collection('c3', TrackType.INTERVIEW)
    ];

    it('splits_problems_by_track', 0, () => {
      expect(TrackFilter.problems(problems, TrackType.INTERVIEW).length).assertEqual(2);
      expect(TrackFilter.problems(problems, TrackType.CONTEST).length).assertEqual(1);
      expect(TrackFilter.problems(problems, TrackType.CONTEST)[0].code).assertEqual('CF-1352C');
    });

    it('splits_collections_by_track', 0, () => {
      expect(TrackFilter.collections(collections, TrackType.INTERVIEW).length).assertEqual(2);
      expect(TrackFilter.collections(collections, TrackType.CONTEST).length).assertEqual(1);
      expect(TrackFilter.collections(collections, TrackType.CONTEST)[0].id).assertEqual('c2');
    });

    it('empty_track_returns_empty', 0, () => {
      expect(TrackFilter.problems([], TrackType.INTERVIEW).length).assertEqual(0);
      expect(TrackFilter.collections([], TrackType.CONTEST).length).assertEqual(0);
    });
  });
}
