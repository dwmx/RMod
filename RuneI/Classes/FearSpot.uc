//=============================================================================
// FearSpot.
//
// Creatures will stop when entering this spot and recalculate their move
//=============================================================================
class FearSpot extends Triggers;


var() bool bInitiallyActive;


function Touch(actor Other)
{
	if (bInitiallyActive && Other.bIsPawn)
	{
		Pawn(Other).FearThisSpot(self);
	}
}

function Trigger(actor Other, pawn EventInstigator)
{
	bInitiallyActive = !bInitiallyActive;
}

defaultproperties
{
     bInitiallyActive=True
}
