//=============================================================================
// EffectSkelGibAxe.
//=============================================================================
class EffectSkelGibAxe expands EffectSkeleton;

simulated function Spawned()
{

	local actor blooddrip;
	local int i;

	for(i=2; i<5; i++)
	{
		blooddrip = Spawn(class'DrippingBlood', self,, GetJointPos(i));
		if(blooddrip != None)
		{
			AttachActorToJoint(blooddrip, i);
			blooddrip.RemoteRole = ROLE_None;
		}
	}

}

defaultproperties
{
}
