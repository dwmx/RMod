//=============================================================================
// CrabPincer.
//=============================================================================
class CrabPincer expands InvisibleWeapon;


//=============================================================================
//
// SpawnHitEffect
//
// Spawns an effect based upon what was struck
//=============================================================================
function SpawnHitEffect(vector HitLoc, vector HitNorm, int LowMask, int HighMask, Actor HitActor)
{	
	local int i,j;
	local EMatterType matter;

	// Determine what kind of matter was hit
	if ((HitActor.Skeletal != None) && (LowMask!=0 || HighMask!=0))
	{
		for (j=0; j<HitActor.NumJoints(); j++)
		{
			if (((j <  32) && ((LowMask  & (1 <<  j      )) != 0)) ||
				((j >= 32) && (j < 64) && ((HighMask & (1 << (j - 32))) != 0)) )
			{	// Joint j was hit
				matter = HitActor.MatterForJoint(j);
				break;
			}
		}
	}
	else if(HitActor.IsA('LevelInfo'))
	{	
		matter = HitActor.MatterTrace(HitLoc, Owner.Location, WeaponSweepExtent);
	}
	else
	{
		matter = HitActor.MatterForJoint(0);
	}

	// Create effects
	switch(matter)
	{
		case MATTER_FLESH:
			if(HitActor.IsA('Sark') || HitActor.IsA('SarkRagnar'))
				Spawn(class'SarkBloodMist',,, HitLoc, rotator(HitNorm)); // Sark blood
			else
				Spawn(class'BloodMist',,, HitLoc, rotator(HitNorm));

			i = Rand(NumFleshSounds);
			PlaySound(HitFlesh[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_WOOD:
			i = Rand(NumWoodSounds);
			PlaySound(HitWood[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_STONE:
			Spawn(class'HitStone',,, HitLoc, rotator(HitNorm));
			i = Rand(NumStoneSounds);
			PlaySound(HitStone[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_METAL:
			i = Rand(NumMetalSounds);
			PlaySound(HitMetal[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_EARTH:
			i = Rand(NumEarthSounds);
			PlaySound(HitDirt[i], SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_BREAKABLEWOOD:
			PlaySound(HitBreakableWood, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_BREAKABLESTONE:
			PlaySound(HitBreakableStone, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_WEAPON:
			PlaySound(HitWeapon, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_SHIELD:
			PlaySound(HitShield, SLOT_Misc,,,, 1.0 + (FRand()-0.5)*2.0*PitchDeviation);
			break;
		case MATTER_ICE:
			break;
		case MATTER_WATER:
			break;
	}
}

defaultproperties
{
     Damage=15
     DamageType=Sever
     ThroughAir(0)=Sound'CreaturesSnd.Crab.crabarm01'
     ThroughAir(1)=Sound'CreaturesSnd.Crab.crabarm02'
     ThroughAir(2)=Sound'CreaturesSnd.Crab.crabattack03'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe10'
     HitFlesh(1)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe10'
     HitFlesh(2)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe10'
     HitWood(0)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitWood(1)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitWood(2)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitStone(0)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitStone(1)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitStone(2)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitMetal(0)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitMetal(1)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitMetal(2)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitDirt(0)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitDirt(1)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitDirt(2)=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitShield=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitWeapon=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitBreakableWood=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     HitBreakableStone=Sound'WeaponsSnd.ImpFlesh.impactflesh03'
     SwipeClass=Class'RuneI.WeaponSwipePurple'
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'weapons.InvisibleShort'
}
