//=============================================================================
// ScriptAction.
//=============================================================================
class ScriptAction expands Keypoint
	native;

#exec Texture Import File=Textures\S_Action.pcx Name=S_Action Mips=Off Flags=2

/* Description:
	When a pawn is 'Scripting' on a ScriptAction, he immediately executes the
	ScriptActions's Properties in the following order, then executes the NextOrders

	Look at looktarget
	Turn to rotation of ScriptAction (if bTurnToScriptAction)
	Start playing AnimToPlay
	Wait for PauseBeforeSound
	Play SoundToPlay
	Wait until AnimTimeToLoop expires (AnimTimeToLoop-PauseBeforeSound)
	Broadcast Event
	Do NextOrder

	Controls are timed control over dynamic joints, a letter = ControlTimeGranularity seconds

	eg:	aaaaaaaaaaamcmcmcmcmqmacamqd
*/

var(ScriptAnim) name		AnimToPlay;				// Animation to play
var(ScriptSnd) float		PauseBeforeSound;		// Time until sound plays
var(ScriptSnd) Sound		SoundToPlay;			// Sound to play
var(ScriptAnim) float		AnimTimeToLoop;			// Time to loop anim (0=play once)

var(ScriptVars) name		NextOrder;				// Order to execute after ReachOrder
var(ScriptVars) name		NextOrderTag;			// associated object
var(ScriptVars) bool		bReleaseUponCompletion;	// Once executed, release to AI
var(ScriptVars) bool		bWaitToBeTriggered;		// Wait to be triggered before executing
var(ScriptVars) bool		bFireEventImmediately;	// fire event after finishing animation
var(ScriptVars) bool		bTurnToRotation;		// Turn to rotation of ScriptAction

var(ScriptSync) string		ControlMouth;			// lip sync string
var(ScriptSync) string		ControlTorso;			// torso control string [a=left, m=center, z=right]
var(ScriptSync) string		ControlHead;			// head control string [a=left, m=center, z=right]
var(ScriptSync) float		ControlTimeGranularity;	// amount of time to sustain each control movement
var(ScriptSync) name		LookTarget;				// Target to look at, overrides head control

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
