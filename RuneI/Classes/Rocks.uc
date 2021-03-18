//=============================================================================
// Rocks.
//=============================================================================
class Rocks expands DecorationRune;

//
// To do:
//
// - Spawn dust and debris when landed() and hitwall()
// - Break into smaller rocks
// - Apply damage when colliding with pawns
//

var vector PrevLocation;
var(Sounds) sound ImpactSound;


// FUNCTIONS ------------------------------------------------------------------

function Trigger(actor other, pawn eventInstigator)
{
	GotoState('FallingRock');
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_STONE;
}

function MakeHitSound(vector hitNormal, float speed)
{
	local float f, m, v;
	local Sound snd;

	m = FClamp(Mass, 0, 200);
	if(hitNormal.Z < 0)
		hitNormal.Z = 0;
	f = FRand()*0.15 + hitNormal.Z*0.3 + m*0.00275;
/*	if(f < 0.166)
		snd = Sound'EnvironmentalSnd.Rocks.Hit1';
	else if(f < 0.333)
		snd = Sound'EnvironmentalSnd.Rocks.Hit2';
	else if(f < 0.5)
		snd = Sound'EnvironmentalSnd.Rocks.Hit3';
	else if(f < 0.666)
		snd = Sound'EnvironmentalSnd.Rocks.Hit4';
	else if(f < 0.833)
		snd = Sound'EnvironmentalSnd.Rocks.Hit5';
	else
		snd = Sound'EnvironmentalSnd.Rocks.Hit6';*/
	speed = FClamp(speed, 0, 400);
	v = f*0.2 + m*0.0015 + speed*0.00125;
	PlaySound(ImpactSound,, 0.2+v*0.8,,, 0.9+FRand()*0.2);
}

// STATES ---------------------------------------------------------------------

state FallingRock
{
	function BeginState()
	{
		SetPhysics(PHYS_Falling);
		//SetCollision(true, false, false);
		//bCollideWorld = true;
		bBounce = true;
		bFixedRotationDir = true;
		DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
		RotationRate.Yaw = 50000;
		PrevLocation = Vect(0x7fffffff, 0x7fffffff, 0x7fffffff);
	}

	function EndState()
	{
		bBounce = false;
		//SetCollision(false, false, false);
		//bCollideWorld = false;
		bBounce = false;
		bFixedRotationDir = false;
	}

	function Landed(vector HitNormal, actor HitActor)
	{
		HitWall(HitNormal, HitActor);
	}

	function HitWall(vector hitNormal, actor hitWall)
	{
		local float speed;

		speed = VSize(Velocity);
		MakeHitSound(hitNormal, speed);

		// Apply a velocity to any pawns that the rock hits
		if(hitWall.bIsPawn)
		{
			Pawn(hitWall).AddVelocity(Velocity * 0.5);
		}

		if(speed < 10 || (hitNormal.Z > 0.8 && speed < 60)
			|| PrevLocation == Location)
		{
//cjr			SetPhysics(PHYS_None);
			SetPhysics(PHYS_Falling);
			bBounce = false;
			bFixedRotationDir = false;
			SetTimer(2.0, false);
		}
		else
		{
			PrevLocation = Location;
			SetPhysics(PHYS_Falling);
			RotationRate.Yaw = VSize(Velocity)*100;

			if(HitNormal.Z > 0.8)
				Velocity = 0.30 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
			else
				Velocity = 0.55 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));

			DesiredRotation = rotator(HitNormal);
		}
	}

	function Timer()
	{
		GotoState('');
	}

begin:
}

defaultproperties
{
     bDestroyable=True
     bStatic=False
     DrawType=DT_SkeletalMesh
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
