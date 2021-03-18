//=============================================================================
// BubbleSystem.
//=============================================================================
class BubbleSystem extends ParticleSystem;

// Load a temporary texture
#exec TEXTURE IMPORT NAME=Bubble FILE=MODELS\Bubble.PCX

// This particle system is a constantly spewing bubble system

defaultproperties
{
     ParticleCount=22
     ParticleTexture(0)=Texture'RuneI.bubble'
     ShapeVector=(X=12.000000,Y=12.000000,Z=2.000000)
     VelocityMin=(X=-2.000000,Y=-2.000000,Z=50.000000)
     VelocityMax=(X=2.000000,Y=2.000000,Z=100.000000)
     ScaleMin=0.200000
     ScaleMax=0.400000
     LifeSpanMin=1.000000
     LifeSpanMax=2.000000
     AlphaStart=100
     AlphaEnd=100
     bApplyZoneVelocity=True
     ZoneVelocityScale=0.750000
     bForceRender=True
     Style=STY_Translucent
     AmbientSound=Sound'EnvironmentalSnd.Bubbles.bubbleswater01L'
}
