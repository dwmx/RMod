//=============================================================================
// Stein.
//=============================================================================
class Stein expands Food;

defaultproperties
{
     Nutrition=35
     JunkActor=Class'RuneI.EmptyStein'
     UseSound=Sound'OtherSnd.Pickups.pickupstein01'
     PickupMessage="You drank some mead"
     Rotation=(Roll=-16384)
     CollisionRadius=7.000000
     CollisionHeight=7.000000
     bCollideWorld=True
     Skeletal=SkelModel'objects.Stein'
}
