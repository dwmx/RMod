class R_ATest_List_AddNone extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Add None object to list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local int ListLength;

	// Instantiation
	ListNode = InstantiateObjectListNode();
	if(ListNode == None)
	{
		return false;
	}

	// Initial length
	ListLength = ListNode.Length();
	if(ListLength != 0)
	{
		FailedResonString = "Initial list length invalid -- expected 0, got" @ ListLength;
		return false;
	}

	// Add None
	ListNode.Add(None);
	ListLength = ListNode.Length();
	if(ListLength != 0)
	{
		FailedResonString = "List length incorrect after adding None -- expected 0, got" @ ListLength;
		return false;
	}

	return true;
}