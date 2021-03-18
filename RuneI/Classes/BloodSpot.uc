//=============================================================================
// BloodSpot.
//=============================================================================
class BloodSpot expands Effects;

var float ExpandScale;
var float ExpandSpeed;

state Expanding
{
	function Tick(float DeltaTime)
	{
		DrawScale += DeltaTime * ExpandSpeed;
		if(DrawScale >= ExpandScale)
		{
			DrawScale = ExpandScale;
			Disable('Tick');
		}
	}
	
begin:
	Enable('Tick');	
}

defaultproperties
{
     DrawType=DT_VerticalSprite
     Style=STY_Modulated
     Texture=Texture'BloodFX.blood01_b'
     DrawScale=0.400000
     bShadowCast=False
}
