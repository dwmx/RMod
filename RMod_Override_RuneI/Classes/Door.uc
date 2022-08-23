//=============================================================================
// Door.
//=============================================================================
class Door extends Mover;

/*
	Description:
		Triggered by ragnar kicking it in (Use).  Delay time can be used to wait for anim
		Also triggered by taking damage

		Unfinished and unused -- cjr
*/

//============================================================================
//
// GetUseAnim
//
// Returns the animation that the player (or a viking) should play when
// this item is 'used'.
//============================================================================

function name GetUseAnim()
{
	return('Neutral_Kick');
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

defaultproperties
{
     bTriggerOnceOnly=True
     bUseTriggered=True
     bDamageTriggered=True
     DamageThreshold=30.000000
     DelayTime=0.700000
     InitialState=TriggerToggle
     TransientSoundRadius=1900.000000
}
