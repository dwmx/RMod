//=============================================================================
// EffectSkelAvalancheSword.
//=============================================================================
class EffectSkelAvalancheSword expands EffectSkeleton;

simulated function Spawned()
{

	local actor rocks;
	local int i;
	
	
	for(i=1; i<6; i++)
	{
		rocks = Spawn(class'FallingRocks', self,, GetJointPos(i));
		if(rocks != None)
		{
			AttachActorToJoint(rocks, i);
			rocks.RemoteRole = ROLE_None;
		}
	}

}

defaultproperties
{
}
