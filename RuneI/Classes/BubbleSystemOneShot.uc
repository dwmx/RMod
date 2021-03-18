//=============================================================================
// BubbleSystemOneShot.
//=============================================================================
class BubbleSystemOneShot extends BubbleSystem;

/* DESCRIPTION: Spawns bubbles once.  Whole system floats to surface and then goes away

*/

// Load a temporary texture (this bubble is from Unreal)
#exec TEXTURE IMPORT NAME=Bubble FILE=MODELS\Bubble.PCX



function PostBeginPlay()
{
	local vector vel;
	Super.PostBeginPlay();
	if (!Region.Zone.bWaterZone)
		Destroy();
	SetPhysics(PHYS_Projectile);
	vel = vect(0,0,0);
	vel.Z = RandRange(20,30);
	Velocity = vel + Region.Zone.ZoneVelocity;
	Acceleration = Velocity;
}


function HitWall(vector HitNorm, actor Wall)
{
	Destroy();
}


function ZoneChange(ZoneInfo newZone)
{
	if (!newZone.bWaterZone)
	{
		spawn(class'ripple');
		Destroy();
		return;
	}
}

defaultproperties
{
     bSystemOneShot=True
     bRelativeToSystem=True
     ParticleCount=4
     ShapeVector=(Z=12.000000)
     VelocityMin=(X=0.000000,Y=0.000000,Z=0.000000)
     VelocityMax=(X=0.000000,Y=0.000000,Z=2.000000)
     ScaleMin=0.100000
     LifeSpanMin=99.000000
     LifeSpanMax=99.000000
}
