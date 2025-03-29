//==============================================================================
//	R_InWorldHUD
//
//	HUD for R_Runeplayer which draws world-space HUD elements like player
//	names above their heads, floating health bars, etc
//==============================================================================
class R_InWorldHUD extends Object;

var R_RunePlayer OwningPlayer;

function InitializeInWorldHUD(R_RunePlayer NewOwningPlayer)
{
	OwningPlayer = NewOwningPlayer;
}

/**
*	InWorldHUDPostRender
*	Main draw function for the InWorldHUD
*	Should be called by owning player's PostRender event
*/
function InWorldHUDPostRender(Canvas C)
{
	local R_Mob MobIterator;

	foreach OwningPlayer.AllActors(Class'R_Mob', MobIterator)
	{
		MobIterator.DrawInWorldHUD(C);
	}
}