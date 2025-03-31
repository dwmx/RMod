class R_ATest_List_AddUniqueNone extends R_ATest_List abstract;

static function String GetTestNameString()
{
	return "Add unique None to list";
}

static function bool RunTest(out String FailedResonString)
{
	local R_ObjectList ListNode;
	local int ListLength;
	
	// Instantiate
	ListNode = InstantiateObjectListNode();
	if(ListNode == None)
	{
		FailedResonString = "List instantiation failed";
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
	ListNode.AddUnique(None);

	ListLength = ListNode.Length();
	if(ListLength != 0)
	{
		FailedResonString = "List length wrong after calling AddUnique with None -- expected 0, got" @ ListLength;
		return false;
	}

	return true;
}