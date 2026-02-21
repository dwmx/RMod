class R_UI_GameUI extends R_UI_DialogClientWindow;

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	WinWidth = C.ClipX;
	WinHeight = C.ClipY;
	ClippingRegion.X = Root.ClippingRegion.X;
	ClippingRegion.Y = Root.ClippingRegion.Y;
	ClippingRegion.W = Root.ClippingRegion.W;
	ClippingRegion.H = Root.ClippingRegion.H;
}

function Paint(Canvas C, float X, float Y)
{
	local float DrawWidth, DrawHeight;
	local float DrawX, DrawY;

	DrawWidth = 256.0;
	DrawHeight = 64.0;

	//DrawX = Canvas.ClipX * 0.5 - DrawWidth * 0.5;
	//DrawY = Canvas.ClipY - DrawHeight;
	DrawX = WinWidth * 0.5 - DrawWidth * 0.5;
	DrawY = WinHeight - DrawHeight;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;

	DrawStretchedTexture(C, DrawX, DrawY, DrawWidth, DrawHeight, WhiteTexture);
}