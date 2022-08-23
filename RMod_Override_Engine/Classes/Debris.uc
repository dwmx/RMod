//=============================================================================
// Debris.
// May want to move this to Projectiles so it can be simulated in netplay
//=============================================================================
class Debris extends Effects
	abstract;


var(Sounds) sound	LandSound;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	SkelMesh=Rand(6);
}

simulated function Spawned()
{
	Velocity = (VRand()+vect(0,0,1)) * RandRange(100,400);
	RotationRate.Yaw = RandRange(-64000, 64000);
	RotationRate.Pitch = RandRange(-64000, 64000);
	RotationRate.Roll = RandRange(-64000, 64000);
}

function SetSize(float Size)
{
	Size=Min(Size, 2.5);
	Size += FRand()-0.5;
	DrawScale=Size;
	SetCollisionSize(Default.CollisionRadius*Size, Default.CollisionHeight*Size);
}

function SetTexture(Texture tex)
{
	if (tex != None)
	{
		SkelGroupSkins[1] = tex;
	}
}

function SetMomentum(vector Mom)
{
	if (Mom != vect(0,0,0))
		Velocity = (Normal(Mom)*2 + VRand() + vect(0,0,1)) * RandRange(50,300);
	else
		Velocity = (VRand()*2+vect(0,0,2)) * RandRange(50,400);
}

simulated function SpawnDebrisDecal(vector HitNormal) {}

simulated function PlayLandSound()
{
	PlaySound(LandSound);
}

simulated function Landed(vector HitNormal, actor HitActor)
{
	HitWall(HitNormal, HitActor);
}
	
simulated function HitWall(vector HitNormal, actor HitWall)
{
	local float speed;
	
	speed = VSize(velocity);
	LifeSpan = RandRange(10, 20);
	if (DrawScale < 0.5)
		Destroy();

	if (speed>300 && DrawScale>0.3 && FRand()>0.6)
	{
		if (!Region.Zone.bWaterZone)
			PlayLandSound();
	}

	if(((HitNormal.Z > 0.8) && (speed < 60)) || (speed < 20))
	{
		SetPhysics(PHYS_None);
		bBounce = false;
		bFixedRotationDir = false;
		SetCollision(false, false, false);
		bCollideWorld = false;
		bLookFocusPlayer = false; // Player isn't interested anymore
		bSimFall=false;
		GotoState('OnGround');

		if (!Region.Zone.bWaterZone)
			SpawnDebrisDecal(HitNormal);
		if (Level.NetMode != NM_Standalone)
			Destroy();
	}
	else
	{			
		SetPhysics(PHYS_Falling);
		RotationRate.Yaw = VSize(Velocity) * 100;
		RotationRate.Pitch = VSize(Velocity) * 50;
		
		Velocity = 0.45 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
		if(VSize(Velocity) < 20)
		{
			self.HitWall(HitNormal, HitWall); // Force the actor to stop
		}
		DesiredRotation = rotator(HitNormal);

		if (!Region.Zone.bWaterZone)
//		if (speed > 200 || FRand() > 0.3)
//		{
			SpawnDebrisDecal(HitNormal);
//		}
	}
}


State OnGround
{
}

defaultproperties
{
     bNetOptional=True
     bSimFall=True
     Physics=PHYS_Falling
     DrawType=DT_SkeletalMesh
     CollisionRadius=10.000000
     CollisionHeight=5.000000
     bCollideWorld=True
     bBounce=True
     bFixedRotationDir=True
     Buoyancy=50.000000
}
