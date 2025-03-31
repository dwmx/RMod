class R_ATest_List_RemoveNone extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Remove None object from list";
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

	// Add object
	ListNode.Add(MockObject);
	ListLength = ListNode.Length();
	if(ListLength != 1)
	{
		FailedResonString = "List length after adding mock wrong -- expected 1, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject)
	{
		FailedResonString = "GetAtIndex did not return the correct object";
		return false;
	}

	// Remove None
	ListNode.Remove(None);
	ListLength = ListNode.Length();
	if(ListLength != 1)
	{
		FailedResonString = "List length after removing None wrong -- expected 1, got" @ ListLength;
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject)
	{
		FailedResonString = "GetAtIndex should have returned Object, but didn't";
		return false;
	}

	return true;
}