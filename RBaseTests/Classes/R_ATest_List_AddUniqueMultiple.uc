class R_ATest_List_AddUniqueMultiple extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Add multiple unique object to list";
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

	if(MockObject1 == None || MockObject2 == None || MockObject3 == None)
	{
		FailedResonString = "Mock object instantiation failed";
		return false;
	}

	// Check initial length
	ListLength = ListNode.Length();
	if(ListLength != 0)
	{
		FailedResonString = "Initial list length wrong -- expected 0, got" @ ListLength;
		return false;
	}

	// AddUnique all mocks
	ListNode.AddUnique(MockObject1);
	ListNode.AddUnique(MockObject2);
	ListNode.AddUnique(MockObject3);

	ListLength = ListNode.Length();
	if(ListLength != 3)
	{
		FailedResonString = "List length wrong after three valid calls to AddUnique -- expected 3, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject1
	|| ListNode.GetAtIndex(1) != MockObject2
	|| ListNode.GetAtIndex(2) != MockObject3)
	{
		FailedResonString = "GetAtIndex failed to return the correct objects after three valid calls to AddUnique";
		return false;
	}

	// Second call to all mocks -- should not get added
	ListNode.AddUnique(MockObject1);
	ListNode.AddUnique(MockObject2);
	ListNode.AddUnique(MockObject3);

	ListLength = ListNode.Length();
	if(ListLength != 3)
	{
		FailedResonString = "List length wrong after additional three calls to AddUnique -- expected 3, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject1
	|| ListNode.GetAtIndex(1) != MockObject2
	|| ListNode.GetAtIndex(2) != MockObject3)
	{
		FailedResonString = "GetAtIndex failed to return the correct objects after additional three calls to AddUnique";
		return false;
	}

	return true;
}