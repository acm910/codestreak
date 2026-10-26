import { CollectionCard, Problem } from '../model/Entities';
import { TrackType } from '../model/Enums';

/** 赛道过滤（求职高频 / 算法竞赛互相独立） */
export class TrackFilter {
  static problems(items: Problem[], track: TrackType): Problem[] {
    const result: Problem[] = [];
    for (const item of items) {
      if (item.track === track) {
        result.push(item);
      }
    }
    return result;
  }

  static collections(items: CollectionCard[], track: TrackType): CollectionCard[] {
    const result: CollectionCard[] = [];
    for (const item of items) {
      if (item.track === track) {
        result.push(item);
      }
    }
    return result;
  }
}
