class R_MyTestWindow extends UWindowDialogClientWindow;

function Created()
{
	local R_MyButton CreatedButton;

	Super.Created();

	// Button 1
	CreatedButton = R_MyButton(CreateControl(class'R_MyButton', 0, 0, 180, 40));
	CreatedButton.Text = "Dwarf Mech Tower";
	CreatedButton.SetHelpText("ExampleButton");
	CreatedButton.WinLeft = 10;
	CreatedButton.WinTop = 10;
	CreatedButton.OverSound = Sound'RMenu.LeftMouseOver';
	CreatedButton.DownSound = Sound'RMenu.LeftButton';
	CreatedButton.BuildableIndex = 0;

	CreatedButton = R_MyButton(CreateControl(class'R_MyButton', 0, 0, 180, 40));
	CreatedButton.Text = "Tree One Tower";
	CreatedButton.SetHelpText("ExampleButton");
	CreatedButton.WinLeft = 10;
	CreatedButton.WinTop = 70;
	CreatedButton.OverSound = Sound'RMenu.LeftMouseOver';
	CreatedButton.DownSound = Sound'RMenu.LeftButton';
	CreatedButton.BuildableIndex = 1;
}


event Paint(Canvas C, float X, float Y)
{
	//Log("Client window is painting");
	WinWidth = 512.0;
	WinHeight = 512.0;
	ClippingRegion.X = 0;
	ClippingRegion.Y = 0;
	ClippingRegion.W = 512;
	ClippingRegion.H = 512;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'UWindow.WhiteTexture');
	//DrawStretchedTextureModded(C, 0, 0, WinWidth, WinHeight, Texture'UWindow.WhiteTexture');
	//ExampleButton.Paint(C, X, Y);
	//PaintClients(C, X, Y);
}
/*
function DrawStretchedTextureModded(
	Canvas C,
	float X, float Y, float W, float H,
	Texture Tex)
{
	DrawStretchedTextureSegmentModded(C, X, Y, W, H, 0, 0, Tex.USize, Tex.VSize, Tex);
}

function DrawStretchedTextureSegmentModded(
	Canvas C,
	float X, float Y, float W, float H,
	float TX, float TY, float TW, float TH,
	Texture Tex)
{
	local float OrgX, OrgY, ClipX, ClipY;
	local float GUIScale;

	GUIScale = 1.0;

	OrgX = C.OrgX;
	OrgY = C.OrgY;
	ClipX = C.ClipX;
	ClipY = C.ClipY;

	//C.SetOrigin(OrgX + ClippingRegion.X*Root.GUIScale, OrgY + ClippingRegion.Y*Root.GUIScale);
	C.SetOrigin(OrgX + ClippingRegion.X, OrgY + ClippingRegion.Y);
	C.SetClip(ClippingRegion.W*GUIScale, ClippingRegion.H*GUIScale);

	C.SetPos((X - ClippingRegion.X)*GUIScale, (Y - ClippingRegion.Y)*GUIScale);
	C.DrawTileClipped( Tex, W*GUIScale, H*GUIScale, tX, tY, tW, tH);
	
	C.SetClip(ClipX, ClipY);
	C.SetOrigin(OrgX, OrgY);
}

function Created()
{
	Super.Created();

	ExampleButton = RuneButton(CreateControl(class'RuneButton', 0, 0, 180, 40));
	ExampleButton.Text = "Example Button";
	ExampleButton.SetHelpText("ExampleButton");
	ExampleButton.WinLeft = 10;
	ExampleButton.WinTop = 10;
	ExampleButton.OverSound = Sound'RMenu.LeftMouseOver';
	ExampleButton.DownSound = Sound'RMenu.LeftButton';
}

function UWindowDialogControl CreateControl(class<UWindowDialogControl> ControlClass, float X, float Y, float W, float H, optional UWindowWindow OwnerWindow)
{
	local UWindowDialogControl C;

	//C = UWindowDialogControl(CreateWindow(ControlClass, X, Y, W, H, OwnerWindow));
	C = New(None) ControlClass;
	C.BeginPlay();
	C.WinTop = Y;
	C.WinLeft = X;
	C.WinWidth = W;
	C.WinHeight = H;
	C.ParentWindow = Self;
	C.OwnerWindow = Self;
	C.BeforeCreate();
	C.Created();
	ShowChildWindow(C); // might be important
	C.AfterCreate();





	C.Register(Self);
	C.Notify(C.DE_Created);

	if(TabLast == None)
	{
		TabLast = C;
		C.TabNext = C;
		C.TabPrev = C;
	}
	else
	{
		C.TabNext = TabLast.TabNext;
		C.TabPrev = TabLast;
		TabLast.TabNext.TabPrev = C;
		TabLast.TabNext = C;

		TabLast = C;
	}

	return C;
}
*/