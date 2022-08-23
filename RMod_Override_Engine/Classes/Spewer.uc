//=============================================================================
// Spewer.
//=============================================================================
class Spewer expands ParticleSystem
	abstract;

#exec Texture Import File=Textures\Spewer.pcx Name=S_Spewer Mips=Off Flags=2

// EDITABLE INSTANCE VARIABLES ////////////////////////////////////////////////

var() bool		bAutoStart;
var() float		DormantDurationMax;
var() float		DormantDurationMin;
var() float		ActiveDurationMax;
var() float		ActiveDurationMin;
var() float		SpewerDamage;
var() float		SpewerRadius;
var() float		SpewerLength;
var() float		SpewerForceMin;
var() float		SpewerForceMax;
var() float		ExpandDuration;
var() float		ShrinkDuration;
var() float		PhaseDelay;
var() name		SpewerDamageType;

struct SpewerMotion
{
	var() float MotMagnitude;
	var() float MotSpeed;
	var() enum ESpewerMotion
	{
		SPM_Steady,
		SPM_Swirl,
		SPM_Wave
	} MotType;
};

var() SpewerMotion MotionYaw;
var() SpewerMotion MotionPitch;

var() enum ESpewerMode
{
	SPWM_SingleSurge,		// Spew once when triggered.
	SPWM_Constant,			// Constant spewing.  Requires a Trigger message
							// to stop.
	SPWM_Periodic			// Erupts at regular intervals of time (defined
							// by the duration vars).  Requires a Trigger
							// message to stop.
} SpewerMode;

// INSTANCE VARIABLES /////////////////////////////////////////////////////////

var float	GStateTime;
var float	GSpewTime;
var bool	bSpewerStopped;
var rotator	SPStartRotation;
var int		SPMaxParticles;
var int		SPAlphaStart;
var float	ForceDelta;
var byte	PCount;
var byte	AStart;

// FUNCTIONS //////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// PostBeginPlay.
//-----------------------------------------------------------------------------
function PostBeginPlay()
{
	super.PostBeginPlay();
	SPStartRotation = Rotation;
	SPMaxParticles = ParticleCount;
	SPAlphaStart = AlphaStart;
	ForceDelta = abs(SpewerForceMax - SpewerForceMin);
	bDirectional = false;	// Required for particles' velocity to behave
							// correctly.
}

//-----------------------------------------------------------------------------
// CommenceSpewing.
//-----------------------------------------------------------------------------
function CommenceSpewing()
{
	bSpewerStopped = false;
	if(PhaseDelay > 0)
		GotoState('EmissionPhaseDelay');
	else
		GotoState('EmissionBegin');
}

//-----------------------------------------------------------------------------
// Trigger.
//-----------------------------------------------------------------------------
function Trigger(actor other, pawn eventInstigator)
{
	CommenceSpewing();
}

//-----------------------------------------------------------------------------
// GetDormantDuration.
//-----------------------------------------------------------------------------
function float GetDormantDuration()
{
	return FMin(DormantDurationMin, DormantDurationMax)
		+ Abs(DormantDurationMax-DormantDurationMin)*FRand();
}

//-----------------------------------------------------------------------------
// GetActiveDuration.
//-----------------------------------------------------------------------------
function float GetActiveDuration()
{
	return FMin(ActiveDurationMin, ActiveDurationMax)
		+ Abs(ActiveDurationMax-ActiveDurationMin)*FRand();
}

//-----------------------------------------------------------------------------
// FixAngle.
//-----------------------------------------------------------------------------
function float FixAngle(float a)
{
	while(a > 32768)
		a -= 65536;
	while(a < -32768)
		a += 65536;
	return a;
}

//-----------------------------------------------------------------------------
// MotionTick.
//-----------------------------------------------------------------------------
function MotionTick(float deltaTime)
{
	local rotator r;
	local vector aX, aY, aZ;

	r = Rotation;
	switch(MotionYaw.MotType)
	{
	case SPM_Swirl:
		r.Yaw += (MotionYaw.MotSpeed * ANGLE_90) * deltaTime;
		break;
	case SPM_Wave:
		r.Yaw = SPStartRotation.Yaw
			+ sin(GSpewTime*4*MotionYaw.MotSpeed)
			* ANGLE_45*MotionYaw.MotMagnitude;
		break;
	}
	switch(MotionPitch.MotType)
	{
	case SPM_Swirl:
		r.Pitch += (MotionPitch.MotSpeed * ANGLE_90) * deltaTime;
		break;
	case SPM_Wave:
		r.Pitch = SPStartRotation.Pitch
			+ sin(GSpewTime*4*MotionPitch.MotSpeed)
			* ANGLE_45*MotionPitch.MotMagnitude;
		break;
	}
	//r.Yaw = FixAngle(r.Yaw);
	//r.Pitch = FixAngle(r.Pitch);
	SetRotation(r);

	VelocityMax = vector(r)*(SpewerForceMin + ForceDelta*FRand());
	VelocityMin = VelocityMax;
}

//-----------------------------------------------------------------------------
// InjureNearbyActors.
//-----------------------------------------------------------------------------
function InjureNearbyActors()
{
	local actor a;
	local vector hitLoc, hitNorm;
	local vector extent;
	
	extent.x = SpewerRadius;
	extent.y = SpewerRadius;
	extent.z = SpewerRadius;
	foreach TraceActors(class'actor', a, hitLoc, hitNorm,
		Location + vector(Rotation) * SpewerLength, Location, extent, false)
	{
		a.JointDamaged(SpewerDamage, None, a.Location, vect(0, 0, 0), SpewerDamageType, 0);
	}
}

// STATES /////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// CheckAutoStart.
//-----------------------------------------------------------------------------
auto state CheckAutoStart
{
begin:
	bHidden = true;
	AlphaStart = 0;
	SoundVolume = 0;
	if(bAutoStart)
		CommenceSpewing();
	else
		GotoState('');
}

//-----------------------------------------------------------------------------
// EmissionBegin.
//-----------------------------------------------------------------------------
state EmissionBegin
{
	function Trigger(actor other, pawn eventInstigator)
	{
		if(SpewerMode != SPWM_SingleSurge)
			bSpewerStopped = true;
	}

	event BeginState()
	{
		GStateTime = 0.0;
		GSpewTime = 0.0;
		bHidden = false;
	}

	event Tick(float deltaTime)
	{
		GStateTime += deltaTime;
		GSpewTime += deltaTime;
		MotionTick(deltaTime);

		PCount = 1+GStateTime*(SPMaxParticles/ExpandDuration);
		AStart = GStateTime*(SPAlphaStart/ExpandDuration);
		ParticleCount = Clamp(PCount, 1, SPMaxParticles);
		AlphaStart = Clamp(AStart, 0, SPAlphaStart);
		SoundVolume = Clamp(GStateTime*(160/ExpandDuration), 0, 128);
		if(GStateTime >= ExpandDuration)
		{
			ParticleCount = SPMaxParticles;
			if(bSpewerStopped == true)
				GotoState('EmissionEnd');
			else
				GotoState('EmissionContinuous');
		}
	}

begin:
}

//-----------------------------------------------------------------------------
// EmissionContinuous.
//-----------------------------------------------------------------------------
state EmissionContinuous
{
	event BeginState()
	{
		GStateTime = 0.0;
		SetTimer(0.25, true);
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		if(SpewerMode != SPWM_SingleSurge)
		{
			bSpewerStopped = true;
			GotoState('EmissionEnd');
		}
	}

	event Tick(float deltaTime)
	{
		GStateTime += deltaTime;
		GSpewTime += deltaTime;
		MotionTick(deltaTime);
	}

	event Timer()
	{
		InjureNearbyActors();
	}

begin:
	if(SpewerMode != SPWM_Constant)
	{
		Sleep(GetActiveDuration());
		GotoState('EmissionEnd');
	}
}

//-----------------------------------------------------------------------------
// EmissionEnd.
//-----------------------------------------------------------------------------
state EmissionEnd
{
	event BeginState()
	{
		GStateTime = 0.0;
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		if(SpewerMode != SPWM_SingleSurge)
			bSpewerStopped = true;
	}

	event Tick(float deltaTime)
	{
		GStateTime += deltaTime;
		GSpewTime += deltaTime;
		MotionTick(deltaTime);

		PCount = SPMaxParticles - GStateTime*(SPMaxParticles/ShrinkDuration);
		AStart = SPAlphaStart - GStateTime*(SPAlphaStart/ShrinkDuration);
		ParticleCount = Clamp(PCount, 1, SPMaxParticles);
		AlphaStart = Clamp(AStart, 0, SPAlphaStart);
		SoundVolume = Clamp(128 - GStateTime*(128/ShrinkDuration), 0, 128);
		if(GStateTime >= ShrinkDuration)
		{
			AlphaStart = 0;
			ParticleCount = 1;
			if(SpewerMode == SPWM_Periodic && bSpewerStopped == false)
				GotoState('EmissionLull');
			else
				GotoState('');
		}
	}

begin:
}

//-----------------------------------------------------------------------------
// EmissionLull.
//-----------------------------------------------------------------------------
state EmissionLull
{
	event BeginState()
	{
		bHidden = true;
	}

	function Trigger(actor other, pawn eventInstigator)
	{
		GotoState('');
	}

begin:
	Sleep(GetDormantDuration());
	GotoState('EmissionBegin');
}

//-----------------------------------------------------------------------------
// EmissionPhaseDelay.
//-----------------------------------------------------------------------------
state EmissionPhaseDelay
{
	function Trigger(actor other, pawn eventInstigator)
	{
		GotoState('');
	}

begin:
	Sleep(PhaseDelay);
	GotoState('EmissionBegin');
}

//-----------------------------------------------------------------------------
// Debug.
//-----------------------------------------------------------------------------
simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);
	Canvas.DrawText("   VelocityMax: " $ VelocityMax);
	Canvas.CurY -= 8;
	Canvas.DrawText("        pcount: " $ pcount);
	Canvas.CurY -= 8;
	Canvas.DrawText("        astart: " $ astart);
	Canvas.CurY -= 8;
	
	Canvas.DrawLine3D(Location, Location + vector(Rotation) * SpewerLength, 255, 0, 0);
}

defaultproperties
{
     bForceRender=True
     Texture=Texture'Engine.S_Spewer'
}
