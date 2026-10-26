/** 平台原始提交（同步入参，未落库） */
export interface SyncSubmission {
  platform: string;
  /** 平台侧唯一 ID */
  externalId: string;
  /** 全局题号，如 CF-1899A */
  problemKey: string;
  title: string;
  /** 平台原生难度值（CF 为 rating，LC 为字符串档位） */
  nativeDifficulty: string;
  /** 归一化难度 1.0–5.0 */
  difficultyNorm: number;
  verdict: string;
  /** 提交时间（epoch 秒） */
  epochSecond: number;
  isAc: boolean;
  tags: string[];
}

/** 解析结果（带失败原因，便于 UI 提示） */
export interface MapperResult {
  ok: boolean;
  message: string;
  submissions: SyncSubmission[];
}
