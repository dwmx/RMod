//=============================================================================
// BubbleSystemDelay.
//=============================================================================
class BubbleSystemDelay extends BubbleSystem;

// This particle system is an intermittent bubble system that
// is set to go off roughly every 8-16 seconds

defaultproperties
{
     RandomDelay=8.000000
     LifeSpanMin=2.000000
     LifeSpanMax=3.500000
     bOneShot=True
}
