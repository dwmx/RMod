//=============================================================================
// ZombieBreath.
//=============================================================================
class ZombieBreath expands ParticleSystem;

var int LifeCount;

function PreBeginPlay()
{
	LifeCount = 8;
	SetTimer(0.25, true);
}

function Timer()
{
	local actor Victim;
	
	foreach VisibleActors(class 'Actor', Victim, 50, Location)
	{
		if(Victim != self && !Victim.IsA('Zombie'))
		{
			Victim.JointDamaged(4, Pawn(Owner), Location, vect(0, 0, 0), 'magic', 0);
		} 
	}

	// Remove the zombie breath cloud after a specified amount of time
	LifeCount--;
	if(LifeCount <= 0)
		RemoveCloud();
}

function HitWall(vector HitNormal, actor Wall)
{
	RemoveCloud();
}

function RemoveCloud()
{
	SetTimer(0, false);
	Velocity = vect(0, 0, 0);
	SetPhysics(PHYS_None);
	bOneShot = true;
	bSystemOneShot = true;
}

defaultproperties
{
     ParticleCount=32
     ParticleTexture(0)=Texture'RuneFX.ZombieBreath'
     ShapeVector=(X=4.000000,Y=4.000000,Z=4.000000)
     ScaleMin=0.600000
     ScaleMax=0.800000
     ScaleDeltaX=0.200000
     ScaleDeltaY=0.200000
     LifeSpanMin=0.300000
     LifeSpanMax=0.800000
     AlphaStart=60
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=0.015000
     Style=STY_AlphaBlend
     ScaleGlow=2.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bCollideWorld=True
}
