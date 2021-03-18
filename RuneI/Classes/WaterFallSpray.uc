//=============================================================================
// WaterFallSpray.
//=============================================================================
//Usage: 
//Place at top of waterfall, in middle of it's width, with the direction parallel to the SOURCE of waterfall

class WaterFallSpray expands ParticleSystem;

defaultproperties
{
     bSpriteInEditor=True
     ParticleCount=32
     ParticleTexture(0)=Texture'RuneFX.splash3'
     SpawnShape=PSHAPE_Line
     ShapeVector=(X=75.000000,Y=6.000000,Z=10.000000)
     VelocityMin=(Y=50.000000,Z=20.000000)
     VelocityMax=(Y=100.000000,Z=50.000000)
     ScaleMin=0.100000
     ScaleMax=0.200000
     LifeSpanMin=0.500000
     LifeSpanMax=1.000000
     AlphaStart=60
     AlphaEnd=60
     bApplyGravity=True
     GravityScale=1.250000
     bForceRender=True
     bDirectional=True
     Style=STY_Translucent
}
