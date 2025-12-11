class R_ATest_List_InsertHead extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Insert new object at head (index 0)";
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

	// Insert 4th as the new head
	if(!ListNode.Insert(MockObject4, 0))
	{
		FailedReasonString = "Insert valid new head node failed -- returned false, expected true";
		return false;
	}
	if(ListNode.Length() != 4)
	{
		FailedReasonString = "Insert valid new head node did not increase list size by 1";
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject4)
	{
		FailedReasonString = "GetAtIndex(0) did not return the newly added valid head node";
		return false;
	}

	return true;
}