//=============================================================================
// WayBeacon.
//=============================================================================
class WayBeacon extends Keypoint;

//temporary beacon for serverfind navigation

function touch(actor other)
{
	if (other == owner)
	{
		if ( Owner.IsA('PlayerPawn') )
			PlayerPawn(owner).ShowPath();
		Disable('Touch');
		Destroy();
	}
}

defaultproperties
{
     bStatic=False
     bHidden=False
     RemoteRole=ROLE_None
     Sprite=Texture'Engine.S_Pickup'
     DrawScale=2.000000
     ScaleGlow=255.000000
     AmbientGlow=255
     bUnlit=True
     CollisionRadius=40.000000
     CollisionHeight=40.000000
     bCollideActors=True
     LightType=LT_Steady
     LightBrightness=125
     LightSaturation=125
}
