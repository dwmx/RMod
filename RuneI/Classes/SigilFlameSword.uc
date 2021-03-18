//=============================================================================
// SigilFlameSword.
//
// SigilFlameSword controls the delays creation of the particle fire on the
// FlameSword, as well as spawning a flashing symbol effect.
// Once the symbol has flashed, it is replaced with more fire (because we
// cannot attached more than one object to a given joint)
//=============================================================================
class SigilFlameSword expands Sigil;

var int FireCount;

simulated function Spawned()
{
	FireCount = 2; // First Joint on flame sword
	SetTimer(0.1, true);
}

simulated function SigilRemove()
{
	local actor fire;

	fire = Spawn(class'TorchFire', Owner,, Owner.GetJointPos(1));
	if(fire != None)
		Owner.AttachActorToJoint(fire, 1);

	Super.SigilRemove();
}

simulated function Timer()
{
	local actor fire;

	fire = Spawn(class'TorchFire', Owner,, Owner.GetJointPos(FireCount));
	if(fire != None)
		Owner.AttachActorToJoint(fire, FireCount);					

	FireCount++;
	if(FireCount > 6)
		SetTimer(0, false);
}

defaultproperties
{
}
