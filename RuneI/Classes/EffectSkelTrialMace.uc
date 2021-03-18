//=============================================================================
// EffectSkelTrialMace.
//=============================================================================
class EffectSkelTrialMace expands EffectSkeleton;

simulated function Spawned()
{

	local actor macefire;

		macefire = Spawn(class'trialpitfire', self,, GetJointPos(3));
		if(macefire != None)
		{
			AttachActorToJoint(macefire, 3);
			macefire.RemoteRole = ROLE_None;
		}

}

defaultproperties
{
}
