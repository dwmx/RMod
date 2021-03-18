//=============================================================================
// ZombieChangeFire.
//=============================================================================
class ZombieChangeFire expands Fire;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(3.0 + FRand(), false);
}

//===================================================================
//
// Timer
//
// Smoothly remove the fire after a few seconds
//===================================================================

function Timer()
{
	bOneShot = true;
	bSystemOneShot = true;
	LifeSpan = 1.0;
}

defaultproperties
{
     ParticleTexture(0)=Texture'RuneFX.ZombieBreath'
     LifeSpanMin=0.300000
     GravityScale=-0.150000
     Style=STY_AlphaBlend
}
