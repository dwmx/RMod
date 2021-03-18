//=============================================================================
// GroundProjectile.
//=============================================================================
class GroundProjectile expands Projectile;

var() int DamageAmount;
var() float DamageRadius;
var() name DamageType;
var() Sound ExplosionSound;
var float TimeToExplode;

simulated function PostBeginPlay()
{
	local actor dust;

	Super.PostBeginPlay();

	dust = Spawn(class'BrownDust',,, Location);
	AttachActorToJoint(dust, 0);

	SetTimer(0.1, true);
}

simulated function Tick(float DeltaSeconds)
{
	local vector HitLocation, HitNormal;
	local vector extent;

	extent.X = CollisionRadius;
	extent.Y = CollisionRadius;
	extent.Z = CollisionHeight;

	// Check below the object to see if it should go down slopes/stairs
	if(Trace(HitLocation, HitNormal, Location - vect(0, 0, 10), Location, false, extent) == None)
	{ // Hit nothing, so destroy the projectile
		Explode(Location, vect(0, 0, 1));
	}

	TimeToExplode -= DeltaSeconds;
	if(TimeToExplode <= 0)
		Explode(Location, vect(0, 0, 1));
}

simulated function Timer()
{
	local int i;
	local vector loc;
	local debris D;
	local texture Texture;
	local vector Momentum;
	local vector center;

	center = GetJointPos(0);

	PrePivot.X = (FRand() - 0.5) * 20;
	PrePivot.Y = (FRand() - 0.5) * 20;

	MatterTrace(Location - vect(0, 0, 50), Location,, Texture);
	for(i = 0; i < 3; i++)
	{
		loc = center;
		loc.X += (FRand() - 0.5) * 30;
		loc.Y += (FRand() - 0.5) * 30;
		loc.Z += (FRand() - 0.5) * 10;

		D = Spawn(class'DebrisStone',,,loc);
		if (D != None)
		{
			D.SetSize(0.1 + FRand() * 0.15);
			D.SetTexture(Texture);
			D.ScaleGlow = 1.5; // Slightly brighter
			D.Velocity = VRand() * 80;
			D.Velocity.Z = FRand() * 100;
		}
	}

	SkelGroupSkins[1] = Texture;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if(Other == Owner)
		return;

	Explode(HitLocation, -Normal(Velocity));
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	Explode(Location, HitNormal);
}

//
// Hurt actors within the radius.
//
function HurtRadius2( float DamageAmount, float DamageRadius, name DamageType, float Momentum, vector HitLocation )
{
	local actor Victim;
	local float damageScale, dist;
	local vector dir;
	
	foreach VisibleCollidingActors( class 'Actor', Victim, DamageRadius, HitLocation )
	{
		if( Victim != self && Victim != Owner)
		{
			if(Victim.IsA('ScriptPawn') && ScriptPawn(Victim).bIsBoss)
			{ // Radius damage doesn't affect bosses
				DamageAmount = 0;
			}

			dir = Victim.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			damageScale = 1 - FMax(0,(dist - Victim.CollisionRadius)/DamageRadius);
			
			Victim.JointDamaged(damageScale * DamageAmount,
				Instigator,
				Victim.Location - 0.5 * (Victim.CollisionHeight + Victim.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType,
				0);
		} 
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	PlaySound(ExplosionSound, SLOT_None);
	Spawn(class'MechRocketExplosion');
	HurtRadius2(Damage, DamageRadius, MyDamageType, Damage * 0.5, Location);
	Destroy();
}

defaultproperties
{
     DamageRadius=200.000000
     ExplosionSound=Sound'WeaponsSnd.PowerUps.aorangepuff01'
     TimeToExplode=2.000000
     Damage=30.000000
     MyDamageType=Blunt
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_SkeletalMesh
     DrawScale=1.500000
     ScaleGlow=1.500000
     CollisionRadius=20.000000
     CollisionHeight=8.000000
     Skeletal=SkelModel'objects.Rocks'
}
