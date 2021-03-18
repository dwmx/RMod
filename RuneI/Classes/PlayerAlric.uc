//=============================================================================
// PlayerAlric.
//=============================================================================
class PlayerAlric expands RunePlayer;

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_TORSO:
			SkelGroupSkins[3] = Texture'players.ragnaral_chestpain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[4] = Texture'players.ragnaral_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[8] = Texture'players.ragnaral_armlegpain';
			SkelGroupSkins[10] = Texture'players.ragnaral_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[13] = Texture'players.ragnaral_armlegpain';
			SkelGroupSkins[11] = Texture'players.ragnaral_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[2] = Texture'players.ragnaral_armlegpain';
			SkelGroupSkins[6] = Texture'players.ragnaral_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[1] = Texture'players.ragnaral_armlegpain';
			SkelGroupSkins[5] = Texture'players.ragnaral_armlegpain';
			break;
	}
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
		case 4:								return BODYPART_HEAD;
		case 10:							return BODYPART_LARM1;
		case 11:							return BODYPART_RARM1;
		case 2: case 6:						return BODYPART_LLEG1;
		case 1:	case 5:						return BODYPART_RLEG1;
		case 3: case 7: case 9: case 12:
			case 8: case 13:				return BODYPART_TORSO;
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
			SkelGroupSkins[9] = Texture'runefx.gore_bone';
			SkelGroupFlags[9] = SkelGroupFlags[9] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[12] = Texture'runefx.gore_bone';
			SkelGroupFlags[12] = SkelGroupFlags[12] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
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
			return class'WolfLArm';
		case BODYPART_RARM1:
			return class'WolfRArm';
		case BODYPART_HEAD:
			return class'AlricHead';
			break;
	}

	return None;
}

defaultproperties
{
     HitSoundLow(0)=Sound'CreaturesSnd.Vikings.vike2hit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Vikings.vike2hit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Vikings.vike2hit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Vikings.vike2hit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Vikings.vike2hit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Vikings.vike2hit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Vikings.vike2hit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Vikings.vike2hit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Vikings.vike2hit03'
     CarcassType=Class'RuneI.PlayerAlricCarcass'
     Die=Sound'CreaturesSnd.Vikings.vike2death01'
     Die2=Sound'CreaturesSnd.Vikings.vike2death02'
     Die3=Sound'CreaturesSnd.Vikings.vike2death03'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=7
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnaral_chest'
     SkelGroupSkins(4)=Texture'Players.Ragnaral_head'
     SkelGroupSkins(5)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(8)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(10)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(12)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(13)=Texture'Players.Ragnaral_armleg'
     SkelGroupSkins(14)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(15)=Texture'Players.Ragnarragd_arms'
}
