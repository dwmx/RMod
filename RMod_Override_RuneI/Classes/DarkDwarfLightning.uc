//=============================================================================
// DarkDwarfLightning.
//=============================================================================
class DarkDwarfLightning expands BeamSystem;


function Trigger( Actor Other, Pawn EventInstigator )
{
	local actor A;

	bHidden = false;
	AmbientSound=Sound'EnvironmentalSnd.SciFi.scifi02l';

	// Broadcast the Trigger message to all matching actors.
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger(Other, Other.Instigator);
}


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
	local float seglength;
		
	if(Target == None)
	{
		return;
	}
	
//	BeamTime += DeltaSeconds;

	if(TargetJointIndex == 0)
	{	
		v = Target.Location - Location;
	}
	else
	{
		v = Target.GetJointPos(TargetJointIndex) - Location;
	}
	
	seglength = VSize(v) / (NumConPts-1);
	GetAxes(rotator(v), X, Y, Z);

	for(i = 1; i < NumConPts-1; i++)
	{
		ConnectionOffset[i] =
			X * ((FRand() - 0.5) * seglength * 0.5) +
			Y * ((FRand() - 0.5) * seglength * 0.5) +
			Z * ((FRand() - 0.5) * seglength * 0.5 );
	}
}

defaultproperties
{
     ParticleCount=45
     ParticleTexture(0)=Texture'RuneFX.Beam2'
     NumConPts=15
     BeamThickness=2.500000
     bHidden=True
}
