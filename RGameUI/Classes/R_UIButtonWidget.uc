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

