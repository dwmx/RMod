//=============================================================================
// BloodlustEnd.
//=============================================================================
class BloodlustEnd expands BloodlustStart;

var float time;

simulated function PreBeginPlay()
{
	Enable('Tick');
	DesiredColorAdjust.X = 64;
	ScaleGlow = 0.75;
	time = 0.75;
}

simulated function Tick(float DeltaSeconds)
{
	local vector newLoc;
	
	DrawScale += time * 0.1;
	ScaleGlow = time;
	
	AnimSequence = Owner.AnimSequence;
	AnimFrame = Owner.AnimFrame;

	SetLocation(Owner.Location);
	SetRotation(Owner.Rotation);
	
	time -= DeltaSeconds;
	if(time <= 0.25)
		DesiredColorAdjust.X = 0;
		
	if(time <= 0)
		Destroy();
}

defaultproperties
{
}
