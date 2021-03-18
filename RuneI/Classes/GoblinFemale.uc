//=============================================================================
// GoblinFemale.
//=============================================================================
class GoblinFemale expands Goblin;


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
			return class'GoblinHead';
	}

	return None;
}


//============================================================
//
// SetupGoblin
//
//============================================================
function SetupGoblin()
{
	// Keep the female skins, mesh
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
		case 12: case 13:					return BODYPART_HEAD;
		case 1:								return BODYPART_LARM1;
		case 10:							return BODYPART_RARM1;
		case 2:								return BODYPART_LLEG1;
		case 3:								return BODYPART_RLEG1;
		case 4: case 5: case 6: case 7:
		case 8: case 9:	case 11:			return BODYPART_TORSO;
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
			SkelGroupSkins[11] = newpage;
			break;
		case BODYPART_HEAD:
			oldpage = SkelGroupSkins[12];
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
			SkelGroupSkins[12] = newpage;
			SkelGroupSkins[13] = newpage;
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

//============================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//============================================================
function bool CanPickup(Inventory item)
{
	if (Health <= 0)
		return false;

	if (item.IsA('Weapon') && (BodyPartHealth[BODYPART_RARM1] > 0) && (Weapon == None))
	{
		return (item.IsA('Torch') || item.IsA('GoblinClaw'));
	}
	else if (item.IsA('Shield') && (BodyPartHealth[BODYPART_LARM1] > 0) && (Shield == None))
	{
		return false;
	}
	return(false);
}

defaultproperties
{
     bLungeAttack=False
     FightOrFlight=0.800000
     FightOrDefend=0.000000
     LatOrVertDodge=0.500000
     HighOrLowBlock=1.000000
     BlockChance=0.000000
     BreathSound=Sound'CreaturesSnd.Goblin.goblinbreath04'
     AcquireSound=Sound'CreaturesSnd.Goblin.goblinsee03'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Goblin.goblinamb13'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Goblin.goblinword01'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Goblin.goblinamb07'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Goblin.goblinattack26'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Goblin.goblinattack31'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Goblin.goblinattack02'
     AmbientWaitSoundDelay=8.500000
     AmbientFightSoundDelay=6.000000
     StartWeapon=Class'RuneI.GoblinClaw'
     StartShield=None
     JumpZ=50.000000
     MaxStepHeight=60.000000
     Health=25
     HitSound1=Sound'CreaturesSnd.Goblin.goblinhit23'
     HitSound2=Sound'CreaturesSnd.Goblin.goblinhit03'
     HitSound3=Sound'CreaturesSnd.Goblin.goblinattack25'
     Die=Sound'CreaturesSnd.Goblin.goblindeath16'
     Die2=Sound'CreaturesSnd.Goblin.goblindeath02'
     Die3=Sound'CreaturesSnd.Goblin.goblindeath01'
     SkelMesh=5
}
