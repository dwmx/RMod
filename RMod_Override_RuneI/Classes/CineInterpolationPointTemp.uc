//=============================================================================
// CineInterpolationPointTemp.
//
// RUNE: A Dummy CineInterpolation point.  Identical, with the exception
// that this doesn't setup the next/prev stuff in BeginPlay.
// Therefore, next and prev MUST be set up after this actor has been spawned.
//
// This class is used in the CineCamera to ease the CineCamera to/from the 
// real behind-camera point.
//=============================================================================
class CineInterpolationPointTemp expands CineInterpolationPoint;

function BeginPlay()
{
	Super(KeyPoint).BeginPlay();
}

defaultproperties
{
}
