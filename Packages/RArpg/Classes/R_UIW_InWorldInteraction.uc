class R_UIW_InWorldInteraction extends UWindowDialogControl;

const WhiteTexture = Texture'UWindow.WhiteTexture';

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	DrawStretchedTexture(C, 0.0, 0.0, WinWidth, WinHeight, WhiteTexture);
}