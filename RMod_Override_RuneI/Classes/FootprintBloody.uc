//=============================================================================
// FootprintBloody.
//=============================================================================
class FootprintBloody extends Footprint;

simulated function BeginPlay()
{
	if (class'GameInfo'.Default.bLowGore || (Level.bDropDetail && (FRand() < 0.35)) )
	{	// Can destroy this here because it's not replicated to client
		Destroy();
		return;
	}

	Super.BeginPlay();
}

defaultproperties
{
     Texture=Texture'RuneFX.bloodprint'
}
