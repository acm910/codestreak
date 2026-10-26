import { MapperResult, SyncSubmission } from '../../model/SyncModels';

interface NcProblem {
  id: string;
  title: string;
}

/**
 * 牛客练习页 HTML 解析（docs/04-技术设计/07 §6.5）
 * 页面为服务端渲染 HTML，提取 /acm/problem/{id} 链接与标题；
 * 牛客不提供提交时间，统一以导入时间作为记录时间（DEV-20）。
 */
export class NowCoderMapper {
  private static decode(text: string): string {
    return text.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
      .replace(/&quot;/g, '"').replace(/&#39;/g, "'").trim();
  }

  static parsePracticePage(html: string): MapperResult {
    if (html.length === 0) {
      return { ok: false, message: '牛客返回空页面，可能需要登录', submissions: [] };
    }
    if (html.indexOf('登录') >= 0 && html.indexOf('/acm/problem/') < 0) {
      return { ok: false, message: '牛客需要登录后才能导入', submissions: [] };
    }
    const found: NcProblem[] = [];
    const seen: Set<string> = new Set<string>();
    const pattern: RegExp = /\/acm\/problem\/(\d+)[^>]*>([^<]{1,120})</g;
    let match: RegExpExecArray | null = pattern.exec(html);
    while (match !== null) {
      const id: string = match[1];
      const title: string = NowCoderMapper.decode(match[2]);
      if (title.length > 0 && !seen.has(id)) {
        seen.add(id);
        const problem: NcProblem = { id: id, title: title };
        found.push(problem);
      }
      match = pattern.exec(html);
    }
    if (found.length === 0) {
      return { ok: false, message: '未解析到已通过题目，请确认已登录且主页可访问', submissions: [] };
    }
    const nowSecond: number = Math.floor(Date.now() / 1000);
    const submissions: SyncSubmission[] = [];
    for (const item of found) {
      submissions.push({
        platform: 'NC',
        externalId: item.id,
        problemKey: `NC-${item.id}`,
        title: item.title,
        nativeDifficulty: '',
        difficultyNorm: 3.0,
        verdict: 'AC',
        epochSecond: nowSecond,
        isAc: true,
        tags: []
      });
    }
    return { ok: true, message: '', submissions: submissions };
  }
}
