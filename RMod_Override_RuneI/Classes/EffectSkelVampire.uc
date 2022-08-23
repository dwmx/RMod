//=============================================================================
// EffectSkelVampire.
//=============================================================================
class EffectSkelVampire expands EffectSkeleton;

simulated function Spawned()
{
	local int i;
	local actor glow;

	for(i = 1; i <= 6; i++)
	{
		glow = Spawn(class'CoronaRed', self,, Location);
		if(glow != None)
		{
			AttachActorToJoint(glow, i);
			glow.RemoteRole = ROLE_None;
		}
	}
}

defaultproperties
{
}
