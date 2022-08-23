//=============================================================================
// SparkSystem.
//=============================================================================

//USAGE: for SparkSystem
//Direct Rotation to the desired direction of the sparks to travel.  
//Due to the system, it maybe better to offset the direction a little to the left.
//If you want this system to be initially active, change bHidden to False. 

class SparkSystem expands ParticleSystem;

var(SparkSystem) bool bInitiallyActive;

simulated function PostBeginPlay()
{
	if(bInitiallyActive)
		bHidden = false;
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	bHidden = false;
}

defaultproperties
{
     bSpriteInEditor=True
     ParticleCount=30
     ParticleTexture(0)=Texture'RuneFX2.sparkbeam'
     RandomDelay=0.500000
     VelocityMin=(X=-100.000000,Y=-100.000000,Z=-50.000000)
     VelocityMax=(X=200.000000,Y=200.000000,Z=150.000000)
     ScaleMin=0.500000
     ScaleMax=1.000000
     ScaleDeltaX=0.500000
     ScaleDeltaY=0.500000
     LifeSpanMin=0.500000
     LifeSpanMax=1.000000
     AlphaStart=225
     AlphaEnd=175
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.650000
     SpawnOverTime=1.000000
     bHidden=True
     bForceRender=True
     bDirectional=True
     Style=STY_Translucent
}
