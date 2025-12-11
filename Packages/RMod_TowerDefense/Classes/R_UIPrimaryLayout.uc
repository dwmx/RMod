//==============================================================================
// R_UIPrimaryLayout
// Primary layout widget for Tower Defense game mode
// This is the RootWidgetClass for R_RunePlayer_TD, and is the main entry point
// for all Game UI Widgets in the Tower Defense game mode
//==============================================================================
class R_UIPrimaryLayout extends R_UIWidget;

const MyButtonTag = 'MyButton';

function BuildWidget()
{
    local R_UIWidget CreatedWidget;
	local R_UIWidget SavedWidget;
    
    Super.BuildWidget();
    
	AnchorMin.X = 0.0;
	AnchorMax.X = 1.0;
	AnchorMin.Y = 0.9;
	AnchorMax.Y = 1.0;

	// Create a widget and set it to take up the left half
    CreatedWidget = UILibrary.Static.CreateWidget(
		Class'RGameUI.R_UIWidget', OwningPlayer);
	CreatedWidget.AnchorMin.X = 0.0;
	CreatedWidget.AnchorMax.X = 0.5;
	CreatedWidget.AnchorMin.Y = 0.0;
	CreatedWidget.AnchorMax.Y = 1.0;
    CreatedWidget.ColorR = 1.0;
    CreatedWidget.ColorG = 0.0;
    CreatedWidget.ColorB = 0.0;
    AddChild(CreatedWidget);

	// Create a widget and set it to take up the right half
	CreatedWidget = UILibrary.Static.CreateWidget(
		Class'RGameUI.R_UIWidget', OwningPlayer);
	CreatedWidget.AnchorMin.X = 0.5;
	CreatedWidget.AnchorMax.X = 1.0;
	CreatedWidget.AnchorMin.Y = 0.0;
	CreatedWidget.AnchorMax.Y = 1.0;
	CreatedWidget.ColorR = 0.0;
	CreatedWidget.ColorG = 1.0;
	CreatedWidget.ColorB = 1.0;
	AddChild(CreatedWidget);
	SavedWidget = CreatedWidget;

	// Add a button to the right half
	// Note the 'MyButtonTag' argument - We will look for this in ReceiveEvent()
	CreatedWidget = UILibrary.Static.CreateWidget(
		Class'RGameUI.R_UIButtonWidget', OwningPlayer, MyButtonTag);
	CreatedWidget.AnchorMin.X = 0.25;
	CreatedWidget.AnchorMax.X = 0.75;
	CreatedWidget.AnchorMin.Y = 0.25;
	CreatedWidget.AnchorMax.Y = 0.75;
	CreatedWidget.ColorR = 0.0;
	CreatedWidget.ColorG = 1.0;
	CreatedWidget.ColorB = 0.0;
	
	// Add the button to the right window
	SavedWidget.AddChild(CreatedWidget);

	// Listen for events emitted from the button
	CreatedWidget.AddEventListener(Self);
}

function ReceiveEvent(R_UIWidget Emitter, Name EventName)
{
	if(EventName == WidgetEvent_Clicked)
	{
		if(Emitter.GetWidgetTag() == MyButtonTag)
		{
			HandleMyButtonPressed();
		}
	}
}

function HandleMyButtonPressed()
{
	local R_RunePlayer_TD RPTD;

	Log("Primary UI Layout just got the button press");

	if(OwningPlayer != None)
	{
		RPTD = R_RunePlayer_TD(OwningPlayer);
		if(RPTD != None)
		{
			RPTD.TestBuildableIndex(0);
		}
	}
}