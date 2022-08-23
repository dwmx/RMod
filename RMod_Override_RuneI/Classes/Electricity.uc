//=============================================================================
// Electricity.
//=============================================================================
class Electricity expands BeamSystem;


var float amplitude;


//=============================================================================
//
// SystemTick
//
// Called when the particle system is ticked IF bEventSystemTick is true
//=============================================================================
event SystemTick(float DeltaSeconds)
{
	local int i;
	local vector v;
	local vector X, Y, Z;
		
	if(Target == None)
		return;

	if(TargetJointIndex == 0)
	{	
		v = Target.Location - Location;
	}
	else
	{
		v = Target.GetJointPos(TargetJointIndex) - Location;
	}
	GetAxes(rotator(v), X, Y, Z);
	
	for(i = 1; i < NumConPts-1; i++)
	{
		ConnectionOffset[i] =
			X * ((FRand() - 0.5) * amplitude) +
			Y * ((FRand() - 0.5) * amplitude) +
			Z * ((FRand() - 0.5) * amplitude );
	}
}

defaultproperties
{
     Amplitude=5.000000
     ParticleCount=24
     ParticleTexture(0)=Texture'RuneFX.beam'
     NumConPts=8
     BeamThickness=1.500000
}
