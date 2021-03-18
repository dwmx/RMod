//=============================================================================
// EffectSkelFlameSword.
//=============================================================================
class EffectSkelFlameSword expands EffectSkeleton;

var(Sounds) sound IgniteSound;

var int FireJoint;

simulated function Spawned()
{
	FireJoint = 2; // First Joint on flame sword
	SetTimer(0.1, true);

}

simulated function Timer()
{
	local actor fire;

	fire = Spawn(class'TorchFire', self,, GetJointPos(FireJoint));
	if(fire != None)
	{
		AttachActorToJoint(fire, FireJoint);
		fire.RemoteRole = ROLE_None;
		fire.bStasis = false;
		
		if(FireJoint > 3)
			AmbientSound = None;
		else
			PlaySound(IgniteSound, SLOT_Interface);
	}

	FireJoint++;
	if(FireJoint > 6)
		SetTimer(0, false);
}

defaultproperties
{
     IgniteSound=Sound'EnvironmentalSnd.Fire.fireignite01'
     DrawScale=0.650000
}
