//=============================================================================
// AttachPolyobj.
//=============================================================================
class AttachPolyobj extends RunePolyobj;

// Allows attachment of actors to this mover, so that they will move
// as the mover moves, keeping their relative position to the mover.
// The relative positions are determined by the positions of the actors
// during the first keyframe (0) of the mover.
// The Tag of the actors and the AttachTag of this mover must be the same
// in order for actors to become attached.

var() name AttachTag;

// Immediately after mover enters gameplay.
function PostBeginPlay()
{
	local Actor Act;
	local Polyobj P;

	Super.PostBeginPlay();

	// Initialize all slaves.
	if ( AttachTag != '' )
		foreach AllActors( class 'Actor', Act, AttachTag )
		{
			P = Polyobj(Act);
			if (P == None)
			{
				Act.SetBase( Self );
			}
			else if (P.bSlave)
			{
				P.GotoState('');
				P.SetBase( Self );
			}
		}
}

defaultproperties
{
}
