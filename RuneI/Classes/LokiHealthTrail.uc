//=============================================================================
// LokiHealthTrail.
//=============================================================================
class LokiHealthTrail expands Effects;

var() class<WeaponSwipe> SwipeClass;
var WeaponSwipe Swipe;
var float time;
var float amplitude;

function PreBeginPlay()
{
	local actor Spark;
	local actor Part;
	
	Super.PreBeginPlay();

	time = 0;
	
	Swipe = Spawn(SwipeClass, self,, Location,);
	Swipe.BaseJointIndex = 0;
	Swipe.OffsetJointIndex = 1;
	Swipe.SystemLifeSpan = -1;
	Swipe.SwipeSpeed = 2;
	
	AttachActorToJoint(Swipe, 1);

	Part = Spawn(class'LokiHealthSystem', self);
	AttachActorToJoint(Part, 0);

	SetPhysics(PHYS_None);
	Enable('Tick');
}

simulated function Tick(float DeltaTime)
{	
	local vector loc;
	local float xRate, yRate;

	time += DeltaTime;

	xRate = cos(time * Velocity.X) * amplitude;
	yRate = sin(time * Velocity.X) * amplitude;

	loc.X = Owner.Location.X + xRate;
	loc.Y = Owner.Location.Y + yRate;
	loc.Z = Location.Z + DeltaTime * Velocity.Z;
		
	SetLocation(loc);
}

defaultproperties
{
     SwipeClass=Class'RuneI.WeaponSwipeGreen'
     DrawType=DT_SkeletalMesh
     Skeletal=SkelModel'weapons.InvisibleShort'
}
