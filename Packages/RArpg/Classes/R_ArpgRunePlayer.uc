//==============================================================================
//	R_ArpgRunePlayer
//	RunePlayer class for Arpg game modes
//==============================================================================
class R_ArpgRunePlayer extends R_RunePlayer;

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const MathLib = Class'RBase.R_AMathLibrary';

//------------------------------------------------------------------------------
//	GameUI
var private Class<R_UI_GameUserInterface> GameUIClass;
var private R_UI_GameUserInterface GameUI;

// Commands that the GameUI needs to be able to handle
// These should be reflected in any UI designed for Arpg
const UICommand_Inventory = 'Inventory';

//------------------------------------------------------------------------------

function InitializePlayerAfterPossess(bool bIsLocallyControlled)
{
    Super.InitializePlayerAfterPossess(bIsLocallyControlled);
    
    // For local player only
    if(bIsLocallyControlled)
    {
		// Enable and initialize the game cursor
        EnableGameCursor();
		if(GameCursor != None)
		{
			GameCursor.SetDragSelectionEnabled(false);
		}
    }
}

function InitializeGameUserInterface()
{
	if(GameUIClass != None)
	{
		GameUI = new(Self) GameUIClass;
		GameUI.Initialize(Self.Player);
	}
}

//------------------------------------------------------------------------------
//	Exec Functions

exec function ArpgInventory()
{
	if(GameUI != None)
	{
		GameUI.InputCommand(UICommand_Inventory);
	}
}

defaultproperties
{
	PlayerCameraClass=Class'RArpg.R_ArpgPlayerCamera'
}