//=============================================================================
// ZoneVelocityTrigger: 
// Changes Zone velocity of zone whose tag matches event to my ZoneVelocity
//=============================================================================
class ZoneVelocityTrigger extends Trigger;


var() vector ZoneVelocity;

//--------------------------------------------------------
//
// TriggerAction
//
//--------------------------------------------------------
function TriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
	local ZoneInfo Z;

	// Change Zone's velocity to mine
	Z = ZoneInfo(Receiver);
	if (Z != None)
	{
		Z.ZoneVelocity = ZoneVelocity;
	}
}


//--------------------------------------------------------
//
// UnTriggerAction
//
//--------------------------------------------------------
function UnTriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
}

defaultproperties
{
}
