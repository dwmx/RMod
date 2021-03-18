//=============================================================================
// Confinement.
//=============================================================================
class Confinement extends Accelerator
	native;

// Confinement actors try to stay in the geometric center of a specified group
// of actors.

var() float MaxVelocityPickup;			// Maximum velocity transfer allowed from collision
var() name ConfinerTag[4];
var actor Confiner[4];

const MaxConfiners = 4;

native(651) final function ConfinementTick(float DeltaSeconds);

function PreBeginPlay()
{
	local actor A;
	local int i;
	
	for (i=0; i<MaxConfiners; i++)
	{
		if (ConfinerTag[i] != '')
			foreach AllActors(class'actor', A, ConfinerTag[i])
				Confiner[i] = A;
	}
}

function Bump(actor Other)
{
//	local vector transfer;
	local int i;
	
	if (Other.IsA('Pawn'))
	{	// Propogate velocity on to my confiners
/*
		transfer = Normal(Other.Velocity) * Min(VSize(Other.Velocity), MaxVelocityPickup);
		for (i=0; i<MaxConfiners; i++)
			if (Confiner[i] != None)
				Confiner[i].Velocity += transfer;
*/
		for (i=0; i<MaxConfiners; i++)
			if (Confiner[i] != None)
				Confiner[i].Touch(Other);
	}
}


function Tick(float DeltaTime)
{
/*
	local vector accum;
	local int i,numConfiners;

	// Move to average location of confiners	
	accum = vect(0,0,0);
	numConfiners = 0;
	for (i=0; i<MaxConfiners; i++)
	{
		if (Confiner[i] != None)
		{
			accum += Confiner[i].Location;
			numConfiners++;
		}
	}
	Move((accum / numConfiners) - Location);

	// Calculate Rotation (if necessary)
*/	
	ConfinementTick(DeltaTime);
}

defaultproperties
{
     MaxVelocityPickup=100.000000
     Physics=PHYS_Projectile
     DrawType=DT_Mesh
     CollisionRadius=20.000000
     CollisionHeight=5.000000
     bBlockActors=True
     bBlockPlayers=True
}
