//==============================================================================
//	R_ArpgItemGrid
//==============================================================================
class R_ArpgItemGrid extends R_ArpgItemContainer;

struct R_ArpgItemGridEntry
{
	var R_ArpgItem StoredItem;
	var int GridIndexX;
	var int GridIndexY;
};

// Entries must be big enough to hold worst case scenario
// MAX_X by MAX_Y grid size, full of 1x1 items
const MAX_GRID_SIZE_X = 16;
const MAX_GRID_SIZE_Y = 16;
var private R_ArpgItemGridEntry Entries[256];
var private int EntriesCount;

var private int GridSizeX;
var private int GridSizeY;

//------------------------------------------------------------------------------
//	R_ArpgObject Interface
function InitializeArpgObject()
{
	EntriesCount = 0;

	// Force clamping on defaultproperties
	SetGridSize(GridSizeX, GridSizeY);
}

//------------------------------------------------------------------------------
//	R_ArpgItemContainer Interface
function bool IsValidIndex(int Index)
{
	return Index >= 0 && Index < EntriesCount;
}

function bool IsEmpty()
{
	return EntriesCount == 0;
}

function bool ContainsItem(R_ArpgItem Item)
{
	local int i;

	if(Item == None)
	{
		return false;
	}

	for(i = 0; i < EntriesCount; ++i)
	{
		if(Entries[i].StoredItem == Item)
		{
			return true;
		}
	}
	return false;
}

function bool AddItem(R_ArpgItem Item)
{
	local int SizeX, SizeY;
	local int IndexX, IndexY;
	local R_ArpgItem ItemIt;
	local int ItemItIndexX, ItemItIndexY;
	local int ItemItSizeX, ItemItSizeY;
	local int i;
	local bool bCanPlace;

	if(Item == None || EntriesCount >= ArrayCount(Entries) || ContainsItem(Item))
	{
		return false;
	}

	Item.GetItemGridSize(SizeX, SizeY);
	if(SizeX < 1 || SizeY < 1)
	{	// Items must be at least 1x1
		return false;
	}

	for(IndexY = 0; IndexY <= GridSizeY - SizeY; ++IndexY)
	{
		for(IndexX = 0; IndexX <= GridSizeX - SizeX; ++IndexX)
		{
			bCanPlace = true;
			for(i = 0; i < EntriesCount; ++i)
			{
				ItemIt = Entries[i].StoredItem;
				ItemItIndexX = Entries[i].GridIndexX;
				ItemItIndexY = Entries[i].GridIndexY;
				ItemIt.GetItemGridSize(ItemItSizeX, ItemItSizeY);

				if(DoGridRegionsIntersect(
					IndexX, IndexY, SizeX, SizeY,
					ItemItIndexX, ItemItIndexY, ItemItSizeX, ItemItSizeY))
				{
					bCanPlace = false;
					break;
				}
			}

			if(bCanPlace)
			{
				Entries[EntriesCount].StoredItem = Item;
				Entries[EntriesCount].GridIndexX = IndexX;
				Entries[EntriesCount].GridIndexY = IndexY;
				++EntriesCount;
				return true;
			}
		}
	}

	return false;
}

function bool RemoveItem(R_ArpgItem Item)
{
	local int i, j;

	for(i = 0; i < EntriesCount; ++i)
	{
		if(Entries[i].StoredItem == Item)
		{
			break;
		}
	}

	if(i == EntriesCount)
	{
		return false;
	}

	j = i + 1;
	while(j < EntriesCount)
	{
		Entries[i].StoredItem = Entries[j].StoredItem;
		Entries[i].GridIndexX = Entries[j].GridIndexX;
		Entries[i].GridIndexY = Entries[j].GridIndexY;
		++i;
		++j;
	}

	--EntriesCount;
	return true;
}

function int GetItemCount()
{
	return EntriesCount;
}

function bool GetItem(int Index, out R_ArpgItem OutItem)
{
	OutItem = None;

	if(IsValidIndex(Index))
	{
		OutItem = Entries[Index].StoredItem;
		return true;
	}

	return false;
}

function bool GetItemIndex(R_ArpgItem Item, out int OutIndex)
{
	local int i;

	OutIndex = INVALID_INDEX;

	if(Item == None)
	{
		return false;
	}

	for(i = 0; i < EntriesCount; ++i)
	{
		if(Entries[i].StoredItem == Item)
		{
			OutIndex = i;
			return true;
		}
	}
	return false;
}

//------------------------------------------------------------------------------
//	R_ArpgItemGrid Interface
function SetGridSize(int NewGridSizeX, int NewGridSizeY)
{
	GridSizeX = Clamp(NewGridSizeX, 1, MAX_GRID_SIZE_X);
	GridSizeY = Clamp(NewGridSizeY, 1, MAX_GRID_SIZE_Y);
}

function GetGridSize(out int OutGridSizeX, out int OutGridSizeY)
{
	OutGridSizeX = GridSizeX;
	OutGridSizeY = GridSizeY;
}

function bool IsValidGridIndex(int IndexX, int IndexY)
{
	if(IndexX >= 0 && IndexX < GridSizeX
	&& IndexY >= 0 && IndexY < GridSizeY)
	{
		return true;
	}
	return false;
}

function bool IsValidGridRegion(int IndexX, int IndexY, int SizeX, int SizeY)
{
	// Must be at least 1x1
	if(SizeX < 1 || SizeY < 1)
	{
		return false;
	}

	if(IndexX >= 0 && IndexX + SizeX <= GridSizeX
	&& IndexY >= 0 && IndexY + SizeY <= GridSizeY)
	{
		return true;
	}
	return false;
}

function bool DoGridRegionsIntersect(
	int IndexX1, int IndexY1, int SizeX1, int SizeY1,
	int IndexX2, int IndexY2, int SizeX2, int SizeY2)
{
	if(IndexX1 + SizeX1 <= IndexX2)	return false;
	if(IndexX2 + SizeX2 <= IndexX1)	return false;
	if(IndexY1 + SizeY1 <= IndexY2)	return false;
	if(IndexY2 + SizeY2 <= IndexY1)	return false;
	return true;
}

function bool AddItemAtGridIndex(R_ArpgItem Item, int IndexX, int IndexY)
{
	local int SizeX, SizeY;
	local R_ArpgItem ItemIt;
	local int ItemItIndexX, ItemItIndexY, ItemItSizeX, ItemItSizeY;
	local int i;

	if(Item == None || EntriesCount >= ArrayCount(Entries))
	{
		return false;
	}

	Item.GetItemGridSize(SizeX, SizeY);
	if(!IsValidGridRegion(IndexX, IndexY, SizeX, SizeY))
	{
		return false;
	}

	// Make sure the region is not intersecting anything
	for(i = 0; i < EntriesCount; ++i)
	{
		ItemIt = Entries[i].StoredItem;
		if(ItemIt == Item)
		{
			return false;
		}

		ItemItIndexX = Entries[i].GridIndexX;
		ItemItIndexY = Entries[i].GridIndexY;
		ItemIt.GetItemGridSize(ItemItSizeX, ItemItSizeY);

		if(DoGridRegionsIntersect(
			IndexX, IndexY, SizeX, SizeY,
			ItemItIndexX, ItemItIndexY, ItemItSizeX, ItemItSizeY))
		{
			return false;
		}
	}

	Entries[EntriesCount].StoredItem = Item;
	Entries[EntriesCount].GridIndexX = IndexX;
	Entries[EntriesCount].GridIndexY = IndexY;
	++EntriesCount;
	return true;
}

// Returns the item at specified sequential index along with its grid region
function bool GetItemAndGridRegion(
	int Index, out R_ArpgItem OutItem,
	out int OutIndexX, out int OutIndexY,
	out int OutSizeX, out int OutSizeY)
{
	local R_ArpgItem Item;
	local int SizeX, SizeY;

	OutItem = None;
	OutIndexX = INVALID_INDEX;
	OutIndexY = INVALID_INDEX;
	OutSizeX = 0;
	OutSizeY = 0;

	if(!IsValidIndex(Index))
	{
		return false;
	}

	Item = Entries[Index].StoredItem;
	if(Item == None || !Item.GetItemGridSize(SizeX, SizeY))
	{
		return false;
	}

	OutItem = Item;
	OutIndexX = Entries[Index].GridIndexX;
	OutIndexY = Entries[Index].GridIndexY;
	OutSizeX = SizeX;
	OutSizeY = SizeY;
	return true;
}

// Returns an item intersecting the specified grid index, if there is one
function bool QueryItemIntersectingGridIndex(
	int IndexX, int IndexY,
	out R_ArpgItem OutItem)
{
	local R_ArpgItem ItemIt;
	local int ItemIndexX, ItemIndexY;
	local int ItemSizeX, ItemSizeY;
	local int i;

	OutItem = None;
	if(!IsValidGridIndex(IndexX, IndexY))
	{
		return false;
	}

	for(i = 0; i < EntriesCount; ++i)
	{
		ItemIt = Entries[i].StoredItem;
		ItemIndexX = Entries[i].GridIndexX;
		ItemIndexY = Entries[i].GridIndexY;
		ItemIt.GetItemGridSize(ItemSizeX, ItemSizeY);

		if(DoGridRegionsIntersect(
			IndexX, IndexY, 1, 1,
			ItemIndexX, ItemIndexY, ItemSizeX, ItemSizeY))
		{
			OutItem = ItemIt;
			return true;
		}
	}

	OutItem = None;
	return true;
}

// Returns up to 16 items intersecting the specified grid region
function bool QueryItemsIntersectingGridRegion(
	int IndexX, int IndexY, int SizeX, int SizeY,
	out R_ArpgItem OutItems[16],
	out int OutItemsIndexX[ArrayCount(OutItems)],
	out int OutItemsIndexY[ArrayCount(OutItems)],
	out int OutItemCount)
{
	local R_ArpgItem ItemIt;
	local int ItemItIndexX, ItemItIndexY;
	local int ItemItSizeX, ItemItSizeY;
	local int i;

	OutItemCount = 0;
	for(i = 0; i < ArrayCount(OutItems); ++i)
	{
		OutItems[i] = None;
	}

	if(!IsValidGridRegion(IndexX, IndexY, SizeX, SizeY))
	{
		return false;
	}

	for(i = 0; i < EntriesCount; ++i)
	{
		if(OutItemCount >= ArrayCount(OutItems))
		{
			break;
		}

		ItemIt = Entries[i].StoredItem;
		ItemItIndexX = Entries[i].GridIndexX;
		ItemItIndexY = Entries[i].GridIndexY;
		ItemIt.GetItemGridSize(ItemItSizeX, ItemItSizeY);

		if(DoGridRegionsIntersect(
			IndexX, IndexY, SizeX, SizeY,
			ItemItIndexX, ItemItIndexY, ItemItSizeX, ItemItSizeY))
		{
			OutItems[OutItemCount] = ItemIt;
			OutItemsIndexX[OutItemCount] = ItemItIndexX;
			OutItemsIndexY[OutItemCount] = ItemItIndexY;
			++OutItemCount;
		}
	}

	return true;
}