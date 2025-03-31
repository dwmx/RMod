class R_ATest_List_InsertMiddle extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Insert new object in the middle";
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

	// Insert 4th at index 2
	if(!ListNode.Insert(MockObject4, 2))
	{
		FailedReasonString = "Insert valid node at index 2 returned false, expected true";
		return false;
	}
	if(ListNode.Length() != 4)
	{
		FailedReasonString = "Insert valid new node at index 2 did not increase list size by 1";
		return false;
	}
	if(ListNode.GetAtIndex(2) != MockObject4)
	{
		FailedReasonString = "GetAtIndex(2) did not return the newly added valid node";
		return false;
	}

	return true;
}