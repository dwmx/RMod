//=============================================================================
// PlayerSarkHammer.
//=============================================================================
class PlayerSarkHammer expands RunePlayer;

//============================================================
//
// BodyPartForPolyGroup
//
//============================================================
function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 8: case 9:				return BODYPART_LLEG1;
		case 4: case 5:				return BODYPART_RLEG1;
		case 11:					return BODYPART_HEAD;
		case 6:						return BODYPART_RARM1;
		case 10:					return BODYPART_LARM1;
		case 1: case 2: case 12: case 3: case 7:	return BODYPART_TORSO;
	}

	return BODYPART_BODY;
}

//============================================================
//
// ApplyGoreCap
//
//============================================================
function ApplyGoreCap(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_HEAD:
			SkelGroupSkins[1] = Texture'runefx.gore_bone';
			SkelGroupFlags[1] = SkelGroupFlags[1] & ~POLYFLAG_INVISIBLE;
			break;
	}
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
		case BODYPART_RARM1:
			return class'SarkHammerArm';
		case BODYPART_HEAD:
			return class'SarkHammerHead';
	}
	return None;
	return None;
}

defaultproperties
{
     Die4=Sound'CreaturesSnd.Ragnar.ragsarkdeath04'
     WeaponThrowSound=Sound'CreaturesSnd.Ragnar.ragpickup01'
     WeaponDropSound=Sound'CreaturesSnd.Ragnar.ragpickup01'
     JumpGruntSound(1)=Sound'CreaturesSnd.Ragnar.ragsarkjump02'
     FallingDeathSound=Sound'CreaturesSnd.Ragnar.ragsarkland02'
     FallingScreamSound=Sound'CreaturesSnd.Ragnar.ragsarkfall01'
     EdgeGrabSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
     KickSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
     HitSoundLow(0)=Sound'CreaturesSnd.Ragnar.ragsarkhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Ragnar.ragsarkhit02'
     HitSoundLow(2)=Sound'CreaturesSnd.Ragnar.ragsarkhit03'
     HitSoundMed(0)=Sound'CreaturesSnd.Ragnar.ragsarkhit04'
     HitSoundMed(1)=Sound'CreaturesSnd.Ragnar.ragsarkhit05'
     HitSoundMed(2)=Sound'CreaturesSnd.Ragnar.ragsarkhit06'
     HitSoundHigh(0)=Sound'CreaturesSnd.Ragnar.ragsarkhit07'
     HitSoundHigh(1)=Sound'CreaturesSnd.Ragnar.ragsarkhit08'
     HitSoundHigh(2)=Sound'CreaturesSnd.Ragnar.ragsarkhit09'
     BerserkSoundStart=Sound'CreaturesSnd.Ragnar.ragsarkberstart'
     BerserkSoundEnd=Sound'CreaturesSnd.Ragnar.ragsarkberend'
     BerserkSoundLoop=Sound'CreaturesSnd.Ragnar.ragsarkberzerkL'
     BerserkYellSound(0)=Sound'CreaturesSnd.Ragnar.ragsarkattack01'
     BerserkYellSound(1)=Sound'CreaturesSnd.Ragnar.ragsarkattack02'
     BerserkYellSound(2)=Sound'CreaturesSnd.Ragnar.ragsarkattack03'
     BerserkYellSound(3)=Sound'CreaturesSnd.Ragnar.ragsarkattack04'
     BerserkYellSound(4)=Sound'CreaturesSnd.Ragnar.ragsarkattack05'
     BerserkYellSound(5)=Sound'CreaturesSnd.Ragnar.ragsarkattack06'
     CarcassType=Class'RuneI.PlayerSarkHammerCarcass'
     Die=Sound'CreaturesSnd.Ragnar.ragsarkdeath01'
     Die2=Sound'CreaturesSnd.Ragnar.ragsarkdeath02'
     Die3=Sound'CreaturesSnd.Ragnar.ragsarkdeath03'
     LandGrunt=Sound'CreaturesSnd.Ragnar.ragsarkhit02'
     LandSoundWood=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundMetal=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundStone=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundFlesh=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundIce=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundSnow=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundEarth=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundWater=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundMud=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundLava=Sound'CreaturesSnd.Sark.sarkland02'
     SkelMesh=21
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(2)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(3)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(4)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(6)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(8)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarsh_chest'
     SkelGroupSkins(10)=Texture'Players.Ragnarsh_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnarsh_head'
     SkelGroupSkins(12)=Texture'Players.Ragnarsh_chest'
}
