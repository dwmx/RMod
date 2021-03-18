//=============================================================================
// MechBladeArm.
//=============================================================================
class MechBladeArm expands LimbWeapon;


function EMatterType MatterForJoint(int joint)
{
	return MATTER_WEAPON;
}

function SpawnBloodSpray(vector HitLoc, vector HitNorm, EMatterType matter)
{
}

defaultproperties
{
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
     DropSound=Sound'WeaponsSnd.Drops.axedrop04'
     SkelMesh=19
     SkelGroupSkins(1)=Texture'creatures.MechaDwarfarmlegpain'
     SkelGroupSkins(2)=Texture'creatures.MechaDwarfarmlegpain'
}
