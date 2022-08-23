//=============================================================================
// EffectSkelIceAxe.
//=============================================================================
class EffectSkelIceAxe expands EffectSkeleton;

simulated function Spawned()
{
	local actor vapor;

	vapor = Spawn(class'IceAxeEffect', self,, GetJointPos(4));
	if(vapor != None)
	{
		AttachActorToJoint(vapor, 4);
		vapor.RemoteRole = ROLE_None;
	}

}

defaultproperties
{
}
