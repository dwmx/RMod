//=============================================================================
// OdinEyeBlast.
//=============================================================================
class OdinEyeBlast expands Effects;

var float GlowSpeed;

function PostBeginPlay()
{
	GlowSpeed = 0.75;
	Enable('Tick');
}

function Tick(float DeltaSeconds)
{
	if(ScaleGlow < 0.8)
	{
		ScaleGlow += GlowSpeed * DeltaSeconds;
		DrawScale += GlowSpeed * DeltaSeconds * 3;	
		
		if(ScaleGlow > 0.8)
			Disable('Tick');
	}
}

defaultproperties
{
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.odincorona'
     DrawScale=0.300000
     ScaleGlow=0.000000
}
