class BladeSwipe extends Actor;

var Actor BladeSwipeBlade;
var Actor BladeSwipeParticles;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	BladeSwipeBlade = Spawn(Class'Spells.BladeSwipeBlade', Self);
	BladeSwipeParticles = Spawn(Class'Spells.BladeSwipeParticles', Self);
}

/*
event Tick(float DeltaSeconds)
{
	local Rotator NewRotation;
	local float RotationRate;
	local Vector RadialLocation;
	local float RadialDistance;

	RotationRate = 2.0;

	NewRotation = Rotation;
	NewRotation.Roll += (65535 * RotationRate * DeltaSeconds);
	SetRotation(NewRotation);

	BladeSwipeBlade.SetLocation(Self.Location);
	BladeSwipeBlade.SetRotation(Self.Rotation);

	RadialDistance = 32.0;
	RadialLocation = Self.Location;
	RadialLocation.X += Cos(Radians(Self.Rotation.Pitch)) * RadialDistance;
	RadialLocation.Y += Cos(Radians(Self.Rotation.Roll)) * RadialDistance;
	RadialLocation.Z += Sin(Radians(Self.Rotation.Roll)) * RadialDistance;

	BladeSwipeParticles.SetLocation(RadialLocation);
	//BladeSwipeParticles.SetRotation(Self.Rotation);
}*/

event Tick(float DeltaSeconds)
{
    local Rotator NewRotation;
    local float RotationRate;
    local Vector Offset;
    local Vector RotatedOffset;
    local Vector RadialLocation;
    local float RadialDistance;
	local float a;

    RotationRate = 2.0;

    NewRotation = Rotation;
    NewRotation.Roll += (65535 * RotationRate * DeltaSeconds);
    SetRotation(NewRotation);

    BladeSwipeBlade.SetLocation(Self.Location);
    BladeSwipeBlade.SetRotation(Self.Rotation);

    RadialDistance = 32.0;

    // base offset along local X (arm length)
    Offset = vect(1, 0, 0) * RadialDistance;

    // rotate that offset by the NEW rotation we just applied
    a = Radians(NewRotation.Roll);
RotatedOffset.X = Cos(a) * RadialDistance;
RotatedOffset.Y = Sin(a) * RadialDistance;
RotatedOffset.Z = Sin(a) * RadialDistance; // keep your Z behavior
RadialLocation = Self.Location + RotatedOffset;

    // keep your Z modification if you still want sin(roll) applied to Z:
    RotatedOffset.Z = Sin(Radians(NewRotation.Roll)) * RadialDistance;

    RadialLocation = Self.Location + RotatedOffset;
    BladeSwipeParticles.SetLocation(RadialLocation);
}



defaultproperties
{
	DrawType=DT_SkeletalMesh
}