//=============================================================================
// BeamSystem.
//=============================================================================
class BeamSystem expands ParticleSystem;

var float BeamTime;
var(ParticleSystem) name TargetTag;

//=============================================================================
//
// PreBeginPlay
//
// Sets up the ParticleCount to be equivalent to NumConPts * 3
//=============================================================================

function PreBeginPlay()
{
	local actor A;
	local int i;

	Super.PreBeginPlay();

	ParticleCount = NumConPts * 3;

	if (TargetTag != '')
	{
		foreach AllActors(class'actor', A, TargetTag)
		{
			Target = A;
		}
	}

	for(i = 0; i < NumConPts; i++)
		ConnectionPoint[i] = Location;

	SetTimer(5 + FRand()*2, false);
}

function Timer()
{
	// Hack - Beams must go through render code once before going to stasis
	bStasis=true;
}

/*
function PostBeginPlay()
{
	local int x, y, z;

	// DEBUG:  Print a warning if any ropes are spawned outside the world
	if(Region.ZoneNumber == 0)
	{
		x = self.Location.x; // truncate
		y = self.Location.y; // truncate
		z = self.Location.z; // truncate
		SLog("WARNING:  BeamSystem ["$self$"] Out of World @ ("$x$","$y$","$z$")");
	}
}
*/

//=============================================================================
//
// SpawnBeamDebris
//
//=============================================================================

function SpawnBeamDebris()
{
	local int i, j;
	local vector v;
	local Debris D;
	local vector loc;

	if(Target == None)
	{
		return;
	}
	
	if(TargetJointIndex == 0)
	{	
		v = Target.Location - Location;
	}
	else
	{
		v = Target.GetJointPos(TargetJointIndex) - Location;
	}

	for(i = 0; i < NumConPts; i++)
	{
		for(j = 0; j < 5; j++)
		{
			loc = ConnectionPoint[i] + VRand() * 4;
			D = Spawn(class'DebrisStone',,, loc);
			if(D != None)
			{
				D.SetSize(0.15);
				D.SetTexture(ParticleTexture[0]);
				D.SetMomentum(VRand() * 3.5);
			}
		}
	}
}

/* This is done in C++ code, but could be overridden if necessary -- cjr
//=============================================================================
//
// SystemInit
//
// Called when the particle system is initialize IF bEventSystemInit is true
//=============================================================================

function SystemInit()
{
	local int i;
	local float alpha;
	local int temp;
	
	alpha = float(AlphaStart) / 255.0;
	for(i = 0; i < ParticleCount; i++)
	{
		ParticleArray[i].Valid = true;
		ParticleArray[i].Style = Style;
		ParticleArray[i].Velocity = vect(0, 0, 0);
		ParticleArray[i].Alpha.X = alpha;
		ParticleArray[i].Alpha.Y = alpha;
		ParticleArray[i].Alpha.Z = alpha;
		ParticleArray[i].Location = Location;
		ParticleArray[i].XScale = 1.0;
		ParticleArray[i].YScale = 1.0;
		ParticleArray[i].TextureIndex = 0;
		ParticleArray[i].LifeSpan = -1;
	}

	for(i = 0; i < NumConPts; i++)
	{
		temp = i * 3;
		ParticleArray[temp].U0 = 0;		
		ParticleArray[temp].V0 = 0;		
		ParticleArray[temp].U1 = 0.33;		
		ParticleArray[temp].V1 = 1;

		temp++;
		ParticleArray[temp].U0 = 0.33;
		ParticleArray[temp].V0 = 0;
		ParticleArray[temp].U1 = 0.66;
		ParticleArray[temp].V1 = 1;

		temp++;
		ParticleArray[temp].U0 = 0.66;
		ParticleArray[temp].V0 = 0;
		ParticleArray[temp].U1 = 1;
		ParticleArray[temp].V1 = 1;
	}

	IsLoaded = true;
}
*/

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

simulated function Debug(Canvas canvas, int mode)
{
	local vector offset;
	local int i;

	Super.Debug(canvas, mode);

	Canvas.DrawText("BeamSystem:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" Target:"@Target);
	Canvas.CurY -= 8;
	
	// Locations of rope
	for(i = 0; i < NumConPts; i++)
	{
		Canvas.DrawLine3D(ConnectionPoint[i] + vect(10, 0, 0), ConnectionPoint[i] + vect(-10, 0, 0), 0, 255, 0);
		Canvas.DrawLine3D(ConnectionPoint[i] + vect(0, 10, 0), ConnectionPoint[i] + vect(0, -10, 0), 0, 255, 0);	
		Canvas.DrawLine3D(ConnectionPoint[i] + vect(0, 0, 10), ConnectionPoint[i] + vect(0, 0, -10), 0, 255, 0);
	}
}

defaultproperties
{
     bSpriteInEditor=True
     ParticleCount=60
     ParticleTexture(0)=FireTexture'RuneFX.MyTex1'
     ParticleType=PART_Beam
     ParticleSpriteType=PSPRITE_QuadUV
     AlphaStart=255
     AlphaEnd=255
     NumConPts=20
     BeamThickness=5.000000
     bEventSystemTick=True
     bStasis=False
     bForceRender=True
     bComplexOcclusion=True
}
