class R_ATest_List_AddUnique extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Add unique object to list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local R_MockObject MockObject;
	local int ListLength;
	
	// Instantiate
	ListNode = InstantiateObjectListNode();
	if(ListNode == None)
	{
		FailedResonString = "List instantiation failed";
		return false;
	}

	MockObject = InstantiateMockObject();
	if(MockObject == None)
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

	// First call to AddUnique
	ListNode.AddUnique(MockObject);

	ListLength = ListNode.Length();
	if(ListLength != 1)
	{
		FailedResonString = "List length wrong after first call to AddUnique -- expected 1, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject)
	{
		FailedResonString = "Index[0] did not return the correct object after first call to AddUnique";
		return false;
	}

	// Second call to AddUnique
	ListNode.AddUnique(MockObject);

	ListLength = ListNode.Length();
	if(ListLength != 1)
	{
		FailedResonString = "List length wrong after second call to AddUnique -- expected 1, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject)
	{
		FailedResonString = "Index[0] did not return the correct object after second call to AddUnique";
		return false;
	}

	return true;
}