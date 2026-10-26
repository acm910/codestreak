import localUnitTest from './LocalUnit.test';
import difficultyTest from './Difficulty.test';
import dateUtilTest from './DateUtil.test';
import checkInServiceTest from './CheckInService.test';
import codeforcesMapperTest from './CodeforcesMapper.test';
import syncPolicyTest from './SyncPolicy.test';
import atCoderMapperTest from './AtCoderMapper.test';
import cpcfinderMapperTest from './CpcfinderMapper.test';
import heatmapTest from './Heatmap.test';
import reminderPlanTest from './ReminderPlan.test';
import luoguMapperTest from './LuoguMapper.test';
import retryQueueTest from './RetryQueue.test';
import leetCodeMapperTest from './LeetCodeMapper.test';
import statsServiceTest from './StatsService.test';
import platformContestMapperTest from './PlatformContestMapper.test';
import nowCoderMapperTest from './NowCoderMapper.test';

export default function testsuite() {
  localUnitTest();
  difficultyTest();
  dateUtilTest();
  checkInServiceTest();
  codeforcesMapperTest();
  syncPolicyTest();
  atCoderMapperTest();
  cpcfinderMapperTest();
  heatmapTest();
  reminderPlanTest();
  luoguMapperTest();
  retryQueueTest();
  leetCodeMapperTest();
  statsServiceTest();
  platformContestMapperTest();
  nowCoderMapperTest();
}
