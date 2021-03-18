//=============================================================================
// MudSplat.
//=============================================================================
class MudSplat expands Effects;

event Tick(float deltaTime)
{
	DrawScale -= 0.2*deltaTime;
	if(DrawScale < 0.05)
		Destroy();
}

defaultproperties
{
     DrawType=DT_VerticalSprite
     Style=STY_Masked
     Texture=Texture'RuneFX.Mudblob2'
     DrawScale=0.250000
     ScaleGlow=1.400000
}
