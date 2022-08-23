//=============================================================================
// DestroyTrigger: 
// Destroys actors whose Tag matches Event
//=============================================================================
class DestroyTrigger extends Trigger;


//--------------------------------------------------------
//
// TriggerAction
//
//--------------------------------------------------------
function TriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
	Receiver.Destroy();
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
