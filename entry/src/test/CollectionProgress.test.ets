import { describe, expect, it } from '@ohos/hypium';
import { CollectionProgress } from '../main/ets/domain/CollectionProgress';
import { CollectionCard } from '../main/ets/model/Entities';
import { TrackType } from '../main/ets/model/Enums';

function collection(id: string, keys: string[]): CollectionCard {
  const item: CollectionCard = {
    id: id, tag: '', title: id, desc: '', done: 0, total: 0, percent: 0,
    track: TrackType.INTERVIEW, url: 'https://example.com', problemKeys: keys
  };
  return item;
}

export default function collectionProgressTest() {
  describe('CollectionProgress', () => {
    it('computes_done_from_membership', 0, () => {
      const items: CollectionCard[] = [collection('c1', ['LC-1', 'LC-15'])];
      const result: CollectionCard[] = CollectionProgress.apply(items, ['LC-1', 'CF-1352C']);
      expect(result[0].done).assertEqual(1);
      expect(result[0].total).assertEqual(2);
      expect(result[0].percent).assertEqual(50);
    });

    it('empty_membership_has_no_progress', 0, () => {
      const items: CollectionCard[] = [collection('c2', [])];
      const result: CollectionCard[] = CollectionProgress.apply(items, ['LC-1']);
      expect(result[0].total).assertEqual(0);
      expect(result[0].percent).assertEqual(0);
    });

    it('keeps_url_and_track', 0, () => {
      const items: CollectionCard[] = [collection('c3', ['LC-15'])];
      const result: CollectionCard[] = CollectionProgress.apply(items, []);
      expect(result[0].url).assertEqual('https://example.com');
      expect(result[0].track).assertEqual(TrackType.INTERVIEW);
      expect(result[0].done).assertEqual(0);
    });
  });
}
