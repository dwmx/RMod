//=============================================================================
// PlayerZombie2.
//=============================================================================
class PlayerZombie2 extends RunePlayer;

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_EARTH;
}

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
	return None;
}

//============================================================
//
// BodyPartForPolyGroup
//
//============================================================
function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 1:	case 3:			return BODYPART_RARM1;
		case 2:					return BODYPART_RLEG1;
		case 4:					return BODYPART_TORSO;
		case 5:					return BODYPART_HEAD;
		case 6:					return BODYPART_LLEG1;
		case 7:	case 8:			return BODYPART_LARM1;
	}
	return BODYPART_BODY;
}

//================================================
//
// SeveredLimbClass
//
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
			return class'ZombieLArm';
		case BODYPART_RARM1:
			return class'ZombieRArm';
		case BODYPART_HEAD:
			return class'ZombieHead';
	}

	return None;
}

defaultproperties
{
     WeaponThrowSound=Sound'CreaturesSnd.Ragnar.ragpickup01'
     WeaponDropSound=Sound'CreaturesSnd.Ragnar.ragpickup01'
     JumpGruntSound(0)=None
     JumpGruntSound(1)=None
     JumpGruntSound(2)=None
     FallingDeathSound=Sound'CreaturesSnd.Ragnar.ragsarkland02'
     FallingScreamSound=None
     EdgeGrabSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
     KickSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
     HitSoundLow(0)=Sound'CreaturesSnd.Zombie.zombiehit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Zombie.zombiehit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Zombie.zombiehit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Zombie.zombiehit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Zombie.zombiehit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Zombie.zombiehit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Zombie.zombiehit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Zombie.zombiehit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Zombie.zombiehit03'
     BerserkYellSound(0)=Sound'CreaturesSnd.Zombie.zombiearm01'
     BerserkYellSound(1)=Sound'CreaturesSnd.Zombie.zombiearm01'
     BerserkYellSound(2)=Sound'CreaturesSnd.Zombie.zombiearm01'
     BerserkYellSound(3)=Sound'CreaturesSnd.Zombie.zombiearm02'
     BerserkYellSound(4)=Sound'CreaturesSnd.Zombie.zombiearm02'
     BerserkYellSound(5)=Sound'CreaturesSnd.Zombie.zombiearm02'
     CarcassType=Class'RuneI.PlayerZombie2Carcass'
     Die=Sound'CreaturesSnd.Zombie.zombiedeath01'
     Die2=Sound'CreaturesSnd.Zombie.zombiedeath03'
     Die3=Sound'CreaturesSnd.Zombie.zombiedeath01'
     LandGrunt=Sound'CreaturesSnd.Ragnar.ragsarkhit02'
     SkelMesh=11
     SkelGroupSkins(1)=Texture'Players.Ragnarz_armleg1'
     SkelGroupSkins(2)=Texture'Players.Ragnarz_armleg1'
     SkelGroupSkins(3)=Texture'Players.Ragnarz_armleg1'
     SkelGroupSkins(4)=Texture'Players.Ragnarz_body1'
     SkelGroupSkins(5)=Texture'Players.Ragnarz_head1'
     SkelGroupSkins(6)=Texture'Players.Ragnarz_armleg1'
     SkelGroupSkins(7)=Texture'Players.Ragnarz_armleg1'
     SkelGroupSkins(8)=Texture'Players.Ragnarz_armleg1'
     SkelGroupSkins(9)=Texture'Players.Ragnarz_head1'
}
