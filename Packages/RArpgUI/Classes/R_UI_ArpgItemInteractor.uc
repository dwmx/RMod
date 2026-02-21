//==============================================================================
//	R_ArpgItemInteractor
//==============================================================================
class R_UI_ArpgItemInteractor extends R_UI_ArpgWindow;

var private R_ArpgItemSlot FloatingItemSlot;
var private float PositionX, PositionY;

const STATE_INSPECTING = 'Inspecting';	// Inspecting items
const STATE_FLOATING = 'Floating';		// Moving a floating item
var Name InteractorState;

var private R_ArpgItem FloatingItem;
var private Vector FloatingAlignment;

//------------------------------------------------------------------------------

function SetFloatingItemSlot(R_ArpgItemSlot NewFloatingItemSlot)
{
	FloatingItemSlot = NewFloatingItemSlot;
}

//------------------------------------------------------------------------------

function Tick(float DeltaSeconds)
{
	if(Root != None)
	{
		GlobalToWindow(Root.MouseX, Root.MouseY, PositionX, PositionY);
	}

	UpdateInteractorState();

	switch(InteractorState)
	{
	case STATE_FLOATING:
		TickFloating(DeltaSeconds);
		break;
	case STATE_INSPECTING:
	default:
		TickInspecting(DeltaSeconds);
		break;
	}
}

function UpdateInteractorState()
{
	local R_ArpgItem NewFloatingItem;

	FloatingItem = None;
	if(FloatingItemSlot != None)
	{
		if(FloatingItemSlot.GetItem(0, NewFloatingItem))
		{
			InteractorState = STATE_FLOATING;
			FloatingItem = NewFloatingItem;
			return;
		}
	}

	InteractorState = STATE_INSPECTING;
}

function TickFloating(float DeltaSeconds)
{}

function TickInspecting(float DeltaSeconds)
{}

//------------------------------------------------------------------------------

function Paint(Canvas C, float X, float Y)
{
	switch(InteractorState)
	{
	case STATE_FLOATING:
		PaintFloating(C, X, Y);
		break;
	case STATE_INSPECTING:
	default:
		PaintInspecting(C, X, Y);
		break;
	}
}

function PaintFloating(Canvas C, float X, float Y)
{
	if(FloatingItem != None)
	{
		PaintItem(C, PositionX, PositionY, FloatingAlignment, FloatingItem);
	}
}

function PaintInspecting(Canvas C, float X, float Y)
{}

defaultproperties
{
	FloatingAlignment=(X=0.5,Y=0.5)
}