class R_ATest_List extends R_ATest abstract;

const TestLibrary = Class'RTest.R_ATestLibrary';

static function String GetTestNameString()
{
	return "Instantiate List";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;

	ListNode = InstantiateObjectListNode();
	return ListNode != None;
}

static function R_ObjectList InstantiateObjectListNode()
{
	return New(None) Class'RBase.R_ObjectList';
}

static function R_MockObject InstantiateMockObject()
{
	// Just use the list node as the mock for now
	// Ideally this should be some other object
	return TestLibrary.Static.InstantiateMockObject();
}