//=============================================================================
// MechArm.
//=============================================================================
class MechArm expands LimbWeapon;

function EMatterType MatterForJoint(int joint)
{
	return MATTER_WEAPON;
}

function SpawnBloodSpray(vector HitLoc, vector HitNorm, EMatterType matter)
{
}

defaultproperties
{
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing01'
     ThroughAir(1)=Sound'WeaponsSnd.Swings.swing02'
     ThroughAir(2)=Sound'WeaponsSnd.Swings.swing03'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impactflesh01'
     HitFlesh(1)=Sound'WeaponsSnd.ImpFlesh.impactflesh02'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood01'
     HitWood(1)=Sound'WeaponsSnd.ImpWood.impactwood02'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone01'
     HitStone(1)=Sound'WeaponsSnd.ImpStone.impactstone03'
     HitStone(2)=Sound'WeaponsSnd.ImpStone.impactstone04'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal02'
     HitMetal(1)=Sound'WeaponsSnd.ImpMetal.impactmetal04'
     HitMetal(2)=Sound'WeaponsSnd.ImpMetal.impactcombo01'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth01'
     HitDirt(1)=Sound'WeaponsSnd.ImpEarth.impactearth02'
     HitDirt(2)=Sound'WeaponsSnd.ImpEarth.impactearth03'
     HitShield=Sound'WeaponsSnd.ImpWood.impactwood02'
     HitWeapon=Sound'WeaponsSnd.ImpMetal.impactmetal02'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood03'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone08'
     SkelMesh=18
     SkelGroupSkins(1)=Texture'creatures.MechaDwarfarmlegpain'
     SkelGroupSkins(2)=Texture'creatures.MechaDwarfarmlegpain'
     SkelGroupSkins(3)=Texture'creatures.MechaDwarfarmlegpain'
     SkelGroupSkins(4)=Texture'creatures.MechaDwarfarmlegpain'
}
