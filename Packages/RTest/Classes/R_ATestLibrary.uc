//==============================================================================
//	R_ATestLibrary;
//	Function library for testing
//==============================================================================
class R_ATestLibrary extends Object abstract;

static function R_MockObject InstantiateMockObject(optional Class<R_MockObject> MockObjectClass)
{
	local R_MockObject MockObjectInstance;

	if(MockObjectClass == None)
	{
		MockObjectClass = Class'RTest.R_MockObject';
	}
	MockObjectInstance = New(None) MockObjectClass;
	return MockObjectInstance;
}