//=============================================================================
// PlayerKarl.
//=============================================================================
class PlayerKarl expands RunePlayer;

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
			SkelGroupSkins[1] = Texture'players.ragnarkarl_chestpain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[5] = Texture'players.ragnarkarl_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[11] = Texture'players.ragnarkarl_armlegpain';
			SkelGroupSkins[9] = Texture'players.ragnarkarl_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'players.ragnarkarl_armlegpain';
			SkelGroupSkins[8] = Texture'players.ragnarkarl_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarkarl_armlegpain';
			SkelGroupSkins[12] = Texture'players.ragnarkarl_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarkarl_armlegpain';
			SkelGroupSkins[13] = Texture'players.ragnarkarl_armlegpain';
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
		case 5:								return BODYPART_HEAD;
		case 9:								return BODYPART_LARM1;
		case 8:								return BODYPART_RARM1;
		case 3: case 12:					return BODYPART_LLEG1;
		case 2:	case 13:					return BODYPART_RLEG1;
		case 1: case 4: case 7: case 10:
			case 6: case 11:				return BODYPART_TORSO;
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
			return class'KarlLArm';
		case BODYPART_RARM1:
			return class'KarlRArm';
		case BODYPART_HEAD:
			return class'KarlHead';
			break;
	}

	return None;
}

//=============================================================================
// Skin support
//=============================================================================
static function int GetNumSkins()
{
	return 2;
}

static function string GetSkinName(int Skin)
{
	switch(Skin)
	{
		case 0:		return "Default";
		case 1:		return "Jarl";
	}

	return "";
}

static function SetSkinActor(actor SkinActor, int NewSkin)
{
	local texture tex1, tex2, tex3;
	local int i;

	switch(NewSkin)
	{
		case 0:
			for (i=0; i<16; i++)
			{
				SkinActor.SkelGroupSkins[i] = Default.SkelGroupSkins[i];
			}
			break;
		case 1:
			tex1 = Texture(DynamicLoadObject("Players.ragnarJarl_armleg", class'Texture'));
			tex2 = Texture(DynamicLoadObject("Players.ragnarJarl_chest", class'Texture'));
			tex3 = Texture(DynamicLoadObject("Players.ragnarJarl_head", class'Texture'));
 			SkinActor.SkelGroupSkins[1]=tex2;
 			SkinActor.SkelGroupSkins[2]=tex1;
 			SkinActor.SkelGroupSkins[3]=tex1;
 			SkinActor.SkelGroupSkins[4]=tex1;
 			SkinActor.SkelGroupSkins[5]=tex3;
 			SkinActor.SkelGroupSkins[6]=tex1;
 			SkinActor.SkelGroupSkins[7]=tex1;
 			SkinActor.SkelGroupSkins[8]=tex1;
 			SkinActor.SkelGroupSkins[9]=tex1;
 			SkinActor.SkelGroupSkins[10]=tex1;
 			SkinActor.SkelGroupSkins[11]=tex1;
 			SkinActor.SkelGroupSkins[12]=tex1;
 			SkinActor.SkelGroupSkins[13]=tex1;
			break;
	}
}

function SpecialPainSkin(int BodyPart)
{
	local texture tex1, tex2, tex3;

	switch(CurrentSkin)
	{
		case 1:
			tex1 = Texture(DynamicLoadObject("Players.ragnarJarl_armlegpain", class'Texture'));
			tex2 = Texture(DynamicLoadObject("Players.ragnarJarl_chestpain", class'Texture'));
			tex3 = Texture(DynamicLoadObject("Players.ragnarJarl_headpain", class'Texture'));
			switch(BodyPart)
			{
				case BODYPART_TORSO:
					SkelGroupSkins[1] = tex2;
					break;
				case BODYPART_HEAD:
					SkelGroupSkins[5] = tex3;
					break;
				case BODYPART_LARM1:
					SkelGroupSkins[11] = tex1;
					SkelGroupSkins[9] = tex1;
					break;
				case BODYPART_RARM1:
					SkelGroupSkins[6] = tex1;
					SkelGroupSkins[8] = tex1;
					break;
				case BODYPART_LLEG1:
					SkelGroupSkins[3] = tex1;
					SkelGroupSkins[12] = tex1;
					break;
				case BODYPART_RLEG1:
					SkelGroupSkins[2] = tex1;
					SkelGroupSkins[13] = tex1;
					break;
			}
			break;
	}
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
     CarcassType=Class'RuneI.PlayerKarlCarcass'
     Die=Sound'CreaturesSnd.Vikings.vike2death01'
     Die2=Sound'CreaturesSnd.Vikings.vike2death02'
     Die3=Sound'CreaturesSnd.Vikings.vike2death03'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=4
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarkarl_chest'
     SkelGroupSkins(2)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(5)=Texture'Players.Ragnarkarl_head'
     SkelGroupSkins(6)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(8)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(11)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(12)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(13)=Texture'Players.Ragnarkarl_armleg'
     SkelGroupSkins(14)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(15)=Texture'Players.Ragnarragd_arms'
}
