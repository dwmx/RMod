class R_UIW_InWorldInteraction extends R_UI_DialogClientWindow;

var private Actor InteractionActor;

var private float BorderThickness;

var private R_UI_MenuButton ButtonBuy;

function Created()
{
	Super.Created();

	ButtonBuy = R_UI_MenuButton(CreateControl(Class'RArpg.R_UI_MenuButton', 0.0, 0.0, 64.0, 32.0));
	ButtonBuy.Text = "Buy";
}

function SetInteractionActor(Actor NewInteractionActor)
{
	InteractionActor = NewInteractionActor;
}

function Paint(Canvas C, float X, float Y)
{
	local Vector ScreenLocation;

	
	//Super.Paint(C, X, Y);
	//return;
	if(InteractionActor != None)
	{
		CanvasLib.Static.GetScreenSpaceLocationAboveActor(C, InteractionActor, ScreenLocation, 32.0);
	}

	//C.Reset();

	WinLeft = ScreenLocation.X - WinWidth * 0.5;
	WinTop = ScreenLocation.Y - WinHeight;

	
	//C.DrawColor.R = 255;
	//C.DrawColor.G = 0;
	//C.DrawColor.B = 0;
	//WindowAlpha = 0.2;

	// Backdrop
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.AlphaScale = 0.5;
	C.Style = 5;
	DrawStretchedTexture(C, 0.0, 0.0, WinWidth, WinHeight, WhiteTexture);

	// Border
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;

	DrawStretchedTexture(C, 0.0, 0.0, WinWidth, BorderThickness, WhiteTexture);
	DrawStretchedTexture(C, 0.0, WinHeight - BorderThickness, WinWidth, BorderThickness, WhiteTexture);
	DrawStretchedTexture(C, 0.0, BorderThickness, BorderThickness, WinHeight - BorderThickness * 2.0, WhiteTexture);
	DrawStretchedTexture(C, WinWidth - BorderThickness, BorderThickness, BorderThickness, WinHeight - BorderThickness * 2.0, WhiteTexture);
}

function Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);
}

defaultproperties
{
	BorderThickness=2.0
}