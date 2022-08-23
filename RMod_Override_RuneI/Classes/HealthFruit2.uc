//=============================================================================
// HealthFruit2.
//=============================================================================
class HealthFruit2 extends Food;

defaultproperties
{
     Nutrition=10
     JunkActor=Class'RuneI.Fruit_Core2'
     UseSound=Sound'OtherSnd.Pickups.pickupfruit02'
     PickupMessage="You ate some fruit"
     DrawScale=0.750000
     LODCurve=LOD_CURVE_CONSERVATIVE
     CollisionRadius=9.000000
     CollisionHeight=3.000000
     bCollideWorld=True
     Skeletal=SkelModel'objects.Fruit'
     SkelGroupSkins(0)=Texture'objects.Fruitfruit_gr'
     SkelGroupSkins(1)=Texture'objects.Fruitfruit_gr'
}
