class R_ATest_List_InsertBadIndex extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Insert with bad index arguments";
}

static function bool RunTest(out String FailedReasonString)
{
	local R_ObjectList ListNode;
	local R_MockObject MockObject1, MockObject2, MockObject3, MockObject4;

	// Instantiate
	ListNode = InstantiateObjectListNode();
	if(ListNode == None)
	{
		FailedReasonString = "List instantiation failed";
		return false;
	}

	// Try inserting None
	if(ListNode.Insert(None, 0))
	{
		FailedReasonString = "Insert with None argument returned true, expected false";
		return false;
	}

	// Instantiate mocks
	MockObject1 = InstantiateMockObject();
	MockObject2 = InstantiateMockObject();
	MockObject3 = InstantiateMockObject();
	MockObject4 = InstantiateMockObject();
	if(MockObject1 == None
	|| MockObject2 == None
	|| MockObject3 == None
	|| MockObject4 == None)
	{
		FailedReasonString = "Mock instantiation failed";
		return false;
	}

	// Add 3 to list
	ListNode.Add(MockObject1);
	ListNode.Add(MockObject2);
	ListNode.Add(MockObject3);

	if(ListNode.Length() != 3)
	{
		FailedReasonString = "List length was incorrect after adding three objects";
		return false;
	}

	// Try inserting at bad index (less than 0 condition)
	if(ListNode.Insert(MockObject4, -1))
	{
		FailedReasonString = "Insert returned true when inserting at bad index (-1)";
		return false;
	}
	if(ListNode.Length() != 3)
	{
		FailedReasonString = "List length changed after failed call to Insert";
		return false;
	}

	// Try inserting at bad index (greater than length condition)
	if(ListNode.Insert(MockObject4, ListNode.Length() + 1))
	{
		FailedReasonString = "Insert returned true when inserting at bad index (length + 1)";
		return false;
	}
	if(ListNode.Length() != 3)
	{
		FailedReasonString = "List length changed after failed call to Insert";
		return false;
	}

	return true;
}