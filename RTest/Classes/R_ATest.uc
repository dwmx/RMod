//==============================================================================
//	R_ATest
//	Abstract base class for performing tests
//	Each test that you define should extend from this class and override RunTest
//==============================================================================
class R_ATest extends Object abstract;

/**
*	GetTestNameString
*	Returns the readable version of this test's name
*	i.e. How you want it to appear in the log
*/
static function String GetTestNameString()
{
	return "BaseTest";
}

/**
*	RunTest
*	Runs the test defined by this class and returns true for pass, false for fail
*/
static function bool RunTest(out String FailedResonString)
{
	return true;
}