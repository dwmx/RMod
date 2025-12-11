//==============================================================================
//	R_UIButtonWidget
//	Base class for UI Buttons in the RMod User Interface package
//==============================================================================
class R_UIButtonWidget extends R_UIWidget;

function OnCursorEnter()
{
	ColorR = 1.0;
	ColorG = 0.0;
	ColorB = 0.0;
}

function OnCursorLeave()
{
	ColorR = 0.0;
	ColorG = 1.0;
	ColorB = 0.0;
}

function OnMouseDown()
{
	BroadcastEvent(WidgetEvent_Pressed);
}

function OnMouseUp()
{
	BroadcastEvent(WidgetEvent_Clicked);
}

function DrawWidgetPostSetup(Canvas C)
{
	local Vector Position, Alignment;
	local Color DrawColor;

	// Super draws self as box
	//Super.DrawWidgetPostSetup(C);

	DrawColor.R = 255;
	DrawColor.G = 255;
	DrawColor.B = 255;

	Position.X = C.ClipX * 0.5;
	Position.Y = C.ClipY * 0.5;

	Alignment.X = 0.5;
	Alignment.Y = 0.5;
}