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

function int Main(String Args)
{
	local int NumPassed, NumFailed;

	Log("Hello World from the Test commandlet", LogCategory);
	Log("This is what your Args string looks like:" @ Args);

	RunAllTests(NumPassed, NumFailed);

	if(NumFailed > 0)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

function RunAllTests(out int OutNumPassed, out int OutNumFailed)
{
	local int NumPassed, NumFailed;
	local Class<R_ATest> Tests[16];
	local int TestIndex;

	Tests[0] = Class'RTest.R_ATest';
	Tests[1] = Class'RTest.R_ATest_SimpleMath';
	Tests[2] = Class'RTest.R_ATest_SuperHardMath';

	NumPassed = 0;
	NumFailed = 0;

	// This is an example of how to run tests
	Log("========================================", LogCategory);
	Log("Running all tests", LogCategory);
	Log("========================================", LogCategory);

	for(TestIndex = 0; TestIndex < 16; ++TestIndex)
	{
		if(Tests[TestIndex] != None)
		{
			if(RunTest(Tests[TestIndex]))
			{
				++NumPassed;
			}
			else
			{
				++NumFailed;
			}
		}
	}

	Log("========================================", LogCategory);
	Log(NumPassed @ "passed," @ NumFailed @ "failed");
	Log("========================================", LogCategory);

	OutNumPassed = NumPassed;
	OutNumFailed = NumFailed;
}

function bool RunTest(Class<R_ATest> TestClass)
{
	local bool bResult;
	local String TestNameString;
	local String ResultString;

	if(TestClass == None)
	{
		Warn("Invalid TestClass");
		return false;
	}

	TestNameString = TestClass.Static.GetTestNameString();

	bResult = TestClass.Static.RunTest();

	if(bResult)
	{
		ResultString = "[Test Passed]:" @ TestNameString;
	}
	else
	{
		ResultString = "[Test Failed]:" @ TestNameString;
	}

	Log(ResultString @ "{Class:" @ TestClass $ "}");
	return bResult;
}