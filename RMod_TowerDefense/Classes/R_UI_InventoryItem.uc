class R_UI_InventoryItem extends UWindowDialogControl;

var Texture ItemTexture;
var bool bTrackMouse;

var int CellCountX;
var int CellCountY;

event Tick(float DeltaSeconds)
{
	//WinLeft += DeltaSeconds * 10.0;
	//WinTop += DeltaSeconds * 100.0;
}

function Paint(Canvas C, float X, float Y)
{
	local float DrawX, DrawY;
	Super.Paint(C, X, Y);

	//bAcceptsFocus = false;
	DrawX = 0.0;
	DrawY = 0.0;

	if(bTrackMouse)
	{
		DrawX = Root.MouseX - 0.5 * ItemTexture.USize;
		DrawY = Root.MouseY - 0.5 * ItemTexture.VSize;
	}

	DrawStretchedTexture(C, DrawX, DrawY, 128.0, 128.0, ItemTexture);
}

function Click(float X, float Y)
{
	Super.Click(X, Y);
	Log("CLICK ON THE INVENTORY WINDOW");
}

function bool CheckMousePassThrough(float X, float Y)
{
	return true;
}

defaultproperties
{
	bTrackMouse=false
	ItemTexture=Texture'Spells.uidba'
	CellCountX=2
	CellCountY=3
}