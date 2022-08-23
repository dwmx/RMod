//=============================================================================
// HitStone.
//=============================================================================
class HitStone expands ParticleSystem;

// Make sure the package is in memory when compiling
//#exec OBJ LOAD PACKAGE=RuneFX FILE=..\textures\RuneFX.utx

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=10
     ParticleTexture(0)=FireTexture'RuneFX.Smoke'
     ShapeVector=(X=3.000000,Y=3.000000,Z=3.000000)
     VelocityMin=(X=20.000000,Y=20.000000,Z=10.000000)
     VelocityMax=(X=30.000000,Y=30.000000,Z=15.000000)
     ScaleMin=0.400000
     ScaleMax=0.700000
     ScaleDeltaX=2.000000
     ScaleDeltaY=2.000000
     LifeSpanMin=0.300000
     LifeSpanMax=0.500000
     AlphaStart=80
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.100000
     bOneShot=True
     SpawnOverTime=0.150000
     bDirectional=True
     Style=STY_Translucent
}
