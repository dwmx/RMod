//=============================================================================
// PlayerSarkSword.
//=============================================================================
class PlayerSarkSword expands RunePlayer;

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
		case 1: case 12:		return BODYPART_LLEG1;
		case 2: case 13:		return BODYPART_RLEG1;
		case 4: case 11:		return BODYPART_LARM1;
		case 9: case 14:		return BODYPART_RARM1;
		case 3: case 5:	case 6:
		case 7: case 8: case 10:
		case 0:					return BODYPART_TORSO;
		case 15:				return BODYPART_HEAD;
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
		case BODYPART_LARM1:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[10] = Texture'players.gore_bone';
			SkelGroupFlags[10] = SkelGroupFlags[10] & ~POLYFLAG_INVISIBLE;
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
			return class'SarkSwordArm';
		case BODYPART_HEAD:
			return class'SarkSwordHead';
	}
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
     CarcassType=Class'RuneI.PlayerSarkSwordCarcass'
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
     SkelMesh=14
     SkelGroupSkins(0)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(1)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(4)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(7)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(9)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(11)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(12)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(13)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(14)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(15)=Texture'Players.Ragnarsw_head'
}
