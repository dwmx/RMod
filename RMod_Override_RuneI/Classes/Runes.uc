//=============================================================================
// Runes.
//=============================================================================
class Runes extends Pickup
	abstract;

var() float RunePower;
var() class<ParticleSystem> SpheresClass;
var ParticleSystem spheres;

function PreBeginPlay()
{
	Super.PreBeginPlay();

	if(SpheresClass != None)
	{
		spheres = Spawn(SpheresClass,self,,Location);
		if(spheres != None)
			AttachActorToJoint(spheres, 1);
	}
}

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(3);
}

function bool PawnWantsRune(Pawn Other)
{// return whether the pawn should currently want this rune
	return true;
}


State Sleeping
{
	ignores Touch;

	function BeginState()
	{
		if (spheres != None)
			spheres.bHidden = true;

		AmbientSound = None;

		Super.BeginState();
	}

	function EndState()
	{
		if (spheres != None)
			spheres.bHidden = false;

		AmbientSound = Default.AmbientSound;

		Super.EndState();
	}
}

defaultproperties
{
     RespawnTime=30.000000
     RespawnSound=Sound'OtherSnd.Respawns.respawn01'
     PickupMessageClass=Class'RuneI.PickupMessage'
     DrawScale=0.500000
     ScaleGlow=3.000000
}
