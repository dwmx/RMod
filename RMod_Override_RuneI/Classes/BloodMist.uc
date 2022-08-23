//=============================================================================
// BloodMist.
//=============================================================================
class BloodMist expands GroundDust;

function PreBeginPlay()
{
	Super.PreBeginPlay();

	if(class'GameInfo'.Default.bVeryLowGore)
	{
		Destroy();
	}
}

defaultproperties
{
     ParticleCount=8
     ParticleTexture(0)=Texture'RuneFX.BLOODCLOUD'
     ShapeVector=(X=10.000000,Y=10.000000,Z=5.000000)
     VelocityMin=(X=-2.000000,Y=-2.000000)
     VelocityMax=(X=-6.000000,Y=-6.000000,Z=5.000000)
     ScaleMin=0.200000
     ScaleMax=0.400000
     ScaleDeltaX=2.000000
     ScaleDeltaY=2.000000
     LifeSpanMin=1.100000
     LifeSpanMax=1.500000
     GravityScale=0.250000
     Style=STY_AlphaBlend
}
