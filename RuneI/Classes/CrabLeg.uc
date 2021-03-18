//=============================================================================
// CrabLeg.
//=============================================================================
class CrabLeg expands LimbWeapon;

defaultproperties
{
     Damage=2
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
     SheathSound=Sound'WeaponsSnd.Stows.xstow02'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow02'
     SwipeClass=Class'RuneI.WeaponSwipePurple'
     PickupSound=Sound'WeaponsSnd.Arm.armimp02'
     DropSound=Sound'WeaponsSnd.Drops.sworddrop03'
     SkelMesh=3
     SkelGroupSkins(1)=Texture'creatures.GiantCrabcrabpain'
}
