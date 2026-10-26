/** CPC Finder 社区赛事（ICPC/CCPC） */
export interface CommunityContest {
  id: string;
  name: string;
  place: string;
  /** YYYY-MM-DD */
  date: string;
  /** PENDING_CONTEST / OK / MISSING_DATA */
  dataStatus: string;
  boardUrl: string;
  isPending: boolean;
}

/** 赛事源解析结果 */
export interface ContestFeedResult {
  ok: boolean;
  message: string;
  items: CommunityContest[];
}
