class R_UI_Window extends UWindowWindow;

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const WhiteTexture = Texture'UWindow.WhiteTexture';

var bool bShouldMousePassThrough;

function bool CheckMousePassThrough(float X, float Y)
{
	return bShouldMousePassThrough;
}

defaultproperties
{
	bShouldMousePassThrough=false;
}