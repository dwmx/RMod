//=============================================================================
// Seeker.
//=============================================================================
class Seeker expands Projectile;

var Pawn TargetPawn;
var ParticleSystem Trail;
var() float ConvergeFactor;

var float TimeToDamage;

simulated function PreBeginPlay()
{
	local vector X,Y,Z;

	Trail = Spawn(class'SeekerTrail');
	Trail.SetBase(self);

	GetAxes(Rotation,X,Y,Z);
	Velocity = X * Speed;
}


simulated function Destroyed()
{
	Trail.Destroy();
}

simulated function Tick(float DeltaTime)
{
	local vector Dir;
	local PlayerPawn aPawn;
	local float dist, bestdist;

	Super.Tick(DeltaTime);
	
	if (TargetPawn==None || TargetPawn.Health<=0)
	{	// Find a new target
		bestdist = 1000000;
		TargetPawn = None;
		foreach VisibleCollidingActors(class'PlayerPawn', aPawn, 1000)
		{
			dist = VSize(aPawn.Location-Location);
			if (aPawn != Instigator && aPawn.Health > 0 && dist < bestdist && aPawn.bProjTarget)
			{	// Target this pawn
				TargetPawn = aPawn;
				bestdist = dist;
			}
		}
	}
	else
	{
		Dir = Normal( Normal(Velocity) + DeltaTime * ConvergeFactor * Normal(TargetPawn.Location-Location) );
		Velocity = Dir * MaxSpeed;
	}
	
	// Code to not allow the seeker to damage constantly while it is touching an actor
	if(TimeToDamage > 0)
	{
		TimeToDamage -= DeltaTime;
	}
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	Explode(Location, HitNormal);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if(Other.IsA('Weapon'))
		return;
			
	if(TimeToDamage <= 0)
	{
		Other.JointDamaged(Damage, Instigator, HitLocation, Velocity, MyDamageType, 0);
		TimeToDamage = 1.0; // Only damage every second
		ConvergeFactor = 10.000000;
	}
	

	if(Other.IsA('Shield')) // The seeker was blocked
		Explode(Location, vect(0, 0, 1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Destroy();
}

defaultproperties
{
     ConvergeFactor=5.000000
     speed=500.000000
     MaxSpeed=500.000000
     Damage=8.000000
     MyDamageType=Electricity
     LifeSpan=6.000000
     SoundRadius=22
     SoundVolume=128
     AmbientSound=Sound'EnvironmentalSnd.Scifi.scifi03L'
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bCollideActors=False
}
