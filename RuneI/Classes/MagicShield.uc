//=============================================================================
// MagicShield.
//=============================================================================
class MagicShield expands Shield;

//=============================================================================
//
// Tick
//
//=============================================================================

simulated function Tick(float DeltaTime)
{
	DrawScale += DeltaTime * 4;
	if(DrawScale > 1.5)
	{
		DrawScale = 1.5;
		Disable('Tick');
	}
}

//=============================================================================
//
// Sound Functions
//
//=============================================================================
function PlayHitSound(name DamageType)
{
}

defaultproperties
{
     Health=110
     rating=5
     DestroyedSound=Sound'WeaponsSnd.Shields.xtroy04'
     bBreakable=False
     DropSound=Sound'WeaponsSnd.Shields.xdrop04'
     Style=STY_Translucent
     DrawScale=0.000000
     LODCurve=LOD_CURVE_ULTRA_CONSERVATIVE
     bUnlit=True
     CollisionRadius=13.000000
     CollisionHeight=5.000000
     bCollideWorld=True
     Mass=150.000000
     Skeletal=SkelModel'weapons.DarkShield'
     SkelGroupSkins(0)=Texture'RuneFX2.runeshield1'
     SkelGroupSkins(1)=Texture'RuneFX2.runeshield1'
     SkelGroupSkins(2)=Texture'RuneFX2.runeshield1'
     SkelGroupSkins(3)=Texture'RuneFX2.runeshield1'
     SkelGroupSkins(4)=Texture'RuneFX2.runeshield1'
}
