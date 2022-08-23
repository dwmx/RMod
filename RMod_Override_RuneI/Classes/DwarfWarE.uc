//=============================================================================
// DwarfWarE.
//=============================================================================
class DwarfWarE expands Dwarf;


//================================================
//
// SeveredLimbClass
//
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LLEG1:
		case BODYPART_RLEG1:
			break;
		case BODYPART_LARM1:
			return class'WarDwarfLArm';
		case BODYPART_RARM1:
			return class'WarDwarfRArm';
		case BODYPART_HEAD:
			return class'WarDwarfEHead';
			break;
	}

	return None;
}


//================================================
//
// BodyPartForPolyGroup
//
//================================================
function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 1: case 3: case 6: case 13: case 14:
		case 4: case 5: case 7:	return BODYPART_TORSO;
		case 15: case 0:		return BODYPART_HEAD;
		case 2:					return BODYPART_RARM1;
		case 12:				return BODYPART_LARM1;
		case 8: case 11:		return BODYPART_RLEG1;
		case 9: case 10:		return BODYPART_LLEG1;
		default:				return BODYPART_BODY;
	}
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
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[4] = Texture'runefx.gore_bone';
			SkelGroupFlags[4] = SkelGroupFlags[4] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
			break;
	}
}


//================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_BODY:
			SkelGroupSkins[1] = Texture'creatures.dwarfwd_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[0] = Texture'creatures.dwarfwd_helmetbpain';
			SkelGroupSkins[15] = Texture'creatures.dwarfwd_bodypain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[12] = Texture'creatures.dwarfwd_armlegpain';
			SkelGroupSkins[14] = Texture'creatures.dwarfwd_bodypain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[2] = Texture'creatures.dwarfwd_armlegpain';
			SkelGroupSkins[13] = Texture'creatures.dwarfwd_bodypain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[9] = Texture'creatures.dwarfwd_armlegpain';
			SkelGroupSkins[10] = Texture'creatures.dwarfwd_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[8] = Texture'creatures.dwarfwd_armlegpain';
			SkelGroupSkins[11] = Texture'creatures.dwarfwd_armlegpain';
			break;
	}
	return None;
}

defaultproperties
{
     BashSound=Sound'CreaturesSnd.Dwarves.attack19'
     BreathSound=Sound'CreaturesSnd.Dwarves.breath08'
     AcquireSound=Sound'CreaturesSnd.Dwarves.boss04'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Dwarves.ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Dwarves.ambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Dwarves.boss07'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Dwarves.word30'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Dwarves.attack24'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Dwarves.attack22'
     AmbientWaitSoundDelay=10.000000
     AmbientFightSoundDelay=3.500000
     HitSound1=Sound'CreaturesSnd.Dwarves.hit32'
     HitSound2=Sound'CreaturesSnd.Dwarves.hit03'
     HitSound3=Sound'CreaturesSnd.Dwarves.hit21'
     Die=Sound'CreaturesSnd.Dwarves.death27'
     Die2=Sound'CreaturesSnd.Dwarves.death22'
     Die3=Sound'CreaturesSnd.Dwarves.death28'
     SkelMesh=7
}
