//=============================================================================
// SpringPoint.
//=============================================================================
class SpringPoint extends Accelerator
	intrinsic;


var() float SpringConstant;			// Spring Tension constant [0..] (0 = no tension)
var() float DampFactor;				// Dampening factor [0..1] (0 = no dampening)
var() float MaxVelocityPickup;		// Maximum velocity transfer allowed from collision

var vector OriginalPos;

intrinsic(653) final function SpringPointTick(float DeltaSeconds);

function PreBeginPlay()
{
	OriginalPos = Location;
	DampFactor = FClamp(DampFactor, -1.0, 1.0);
}

function Touch(actor Other)
{
	Velocity += Normal(Other.Velocity) * Min(VSize(Other.Velocity), MaxVelocityPickup);
	WakeUp();
}

function Bump(actor Other)
{
	if (Other.IsA('Pawn'))
	{
		Velocity += Normal(Other.Velocity) * Min(VSize(Other.Velocity), MaxVelocityPickup);
		WakeUp();
	}
}

function WakeUp()
{
	GotoState('Active');
}

state Inactive
{
	ignores Tick;

	function BeginState()
	{
		SetPhysics(PHYS_NONE);
	}
}


auto state Active
{
	function Tick(float DeltaTime)
	{
		SpringPointTick(DeltaTime);
/*
		local vector deviation;
		
		// Apply spring acceleration based on deviation from original position
		deviation = OriginalPos - Location;
		Velocity += deviation * (SpringConstant * DeltaTime / Mass);
		Velocity *= (1.0 - DampFactor);
*/

		if (VSize(Velocity) < 0.1)
		{
			Velocity = vect(0,0,0);
			GotoState('Inactive');
		}
	}

	function BeginState()
	{
		SetPhysics(PHYS_PROJECTILE);
	}
}

defaultproperties
{
     SpringConstant=2000.000000
     DampFactor=0.100000
     MaxVelocityPickup=500.000000
     Physics=PHYS_Projectile
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bCollideActors=True
     bCollideWorld=True
}
