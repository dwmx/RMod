//=============================================================================
// LightningSwordBeam.
//=============================================================================
class LightningSwordBeam expands BeamSystem;

//=============================================================================
//
// SystemTick
//
// Called when the particle system is ticked IF bEventSystemTick is true
//=============================================================================

event SystemTick(float DeltaSeconds)
{
	local int i;
	local float amp;
	local vector v;
	local vector X, Y, Z;
	local float dist;
		
	if(Target == None)
	{
		return;
	}
	
	BeamTime += DeltaSeconds;

	if(TargetJointIndex == 0)
	{	
		v = Target.Location - Location;
	}
	else
	{
		v = Target.GetJointPos(TargetJointIndex) - Location;
	}
	
	dist = VSize(v) * 0.03;
	GetAxes(rotator(v), X, Y, Z);
	
	for(i = 0; i < NumConPts; i++)
	{
		if(i < NumConPts / 2)
		{
			amp = dist * float(i) / NumConPts;
		}
		else
		{
			amp = dist * float(NumConPts - i) / NumConPts;
		}
		
		ConnectionOffset[i] = Z * 6 * amp * sin(BeamTime * 30 + i * 0.5)
			+ Y * amp * 7 * sin(BeamTime * 25 + i * 0.5);
	}
}

defaultproperties
{
     ParticleCount=30
     ParticleTexture(0)=Texture'RuneFX.beam'
     AlphaStart=60
     NumConPts=10
     BeamThickness=2.000000
     bTaperStartPoint=True
     bTaperEndPoint=True
     Style=STY_Translucent
}
