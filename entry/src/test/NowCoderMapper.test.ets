import { describe, expect, it } from '@ohos/hypium';
import { NowCoderMapper } from '../main/ets/data/remote/NowCoderMapper';
import { MapperResult } from '../main/ets/model/SyncModels';

const PRACTICE_HTML: string = `<html><body>
  <div class="list">
    <a href="/acm/problem/1001" target="_blank">A+B Problem</a>
    <a href="/acm/problem/1001" target="_blank">A+B Problem</a>
    <a href="/acm/problem/1002" target="_blank">数组求和 &amp; 前缀和</a>
  </div>
</body></html>`;

const LOGIN_HTML: string = '<html><body><div>请先登录后再查看</div></body></html>';

export default function nowCoderMapperTest() {
  describe('NowCoderMapper', () => {
    it('parses_problem_links_and_dedupes', 0, () => {
      const result: MapperResult = NowCoderMapper.parsePracticePage(PRACTICE_HTML);
      expect(result.ok).assertTrue();
      expect(result.submissions.length).assertEqual(2);
      expect(result.submissions[0].problemKey).assertEqual('NC-1001');
      expect(result.submissions[1].title).assertEqual('数组求和 & 前缀和');
      expect(result.submissions[0].isAc).assertTrue();
    });

    it('login_page_is_rejected', 0, () => {
      const result: MapperResult = NowCoderMapper.parsePracticePage(LOGIN_HTML);
      expect(result.ok).assertFalse();
      expect(result.message).assertContain('登录');
    });

    it('empty_page_is_rejected', 0, () => {
      const result: MapperResult = NowCoderMapper.parsePracticePage('');
      expect(result.ok).assertFalse();
    });

    it('no_ac_problems_is_reported', 0, () => {
      const result: MapperResult = NowCoderMapper.parsePracticePage('<html><body><div>暂无记录</div></body></html>');
      expect(result.ok).assertFalse();
      expect(result.message).assertContain('未解析到');
    });
  });
}
