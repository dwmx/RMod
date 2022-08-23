//=============================================================================
// PlayerConrack.
//=============================================================================
class PlayerConrack expands RunePlayer;

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
			SkelGroupSkins[1] = Texture'players.ragnarcon_chestpain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[11] = Texture'players.ragnarcon_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.ragnarcon_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'players.ragnarcon_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarcon_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarcon_armlegpain';
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
		case 11:					return BODYPART_HEAD;
		case 10:					return BODYPART_LARM1;
		case 5:						return BODYPART_RARM1;
		case 2:						return BODYPART_LLEG1;
		case 3:						return BODYPART_RLEG1;
		case 4: case 7: case 8:	// Gore caps
		case 6: case 9:			// Arm stubs
		case 1:						return BODYPART_TORSO;
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
	{	// no gore caps exist
		case BODYPART_LARM1:
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[4] = Texture'runefx.gore_bone';
			SkelGroupFlags[4] = SkelGroupFlags[4] & ~POLYFLAG_INVISIBLE;
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
			return class'ConrackLArm';
		case BODYPART_RARM1:
			return class'ConrackRArm';
		case BODYPART_HEAD:
			return class'ConrackHead';
			break;
	}

	return None;
}

defaultproperties
{
     HitSoundLow(0)=Sound'CreaturesSnd.Vikings.conrakhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Vikings.conrakhit01'
     HitSoundLow(2)=Sound'CreaturesSnd.Vikings.conrakhit01'
     HitSoundMed(0)=Sound'CreaturesSnd.Vikings.conrakhit02'
     HitSoundMed(1)=Sound'CreaturesSnd.Vikings.conrakhit02'
     HitSoundMed(2)=Sound'CreaturesSnd.Vikings.conrakhit02'
     HitSoundHigh(0)=Sound'CreaturesSnd.Vikings.conrakhit03'
     HitSoundHigh(1)=Sound'CreaturesSnd.Vikings.conrakhit03'
     HitSoundHigh(2)=Sound'CreaturesSnd.Vikings.conrakhit03'
     CarcassType=Class'RuneI.PlayerConrackCarcass'
     Die=Sound'CreaturesSnd.Vikings.conrakdeath01'
     Die2=Sound'CreaturesSnd.Vikings.conrakdeath02'
     Die3=Sound'CreaturesSnd.Vikings.conrakdeath03'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=3
     SkelGroupSkins(0)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(1)=Texture'Players.Ragnarcon_chest'
     SkelGroupSkins(2)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(5)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(8)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(9)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnarcon_head'
}
