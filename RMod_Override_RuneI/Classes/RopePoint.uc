//=============================================================================
// RopePoint.
//=============================================================================
class RopePoint extends Accelerator
	native;

var() name NextTag;						// Tag of next ropepoint
var() name PrevTag;						// Tag of prev ropepoint
var RopePoint NextPoint;				// Next Point in Rope
var RopePoint PrevPoint;				// Prev Point in Rope

var() bool bAnchored;					// If this point is anchored in place
var() float SpringConstant;				// Spring Tension constant [0..] (0 = no tension)
var() float DampFactor;					// Dampening factor [0..1] (0 = no dampening)
var() float MaxVelocityPickup;			// Maximum velocity transfer allowed from collision

var vector OriginalPos;					// Equillibrium positon


native(652) final function RopePointTick(float DeltaSeconds);

function PreBeginPlay()
{
	local RopePoint A;
	local int adj;

	// Validate user set variables
	DampFactor = FClamp(DampFactor, 0.0, 1.0);

	// Link the rope list
	NextPoint = None;
	foreach AllActors(class'RopePoint', A, NextTag)
	{
		NextPoint = A;
		break;
	}
	PrevPoint = None;
	foreach AllActors(class'RopePoint', A, PrevTag)
	{
		PrevPoint = A;
		break;
	}
	
	OriginalPos = Location;
	
	if (bAnchored)
	{	// Fix the anchor to the current location
		SetPhysics(PHYS_NONE);
	}
	
	// Create a collision actor that encompasses the entire rope to wake up rope ?
	
}


function Tick(float DeltaTime)
{
}

defaultproperties
{
     SpringConstant=2000.000000
     DampFactor=0.100000
     MaxVelocityPickup=100.000000
     Physics=PHYS_Projectile
     CollisionRadius=20.000000
     CollisionHeight=20.000000
     bCollideActors=True
     bCollideWorld=True
}
