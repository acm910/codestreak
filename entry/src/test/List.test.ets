import localUnitTest from './LocalUnit.test';
import difficultyTest from './Difficulty.test';
import dateUtilTest from './DateUtil.test';
import checkInServiceTest from './CheckInService.test';
import codeforcesMapperTest from './CodeforcesMapper.test';
import syncPolicyTest from './SyncPolicy.test';

export default function testsuite() {
  localUnitTest();
  difficultyTest();
  dateUtilTest();
  checkInServiceTest();
  codeforcesMapperTest();
  syncPolicyTest();
}
