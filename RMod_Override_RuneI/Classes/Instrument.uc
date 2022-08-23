//=============================================================================
// Instrument.
//=============================================================================
class Instrument expands DecorationRune
	abstract;

var() bool bTriggerOnceOnly;
var	  bool bWasTriggered;

//============================================================
// Stimulus
//============================================================

function Trigger(actor Other, pawn EventInstigator)
{
	PlayInstrument(Other);
}

function bool UseTrigger(actor Other)
{
	PlayInstrument(Other);
	return true;
}

//============================================================================
//
// CanBeUsed
//
// Whether the actor can be used.
//============================================================================

function bool CanBeUsed(Actor Other)
{
	// Can only be used if the player is facing it
	if(!Other.ActorInSector(self, ANGLE_45))
		return(false);

	return(true);
}

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(7);
}

//============================================================================
//
// GetUseAnim
//
// Returns the animation that the player (or a viking) should play when
// this item is 'used'. 
//============================================================================

function name GetUseAnim()
{
	return('pumpTrigger'); // TEMP:  Using pumpTrigger until we have proper instrument anims
}

//============================================================
//
// PlayInstrument
//
// Override with playing sounds, anims, dynamics, etc. and call from stimuli
//============================================================
function PlayInstrument(actor Musician)
{
	local actor A;

	if(bTriggerOnceOnly && bWasTriggered)
	{ // Don't allow re-triggering if it isn't necessary
		return;
	}

	// Broadcast the Trigger message to all matching actors.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger(Musician, Musician.Instigator);

	bWasTriggered = true;
}

defaultproperties
{
     bTriggerOnceOnly=True
}
