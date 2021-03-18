//=============================================================================
// FireObject.
//=============================================================================
class FireObject expands DecorationRune
	abstract;

var() bool bLit;
var() class<ParticleSystem> FireClass;
var() name FireJoint;

var ParticleSystem Fire;

//===================================================================
//
// PostBeginPlay
//
//===================================================================

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(bLit)
		SpawnFire();
}

//===================================================================
//
// SpawnFire
//
//===================================================================

simulated function SpawnFire()
{
	local int jointIndex;

	if(FireClass == None || FireJoint == '')
		return;

	jointIndex = JointNamed(FireJoint);
	Fire = Spawn(FireClass, self,, Location);
	AttachActorToJoint(Fire, jointIndex);
}

defaultproperties
{
     bLit=True
     FireClass=Class'RuneI.SmallFire'
     FireJoint=offset
     DrawType=DT_SkeletalMesh
     bCollideActors=True
     bCollideWorld=True
}
