//=============================================================================
// BlastGlow.
//=============================================================================
class BlastGlow expands Effects;

var float ScaleDelta;

simulated function Tick(float DeltaTime)
{
	DrawScale += 0.25 * ScaleDelta * DeltaTime;
	ScaleGlow += ScaleDelta * DeltaTime;
	if(ScaleGlow < 0.2 || ScaleGlow > 0.8)
		ScaleDelta = -ScaleDelta;

}

defaultproperties
{
     ScaleDelta=-0.500000
     bNetTemporary=False
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.Blastring'
     DrawScale=0.350000
     ScaleGlow=0.800000
     SpriteProjForward=1.000000
     bUnlit=True
}
