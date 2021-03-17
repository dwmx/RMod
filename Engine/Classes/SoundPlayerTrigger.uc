//=============================================================================
// SoundPlayerTrigger.
//=============================================================================
class SoundPlayerTrigger expands SoundPlayer;

// EDITABLE INSTANCE VARIABLES ////////////////////////////////////////////////

var(SoundPlayer) bool	bDestroyGroup;		// Destroy all actors with a
											// matching tag when the countdown
											// has completed.
var(SoundPlayer) float	ReTriggerDelay;		// Minimum time before trigger
											// can be triggered again.

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

var float TriggerTime;

// FUNCTIONS //////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Touch.
//-----------------------------------------------------------------------------
function Touch(actor other)
{
	local actor a;

	if(Pawn(other) != none && Pawn(other).bIsPlayer)
	{
		if(ReTriggerDelay > 0)
		{
			if(Level.TimeSeconds - TriggerTime < ReTriggerDelay)
				return;
			TriggerTime = Level.TimeSeconds;
		}

		// Trigger self.
		Trigger(none, none);

		// Broadcast the Trigger message to all matching actors.
		if(Event != '')
			foreach AllActors(class'Actor', a, Event)
				a.Trigger(other, other.Instigator);
	}
}

//-----------------------------------------------------------------------------
// SoundAction.
//  Do nothing.
//-----------------------------------------------------------------------------
function SoundAction()
{
}

//-----------------------------------------------------------------------------
// CompletedCountdown.
//-----------------------------------------------------------------------------
function CompletedCountdown()
{
	local actor a;

	SetCollision(false);
	if(bDestroyGroup)
	{
		foreach AllActors(class'Actor', a, Tag)
			a.Destroy();
	}
}

// STATES /////////////////////////////////////////////////////////////////////

defaultproperties
{
     bAutoContinuous=False
     TriggerBehavior=SNDTB_Single
     bCollideActors=True
}
