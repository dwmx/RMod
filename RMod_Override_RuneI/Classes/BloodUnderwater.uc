//=============================================================================
// BloodUnderwater.
//=============================================================================
class BloodUnderwater expands Effects;

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
     ExpandSpeed=0.160000
     GlowSpeed=0.160000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.WaterBlood'
     DrawScale=0.400000
     bShadowCast=False
}
