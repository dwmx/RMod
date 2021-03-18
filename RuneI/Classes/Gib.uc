//=============================================================================
// Gib.
//=============================================================================
class Gib expands DecorationRune;

auto state FallingGib
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
//		MakeHitSound(hitNormal, speed);

		// Apply a velocity to any pawns that the rock hits
		if(hitWall.bIsPawn)
		{
			Pawn(hitWall).AddVelocity(Velocity * 0.5);
		}

		if(speed < 10 || (hitNormal.Z > 0.8 && speed < 60))
		{
			SetPhysics(PHYS_Falling);
			bBounce = false;
			bFixedRotationDir = false;
			SetTimer(2.0, false);
		}
		else
		{
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
     bStatic=False
     DrawType=DT_SkeletalMesh
     bCollideWorld=True
}
