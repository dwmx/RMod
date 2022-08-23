//=============================================================================
// WayBeaconDest.
//=============================================================================
class WayBeaconDest expands WayBeacon;


function touch(actor other)
{
	if (other == owner)
	{
		Destroy();
	}
}

defaultproperties
{
     Sprite=None
     Texture=Texture'Engine.S_Flag'
}
