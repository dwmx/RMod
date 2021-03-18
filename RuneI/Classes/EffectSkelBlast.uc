//=============================================================================
// EffectSkelBlast.
//=============================================================================
class EffectSkelBlast expands EffectSkeleton;

simulated function Spawned()
{
	local actor glow;

	glow = Spawn(class'BlastGlow', self,, Location);
	if(glow != None)
	{
		AttachActorToJoint(glow, 3);
		glow.RemoteRole = ROLE_None;
	}
}

defaultproperties
{
     DrawScale=0.800000
}
