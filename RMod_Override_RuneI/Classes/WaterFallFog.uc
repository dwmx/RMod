//=============================================================================
// WaterFallFog.
//=============================================================================
//USAGE:
//Place at bottom of waterfall, in middle of it's width.  Set Direction pointing away from waterfall.

// To change the length of the fog effect, change ShapeVector.X
// Tweak with ScaleMin/ScaleMax to change the size of each of the particles

class WaterFallFog expands ParticleSystem;

defaultproperties
{
     ParticleCount=25
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     SpawnShape=PSHAPE_Line
     ShapeVector=(X=80.000000,Y=10.000000,Z=10.000000)
     VelocityMin=(X=-0.500000,Y=75.000000,Z=300.000000)
     VelocityMax=(X=0.500000,Y=100.000000,Z=500.000000)
     ScaleMin=1.500000
     ScaleMax=2.000000
     ScaleDeltaX=2.000000
     ScaleDeltaY=2.500000
     LifeSpanMin=0.400000
     LifeSpanMax=0.750000
     AlphaStart=200
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.400000
     bForceRender=True
     bDirectional=True
     Style=STY_Translucent
}
