//=============================================================================
// SpiderBomb.
//=============================================================================
class SpiderBomb expands Projectile;

var Actor TorchFire;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Spawn fire on the torch
	TorchFire = Spawn(class'trailfire',,, Owner.Location,);
	
	AttachActorToJoint(TorchFire, JointNamed('offset'));
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if(Other.IsA('Weapon'))
		return;
		
	Other.JointDamaged(Damage, Pawn(Owner), HitLocation, Velocity * 0.5, 'fire', 0);
	Explode(HitLocation, vect(0, 0, 0));
}

simulated function Landed(vector HitNormal, actor HitActor)
{
	Explode(Location, HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if(TorchFire != None)
	{
		TorchFire.Destroy();
	}
	
	Destroy();
}

defaultproperties
{
     Damage=6.000000
     DrawType=DT_SkeletalMesh
     DrawScale=1.250000
     AmbientGlow=50
     Skeletal=SkelModel'objects.Rocks'
}
