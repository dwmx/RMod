//=============================================================================
// DarkDwarfConcentrator.
//=============================================================================
class DarkDwarfConcentrator expands BeamSystem;


var float amplitude;
var int powerlevel;

function Trigger( Actor Other, Pawn EventInstigator )
{
	local actor A;

	powerlevel++;
	amplitude += 10;
	BeamThickness+=10.000000;
	SoundVolume += 30;
	SoundPitch += 20;
	if (powerlevel >= 5)
	{	// Powerlevel 4
		ParticleTexture[0]=Texture'RuneFX.swipe2';
		BeamThickness=60.000000;
		amplitude = 70;
	}

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

		if (i != 0 && i != NumConPts-1)
			amp = amplitude;
		
		ConnectionOffset[i] = Z * amp * sin(BeamTime * 20 + i * 0.5)
			+ Y * amp * 2 * sin(BeamTime * 15 + i * 0.5);
	}
}

defaultproperties
{
     Amplitude=20.000000
     PowerLevel=1
     ParticleTexture(0)=Texture'RuneFX.swipe'
     AlphaStart=60
     AlphaEnd=60
     BeamThickness=8.000000
     Style=STY_Translucent
     SoundRadius=128
     SoundVolume=64
     AmbientSound=Sound'EnvironmentalSnd.Scifi.scifi01L'
}
