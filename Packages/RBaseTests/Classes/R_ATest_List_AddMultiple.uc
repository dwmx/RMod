class R_ATest_List_AddMultiple extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Add multiple objects to list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local R_MockObject MockObject1, MockObject2, MockObject3;
	
	ListNode = InstantiateObjectListNode();
	if(ListNode == None)
	{
		return false;
	}

	if(ListNode.Length() != 0)
	{
		return false;
	}

	MockObject1 = InstantiateMockObject();
	ListNode.Add(MockObject1);
	if(ListNode.Length() != 1 || ListNode.GetAtIndex(0) != MockObject1)
	{
		return false;
	}

	MockObject2 = InstantiateMockObject();
	ListNode.Add(MockObject2);
	if(ListNode.Length() != 2 || ListNode.GetAtIndex(1) != MockObject2)
	{
		return false;
	}

	MockObject3 = InstantiateMockObject();
	ListNode.Add(MockObject3);
	if(ListNode.Length() != 3 || ListNode.GetAtIndex(2) != MockObject3)
	{
		return false;
	}

	return true;
}