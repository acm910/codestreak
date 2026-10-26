import { describe, expect, it } from '@ohos/hypium';
import { SyncPolicy } from '../main/ets/domain/SyncPolicy';

export default function syncPolicyTest() {
  describe('SyncPolicy', () => {
    it('first_request_has_no_wait', 0, () => {
      expect(SyncPolicy.waitMs(0, 1000)).assertEqual(0);
    });

    it('waits_until_two_seconds_gap', 0, () => {
      expect(SyncPolicy.waitMs(1000, 1500)).assertEqual(1500);
      expect(SyncPolicy.waitMs(1000, 3000)).assertEqual(0);
    });

    it('retry_backoff_sequence', 0, () => {
      expect(SyncPolicy.retryDelayMs(1)).assertEqual(60000);
      expect(SyncPolicy.retryDelayMs(2)).assertEqual(300000);
      expect(SyncPolicy.retryDelayMs(3)).assertEqual(900000);
      expect(SyncPolicy.retryDelayMs(9)).assertEqual(900000);
    });

    it('degrades_after_three_failures', 0, () => {
      expect(SyncPolicy.shouldDegrade(0)).assertFalse();
      expect(SyncPolicy.shouldDegrade(2)).assertFalse();
      expect(SyncPolicy.shouldDegrade(3)).assertTrue();
    });

    it('classifies_retryable_errors', 0, () => {
      expect(SyncPolicy.isRetryable('HTTP 429')).assertTrue();
      expect(SyncPolicy.isRetryable('网络请求失败：timeout')).assertTrue();
      expect(SyncPolicy.isRetryable('handle: User with handle nobody not found')).assertFalse();
    });
  });
}
