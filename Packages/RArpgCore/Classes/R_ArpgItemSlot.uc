//==============================================================================
//	R_ArpgItemSlot
//	Most basic implementation of an ItemContainer
//	Suitable for equipment slots and floating item slot
//==============================================================================
class R_ArpgItemSlot extends R_ArpgItemContainer;

var private R_ArpgItem StoredItem;
var private R_ArpgObject EventListener;

//------------------------------------------------------------------------------
// 	Events emitted from this object
const EVENT_ITEM_CHANGED = 'ItemChanged'; // Payload: New stored item

//------------------------------------------------------------------------------

function SetStoredItem(R_ArpgItem NewItem)
{
	if(StoredItem == NewItem)
	{
		return;
	}

	StoredItem = NewItem;

	FireEvent(EVENT_ITEM_CHANGED, StoredItem);
}

//------------------------------------------------------------------------------

function bool IsValidIndex(int Index)
{
	// Only valid when StoredItem != None and Index == 0
	if(StoredItem == None)
	{
		return false;
	}

	return Index == 0;
}

function bool IsEmpty()
{
	return StoredItem == None;
}

function bool ContainsItem(R_ArpgItem Item)
{
	if(Item == None || StoredItem == None)
	{
		return false;
	}

	return Item == StoredItem;
}

function bool AddItem(R_ArpgItem Item)
{
	// Can only add item if slot is empty
	if(StoredItem != None || Item == None)
	{
		return false;
	}

	SetStoredItem(Item);
	return true;
}

function bool RemoveItem(R_ArpgItem Item)
{
	if(StoredItem == None || Item == None)
	{
		return false;
	}

	if(StoredItem == Item)
	{
		SetStoredItem(None);
		return true;
	}

	return false;
}

function int GetItemCount()
{
	if(StoredItem != None)
	{
		return 1;
	}
	return 0;
}

function bool GetItem(int Index, out R_ArpgItem OutItem)
{
	if(StoredItem != None && Index == 0)
	{
		OutItem = StoredItem;
		return true;
	}
	OutItem = None;
	return false;
}

function bool GetItemIndex(R_ArpgItem Item, out int OutIndex)
{
	if(StoredItem != None && StoredItem == Item)
	{
		OutIndex = 0;
		return true;
	}
	OutIndex = INVALID_INDEX;
	return false;
}

//------------------------------------------------------------------------------

function SetEventListener(R_ArpgObject NewEventListener)
{
	EventListener = NewEventListener;
}

function FireEvent(Name EventName, optional Object OptionalPayload)
{
	local R_ArpgEventPayload Payload;

	if(EventListener != None)
	{
		Payload.OptionalObject = OptionalPayload;
		EventListener.ReceiveArpgEvent(EventName, Self, Payload);
	}
}