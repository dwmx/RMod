//=============================================================================
// LokiSconce2.
//=============================================================================
class LokiSconce2 expands FireObject;

//===================================================================
//
// SpawnFire
//
// Overridden because LokiSconce1 has two fire sources
//===================================================================

function SpawnFire()
{
	local int jointIndex;

	if(FireClass == None)
		return;

	jointIndex = JointNamed('offseta');
	Fire = Spawn(FireClass, self,, Location);
	AttachActorToJoint(Fire, jointIndex);

	jointIndex = JointNamed('offsetb');
	Fire = Spawn(FireClass, self,, Location);
	AttachActorToJoint(Fire, jointIndex);
}

defaultproperties
{
     CollisionRadius=10.000000
     CollisionHeight=14.000000
     Skeletal=SkelModel'objects.LokiSconce'
}
