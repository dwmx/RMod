//=============================================================================
// ShipWreckRagnar.
//=============================================================================
class ShipWreckRagnar extends RunePlayer;

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
			SkelGroupSkins[8] = Texture'players.ragnarragsw_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[7] = Texture'players.ragnartn_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[9] = Texture'players.ragnarragsw_armspain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[4] = Texture'players.ragnarragsw_armspain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarragsw_legspain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[6] = Texture'players.ragnarragsw_legspain';
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
		case 7:								return BODYPART_HEAD;
		case 9: 							return BODYPART_LARM1;
		case 4:								return BODYPART_RARM1;
		case 2:								return BODYPART_LLEG1;
		case 6:								return BODYPART_RLEG1;
		case 1: case 3: case 5:
		case 8: case 10: case 11:			return BODYPART_TORSO;
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
			SkelGroupSkins[10] = Texture'runefx.gore_bone';
			SkelGroupFlags[10] = SkelGroupFlags[10] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[11] = Texture'runefx.gore_bone';
			SkelGroupFlags[11] = SkelGroupFlags[11] & ~POLYFLAG_INVISIBLE;
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
			return class'TownRagnarArm';
		case BODYPART_HEAD:
			return class'TownRagnarHead';
	}

	return None;
}

defaultproperties
{
     CarcassType=Class'RuneI.PlayerShipWreckRagnarCarcass'
     Health=50
     SkelMesh=13
     SkelGroupSkins(0)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(3)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(4)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(5)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(6)=Texture'Players.Ragnarragsw_legs'
     SkelGroupSkins(8)=Texture'Players.Ragnarragsw_body'
     SkelGroupSkins(9)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(10)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(11)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(12)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(13)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(14)=Texture'Players.Ragnarragsw_arms'
     SkelGroupSkins(15)=Texture'Players.Ragnarragsw_arms'
}
