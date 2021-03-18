//=============================================================================
// TeleporterTriggered.
//
// When triggered, this will teleport the player (as if the player had touched
// the trigger)
//=============================================================================
class TeleporterTriggered extends Teleporter;

//-----------------------------------------------------------------------------
// Teleporter functions.

function Trigger(actor Other, pawn EventInstigator)
{
	local Pawn P;

	for(P = Level.PawnList; P != None; P = P.nextPawn)
	{
		if(P.IsA('PlayerPawn'))
		{
			Touch(P);
		}
	}
}

defaultproperties
{
     bCollideActors=False
}
