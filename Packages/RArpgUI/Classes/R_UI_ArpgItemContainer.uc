//==============================================================================
//	R_UI_ArpgItemContainer
//==============================================================================
class R_UI_ArpgItemContainer extends R_UI_ArpgWindow;

/**
	QueryItemAtLocation
	Returns the item at the specified location
*/
function bool QueryItemAtLocation(
	float PositionX, float PositionY,
	out R_ArpgItem OutItem)
{
	OutItem = None;
	return false;
}

/**
	QueryPlaceFloatingItem
	Returns an answer to the question: "If I were to try to place an item here,
	what would happen?". Used by ArpgItemInteractor to draw the correct
	indicated color for floating item being held over a region.

	Returns false if query failed (i.e. bad args or bad underlying container)
*/
function bool QueryPlaceFloatingItem(
	R_ArpgItem Item,
	float PositionX, float PositionY,
	Vector Alignment,
	out int OutQueryResult,
	out R_ArpgWindowRegion OutFloatingItemRegion,
	out R_ArpgItem OutSwapItem,
	out R_ArpgWindowRegion OutSwapItemRegion)
{
	OutQueryResult = QUERY_RESULT_INVALID;
	OutFloatingItemRegion = ArpgWindowRegion(0,0,0,0);
	OutSwapItem = None;
	OutSwapItemRegion = ArpgWindowRegion(0,0,0,0);
	return false;
}

/**
	TryPlaceFloatingItem
	Attempts to place the floating using the specified window coordinates.
	
	Return true if the item was successfully placed
*/
function bool TryPlaceFloatingItem(
	R_ArpgItem Item,
	float PositionX, float PositionY,
	Vector Alignment)
{
	return false;
}

function bool RemoveItem(R_ArpgItem Item)
{
	return false;
}

//------------------------------------------------------------------------------
//	Paint Funtions

function Paint(Canvas C, float X, float Y)
{
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Style = 1;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, WhiteTexture);
}