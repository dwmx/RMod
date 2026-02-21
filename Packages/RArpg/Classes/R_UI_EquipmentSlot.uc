class R_UI_EquipmentSlot extends R_UI_Window;

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, WhiteTexture);
}