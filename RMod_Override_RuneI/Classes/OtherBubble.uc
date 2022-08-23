//=============================================================================
// OtherBubble.
//
// OtherBubbles should be used as alternates to mud bubbles, for instance
// as lava bubbles or water bubbles
//=============================================================================
class OtherBubble expands MudBubble;

var() Texture BubbleTexture;

//=============================================================================
//
// PreBeginPlay
//
//=============================================================================

function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Set the skin appropriate to this bubble
	SkelGroupSkins[0] = BubbleTexture;
	SkelGroupSkins[1] = BubbleTexture;
}

//=============================================================================
//
// Burst
//
// OtherBubble burst currently doesn't spew out any globs
//=============================================================================

function Burst()
{
	Spawn(class'SteamBlast',,, Location+Vect(0, 0, 8));
}

defaultproperties
{
     ScaleMax=3.500000
     Style=STY_Translucent
     ScaleGlow=0.700000
}
