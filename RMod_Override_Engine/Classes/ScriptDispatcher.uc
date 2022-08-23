//=============================================================================
// ScriptAction.
//=============================================================================
class ScriptDispatcher expands Keypoint
	native;

#exec Texture Import File=Textures\S_Action.pcx Name=S_Action Mips=Off Flags=2

/* Description:
	When a pawn is 'Scripting' on a ScriptDispatcher, he immediately executes the
	ScriptActions's Properties, then executes the NextOrders

	Look at looktarget
	Start playing AnimToPlay
	Play SoundToPlay
	Broadcast Event
	Do NextOrder

	Controls are timed control over dynamic joints, a letter = ControlTimeGranularity seconds

	eg:	aaaaaaaaaaamcmcmcmcmqmacamqd
*/

struct SAction
{
	var() float		Delay;					// Delay before executing
	var() name		AnimToPlay;				// Animation to play
	var() name		EventToFire;			// Event to broadcast
	var() Sound		SoundToPlay;			// Sound to play
	var() bool		bTaskLocked;			// TaskLocked during this action
};


var(ScriptSync) name	LookTarget[12];				// Target to look at, overrides head control
var(ScriptSync) string	ControlMouth[12];			// lip sync string
var(ScriptSync) string	ControlHead[12];			// head control string [a=left, m=center, z=right]
var(ScriptSync) float	ControlTimeGranularity;		// amount of time to sustain each control movement


var(ScriptVars) SAction		Actions[12];			// Actions to execute
var(ScriptVars) name		NextOrder;				// Order to execute after ReachOrder
var(ScriptVars) name		NextOrderTag;			// associated object
var(ScriptVars) bool		bWaitToBeTriggered;		// Wait to be triggered before executing


// Internal variables
var Pawn					WaitingScripter;



function Trigger(actor Other, pawn EventInstigator)
{
	// Pass this trigger message on to any waiting scripter
	if (WaitingScripter != None)
	{
		WaitingScripter.Release();
		WaitingScripter = None;
	}
}

defaultproperties
{
     NextOrder=Scripting
     bDirectional=True
     Texture=Texture'Engine.S_Action'
}
