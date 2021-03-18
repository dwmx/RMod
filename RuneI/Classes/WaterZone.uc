//=============================================================================
// WaterZone.
//=============================================================================
class WaterZone expands ZoneInfo;

defaultproperties
{
     EntrySound=Sound'MurmurSnd.Water.splash01'
     EntrySoundBig=Sound'MurmurSnd.Water.splash02'
     ExitSound=Sound'MurmurSnd.Water.splash08'
     EntryActor=Class'RuneI.splash'
     ExitActor=Class'RuneI.Ripple'
     bWaterZone=True
}
