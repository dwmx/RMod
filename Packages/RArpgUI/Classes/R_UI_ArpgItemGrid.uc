//==============================================================================
//	R_UI_ArpgItemGrid
//==============================================================================
class R_UI_ArpgItemGrid extends R_UI_ArpgItemContainer;

var private R_ArpgItemGrid ItemGrid;

var private float GridLineWidth;

function SetItemGrid(R_ArpgItemGrid NewItemGrid)
{
	ItemGrid = NewItemGrid;
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
	local int SizeX, SizeY;
	local int IndexX, IndexY;

	OutQueryResult = QUERY_RESULT_INVALID;
	OutFloatingItemRegion = ArpgWindowRegion(0,0,0,0);
	OutSwapItem = None;
	OutSwapItemRegion = ArpgWindowRegion(0,0,0,0);

	if(Item == None || ItemGrid == None)
	{
		return false;
	}

	Item.GetItemGridSize(SizeX, SizeY);
	SnapFloatingGridRegion(PositionX, PositionY, Alignment, SizeX, SizeY, IndexX, IndexY);
	GetWindowRegionForGridRegion(IndexX, IndexY, SizeX, SizeY, OutFloatingItemRegion);
	OutQueryResult = QUERY_RESULT_CAN_PLACE;

	return true;
}

function bool TryPlaceFloatingItem(
	R_ArpgItem Item,
	float PositionX, float PositionY,
	Vector Alignment)
{
	local int SizeX, SizeY;
	local int IndexX, IndexY;

	if(Item == None || ItemGrid == None)
	{
		return false;
	}

	Item.GetItemGridSize(SizeX, SizeY);
	SnapFloatingGridRegion(PositionX, PositionY, Alignment, SizeX, SizeY, IndexX, IndexY);
	return ItemGrid.AddItemAtGridIndex(Item, IndexX, IndexY);
}

function bool RemoveItem(R_ArpgItem Item)
{
	if(ItemGrid != None)
	{
		return ItemGrid.RemoveItem(Item);
	}
	return false;
}

//------------------------------------------------------------------------------

function SnapFloatingGridRegion(
	float PositionX, float PositionY,
	Vector Alignment,
	int SizeX, int SizeY,
	out int OutIndexX, out int OutIndexY)
{
	local float CellSizeX, CellSizeY;
	local float Left, Top;

	GetGridCellPixelSize(CellSizeX, CellSizeY);
	Left = PositionX - CellSizeX * SizeX * Alignment.X + CellSizeX * 0.5;
	Top = PositionY - CellSizeY * SizeY * Alignment.Y + CellSizeY * 0.5;

	OutIndexX = int(Left / CellSizeX);
	OutIndexY = int(Top  / CellSizeY);
}

function GetWindowRegionForGridRegion(
	int IndexX, int IndexY,
	int SizeX, int SizeY,
	out R_ArpgWindowRegion OutWindowRegion)
{
	local float CellSizeX, CellSizeY;

	GetGridCellPixelSize(CellSizeX, CellSizeY);
	OutWindowRegion.SizeX = CellSizeX * float(SizeX);
	OutWindowRegion.SizeY = CellSizeY * float(SizeY);
	OutWindowRegion.PositionX = CellSizeX * float(IndexX);
	OutWindowRegion.PositionY = CellSizeY * float(IndexY);
}

//------------------------------------------------------------------------------

function Paint(Canvas C, float X, float Y)
{
	PaintGrid(C, X, Y);
	PaintItems(C, X, Y);
}

function PaintGrid(Canvas C, float X, float Y)
{
	local float CellSizeX, CellSizeY;
	local int GridSizeX, GridSizeY;
	local int i;

	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Style = 1;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, WhiteTexture);

	// Draw grid lines
	if(ItemGrid != None)
	{
		GetGridCellPixelSize(CellSizeX, CellSizeY);
		ItemGrid.GetGridSize(GridSizeX, GridSizeY);

		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;

		// Horizontal lines
		for(i = 0; i <= GridSizeY; ++i)
		{
			DrawStretchedTexture(
				C,
				0,
				CellSizeY * i - GridLineWidth * 0.5,
				WinWidth,
				GridLineWidth,
				WhiteTexture);
		}

		// Vertical lines
		for(i = 0; i < GridSizeX; ++i)
		{
			DrawStretchedTexture(
				C,
				CellSizeX * i - GridLineWidth * 0.5,
				0,
				GridLineWidth,
				WinHeight,
				WhiteTexture);
		}
	}
}

function PaintItems(Canvas C, float X, float Y)
{
	local int ItemCount;
	local int IndexX, IndexY;
	local int SizeX, SizeY;
	local R_ArpgItem Item;
	local int i;
	local R_ArpgWindowRegion ItemWindowRegion;

	if(ItemGrid != None)
	{
		ItemCount = ItemGrid.GetItemCount();
		for(i = 0; i < ItemCount; ++i)
		{
			if(!ItemGrid.GetItemAndGridRegion(i, Item, IndexX, IndexY, SizeX, SizeY))
			{
				continue;
			}

			GetWindowRegionForGridRegion(IndexX, IndexY, SizeX, SizeY, ItemWindowRegion);
			PaintItem(C, ItemWindowRegion.PositionX, ItemWindowRegion.PositionY, Vect(0,0,0), Item);
		}
	}
}

defaultproperties
{
	GridLineWidth=2.0
}