//=============================================================================
// BlastRadius.
//=============================================================================
class BlastRadius expands Effects;


var float TimePassed;
const StartRadius = 22.0;
const EndRadius=500.0;
const EffectTime=1.0;

simulated function Spawned()
{
	TimePassed=0.0;
	ScaleGlow = EffectTime;

	DoRadiusEffect();
}

function PushActor(actor A)
{
	local vector Vel;

	Vel = Normal(A.Location-Location);
	Vel.Z = 0.5;
	Vel *= 600;
	A.AddVelocity(Vel);
}

function DoRadiusEffect()
{
	local actor A;
	foreach RadiusActors(class'actor', A, EndRadius, Location)
	{
		if (A==Instigator)
			continue;

		if (A.bHidden)
			continue;

		if (!FastTrace(Location, A.Location))
			continue;

		if(A.IsA('ScriptPawn') && ScriptPawn(A).bIsBoss)
			continue;

		PushActor(A);
	}
}

simulated function Tick(float DeltaTime)
{
	local float newRadius;

	TimePassed += DeltaTime;
	newRadius = StartRadius + (EndRadius-StartRadius) * (TimePassed/EffectTime);
	DrawScale = newRadius/StartRadius;
	
	// Fade the blast radius out
	ScaleGlow -= DeltaTime;
	if(ScaleGlow <= 0)
		Destroy();
//	SetCollisionSize(newRadius, CollisionHeight);
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_VerticalSprite
     Style=STY_Translucent
     Texture=Texture'RuneFX.Blastring'
     AmbientGlow=50
     CollisionRadius=22.000000
     CollisionHeight=22.000000
     bCollideActors=True
}
