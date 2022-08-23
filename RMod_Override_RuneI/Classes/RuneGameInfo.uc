//=============================================================================
// RuneGameInfo.
//=============================================================================
class RuneGameInfo extends GameInfo;


var localized string GenericDiedMessage;


function bool RestartPlayer( pawn aPlayer )
{
	local RunePlayer rPlayer;
	local bool retval;

	retval = Super.RestartPlayer(aPlayer);

	rPlayer = RunePlayer(aPlayer);
	if (rPlayer!=None)
	{
		rPlayer.OldCameraStart = rPlayer.Location;
		rPlayer.OldCameraStart.Z += rPlayer.CameraHeight;
		rPlayer.CurrentDist = rPlayer.CameraDist;
		rPlayer.LastTime = 0;
		rPlayer.CurrentTime = 0;
		rPlayer.CurrentRotation = rPlayer.Rotation;
	}

	return retval;
}


//
// Default death message.
//
static function string KillMessage( name damageType, pawn killer )
{
	return default.GenericDiedMessage;
}

defaultproperties
{
     GenericDiedMessage=" died."
     HUDType=Class'RuneI.RuneHUD'
     GameReplicationInfoClass=Class'RuneI.RuneGameReplicationInfo'
}
