class R_FX_SwordHitIce extends ParticleSystem;

defaultproperties
{
     bSystemOneShot=True
     ParticleCount=75
     ParticleTexture(0)=Texture'RuneFX.sparkltblue'
     VelocityMin=(X=-100.000000,Y=-100.000000,Z=-50.000000)
     VelocityMax=(X=100.000000,Y=100.000000,Z=75.000000)
     ScaleMin=0.1500000
     ScaleMax=0.3500000
     ScaleDeltaX=0.300000
     ScaleDeltaY=0.300000
     LifeSpanMin=0.400000
     LifeSpanMax=1.200000
     AlphaStart=225
     AlphaEnd=175
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.550000
     bOneShot=True
     bDirectional=True
     Style=STY_Translucent
}