//=============================================================================
// EffectSkelSonicClub.
//=============================================================================
class EffectSkelSonicClub expands EffectSkeleton;

simulated function Spawned()
{

	local actor blast;
	local int i;

	for(i=1; i < 3; i++)
	{
		blast = Spawn(class'SonicClubEffect', self,, GetJointPos(i));
		if(blast != None)
		{
			blast.DrawScale = 0.35 * i;
			AttachActorToJoint(blast, i);
			blast.RemoteRole = ROLE_None;
		}
	}

}

defaultproperties
{
}
