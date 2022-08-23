//=============================================================================
// WeaponHelix.
//=============================================================================
class WeaponHelix expands ParticleSystem;

var float ElapsedTime;

var float MaxDeviation;	//Affects speed of the helix-travel..
var float CircleRadius;	//Affects how wide the helix is..
var float HalfLength;	//Affects how far back and forth the helix travels..
var float Multiplier;	//Affects distance between particles..


// init function
simulated function SystemInit()
{
	local int i;
	local float f;

	ElapsedTime = RandRange(0.0, 5.0);
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Valid = True;
		ParticleArray[i].Velocity = vect(0,0,0);
		ParticleArray[i].Alpha = vect(1,1,1)*AlphaStart;
		ParticleArray[i].LifeSpan = 0;
		ParticleArray[i].TextureIndex = 0;
		ParticleArray[i].Style = Style;

		if (bRelativeToSystem)
			ParticleArray[i].Location = vect(0,0,0);
		else
			ParticleArray[i].Location = Location;

		// small sparks
		f = ScaleMax;
		ParticleArray[i].ScaleStartX = f;
		ParticleArray[i].ScaleStartY = f;
		ParticleArray[i].XScale = f;
		ParticleArray[i].YScale = f;
	}
	
	IsLoaded=true;
}

simulated function SystemTick(float DeltaTime)
{
	local int i;
	local vector X,Y,Z;

	ElapsedTime += DeltaTime;
	
	if(AttachParent.IsA('EffectSkeleton'))
		GetAxes(rotator(AttachParent.GetJointPos(3) - AttachParent.GetJointPos(2)), X, Y, Z);
	
	for (i=0; i<ParticleCount; i++)
	{
	    ParticleArray[i].Location = Location + 
	    	(X * (Sin((ElapsedTime/2 + (i*Multiplier))) * HalfLength))
	    	+ (Y * (Cos((ElapsedTime + (i*Multiplier))  * MaxDeviation) * CircleRadius))
	    	+ (Z * (Sin((ElapsedTime + (i*Multiplier))  * MaxDeviation) * CircleRadius));
	}
}

defaultproperties
{
     MaxDeviation=5.000000
     CircleRadius=15.000000
     HalfLength=30.000000
     Multiplier=0.100000
     ParticleCount=10
     ParticleTexture(0)=Texture'RuneFX.Spark1'
     ShapeVector=(X=8.000000,Y=8.000000,Z=2.000000)
     VelocityMin=(X=0.300000,Y=0.300000,Z=50.000000)
     VelocityMax=(X=2.500000,Y=2.500000,Z=120.000000)
     ScaleMin=0.150000
     ScaleMax=0.150000
     ScaleDeltaX=1.000000
     ScaleDeltaY=1.000000
     LifeSpanMin=999999.000000
     LifeSpanMax=999999.000000
     AlphaStart=10
     AlphaEnd=10
     bEventSystemInit=True
     bEventSystemTick=True
     RemoteRole=ROLE_SimulatedProxy
     bDirectional=True
     Style=STY_Translucent
     ScaleGlow=3.000000
}
