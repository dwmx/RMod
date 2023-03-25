//==============================================================================
//  R_Camera_ArenaSpectator
//  Camera used by spectators in R_GameInfo_Arena game modes
//==============================================================================
class R_Camera_ArenaSpectator extends R_Camera_Spectator;

//	IsValidViewTarget (override)
//	Overridden to ignore players not in the arena match when searching for a
//	view target
function bool IsValidViewTarget(Pawn P)
{
	if(!Super.IsValidViewTarget(P))
	{
		return false;
	}
	
	// Return true if the pawn is not waiting / queueing (team 255)
	if(P.PlayerReplicationInfo != None)
	{
		if(P.PlayerReplicationInfo.Team != 255)
		{
			return true;
		}
	}
	
	return false;
}