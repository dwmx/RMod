//=============================================================================
// TreePoint.
//=============================================================================
class TreePoint extends Accelerator
	native;

var() bool bHooker;					// Whether this point "hooks" actors
var() bool bRestrictVelocity;		// Restrict TreePoint velocity to MaxVelocityAllowed
var() bool bAffectsParent;			// If children affect parent velocity
var() bool bDrawRope;				// Draw our fake rope between this and child
var() float MaxVelocityAllowed;		// Creates cone centered at DesiredRotation
var() float GravAccel;				// Acceleration magnitude of gravitation
var() float DampFactor;				// Dampening Factor [0..1] (1=infinite damp)
var() name ParentTag;				// Tag of this TreePoint's parent
var() bool bApplyAcceleration;		// Apply local gravitation force
var() bool bStiffRotation;			// Rotation stays perfectly synced with parent
var() bool bSpring;
var() float SpringConstant;

var() bool bApplySway;				// Get rid of these, use controller class to sway
var() vector SwayDir;
var() float SwayMagnitude;

var(Sounds)	sound WhileMoving;		
var(Sounds) sound HitAWall;

var TreePoint Parent;
var bool bLeaf;						// This is last TreePoint in chain
var private vector GravDir;			// Direction of gravitation
var float BranchLength;				// Distance to parent TreePoint
var actor Attraction;				// Actor attracted to
var actor BeamActor;				// Beam actor for drawing

const MaximumVelocityPickup = 500;	// Maximum velocity transfer allowed from collision

// To be implimented
var actor hooked;					// Actor hooked to point
var rotator hookOrientation;		// Orientation of Hooked actors


native(654) final function TreePointTick(float DeltaSeconds);


// Public interface members
// --------------------------------------------------------

function SetGravDir(vector dir)
{
	GravDir = Normal(dir);
}

function SetBranchLength(float len)
{
	BranchLength = len;
	UpdateBeam();
}

function SetAttraction(actor Other)
{
	Attraction = None;
}

function SetDrawRope(bool on)
{
	if (on)
	{
		if (BeamActor == None)
			Spawn(class'Beam',,,Location,);
		UpdateBeam();
		bDrawRope = true;
	}
	else
	{
		if (BeamActor != None)
			BeamActor.Destroy();
		bDrawRope = false;
	}
}

function SpawnChild()
{
}


// Private members
// --------------------------------------------------------


function PreBeginPlay()
{
	// Validate user set variables
	SetPhysics(PHYS_PROJECTILE);	// Don't force this, may want gravity
	bLeaf = true;					// Nodes are leaves until proven otherwise
	Parent = None;
	BeamActor = None;
	Attraction = None;
	DampFactor = FClamp(DampFactor, -1.0, 1.0);
}


function PostBeginPlay()
{
	local TreePoint PotentialParent;

	if (ParentTag == '')
	{	// Root
		SetPhysics(PHYS_NONE);
	}
	else
	{	// Fill in 'Parent' based on 'ParentTag'
		foreach AllActors(class'TreePoint', PotentialParent, ParentTag)
		{
			// Notice: If more than one matches ParentTag, the last is used
			Parent = PotentialParent;
			PotentialParent.bLeaf = false;

			// Pre-calc variables
			GravDir = Location - PotentialParent.Location;
			BranchLength = VSize(GravDir);
			Gravdir = Normal(GravDir);
		}
		
		SetDrawRope(bDrawRope);
	}
	
	if (Skeletal != None)
	{
		LoopAnim('run', 1.0, 0.0);
	}
}

function ElasticCollision(actor a1, actor a2)
{
	local float m1,m2,mt;
	local vector v1,v2;
	
	m1 = a1.Mass;
	m2 = a2.Mass;
	mt = m1+m2;
	v1 = a1.Velocity;
	v2 = a2.Velocity;
	a1.Velocity = (m1*v1 + 2*m2*v2 - m2*v1) / mt;
	a2.Velocity = (m2*v2 + 2*m1*v1 - m1*v2 ) / mt;
}

function HitWall(vector HitNormal, actor HitWall)
{
	PlaySound(HitAWall, , 1.0);
}

function Touch(actor Other)
{
	// Note:
	//	When objects are internally in order such that this touch gets called
	//	after the swing calculations, velocity can be transfered continually,
	//	moving the TreePoint out of it's orbit.  Maybe Touch/UnTouch are not
	//	behaving as expected.  Perhaps moving this swing logic to the physics
	//	subsystem would cure this ordering problem.

	// Non-blocking velocity transfer
	if (!Other.IsA('TreePoint'))
	{
		Velocity += Normal(Other.Velocity) * Min(VSize(Other.Velocity), MaximumVelocityPickup);
		Disable('Touch');
		WakeUp();
	}
	return;

	// Rigid body elastic collision
	ElasticCollision(Other, self);
	Disable('Touch');
	WakeUp();
}

function UnTouch(actor Other)
{
	Enable('Touch');
}

function UpdateBeam()
{
	if (BeamActor != None)
	{
		Beam(BeamActor).SetEndPoints(Location, Parent.Location);
	}
}

// r1 = parent,  r2 = child
function ApplySwing(TreePoint r1, TreePoint r2, float DeltaTime)
{
	local vector RopeVector, VelocityLookahead, RopeDir, NewLocation,NewVelocity;
	local float velmag;
	local rotator rot;
	local float stretchAmount;
	local vector SpringAccel;
	local vector loc1, loc2;
		
	if ((r1 == None)||(r2 == None))
		return;

	loc1 = r1.Location;
	loc2 = r2.Location;
	
	// Apply Acceleration
	if (r2.bApplyAcceleration)
		r2.Velocity += r2.GravDir*(r2.GravAccel*DeltaTime);

	// Apply sway
	if (r2.bApplySway && (FRand() < 0.1))
		r2.Velocity += Normal(r2.SwayDir) * FRand() * SwayMagnitude * DeltaTime;

	// Apply velocity on child TreePoint
	VelocityLookahead = Loc2 + (r2.Velocity * DeltaTime);
	RopeDir = Normal(Loc1 - VelocityLookahead);

	// Find Next child Location
	if (r2.bSpring)
	{	// Apply spring acceleration
		RopeVector = Loc1 - Loc2;
		stretchAmount = VSize(RopeVector) - r2.BranchLength;
		SpringAccel = Normal(RopeVector) * (r2.SpringConstant * stretchAmount / r2.Mass);
		NewLocation = VelocityLookahead + SpringAccel * (DeltaTime * DeltaTime);
	}
	else
	{
		RopeVector = RopeDir * r2.BranchLength;
		NewLocation = Loc1 - RopeVector;
	}
	
	NewVelocity = NewLocation - Loc2;
	if (r2.bRestrictVelocity)
	{
		velmag = VSize(NewVelocity);
		if (velmag > r2.MaxVelocityAllowed)
		{
			NewVelocity = Normal(NewVelocity) * r2.MaxVelocityAllowed;
		}
	}
	r2.Velocity = NewVelocity *(1.0-r2.DampFactor)/ DeltaTime;

	// Set child's rotation
	if (bStiffRotation)
		rot = rotator(-RopeVector);				// Predicted location
	else
		rot = rotator(Loc2-Loc1);	// Last location (lagged)
	rot.Roll = rot.Yaw;
	r2.SetRotation(rot);
	
//*** This needs to be moved to C side ***
	if (r1.Parent == None)						// Set root rotation too
		r1.SetRotation(rot);

	// Apply velocity on parent TreePoint
	if (r2.bAffectsParent)
	{
		r1.Velocity = (r1.Velocity + (r2.Velocity * 0.5)) * 0.5;
	}

	// Play WhileMoving Sound
	if (VSize(r2.Velocity) > 1.0)
		PlaySound(r2.WhileMoving, , 1.0);
}


function WakeSelfAndParents()
{
	if (Parent != None)
	{
		GotoState('Active');
		Parent.WakeSelfAndParents();
	}
}
	
function WakeSelfAndChildren()
{
	local TreePoint point;
	
	// Wake myself if not the root
	if (Parent != None)
		GotoState('Active');
		foreach AllActors(class'TreePoint', point)
	{
		if (point.Parent == self)
			point.WakeSelfAndChildren();
	}
}

function WakeUp()
{
	WakeSelfAndParents();
	WakeSelfAndChildren();
}

state Inactive
{
	ignores Tick;

	function BeginState()
	{
		SetPhysics(PHYS_NONE);
	}
}


auto state Active
{
	function Tick(float DeltaTime)
	{
		local TreePoint point;

		UpdateBeam();
		
		if (bLeaf)
		{
//			TreePointTick(DeltaTime);
//			
			point = self;
			while (point != None)
			{
				ApplySwing(point.Parent, point, DeltaTime);
				point = point.Parent;
			}
//
		}
		
		if (VSize(Velocity) < 0.1)
		{
			Velocity = vect(0,0,0);
			GotoState('Inactive');
		}
	}
	
	function BeginState()
	{
		SetPhysics(PHYS_PROJECTILE);
	}
}

defaultproperties
{
     bAffectsParent=True
     bDrawRope=True
     GravAccel=950.000000
     DampFactor=0.010000
     bApplyAcceleration=True
     Physics=PHYS_Projectile
     CollisionRadius=20.000000
     CollisionHeight=30.000000
     bCollideActors=True
     bCollideWorld=True
}
