//=============================================================================
// MechFireSpewer.
//=============================================================================
class MechFireSpewer expands Spewer;

defaultproperties
{
     DormantDurationMax=2.000000
     DormantDurationMin=2.000000
     ActiveDurationMax=5.000000
     ActiveDurationMin=5.000000
     SpewerForceMin=600.000000
     SpewerForceMax=800.000000
     ExpandDuration=1.500000
     ShrinkDuration=1.500000
     MotionYaw=(MotMagnitude=1.000000,MotSpeed=1.000000)
     MotionPitch=(MotMagnitude=1.000000,MotSpeed=1.000000)
     SpewerMode=SPWM_Periodic
     ParticleCount=60
     ParticleTexture(0)=FireTexture'RuneFX.Flame'
     ShapeVector=(X=8.000000,Y=8.000000,Z=8.000000)
     VelocityMin=(X=-90.000000,Y=-90.000000,Z=700.000000)
     VelocityMax=(X=90.000000,Y=90.000000,Z=900.000000)
     ScaleMin=1.500000
     ScaleMax=2.200000
     ScaleDeltaX=2.000000
     ScaleDeltaY=4.000000
     LifeSpanMin=0.200000
     LifeSpanMax=0.450000
     AlphaStart=75
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.250000
     SpawnOverTime=1.500000
     bDirectional=True
     Style=STY_Translucent
}
