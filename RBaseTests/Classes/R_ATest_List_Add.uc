class R_ATest_List_Add extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Add one object to list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local R_MockObject MockObject;
	local int LengthBeforeAdd;
	local int LengthAfterAdd;

	ListNode = InstantiateObjectListNode();
	if(ListNode == None)
	{
		return false;
	}

	MockObject = InstantiateMockObject();
	if(MockObject == None)
	{
		return false;
	}

	LengthBeforeAdd = ListNode.Length();
	ListNode.Add(MockObject);
	LengthAfterAdd = ListNode.Length();

	if(LengthBeforeAdd != 0 || LengthAfterAdd != 1)
	{
		return false;
	}
	if(ListNode.GetAtIndex(0) != MockObject)
	{
		return false;
	}

	return true;
}