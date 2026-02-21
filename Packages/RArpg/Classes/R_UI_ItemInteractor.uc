// Interacts with items in the UI
class R_UI_ItemInteractor extends R_UI_Window;

var private R_ArpgItem InspectedItem;

function SetInspectedItem(R_ArpgItem NewInspectedItem)
{
	InspectedItem = NewInspectedItem;
}

function Paint(Canvas C, float X, float Y)
{
	WinWidth = 256.0;
	WinHeight = 64.0;

	if(InspectedItem != None)
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
		DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, WhiteTexture);

		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.Font = C.MedFont;
		C.SetPos(0.0, 0.0);
		C.DrawText(String(InspectedItem));
	}
}