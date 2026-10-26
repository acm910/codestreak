import localUnitTest from './LocalUnit.test';
import difficultyTest from './Difficulty.test';
import dateUtilTest from './DateUtil.test';
import checkInServiceTest from './CheckInService.test';

export default function testsuite() {
  localUnitTest();
  difficultyTest();
  dateUtilTest();
  checkInServiceTest();
}
