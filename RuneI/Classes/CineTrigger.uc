//=============================================================================
// CineTrigger.
//=============================================================================
class CineTrigger expands Trigger;

var() bool SmoothCamera;
var() bool bInteruptable;

//=============================================================================
//
// TriggerAction
//
//=============================================================================

function TriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
	local CineCamera Camera;
	
	foreach AllActors(class'CineCamera', Camera)
	{ // Do not allow the trigger to occur if a CineCamera is already instanced
		return;
	}
	
	Camera = Spawn(class'CineCamera', EventInstigator);
	Camera.Event = Event;
	Camera.StartCam(SmoothCamera, bInteruptable);
}

//=============================================================================
//
// Trigger
//
//=============================================================================

function Trigger( actor Other, pawn EventInstigator )
{
	TriggerAction(Other, EventInstigator, EventInstigator);
}

defaultproperties
{
     SmoothCamera=True
     bInteruptable=True
}
