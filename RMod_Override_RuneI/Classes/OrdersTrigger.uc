//=============================================================================
// OrdersTrigger: 
// When fired, issues orders to a pawn whose tag matches PawnTag
//=============================================================================
class OrdersTrigger extends Trigger;

var() name PawnTag;
var() name ScriptTag;


//--------------------------------------------------------
//
// TriggerAction
//
//--------------------------------------------------------
function TriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
	local Pawn P;

	if( PawnTag != '' && ScriptTag != '' )
	{
		foreach AllActors( class 'Pawn', P, PawnTag )
		{
			P.FollowOrders('Scripting', ScriptTag);
		}
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
