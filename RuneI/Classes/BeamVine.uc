//=============================================================================
// BeamVine.
//
// Generic beam, purely visual
//=============================================================================
class BeamVine extends BeamSystem;


var(Sounds) Sound BreakSound;


state() BreakWhenTriggered
{
	function Trigger(actor Other, pawn EventInstigator)
	{
		PlaySound(BreakSound, SLOT_Misc,,,, 1.0 + (FRand() * 0.2 - 0.1));
		bHidden = true;
	}
}

defaultproperties
{
     ParticleCount=9
     ParticleTexture(0)=Texture'RuneFX.Vine1'
     NumConPts=3
     BeamThickness=2.500000
     BeamTextureScale=0.040000
     bEventSystemTick=False
}
