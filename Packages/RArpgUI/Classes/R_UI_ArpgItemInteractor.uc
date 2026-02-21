//==============================================================================
//	R_ArpgItemInteractor
//==============================================================================
class R_UI_ArpgItemInteractor extends R_UI_ArpgWindow;

var private R_ArpgItemSlot FloatingItemSlot;

function SetFloatingItemSlot(R_ArpgItemSlot NewFloatingItemSlot)
{
	FloatingItemSlot = NewFloatingItemSlot;
}

function Paint(Canvas C, float X, float Y)
{
}