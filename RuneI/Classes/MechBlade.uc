//=============================================================================
// MechBlade.
//=============================================================================
class MechBlade expands InvisibleWeapon;


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
			if(BloodTexture != None && Owner != None)
			{
				if (ChainedWeapon == None)
				{	// bloody right blade
					Owner.SkelGroupSkins[7] = BloodTexture;
					Owner.SkelGroupSkins[8] = BloodTexture;
				}
				else
				{
					// bloody left blade
					Owner.SkelGroupSkins[9] = BloodTexture;
					Owner.SkelGroupSkins[10] = BloodTexture;
				}
			}
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
     DamageType=Sever
     ThroughAir(0)=Sound'CreaturesSnd.Mech.mechblade01'
     ThroughAir(1)=Sound'CreaturesSnd.Mech.mechblade02'
     ThroughAir(2)=Sound'CreaturesSnd.Mech.mechblade03'
     HitFlesh(0)=Sound'CreaturesSnd.Mech.mechimpactplayer'
     HitFlesh(1)=Sound'CreaturesSnd.Mech.mechimpactplayer'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood05'
     HitWood(1)=Sound'WeaponsSnd.ImpWood.impactwood06'
     HitWood(2)=Sound'WeaponsSnd.ImpWood.impactwood17'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone05'
     HitStone(1)=Sound'WeaponsSnd.ImpStone.impactstone03'
     HitStone(2)=Sound'WeaponsSnd.ImpStone.impactstone15'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal18'
     HitMetal(1)=Sound'WeaponsSnd.ImpMetal.impactmetal12'
     HitMetal(2)=Sound'WeaponsSnd.ImpMetal.impactmetal04'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth04'
     HitDirt(1)=Sound'WeaponsSnd.ImpEarth.impactearth07'
     HitDirt(2)=Sound'WeaponsSnd.ImpEarth.impactearth04'
     HitShield=Sound'WeaponsSnd.Shields.shield10'
     HitWeapon=Sound'WeaponsSnd.ImpMetal.impactmetal02'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood05'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone05'
     SheathSound=Sound'WeaponsSnd.Stows.stow05'
     UnsheathSound=Sound'WeaponsSnd.Stows.stow06'
     PitchDeviation=0.000000
     SwipeClass=Class'RuneI.WeaponSwipePurple'
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'weapons.MechClaw'
}
