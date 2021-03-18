//=============================================================================
// BloodWaterSurface.
//=============================================================================
class BloodWaterSurface expands Effects;

var float ExpandSpeed;
var float GlowSpeed;

auto state Expanding
{
	function Tick(float DeltaTime)
	{
		DrawScale += DeltaTime * ExpandSpeed;
		ScaleGlow -= DeltaTime * GlowSpeed;
		if (ScaleGlow < 0)
			Destroy();
	}
	
begin:
}

defaultproperties
{
     ExpandSpeed=0.500000
     GlowSpeed=0.430000
     DrawType=DT_VerticalSprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.WaterBlood'
     DrawScale=0.400000
     ScaleGlow=1.300000
     bShadowCast=False
}
