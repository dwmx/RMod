class R_UI_InventoryItem extends UWindowDialogControl;

var Texture ItemTexture;
var bool bTrackMouse;

var int CellCountX;
var int CellCountY;

var Vector Position;

event Tick(float DeltaSeconds)
{
	//WinLeft += DeltaSeconds * 10.0;
	//WinTop += DeltaSeconds * 100.0;
}

function Paint(Canvas C, float X, float Y)
{
	local float DrawX, DrawY;
	Super.Paint(C, X, Y);

	WinLeft = Position.X;
	WinTop = Position.Y;
	//bAcceptsFocus = false;
	DrawX = 0.0;
	DrawY = 0.0;

	if(bTrackMouse)
	{
		//DrawX = Root.MouseX - 0.5 * ItemTexture.USize;
		//DrawY = Root.MouseY - 0.5 * ItemTexture.VSize;
		Position.X = Root.MouseX - 0.5 * ItemTexture.USize;
		Position.Y = Root.MouseY - 0.5 * ItemTexture.VSize;
	}

	//DrawStretchedTexture(C, Position.X, Position.Y, 128.0, 128.0, ItemTexture);
	DrawStretchedTexture(C, 0.0, 0.0, 128.0, 128.0, ItemTexture);
}

function Click(float X, float Y)
{
	local R_UI_InventoryWindow InventoryWindow;
	//Log(Self @ "clicked");

	InventoryWindow = R_UI_InventoryWindow(ParentWindow);
	if(InventoryWindow != None)
	{
		InventoryWindow.ActiveUIItem = Self;
		bTrackMouse = true;
	}
}

function bool CheckMousePassThrough(float X, float Y)
{
	local R_UI_InventoryWindow InventoryWindow;

	InventoryWindow = R_UI_InventoryWindow(ParentWindow);
	if(InventoryWindow != None)
	{
		if(InventoryWindow.ActiveUIItem != None)
		{
			return true;
		}
	}
	return false;
}

defaultproperties
{
	bTrackMouse=false
	ItemTexture=Texture'Spells.uidba'
	CellCountX=2
	CellCountY=3
}