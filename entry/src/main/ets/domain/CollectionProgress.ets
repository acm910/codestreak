import { CollectionCard } from '../model/Entities';

/**
 * 题单完成度计算（docs/03-页面设计/03 C-23）
 * 只有配置了成员题号（problemKeys）的题单才计算真实完成度；
 * 无成员清单时 total = 0，界面展示入口而非假进度。
 */
export class CollectionProgress {
  static apply(items: CollectionCard[], solvedKeys: string[]): CollectionCard[] {
    const solved: Set<string> = new Set<string>(solvedKeys);
    const result: CollectionCard[] = [];
    for (const item of items) {
      let done: number = 0;
      for (const key of item.problemKeys) {
        if (solved.has(key)) {
          done = done + 1;
        }
      }
      const total: number = item.problemKeys.length;
      const percent: number = total === 0 ? 0 : Math.round(done * 100 / total);
      const updated: CollectionCard = {
        id: item.id, tag: item.tag, title: item.title, desc: item.desc,
        done: done, total: total, percent: percent,
        track: item.track, url: item.url, problemKeys: item.problemKeys
      };
      result.push(updated);
    }
    return result;
  }
}
