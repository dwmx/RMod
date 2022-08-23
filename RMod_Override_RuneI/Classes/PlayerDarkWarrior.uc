//=============================================================================
// PlayerDarkWarrior.
//=============================================================================
class PlayerDarkWarrior expands RunePlayer;

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
			SkelGroupSkins[4] = Texture'players.ragnardw_torsopain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[10] = Texture'players.ragnardw_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[3] = Texture'players.ragnardw_armlegpain';
			SkelGroupSkins[9] = Texture'players.ragnardw_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[2] = Texture'players.ragnardw_armlegpain';
			SkelGroupSkins[6] = Texture'players.ragnardw_armlegpain';
			break;
		case BODYPART_LLEG1:
		case BODYPART_RLEG1:
			SkelGroupSkins[1] = Texture'players.ragnardw_armlegpain';
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
		case 10:							return BODYPART_HEAD;
		case 9:								return BODYPART_LARM1;
		case 6:								return BODYPART_RARM1;
		case 1:								return BODYPART_LLEG1;
		case 2: case 3:
		case 4:	case 5: case 7: case 8:		return BODYPART_TORSO;
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
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
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
			return class'DarkVikingLArm';
		case BODYPART_RARM1:
			return class'DarkVikingRArm';
		case BODYPART_HEAD:
			return class'DarkVikingHead';
			break;
	}

	return None;
}

defaultproperties
{
     HitSoundLow(0)=Sound'CreaturesSnd.Vikings.darkhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Vikings.darkhit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Vikings.darkhit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Vikings.darkhit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Vikings.darkhit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Vikings.darkhit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Vikings.darkhit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Vikings.darkhit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Vikings.darkhit03'
     CarcassType=Class'RuneI.PlayerDarkWarriorCarcass'
     Die=Sound'CreaturesSnd.Vikings.darkdeath01'
     Die2=Sound'CreaturesSnd.Vikings.darkdeath02'
     Die3=Sound'CreaturesSnd.Vikings.darkdeath03'
     SkelMesh=18
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnardw_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnardw_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnardw_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnardw_torso'
     SkelGroupSkins(5)=Texture'Players.Ragnardw_torso'
     SkelGroupSkins(6)=Texture'Players.Ragnardw_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnardw_torso'
     SkelGroupSkins(8)=Texture'Players.Ragnardw_torso'
     SkelGroupSkins(9)=Texture'Players.Ragnardw_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnardw_head'
}
