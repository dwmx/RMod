//=============================================================================
// FireRingWithFire.
//=============================================================================
class FireRingWithFire expands FireRing;

function PreBeginPlay()
{
	local Actor a;
	
	a = Spawn(class'Fire',,,Location + vect(0, 0, 10));
	
	Super.PreBeginPlay();
}

defaultproperties
{
}
