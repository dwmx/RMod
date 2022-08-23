//=============================================================================
//
// CineInterpolationPoint.
//
// RUNE:  A special cinematic interpolation point
//=============================================================================
class CineInterpolationPoint expands InterpolationPoint;

var() float PauseTime;

function InterpolateEnd(Actor Other)
{
	FireEvent(Event);
}

defaultproperties
{
}
