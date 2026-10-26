import { describe, expect, it } from '@ohos/hypium';
import { RetryEntry, RetryQueue } from '../main/ets/domain/RetryQueue';

export default function retryQueueTest() {
  describe('RetryQueue', () => {
    it('encode_decode_roundtrip', 0, () => {
      const entry: RetryEntry = { platform: 'CF', target: 'tourist', attempt: 1, nextAt: 1730000000000 };
      const decoded: RetryEntry | null = RetryQueue.decode(RetryQueue.encode(entry));
      expect(decoded !== null).assertTrue();
      expect(decoded!.platform).assertEqual('CF');
      expect(decoded!.target).assertEqual('tourist');
      expect(decoded!.attempt).assertEqual(1);
      expect(decoded!.nextAt).assertEqual(1730000000000);
    });

    it('decode_invalid_returns_null', 0, () => {
      expect(RetryQueue.decode('') === null).assertTrue();
      expect(RetryQueue.decode('CF|tourist|1') === null).assertTrue();
      expect(RetryQueue.decode('CF|tourist|x|y') === null).assertTrue();
    });

    it('is_due', 0, () => {
      const entry: RetryEntry = { platform: 'AC', target: 'u', attempt: 1, nextAt: 1000 };
      expect(RetryQueue.isDue(entry, 999)).assertFalse();
      expect(RetryQueue.isDue(entry, 1000)).assertTrue();
    });

    it('backoff_sequence_and_cap', 0, () => {
      const first: RetryEntry | null = RetryQueue.afterFailure('CF', 'tourist', 0, 1000);
      expect(first !== null).assertTrue();
      expect(first!.attempt).assertEqual(1);
      expect(first!.nextAt).assertEqual(1000 + 60000);

      const second: RetryEntry | null = RetryQueue.afterFailure('CF', 'tourist', 1, 1000);
      expect(second!.nextAt).assertEqual(1000 + 300000);

      const third: RetryEntry | null = RetryQueue.afterFailure('CF', 'tourist', 2, 1000);
      expect(third!.nextAt).assertEqual(1000 + 900000);

      expect(RetryQueue.afterFailure('CF', 'tourist', 3, 1000) === null).assertTrue();
    });
  });
}
