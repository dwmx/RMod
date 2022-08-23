//=============================================================================
// Chain.
//
// Chain for snowbeast
//=============================================================================
class Chain expands BeamSystem;


var(Sounds) Sound ChainBreakSound;


function Trigger(actor Other, pawn EventInstigator)
{
	PlaySound(ChainBreakSound, SLOT_Misc,,,, 1.0 + (FRand() * 0.2 - 0.1));
	SpawnBeamDebris();
	bHidden = true;
}

defaultproperties
{
     ParticleCount=12
     ParticleTexture(0)=Texture'RuneFX.chain1'
     NumConPts=4
     BeamThickness=3.000000
     BeamTextureScale=0.040000
     bEventSystemTick=False
}
