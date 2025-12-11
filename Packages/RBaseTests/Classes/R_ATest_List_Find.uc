class R_ATest_List_Find extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Find object index in list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local R_MockObject MockObject1, MockObject2, MockObject3;
	local int ListLength;
	local int Index;
	
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
	|| MockObject2 == None
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

	// Add mocks
	ListNode.Add(MockObject1);
	ListNode.Add(MockObject2);
	ListNode.Add(MockObject3);
	ListLength = ListNode.Length();
	if(ListLength != 3)
	{
		FailedResonString = "List length after adding three mocks wrong -- expected 3, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject1
	|| ListNode.GetAtIndex(1) != MockObject2
	|| ListNode.GetAtIndex(2) != MockObject3)
	{
		FailedResonString = "GetAtIndex did not return the correct object";
		return false;
	}

	// Find each object
	if(!ListNode.Find(MockObject1, Index) || Index != 0)
	{
		FailedResonString = "Find did not return correctly for first object";
		return false;
	}
	if(!ListNode.Find(MockObject2, Index) || Index != 1)
	{
		FailedResonString = "Find did not return correctly for second object";
		return false;
	}
	if(!ListNode.Find(MockObject3, Index) || Index != 2)
	{
		FailedResonString = "Find did not return correctly for third object";
		return false;
	}

	// Remove one object and test again
	ListNode.Remove(MockObject2);
	if(!ListNode.Find(MockObject1, Index) || Index != 0)
	{
		FailedResonString = "Find after remove did not return correctly for first object";
		return false;
	}
	if(!ListNode.Find(MockObject3, Index) || Index != 1)
	{
		FailedResonString = "Find after remove did not return correctly for third object";
		return false;
	}

	// Remove the rest of the object and test again
	ListNode.Remove(MockObject1);
	ListNode.Remove(MockObject3);

	if(ListNode.Find(MockObject1, Index)
	|| ListNode.Find(MockObject2, Index)
	|| ListNode.Find(MockObject3, Index))
	{
		FailedResonString = "Find returned true even after removing all objects, should have returned false";
		return false;
	}

	// Test None argument
	if(ListNode.Find(None, Index))
	{
		FailedResonString = "Find returned true for None argument, should have returned false";
		return false;
	}

	return true;
}