//=============================================================================
// GoblinCrazy.
//=============================================================================
class GoblinCrazy expands Goblin;


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
			return class'GoblinLArm';
		case BODYPART_RARM1:
			return class'GoblinRArm';
		case BODYPART_HEAD:
			return class'GoblinEHead';
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
		case 11: case 12:					return BODYPART_HEAD;
		case 1:								return BODYPART_LARM1;
		case 10:							return BODYPART_RARM1;
		case 2:								return BODYPART_LLEG1;
		case 3:								return BODYPART_RLEG1;
		case 4: case 5: case 6: case 7:
		case 8: case 9:						return BODYPART_TORSO;
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
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[4] = Texture'runefx.gore_bone';
			SkelGroupFlags[4] = SkelGroupFlags[4] & ~POLYFLAG_INVISIBLE;
			break;
	}
}

//============================================================
//
// SetGoblinSkins
//
//============================================================
function SetGoblinSkins(EGoblinLimb arms, EGoblinTorso torso, EGoblinHead head)
{
	switch(arms)
	{
		case LIMB_NORMAL:
			break;
		case LIMB_WARPAINT1:
			SkelGroupSkins[1] = texture'runei.goblinpaintedarmleg';
			SkelGroupSkins[6] = texture'runei.goblinpaintedarmleg';
			SkelGroupSkins[9] = texture'runei.goblinpaintedarmleg';
			SkelGroupSkins[10] = texture'runei.goblinpaintedarmleg';
			break;
	}
	switch(torso)
	{
		case TORSO_NORMAL:
			break;
		case TORSO_WARPAINT1:
			SkelGroupSkins[5] = texture'runei.goblinpaintedbody';
			break;
		case TORSO_WARPAINT2:
			SkelGroupSkins[5] = texture'runei.goblinpaintedbody2';
			break;
		case TORSO_WARPAINT3:
			SkelGroupSkins[5] = texture'runei.goblinpaintedbody3';
			break;
	}
	switch(head)
	{
		case HEAD_NORMAL:
			break;
		case HEAD_WARPAINT1:
			SkelGroupSkins[11] = texture'runei.goblinpaintedhead';
			SkelGroupSkins[12] = texture'runei.goblinpaintedhead';
			break;
		case HEAD_WARPAINT2:
			SkelGroupSkins[11] = texture'runei.goblinpaintedhead2';
			SkelGroupSkins[12] = texture'runei.goblinpaintedhead2';
			break;
		case HEAD_WARPAINT3:
			SkelGroupSkins[11] = texture'runei.goblinpaintedhead3';
			SkelGroupSkins[12] = texture'runei.goblinpaintedhead3';
			break;
	}
}

//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
	local Texture newpage;
	local Texture oldpage;
	
	switch(BodyPart)
	{
		case BODYPART_TORSO:
			oldpage = SkelGroupSkins[5];
			if (oldpage == Texture'creatures.goblinbody')
				newpage = Texture'creatures.goblinpainbody';
			else if (oldpage == Texture'creatures.goblinpaintedbody')
				newpage = Texture'creatures.goblinpainbodypainted1';
			else if (oldpage == Texture'creatures.goblinpaintedbody2')
				newpage = Texture'creatures.goblinpainbodypainted2';
			else if (oldpage == Texture'creatures.goblinpaintedbody3')
				newpage = Texture'creatures.goblinpainbodypainted3';
			else
				newpage = oldpage;
			SkelGroupSkins[5] = newpage;
			break;
		case BODYPART_HEAD:
			oldpage = SkelGroupSkins[11];
			if (oldpage == Texture'creatures.goblinhead')
				newpage = Texture'creatures.goblinpainhead';
			else if (oldpage == Texture'creatures.goblinpaintedhead')
				newpage = Texture'creatures.goblinpainheadpainted';
			else if (oldpage == Texture'creatures.goblinpaintedhead2')
				newpage = Texture'creatures.goblinpainheadpainted2';
			else if (oldpage == Texture'creatures.goblinpaintedhead3')
				newpage = Texture'creatures.goblinpainheadpainted3';
			else
				newpage = oldpage;
			SkelGroupSkins[11] = newpage;
			SkelGroupSkins[12] = newpage;
			break;
		case BODYPART_LARM1:
			oldpage = SkelGroupSkins[1];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[1] = newpage;
			SkelGroupSkins[6] = newpage;
			break;
		case BODYPART_RARM1:
			oldpage = SkelGroupSkins[10];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[9] = newpage;
			SkelGroupSkins[10] = newpage;
			break;
		case BODYPART_LLEG1:
			oldpage = SkelGroupSkins[2];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[2] = newpage;
			break;
		case BODYPART_RLEG1:
			oldpage = SkelGroupSkins[3];
			if (oldpage == Texture'creatures.goblinarmleg')
				newpage = Texture'creatures.goblinpainarmleg';
			else if (oldpage == Texture'creatures.goblinpaintedarmleg')
				newpage = Texture'creatures.goblinpainarmlegpainted';
			else
				newpage = oldpage;
			SkelGroupSkins[3] = newpage;
			break;
	}
	return None;
}

defaultproperties
{
     BreathSound=Sound'CreaturesSnd.Goblin.goblinbreath07'
     AcquireSound=Sound'CreaturesSnd.Goblin.goblinword12'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Goblin.goblinamb16'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Goblin.goblinword11'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Goblin.goblinamb12'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Goblin.goblinattack21'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Goblin.goblinattack06'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Goblin.goblinattack05'
     AmbientWaitSoundDelay=8.000000
     HitSound1=Sound'CreaturesSnd.Goblin.goblinhit02'
     HitSound2=Sound'CreaturesSnd.Goblin.goblinhit21'
     HitSound3=Sound'CreaturesSnd.Goblin.goblinhit10'
     Die=Sound'CreaturesSnd.Goblin.goblindeath05'
     Die2=Sound'CreaturesSnd.Goblin.goblindeath12'
     Die3=Sound'CreaturesSnd.Goblin.goblindeath15'
     SkelMesh=4
}
