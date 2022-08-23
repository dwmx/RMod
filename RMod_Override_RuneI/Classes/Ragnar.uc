//=============================================================================
// Ragnar.
//=============================================================================
class Ragnar extends RunePlayer;

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
			SkelGroupSkins[1] = Texture'players.ragnarragd_torsopain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[13] = Texture'players.ragnarragd_headpain'; 
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.ragnarragd_armspain';
			SkelGroupSkins[11] = Texture'players.ragnarragd_armspain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'players.ragnarragd_armspain';
			SkelGroupSkins[7] = Texture'players.ragnarragd_armspain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarragd_legspain';
			SkelGroupSkins[8] = Texture'players.ragnarragd_legspain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarragd_legspain';
			SkelGroupSkins[4] = Texture'players.ragnarragd_legspain';
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
		case 13: case 14:					return BODYPART_HEAD;
		case 10: 							return BODYPART_LARM1;
		case 6:								return BODYPART_RARM1;
		case 3: case 8:						return BODYPART_LLEG1;
		case 2:	case 4:						return BODYPART_RLEG1;
		case 1: case 5: case 7: case 9:
			case 11: case 12:				return BODYPART_TORSO;
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
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[12] = Texture'runefx.gore_bone';
			SkelGroupFlags[12] = SkelGroupFlags[12] & ~POLYFLAG_INVISIBLE;
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
			return class'RagnarLArm';
		case BODYPART_RARM1:
			return class'RagnarRArm';
		case BODYPART_HEAD:
			return class'RagnarHead';
	}

	return None;
}

defaultproperties
{
     CarcassType=Class'RuneI.RagnarCarcass'
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarragd_torso'
     SkelGroupSkins(2)=Texture'Players.Ragnarragd_legs'
     SkelGroupSkins(3)=Texture'Players.Ragnarragd_legs'
     SkelGroupSkins(4)=Texture'Players.Ragnarragd_legs'
     SkelGroupSkins(5)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(6)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(7)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(8)=Texture'Players.Ragnarragd_legs'
     SkelGroupSkins(9)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(10)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(11)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(12)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(13)=Texture'Players.RagnarRagd_head'
     SkelGroupSkins(14)=Texture'Players.RagnarRagd_head'
}
