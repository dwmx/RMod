//=============================================================================
// EffectSkelGroundHammer.
//=============================================================================
class EffectSkelGroundHammer expands EffectSkeleton;

simulated function Spawned()
{
	local actor HammerEffect;
	local int i;

	for(i=2; i<5; i++)
	{
		HammerEffect = Spawn(class'GroundHammerEffect', self,, GetJointPos(i));
		if(HammerEffect != None)
		{
			AttachActorToJoint(HammerEffect, i);
			HammerEffect.RemoteRole = ROLE_None;
		}	
    }

}

defaultproperties
{
}
