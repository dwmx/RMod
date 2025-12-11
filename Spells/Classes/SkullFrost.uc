class SkullFrost extends Actor;

var Actor Eyes;
var Actor GroundFireEffect;
var Actor GroundDustEffect;
var Actor TrailEffect;
var Actor SkullParticles;

var Sound SpawnSound;
var float DebrisTimeAccumulator;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	Eyes = Spawn(Class'RuneI.SarkEyeRagnar', Self);
	Eyes.DrawScale = 0.6;
	AttachActorToJoint(Eyes, JointNamed('base'));

	GroundFireEffect = Spawn(Class'Spells.GroundDustEffect', Self,, Self.Location, Self.Rotation);
	GroundDustEffect = Spawn(Class'Spells.GroundDustEffectTwo', Self,, Self.Location, Self.Rotation);

	TrailEffect = Spawn(Class'Spells.SkullTrailEffect', Self,, Self.Location, Self.Rotation);
	SkullTrailEffect(TrailEffect).BaseJointIndex = 0;
	SkullTrailEffect(TrailEffect).OffsetJointIndex = 1;

	SkullParticles = Spawn(Class'Spells.SkullParticles', Self);
	AttachActorToJoint(SkullParticles, JointNamed('base'));
}

event Spawned()
{
	local Texture IceTexture;

	super.Spawned();

	SpawnSound = Sound(DynamicLoadObject("CreaturesSnd.torturefar01", Class'Sound'));
	PlaySound(SpawnSound);
	DebrisTimeAccumulator = 0.0;

	IceTexture = Texture(DynamicLoadObject("Snowice.Ice5", Class'Texture'));
	SkelGroupSkins[0] = IceTexture;
	SkelGroupSkins[1] = IceTexture;
}

/*
event Tick(float DeltaSeconds)
{
	local Vector FloorLocation, FloorNormal;
	local float FloorAlpha;
	local Rotator NewRotation;

	FloorAlpha = FloorTrace(FloorLocation, FloorNormal);
	GroundFireEffect.SetLocation(FloorLocation);

	NewRotation = Rotation;
	NewRotation.Pitch = 16000 * 0.15;
	//SetRotation(NewRotation);

	//Velocity += Region.Zone.ZoneGravity * DeltaSeconds;
	Velocity = Vector(Rotation) * 256.0;
	
	SetLocation(Location + Velocity * DeltaSeconds);
}
	*/

event Tick(float DeltaSeconds)
{
	local Vector FloorLocation, FloorNormal;
	local float FloorAlpha;
	local Rotator NewRotation;
	local float TargetAlpha;
	local float SpringK;   // spring stiffness: tune to taste
	local float DampingC;   // damping: tune to prevent bouncing
	local float Error;
	local float SpringForce;
	local float DampingForce;
	local float VerticalForce;
	local float Speed;

	TargetAlpha = 0.9;
	SpringK = 6000.0;
	DampingC = 3.0;

	FloorAlpha = FloorTrace(FloorLocation, FloorNormal);
	GroundFireEffect.SetLocation(FloorLocation);
	GroundDustEffect.SetLocation(FloorLocation);

	NewRotation = Rotation;
	NewRotation.Pitch = 16000 * 0.15;
	//SetRotation(NewRotation);

	// Hover control:
	// Error is positive if we're too high (alpha < target)
	Error = (FloorAlpha - TargetAlpha);
	Log(FloorAlpha);

	// Spring tries to push alpha toward target
	SpringForce = SpringK * Error;

	// Damping based on current vertical vel (against bouncing)
	DampingForce = -DampingC * Velocity.Z;

	VerticalForce = SpringForce + DampingForce;

	Velocity.Z += VerticalForce * DeltaSeconds;

	// Optional minimal gravity to prevent floating forever
	// Velocity.Z += (Region.Zone.ZoneGravity.Z * 0.2) * DeltaSeconds;

	// Maintain horizontal behavior you had:
	Speed = 400.0;
	Velocity.X = (Vector(Rotation) * Speed).X;
	Velocity.Y = (Vector(Rotation) * Speed).Y;

	SetLocation(Location + Velocity * DeltaSeconds);

	DebrisTimeAccumulator += DeltaSeconds;
	if(DebrisTimeAccumulator >= 0.1 && FRand() > 0.3)
	{
		DebrisTimeAccumulator = 0.0;
		Spawn(Class'RuneI.DebrisWood',,, FloorLocation);
	}
}


function float FloorTrace(out Vector OutFloor, out Vector OutNormal)
{
	local Vector TraceStart, TraceEnd;
	local Vector HitLocation, HitNormal;
	local float Length;

	TraceStart = Self.Location;
	TraceEnd = Self.Location + Vect(0,0,-1) * 256.0;

	Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false);
	OutFloor = HitLocation;
	OutNormal = HitNormal;

	Length = VSize(HitLocation - Self.Location);
	return FClamp(1.0 - (Length / 256.0), 0.0, 1.0);
}

defaultproperties
{
	DrawType=DT_SkeletalMesh
	Skeletal=SkelModel'objects.Skull'
	DrawScale=6.0
	Style=STY_Translucent
	ScaleGlow=10.0
	SpawnSound=Sound'CreaturesSnd.torturefar01'
}