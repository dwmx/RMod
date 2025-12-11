//==============================================================================
//	R_TestCommandlet
//	Entry point for running tests, can be called directly via UCC
//
//	UCC.exe RTest.R_TestCommandlet
//		or
//	UCC.exe RTest.R_Test
//
//	UCC is able to execute UnrealScript in a raw context via commandlets,
//	meaning that there is no game instance and no actors exist
//==============================================================================
class R_TestCommandlet extends Commandlet;

const LogCategory = 'RTest';

const RET_AllPassed = 0;
const RET_SomeFailed = 1;
const RET_FailedToExecuteTests = 2;

function int Main(String Args)
{
	local Class<R_ATestCollection> TestListClass;
	local int NumPassed, NumFailed;

	TestListClass = Class<R_ATestCollection>(DynamicLoadObject(Args, Class'Class'));
	if(TestListClass == None)
	{
		Log("Failed to load test list from argument" @ Args);
		LogReturnValue(RET_FailedToExecuteTests);
		return RET_FailedToExecuteTests;
	}

	//Log("Hello World from the Test commandlet", LogCategory);
	//Log("This is what your Args string looks like:" @ Args);

	//Class'RTest.R_ATestSet'.Static.RunAllTests(NumPassed, NumFailed);
	TestListClass.Static.RunAllTests(NumPassed, NumFailed);

	if(NumFailed > 0)
	{
		LogReturnValue(RET_SomeFailed);
		return RET_SomeFailed;
	}
	else
	{
		LogReturnValue(RET_AllPassed);
		return RET_AllPassed;
	}
}

function LogReturnValue(int ReturnValue)
{
	switch(ReturnValue)
	{
	case RET_AllPassed:				Log("All tests passed");		return;
	case RET_SomeFailed:			Log("Some tests failed");		return;
	case RET_FailedToExecuteTests:	Log("Tests failed to execute");	return;
	}
}