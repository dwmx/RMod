//=============================================================================
// Sigil.
//
// Sigils are simply a flash graphic that appears whenever a weapon is powered up
//=============================================================================
class Sigil expands Effects;

simulated function SigilRemove()
{
	Destroy();
}

simulated function Tick(float DeltaTime)
{
	local actor fire;
	DrawScale += DeltaTime * 1.5;
	
	// Fade out
	ScaleGlow -= DeltaTime * 3;
	if(ScaleGlow <= 0)
	{
		Owner.DetachActorFromJoint(1);
		SigilRemove();
	}
}

defaultproperties
{
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.SigilFire'
     DrawScale=0.100000
     ScaleGlow=2.000000
     SpriteProjForward=5.000000
}
