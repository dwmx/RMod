class R_UI_Item extends R_UI_Window;

var bool bTrackMouse;
var Vector Position;

var int GridXCount;
var int GridYCount;

function Paint(Canvas C, float X, float Y)
{
	local PlayerPawn PlayerOwner;
	Super.Paint(C, X, Y);

	//PlayerOwner = GetPlayerOwner();
	//WinTop = 0;
	//WinLeft = (Sin(PlayerOwner.Level.TimeSeconds) + 1.0) * 0.5 * 512.0;

	//WinLeft = Position.X;
	//WinTop = Position.Y;

	//if(bTrackMouse)
	//{
	//	Position.X = Root.MouseX - 64.0;
	//	Position.Y = Root.MouseY - 64.0;
	//}

	C.DrawColor.R = 0;
	C.DrawColor.G = 255;
	C.DrawColor.B = 0;
	DrawStretchedTexture(C, 0, 0, 128.0, 128.0, WhiteTexture);
	//DrawStretchedTexture(C, 0.0, 0.0, 128.0, 128.0, WhiteTexture);
}

function Click(float X, float Y)
{
	local R_UIW_InWorldRootWindow InWorldRoot;

	InWorldRoot = R_UIW_InWorldRootWIndow(Root);
	InWorldRoot.ShowActiveItem();
	Close();
	// Report click to root window
	// Root can then do whatever

	// Will need to place the active item on the root window then (right now its in GameUI)
}

defaultproperties
{
	bShouldMousePassThrough=false
	GridXCount=2
	GridYCount=2
}