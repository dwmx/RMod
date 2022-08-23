//=============================================================================
// ProtSphereDamage.
//=============================================================================
class ProtSphereDamage expands Effects;

var() float DecayPerSecond;


function Tick(float DeltaTime)
{
	if (ScaleGlow > 0)
	{
		ScaleGlow -= DeltaTime * DecayPerSecond;
		if (ScaleGlow < 0)
		{
			ScaleGlow = 0;
			Destroy();
		}
	}
}

defaultproperties
{
     DecayPerSecond=2.000000
     DrawType=DT_VerticalSprite
     Style=STY_Translucent
     Sprite=Texture'RuneFX.Spark1'
     Texture=Texture'RuneFX.Spark1'
     DrawScale=2.000000
     ScaleGlow=3.000000
}
