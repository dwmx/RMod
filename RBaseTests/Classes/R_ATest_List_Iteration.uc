class R_ATest_List_Iteration extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Iterate over list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local R_MockObject MockObject1, MockObject2, MockObject3;
	local int ListLength;
	local R_ObjectList NodeIt;
	local Object ObjectIt;

	// Instantiate
	ListNode = InstantiateObjectListNode();
	if(ListNode == None)
	{
		FailedResonString = "List instantiation failed";
		return false;
	}

	MockObject1 = InstantiateMockObject();
	MockObject2 = InstantiateMockObject();
	MockObject3 = InstantiateMockObject();
	if(MockObject1 == None
	|| MockObject2 == none
	|| MockObject3 == None)
	{
		FailedResonString = "Mock instantiation failed";
		return false;
	}

	// Check initial length
	ListLength = ListNode.Length();
	if(ListLength != 0)
	{
		FailedResonString = "Initial list length wrong -- expected 0 got" @ ListLength;
		return false;
	}

	// Add Mocks
	ListNode.Add(MockObject1);
	ListNode.Add(MockObject2);
	ListNode.Add(MockObject3);

	ListLength = ListNode.Length();
	if(ListLength != 3)
	{
		FailedResonString = "List length wrong after adding three mocks -- expected 3, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject1
	|| ListNode.GetAtIndex(1) != MockObject2
	|| ListNode.GetAtIndex(2) != MockObject3)
	{
		FailedResonString = "GetAtIndex did not return the correct object";
		return false;
	}

	// Manually iterate over three objects
	NodeIt = ListNode.Begin();

	// First three calls should succeed
	if(!ListNode.Iterate(NodeIt, ObjectIt) || ObjectIt != MockObject1)
	{
		FailedResonString = "First call to Iterate failed";
		return false;
	}
	if(!ListNode.Iterate(NodeIt, ObjectIt) || ObjectIt != MockObject2)
	{
		FailedResonString = "Second call to Iterate failed";
		return false;
	}
	if(!ListNode.Iterate(NodeIt, ObjectIt) || ObjectIt != MockObject3)
	{
		FailedResonString = "Third call to Iterate failed";
		return false;
	}

	// Last call should return false
	if(ListNode.Iterate(NodeIt, ObjectIt) || NodeIt != None || ObjectIt != None)
	{
		FailedResonString = "Iterate did not return false or did not None its iterators when it should have";
		return false;
	}

	return true;
}