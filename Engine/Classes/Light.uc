//=============================================================================
// The light class.
//=============================================================================
class Light extends Actor
	native;

#exec Texture Import File=Textures\S_Light.pcx  Name=S_Light Mips=Off Flags=2


simulated function Debug(canvas Canvas, int mode)
{
	Super.Debug(Canvas, mode);

	if (bAffectActors)
	{
		Canvas.DrawText("Affects Actors");
		Canvas.CurY -= 8;
	}
	if (bAffectWorld)
	{
		Canvas.DrawText("Affects World");
		Canvas.CurY -= 8;
	}
}

defaultproperties
{
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=Texture'Engine.S_Light'
     bMovable=False
     CollisionRadius=24.000000
     CollisionHeight=24.000000
     LightType=LT_Steady
     LightBrightness=64
     LightHue=51
     LightSaturation=255
     LightRadius=64
     LightPeriod=32
     LightCone=128
     VolumeBrightness=64
}
