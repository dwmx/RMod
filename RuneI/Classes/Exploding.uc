//=============================================================================
// Exploding.
//=============================================================================

//USAGE:
//Place slightly away from originating wall (particles are larger, so may occlude if too close)
//Choose specific Mode (TriggerConstant, Constant, TriggerSingle)
//NOTE: Please try and use TriggerConstant in place of TriggerSingle whenenver possible.
//If using TriggerSingle, enter desired Duration (time to fade out is extra....)
//Try to setup MaxForce and direction so that particles don't reach other walls...
//VelocityRadius describes the MaxRadius in the direction that particles can travel...(think of a cone)

class Exploding expands ParticleSystem;

var() float VelocityRadius;
var() float MaxForce;
var() float ExpDuration;	//Only used for EXPM_TriggerSingle


var() enum EExplodingMode
{
	EXPM_TriggerConstant,	// Constant explosion.  Requires a Trigger message to start.							
	EXPM_Constant,			//Constant explosion.  Initially active.
	EXPM_TriggerSingle		// Explode for a specified duration once triggered...
} ExplodingMode;

var float CurDuration;

simulated function PostBeginPlay()
{
	local vector temp, rotVect;
	
	Super.PostBeginPlay();
	
	bDirectional = false;	//Turn off so particles behave correctly...
	
	if(ExplodingMode != EXPM_Constant)
		bHidden = true;			//Hide it initially (unless EXPM_Constant)...
	
	rotVect = vector(Rotation);
	
	temp = rotVect cross vect(0,0,1) * VelocityRadius + rotVect cross vect(0,1,0) * VelocityRadius +
		rotVect cross vect(1,0,0) * VelocityRadius;		//Set up conic shape to travel within....
	
	VelocityMax = (rotVect * MaxForce) + temp;		
	VelocityMin = (rotVect * MaxForce) - temp;
}


function Trigger(actor other, pawn eventInstigator)
{
	bHidden = false;
	if(ExplodingMode == EXPM_TriggerSingle)
	{
		CurDuration = ExpDuration;
		GotoState('EmmissionBegin');	
	}
}

		//System stays in this state until time elapsed...
State EmmissionBegin
{
	ignores Trigger;
	
	event Tick(float DeltaTime)
	{	
		CurDuration -= DeltaTime;
		if(CurDuration <= 0)
		{
			CurDuration = 0;
			GotoState('EmmissionDie');
		}
	}
	
	Begin:
}

		//System is currently fading away now...
State EmmissionDie
{
	ignores Trigger;
	
	event Tick(float DeltaTime)
	{	
		if(AlphaStart <= 0)
		{
			if(ParticleCount > 1)
				ParticleCount--;
			else
				GotoState('EmmissionDead');
		}
		else
			AlphaStart -= 1 * (Rand(2));
	}
	
	Begin:
}

		//Dormant State..
State EmmissionDead
{
	ignores Trigger, Tick;

	Begin:
		bHidden = true;
}


simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
		
	Canvas.DrawLine3D(Location, Location + VelocityMax, 255,0,0);
	Canvas.DrawLine3D(Location, Location + VelocityMin, 0, 0, 255);	
}

defaultproperties
{
     VelocityRadius=100.000000
     MaxForce=300.000000
     ExpDuration=5.000000
     bSpriteInEditor=True
     ParticleCount=30
     ParticleTexture(0)=FireTexture'RuneFX.Flame'
     VelocityMin=(X=25.000000,Y=-50.000000)
     VelocityMax=(X=50.000000,Y=50.000000)
     ScaleMin=3.000000
     ScaleMax=4.000000
     ScaleDeltaX=2.000000
     ScaleDeltaY=2.000000
     LifeSpanMin=0.900000
     LifeSpanMax=1.500000
     AlphaStart=100
     AlphaEnd=50
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.025000
     SpawnOverTime=2.000000
     bDirectional=True
     Style=STY_Translucent
}
