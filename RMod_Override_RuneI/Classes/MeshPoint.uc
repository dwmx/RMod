//=============================================================================
// MeshPoint
//=============================================================================
class MeshPoint extends Accelerator
	native;

var() bool bAnchored;					// If this point is anchored in place
var() bool bDrawRopes;					// Draw rope between this and adjacents
var() float SpringConstant;				// Spring Tension constant [0..] (0 = no tension)
var() float DampFactor;					// Dampening factor [0..1] (0 = no dampening)
var() float MaxVelocityPickup;			// Maximum velocity transfer allowed from collision
var() name AdjacentTag[4];				// Tags of adjacent RopePoints

var MeshPoint Adjacent[4];				// Adjacent RopePoints
var vector OriginalPos;					// Equillibrium positon

const maxAdjacents = 4;


native(655) final function MeshPointTick(float DeltaSeconds);

function PreBeginPlay()
{
	local MeshPoint A;
	local int adj;

	// Validate user set variables
	DampFactor = FClamp(DampFactor, 0.0, 1.0);
	OriginalPos = Location;

	// Build adjacency graph by tags
	for (adj=0; adj<maxAdjacents; adj++)
	{
		Adjacent[adj] = None;
		if (AdjacentTag[adj] != '')
		{
			foreach AllActors(class'MeshPoint', A, AdjacentTag[adj])
			{
				Adjacent[adj] = A;
			}
		}
	}
	
	if (bAnchored)
	{	// Fix the anchor to the current location
		SetPhysics(PHYS_NONE);
	}
}

function Touch(actor Other)
{
	if (!Other.IsA('MeshPoint'))
	{
		Velocity += Normal(Other.Velocity) * Min(VSize(Other.Velocity), MaxVelocityPickup);
		WakeUp();
	}
}

function DrawRopeBetween(actor a1, actor a2, float DeltaTime)
{
}


function WakeUp()
{
	local MeshPoint A;

	GotoState('Active');
	foreach AllActors(class'MeshPoint', A)
	{
		//if (A.Group == Group)
		A.GotoState('Active');
	}
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
		MeshPointTick(DeltaTime);
/*
		local vector Deviation,AdditionalVelocity;
		local int adj;

		//TODO: Update with beams

		if (!bAnchored)
		{
			// Apply spring acceleration to myself
			Deviation = OriginalPos - Location;
			AdditionalVelocity = Deviation * (SpringConstant * DeltaTime / Mass);
			Velocity += AdditionalVelocity;
			Velocity *= (1.0 - DampFactor);
		}
	
		// Propogate acceleration to adjacents
		for (adj=0; adj<maxAdjacents; adj++)
		{
			if (Adjacent[adj]!=None)
			{
				if ((!bAnchored) && (!Adjacent[adj].bAnchored))
					Adjacent[adj].Velocity -= AdditionalVelocity * 0.25;
	
				// handle seperate bool for each rope
				if (bDrawRopes)
					DrawRopeBetween(self, Adjacent[adj], DeltaTime);
			}
		}
*/

		if (VSize(Velocity) < 0.1)
		{
			Velocity = vect(0,0,0);
			GotoState('Inactive');
		}
	}

	function BeginState()
	{
		if (!bAnchored)
			SetPhysics(PHYS_PROJECTILE);
	}
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
