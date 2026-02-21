class R_UI_MenuButton extends UWindowDialogControl;

var private float TextX;
var private float TextY;
var private bool bMouseOver;

function BeforePaint(Canvas C, float X, float Y)
{
	local float TextW, TextH;

	Super.BeforePaint(C, X, Y);

	C.Font = C.MedFont;
	TextSize(C, RemoveAmpersand(Text), TextW, TextH);
	TextX = (WinWidth - TextW) / 2.0;
	TextY = (WinHeight - TextH) / 2.0;
	TextY += 2.0;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	if(Text != "")
	{
		if(bMouseOver)
		{
			C.DrawColor.R = 255;
			C.DrawColor.G = 255;
			C.DrawColor.B = 0;
		}
		else
		{
			C.DrawColor.R = 255;
			C.DrawColor.G = 255;
			C.DrawColor.B = 255;
		}
		
		ClipText(C, TextX, TextY, Text, true);
	}
}

function MouseEnter()
{
	Super.MouseEnter();
	//Log("MOUSE ENTER!!!!!!!!");
	bMouseOver = true;
}

function MouseLeave()
{
	Super.MouseLeave();

	bMouseOver = false;
}

function Click(float X, float Y)
{
	Log("CLICK!!!");
}