class R_ATest_List_RemoveStaggered extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Remove staggered objects from list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local R_MockObject MockObject1, MockObject2, MockObject3;
	local int ListLength;
	
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

	// Remove middle object
	ListNode.Remove(MockObject2);

	ListLength = ListNode.Length();
	if(ListLength != 2)
	{
		FailedResonString = "List length after removing one mock wrong -- expected 2, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject1
	|| ListNode.GetAtIndex(1) != MockObject3)
	{
		FailedResonString = "GetAtIndex did not return the correct object after staggered removal";
		return false;
	}

	return true;
}