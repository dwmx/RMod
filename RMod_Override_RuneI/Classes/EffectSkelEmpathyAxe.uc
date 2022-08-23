//=============================================================================
// EffectSkelEmpathyAxe.
//=============================================================================
class EffectSkelEmpathyAxe expands EffectSkeleton;

simulated function Spawned()
{

	local actor helix;
	local int i;

		helix = Spawn(class'HelixEmpathy', self,, GetJointPos(3));
		if(helix != None)
		{
			AttachActorToJoint(helix, 3);
			helix.RemoteRole = ROLE_None;
		}

}

defaultproperties
{
}
