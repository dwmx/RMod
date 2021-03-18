//=============================================================================
// HealthFruit1.
//=============================================================================
class HealthFruit1 extends Food;

defaultproperties
{
     Nutrition=15
     JunkActor=Class'RuneI.Fruit_Core'
     UseSound=Sound'OtherSnd.Pickups.pickupfruit01'
     PickupMessage="You ate some delicious fruit"
     LODCurve=LOD_CURVE_CONSERVATIVE
     CollisionRadius=3.000000
     CollisionHeight=3.000000
     bCollideWorld=True
     Skeletal=SkelModel'objects.Fruit'
}
