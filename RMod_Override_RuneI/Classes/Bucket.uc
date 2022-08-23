//=============================================================================
// Bucket.
//=============================================================================
class Bucket expands DecorationRune;

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

	if(bDestroyable)
		return(true);
	else
		return(false);
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
// UseTrigger
//
// When 'used', kegs are destroyed (via a kick animation)
//============================================================================

function bool UseTrigger(Actor Other)
{
	Momentum = (Location - Other.Location) * 0.25;
	Destroy();
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_WOOD;
}

defaultproperties
{
     bDestroyable=True
     DestroyedSound=Sound'WeaponsSnd.ImpCrashes.crashxbucket01'
     bBurnable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     CollisionRadius=17.000000
     CollisionHeight=15.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     Skeletal=SkelModel'objects.Bucket'
}
