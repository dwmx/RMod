//=============================================================================
// SigilLightningSword.
//=============================================================================
class SigilLightningSword expands Sigil;


simulated function SigilRemove()
{
	local ParticleSystem beam;
	local actor flash;

	beam = Spawn(class'LightningSwordBeam', Owner,, Owner.GetJointPos(1));
	if(beam != None)
	{
		beam.Target = Owner;
		beam.TargetJointIndex = 2;
		Owner.AttachActorToJoint(beam, 1);					
	}

	flash = Spawn(class'DanglerLight', Owner,, Owner.GetJointPos(2));
	if(flash != None)
	{
		flash.DrawScale = 0.4;
		Owner.AttachActorToJoint(flash, 2);					
	}
	
	Super.SigilRemove();
}

defaultproperties
{
     Texture=Texture'RuneFX.SigilBlue'
}
