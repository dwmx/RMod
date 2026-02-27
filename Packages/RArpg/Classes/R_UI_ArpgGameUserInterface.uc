//==============================================================================
//	R_UI_ArpgGameUserInterface
//	Top-level Game User interface class for Arpg mode
//==============================================================================
class R_UI_ArpgGameUserInterface extends RGameUI.R_UI_GameUserInterface;

// UI Commands
const UICommand_Inventory = 'Inventory';

function InputCommand(Name Command)
{
	switch(Command)
	{
		case UICommand_Inventory:	HandleCommand_Inventory();	break;
	}	
}

function HandleCommand_Inventory() {}
function SetItemContainerSet(R_ArpgItemContainerSet NewItemContainerSet) {}

defaultproperties
{
	RootWindowClass=Class'RArpgUI.R_UI_ArpgRootWindow'
}