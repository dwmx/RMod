//=============================================================================
// WindmillPolyobj.
//=============================================================================
class WindmillPolyobj expands RunePolyobj;


/*
	Trigger toggles the acceleration direction

	when in "safe" window, encroachment properties/touch doesn't do damage
*/

var() float InitialRotationRate;
var() float DangerousTime;
var() float SafeTime;
var() float SlowRotationRate;
var(Sounds) Sound SafeSound;

var float delta;		// Angle units / second


function PreBeginPlay()
{
	delta = (InitialRotationRate-SlowRotationRate) / (DangerousTime+SafeTime);
	RotationRate.Pitch = InitialRotationRate;
	Super.PreBeginPlay();
}

function ShredActor(actor Other)
{
	Other.SetCollision(false, false, false);
	Other.JointDamaged(1000, Other.Instigator, Other.Location, Other.Velocity, 'gibbed', 0);
}


function bool EncroachingOn( actor Other )
{
	ShredActor(Other);
}


auto State() Spinning
{
	function BeginState()
	{
		AmbientSound = MoveAmbientSound;
		RotationRate.Pitch = InitialRotationRate;
	}

	function Bump(actor Other)
	{
		ShredActor(Other);
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		GotoState('DangerousSlowing');
	}

Begin:

}


State DangerousSlowing
{
	function Bump(actor Other)
	{
		ShredActor(Other);
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		GotoState('DangerousSpeeding');
	}

	function Tick(float DeltaTime)
	{
		RotationRate.Pitch -= delta * DeltaTime;
		if (RotationRate.Pitch > SlowRotationRate)	// made from negative rotation
			RotationRate.Pitch = SlowRotationRate;

		Super.Tick(DeltaTime);
	}

Begin:
	AmbientSound = MoveAmbientSound;
	Sleep(DangerousTime);
	GotoState('SafeSlowing');
}


State SafeSlowing
{
	function Trigger( Actor other, Pawn EventInstigator )
	{
		GotoState('SafeSpeeding');
	}

	function Tick(float DeltaTime)
	{
		RotationRate.Pitch -= delta * DeltaTime;
		if (RotationRate.Pitch > SlowRotationRate)
			RotationRate.Pitch = SlowRotationRate;

		Super.Tick(DeltaTime);
	}

Begin:
	AmbientSound = SafeSound;
	Sleep(SafeTime);
	GotoState('Safe');
}


State Safe
{
	function BeginState()
	{
		RotationRate.Pitch = SlowRotationRate;
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		GotoState('SafeSpeeding');
	}
Begin:
	AmbientSound = SafeSound;
}


State SafeSpeeding
{
	function Trigger( Actor other, Pawn EventInstigator )
	{
		GotoState('SafeSlowing');
	}

	function Tick(float DeltaTime)
	{
		RotationRate.Pitch += delta * DeltaTime;
		if (RotationRate.Pitch < InitialRotationRate)	// Setup for negative rotation
			RotationRate.Pitch = InitialRotationRate;

		Super.Tick(DeltaTime);
	}

Begin:
	AmbientSound = SafeSound;
	Sleep(SafeTime);
	GotoState('DangerousSpeeding');
}


State DangerousSpeeding
{
	function Bump(actor Other)
	{
		ShredActor(Other);
	}

	function Trigger( Actor other, Pawn EventInstigator )
	{
		GotoState('DangerousSlowing');
	}

	function Tick(float DeltaTime)
	{
		RotationRate.Pitch += delta * DeltaTime;
		if (RotationRate.Pitch < InitialRotationRate)
			RotationRate.Pitch = InitialRotationRate;

		Super.Tick(DeltaTime);
	}

Begin:
	AmbientSound = MoveAmbientSound;
	Sleep(DangerousTime);
	GotoState('Spinning');
}

defaultproperties
{
}
