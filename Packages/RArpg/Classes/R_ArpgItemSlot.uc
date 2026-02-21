//==============================================================================
//	R_ArpgItemSlot
//	An ItemContainer capable of holding one, and only one ArpgItem
//==============================================================================
class R_ArpgItemSlot extends R_ArpgItemContainer;

var private R_ArpgItem StoredItem;

//------------------------------------------------------------------------------

function bool InternalSetStoredItem(R_ArpgItem NewStoredItem)
{
	if(StoredItem == NewStoredItem)
	{
		return false;
	}

	StoredItem = NewStoredItem;
	return true;
}

function bool InternalIsSlotAvailable()
{
	return StoredItem == None;
}

//------------------------------------------------------------------------------

function bool AddItem(R_ArpgItem Item)
{
	if(Item == None || !InternalIsSlotAvailable())
	{
		return false;
	}

	return InternalSetStoredItem(Item);
}

function bool RemoveItem(R_ArpgItem Item)
{
	if(Item == None || StoredItem != Item)
	{
		return false;
	}

	return InternalSetStoredItem(None);
}

function int GetNumItems()
{
	if(StoredItem == None)
	{
		return 0;
	}
	return 1;
}

function R_ArpgItem GetItemAtIndex(int Index)
{
	if(Index == 0)
	{
		return StoredItem;
	}
	return None;
}