//=============================================================================
// DarkDwarfLightning2.
//=============================================================================
class DarkDwarfLightning2 expands BeamSystem;


var float amplitude;

function Trigger( Actor Other, Pawn EventInstigator )
{
	amplitude += 5;

	if (amplitude >= 35)
	{	// Powerlevel 4
		ParticleTexture[0]=Texture'RuneFX.Beam2Red';
	}
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
		
		ConnectionOffset[i] = Z * amp * sin(BeamTime * 20 + i * 0.5)
			+ Y * amp * 2 * sin(BeamTime * 15 + i * 0.5);
	}
}

defaultproperties
{
     Amplitude=20.000000
     bSystemTicks=True
     ParticleCount=30
     ParticleTexture(0)=Texture'RuneFX.swipe'
     AlphaStart=60
     AlphaEnd=60
     NumConPts=10
     BeamThickness=8.000000
     Style=STY_Translucent
}
