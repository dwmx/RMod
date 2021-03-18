//=============================================================================
// EffectSkelLightningSword.
//=============================================================================
class EffectSkelLightningSword expands EffectSkeleton;

var int LightningJoint;

simulated function Spawned()
{
	LightningJoint = 2; // First Joint on flame sword
	SetTimer(0.1, true);
}

simulated function Timer()
{
	local actor lightning;
	lightning = Spawn(class'LightningSwordEffect', self,, GetJointPos(LightningJoint));
	if(lightning != None)
	{
		AttachActorToJoint(lightning, LightningJoint);
		lightning.RemoteRole = ROLE_None;
		lightning.bStasis = false;
	}

	LightningJoint++;
	if(LightningJoint > 5)
		SetTimer(0, false);
}

defaultproperties
{
}
