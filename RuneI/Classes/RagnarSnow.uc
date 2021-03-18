//=============================================================================
// RagnarSnow.
//=============================================================================
class RagnarSnow expands RunePlayer;


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
			SkelGroupSkins[2] = Texture'players.ragnarragsno_torsopain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[11] = Texture'players.ragnartn_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.ragnarragsno_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[9] = Texture'players.ragnarragsno_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[1] = Texture'players.ragnarragsno_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarragsno_armlegpain';
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
		case 11:							return BODYPART_HEAD;
		case 10: 							return BODYPART_LARM1;
		case 9:								return BODYPART_RARM1;
		case 1:								return BODYPART_LLEG1;
		case 3:								return BODYPART_RLEG1;
		case 2: case 4: case 5:
		case 6: case 7: case 8:				return BODYPART_TORSO;
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
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
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
		case BODYPART_RARM1:
			return class'SnowRagnarArm';
		case BODYPART_HEAD:
			return class'TownRagnarHead';
	}

	return None;
}

defaultproperties
{
     CarcassType=Class'RuneI.PlayerRagnarSnowCarcass'
     SkelMesh=20
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarragsno_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnarragsno_torso'
     SkelGroupSkins(3)=Texture'Players.Ragnarragsno_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(5)=Texture'Players.Ragnarragsno_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(7)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(8)=Texture'Players.Ragnarragsno_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarragsno_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarragsno_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnartn_head'
}
