//=============================================================================
// SpongeMushroom.
//=============================================================================
class SpongeMushroom extends Plants;

var float LastPuff;
var() bool bSpawnPuff;


function SpawnPuff(int joint)
{
	local actor a;

	if(!bSpawnPuff)
		return;

	if (Level.TimeSeconds - LastPuff > 1.0)
	{
		LastPuff = Level.TimeSeconds;
		a = Spawn(class'MushroomPuff', self,, GetJointPos(joint));
		if (a!=None)
		{
			a.Velocity = vect(0,0,20);
			a.SetPhysics(PHYS_Projectile);
		}
	}

}

simulated function JointTouchedBy(actor Other, int joint)
{
	Super.JointTouchedBy(Other, joint);
	SpawnPuff(joint);
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	if (joint != 0)
		SpawnPuff(joint);

	return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}

defaultproperties
{
     bSpawnPuff=True
     TouchFactor=0.030000
     CollisionRadius=12.000000
     CollisionHeight=12.000000
     Skeletal=SkelModel'plants.Sponge_Mushroom'
}
