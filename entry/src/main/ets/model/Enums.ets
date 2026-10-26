/** 平台代码（与 docs/01-产品设计/04 平台码表一致） */
export enum PlatformCode {
  LC = 'LC',
  CF = 'CF',
  LG = 'LG',
  AC = 'AC',
  NC = 'NC'
}

/** 每日状态 */
export enum CheckInStatus {
  PENDING = 'pending',
  ACHIEVED = 'achieved',
  MISSED = 'missed',
  MAKEUP = 'makeup'
}

/** 题目在本地矩阵中的状态 */
export enum SolveStatus {
  SOLVED = 'solved',
  DOING = 'doing',
  TODO = 'todo'
}

/** 赛事状态（C-29 五态，此处含展示用扩展） */
export enum ContestStatus {
  LIVE = 'live',
  REGISTERING = 'registering',
  PREPARING = 'preparing',
  UPCOMING = 'upcoming',
  ENDED = 'ended'
}

/** 补题状态 */
export enum UpsolveState {
  AC_IN_CONTEST = 'ac_in_contest',
  AC_AFTER = 'ac_after',
  PENDING = 'pending'
}

/** 赛道 */
export enum TrackType {
  INTERVIEW = 'interview',
  CONTEST = 'contest'
}

/** 底部 Tab 索引 */
export enum TabIndex {
  TODAY = 0,
  MATRIX = 1,
  CONTEST = 2,
  STATS = 3
}
