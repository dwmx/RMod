class R_ATestCollection extends Object abstract;

const LogCategory = 'RTest';

static function String GetTestCollectionNameString()
{
	return "Test Collection";
}

static function int GetNumTests()
{
	return 4;
}

static function Class<R_ATest> GetTestAtIndex(int TestIndex)
{
	switch(TestIndex)
	{
		case 0: return Class'RTest.R_ATest';
		case 1: return Class'RTest.R_ATest_SimpleMath';
		case 2: return Class'RTest.R_ATest_SuperHardMath';
		case 3: return Class'RTest.R_ATest_IntentionalFail';
	}

	return None;
}

static function RunAllTests(out int OutNumPassed, out int OutNumFailed)
{
	local int NumPassed, NumFailed;
	local int NumTests;
	local Class<R_ATest> CurrentTestClass;
	local int TestIndex;

	NumPassed = 0;
	NumFailed = 0;

	// This is an example of how to run tests
	Log("========================================", LogCategory);
	Log("[Test Collection]:" @ GetTestCollectionNameString());
	Log("Running all tests", LogCategory);
	Log("========================================", LogCategory);

	NumTests = GetNumTests();
	for(TestIndex = 0; TestIndex < NumTests; ++TestIndex)
	{
		CurrentTestClass = GetTestAtIndex(TestIndex);
		if(CurrentTestClass != None)
		{
			if(RunTest(CurrentTestClass))
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

static function bool RunTest(Class<R_ATest> TestClass)
{
	local bool bResult;
	local String TestNameString;
    local String ReasonString;
	local String ResultString;

	if(TestClass == None)
	{
		Warn("Invalid TestClass");
		return false;
	}

	TestNameString = TestClass.Static.GetTestNameString();

	ReasonString = "";
	bResult = TestClass.Static.RunTest(ReasonString);

	if(bResult)
	{
		ResultString = "[Test Passed]:" @ TestNameString;
	}
	else
	{
		ResultString = "[Test Failed]:" @ TestNameString;
	}

	Log(ResultString @ "{Class:" @ TestClass $ "}");
	if(ReasonString != "")
	{
		Log("- [REASON]:" @ ReasonString);
	}
	return bResult;
}