//==============================================================================
//	R_UI_ArpgItemSlot
//==============================================================================
class R_UI_ArpgItemSlot extends R_UI_ArpgItemContainer;

var private R_ArpgItemSlot ItemSlot;

function SetItemSlot(R_ArpgItemSlot NewItemSlot)
{
	ItemSlot = NewItemSlot;
}

function bool IsPositionValid(float PositionX, float PositionY)
{
	return PositionX >= 0.0 && PositionX < WinWidth && PositionY >= 0.0 && PositionY < WinHeight;
}

function bool QueryItemAtLocation(
	float PositionX, float PositionY,
	out R_ArpgItem OutItem)
{
	OutItem = None;

	if(!IsPositionValid(PositionX, PositionY))
	{
		return false;
	}

	if(ItemSlot != None)
	{
		ItemSlot.GetItem(0, OutItem);
	}

	return true;
}

function bool QueryPlaceFloatingItem(
	R_ArpgItem Item,
	float PositionX, float PositionY,
	Vector Alignment,
	out int OutQueryResult,
	out R_ArpgWindowRegion OutFloatingItemRegion,
	out R_ArpgItem OutSwapItem,
	out R_ArpgWindowRegion OutSwapItemRegion)
{
	local R_ArpgItem StoredItem;

	OutQueryResult = QUERY_RESULT_INVALID;
	OutFloatingItemRegion = ArpgWindowRegion(0, 0, 0, 0);
	OutSwapItem = None;
	OutSwapItemRegion = ArpgWindowRegion(0, 0, 0, 0);

	if(ItemSlot == None || !IsPositionValid(PositionX, PositionY))
	{
		return false;
	}

	OutFloatingItemRegion = ArpgWindowRegion(0, 0, WinWidth, WinHeight);
	OutQueryResult = QUERY_RESULT_CAN_PLACE;

	if(ItemSlot.GetItem(0, StoredItem))
	{
		OutSwapItem = StoredItem;
		OutQueryResult = QUERY_RESULT_CAN_SWAP;
		OutSwapItemRegion = ArpgWindowRegion(0, 0, WinWidth, WinHeight);
	}

	return true;
}

function bool TryPlaceFloatingItem(
	R_ArpgItem Item,
	float PositionX, float PositionY,
	Vector Alignment)
{
	if(ItemSlot == None || !IsPositionValid(PositionX, PositionY))
	{
		return false;
	}

	return ItemSlot.AddItem(Item);
}

function bool RemoveItem(R_ArpgItem Item)
{
	if(ItemSlot == None)
	{
		return false;
	}

	return ItemSlot.RemoveItem(Item);
}

function Paint(Canvas C, float X, float Y)
{
	PaintBackdrop(C);
	PaintItems(C);
}

function PaintBackdrop(Canvas C)
{
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Style = 1;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, WhiteTexture);
}

function PaintItems(Canvas C)
{
	local R_ArpgItem StoredItem;

	if(ItemSlot != None)
	{
		if(ItemSlot.GetItem(0, StoredItem))
		{
			PaintItem(C, WinWidth * 0.5, WinHeight * 0.5, Vect(0.5,0.5,0), StoredItem);
		}
	}
}