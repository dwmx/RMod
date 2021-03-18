/////////////////////////////////////////////////////////////////////////////////
//	R_RigidBall
//	Crude implementation of a rigid-body ball Actor.
//
//	Important notes:
//
//	- 	Physics must be set to PHYS_Projectile and acceleration must be
//		calculated manually each tick in order to minimize fighting with engine.
//
//	-	In order to roll smoothly, the ball caches surface normals each time
//		it comes in contact with something. Each tick, the ball traces to see
//		whether or not the normals are still touching and prunes them if not.
//
//	-	If velocity is pointed any amount inward towards a contacting surface,
//		the ball will come to a complete stop. To counteract this, the ball
//		traces it's trajectory path before performing physics, and modifies
//		velocity as necessary.
//
//	-	The ball uses only CollisionRadius in physics calculations, but it's
//		important that CollisionHeight also match for the ball to behave.
class R_RigidBall extends Actor;

var class<R_AUtilities> UtilitiesClass;

struct FOrientation
{
	var Vector X, Y, Z;
};
var FOrientation ReferenceOrientation;
var Vector AngularVelocity;

const MAX_CONTACT_SURFACE_NORMALS = 2;
var Vector ContactNormals[2];
var int ContactNormalCount;

const CONTACT_SURFACE_NORMAL_COINCIDENCE = 0.995;
const CONTACT_SURFACE_SEPARATION_EPSILON = 8.0;

var float Restitution;

// For debug drawing purposes
var Vector LastImpulseVector;
var Vector LastImpulseContactNormal;

struct FCalcAccelerationResult
{
	var Vector Translational;
	var Vector Angular;
};

// Networking
var Vector RealLocation;
var Vector RealVelocity;
var Vector RealAngularVelocity;

replication
{
	unreliable if(Role == ROLE_Authority && !bNetOwner)
		RealLocation,
		RealVelocity,
		RealAngularVelocity;
}

simulated event Spawned()
{
	Super.PostBeginPlay();
	SetPhysics(PHYS_Projectile);
}

simulated event Tick(float DeltaSeconds)
{
	TickOrientation(DeltaSeconds);
	TickPhysics(DeltaSeconds);
}

/////////////////////////////////////////////////////////////////////////////////
//  TickOrientation
//	Update the ball's orientation, to be called once per tick.
//	First, orient the ball into its reference frame.
//	Second, rotate that entire reference frame about the angular velocity vector.
//	Third, update the Actor's rotation using this new orientation.
//	Fourth, save the new orientation as the ball's current reference.
simulated function TickOrientation(float DeltaSeconds)
{
	local float AngularDisplacement;
	local Rotator AngularVelocityRotator;
	local FOrientation CurrentOrientation;
	
	AngularDisplacement = VSize(AngularVelocity) * DeltaSeconds;
	AxisAngleToOrientation(
        AngularVelocity,
        AngularDisplacement,
        CurrentOrientation);
		
	AngularVelocityRotator = OrthoRotation(
		CurrentOrientation.X,
		CurrentOrientation.Y,
		CurrentOrientation.Z);
	
	CurrentOrientation.X = ReferenceOrientation.X >> AngularVelocityRotator;
    CurrentOrientation.Y = ReferenceOrientation.Y >> AngularVelocityRotator;
    CurrentOrientation.Z = ReferenceOrientation.Z >> AngularVelocityRotator;
	
	SetRotation(OrthoRotation(
		CurrentOrientation.X,
		CurrentOrientation.Y,
		CurrentOrientation.Z));
	
	GetAxes(
		Rotation,
		ReferenceOrientation.X,
		ReferenceOrientation.Y,
		ReferenceOrientation.Z);
}

/////////////////////////////////////////////////////////////////////////////////
//	TickPhysics
simulated function TickPhysics(float DeltaSeconds)
{
	local FCalcAccelerationResult CalcAccelerationResult;
	
	CalcAccelerationResult = CalcAcceleration();
	Acceleration = CalcAccelerationResult.Translational;
	AngularVelocity =
		AngularVelocity + (CalcAccelerationResult.Angular * DeltaSeconds);
	TravelSurfaceNormalVelocity(DeltaSeconds);
	PruneContactNormals();
	
	if(Role == ROLE_Authority)
	{
		RealLocation = Location;
		RealVelocity = Velocity;
		RealAngularVelocity = AngularVelocity;
	}
	else
	{
		if(RealLocation != Vect(0.0, 0.0, 0.0))
		{
			SetLocation(RealLocation);
			RealLocation = Vect(0.0, 0.0, 0.0);
		}
		if(RealVelocity != Vect(0.0, 0.0, 0.0))
		{
			Velocity = RealVelocity;
			RealVelocity = Vect(0.0, 0.0, 0.0);
		}
		if(RealAngularVelocity != Vect(0.0, 0.0, 0.0))
		{
			AngularVelocity = RealAngularVelocity;
			RealAngularVelocity = Vect(0.0, 0.0, 0.0);
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////
//  AxisAngleToOrientation
//  Generate basis vectors from an axis-angle representation.
simulated function AxisAngleToOrientation(
    Vector Axis, float Radians,
    out FOrientation Orientation)
{
    local float c, s, t;

    Axis = Normal(Axis);
    c = Cos(Radians);
    s = Sin(Radians);
    t = 1.0 - c;

    Orientation.X.X = t * Axis.X * Axis.X + c;
	Orientation.X.Y = t * Axis.X * Axis.Y - Axis.Z * s;
	Orientation.X.Z = t * Axis.X * Axis.Z + Axis.Y * s;

    Orientation.Y.X = t * Axis.X * Axis.Y + Axis.Z * s;
    Orientation.Y.Y = t * Axis.Y * Axis.Y + c;
    Orientation.Y.Z = t * Axis.Y * Axis.Z - Axis.X * s;

	Orientation.Z.X = t * Axis.X * Axis.Z - Axis.Y * s;
	Orientation.Z.Y = t * Axis.Y * Axis.Z + Axis.X * s;
    Orientation.Z.Z = t * Axis.Z * Axis.Z + c;
}

////////////////////////////////////////////////////////////////////////////////
//	CalcAcceleration
//	Calculates the translational and angular acceleration of the ball for the
//	next call to Tick.
simulated function FCalcAccelerationResult CalcAcceleration()
{
	local Vector NewAcceleration;
	local Vector NewAccelerationCoincident;
	local Vector NewAngularAcceleration;
	local Vector ContactNormal;
	local Vector ContactVelocity;
	local Vector Friction;
	local FCalcAccelerationResult Result;
	
	// Accumulate forces
	NewAngularAcceleration = Vect(0.0, 0.0, 0.0);
	NewAcceleration = Vect(0.0, 0.0, 0.0);
	NewAcceleration += Region.Zone.ZoneGravity;
	
	// Calculate the contact normal based on touching surfaces
	if(ContactNormalCount == 1)
	{
		ContactNormal = ContactNormals[0];
	}
	else if(ContactNormalCount == 2)
	{
		ContactNormal = ContactNormals[0] + ContactNormals[1] * 0.5;
		ContactNormal = Normal(ContactNormal);
	}
	else
	{
		ContactNormal = Vect(0.0, 0.0, 0.0);
	}
	
	// Calculate friction
	if(ContactNormal == Vect(0.0, 0.0, 0.0)
	|| ContactNormal Dot NewAcceleration >= 0.0)
	{
		Friction = Vect(0.0, 0.0, 0.0);
	}
	else
	{
		NewAccelerationCoincident =
			ContactNormal * (ContactNormal Dot NewAcceleration);
		NewAcceleration = NewAcceleration - NewAccelerationCoincident;
		ContactVelocity = CalcVelocityAtContactNormal(ContactNormal);
		
		// Account for momentum
		Friction = ContactVelocity -
			(ContactNormal * (ContactNormal Dot ContactVelocity));
		Friction = Normal(Friction) * -1.0 * VSize(ContactVelocity);
		Friction = Friction * Region.Zone.ZoneGroundFriction;

		// Account for acceleration
		Friction = Friction + -1.0 * NewAcceleration;

		NewAcceleration += Friction;
		NewAngularAcceleration = Normal(ContactNormal Cross Friction);
		NewAngularAcceleration *= (VSize(Friction) / (CollisionRadius));
		
		// Slow the ball down over time
		if(VSize(AngularVelocity) > 0.0)
		{
			NewAngularAcceleration += -1.0 * Normal(AngularVelocity) *
				Sqrt(Region.Zone.ZoneGroundFriction);
		}
	}
	
	Result.Translational = NewAcceleration;
	Result.Angular = NewAngularAcceleration;
	return Result;
}

////////////////////////////////////////////////////////////////////////////////
//	CalcVelocityAtContactNormal
//	Returns the total linear velocity of the point on the ball that would be
//	in contact with the specific ContactNormal.
simulated function Vector CalcVelocityAtContactNormal(Vector ContactNormal)
{
	local Vector Axis;
	local Vector Result;
	
	if(ContactNormal == Vect(0.0, 0.0, 0.0))
	{
		Result = Velocity;
	}
	else
	{
		Axis = Normal(AngularVelocity);
		Result = Axis Cross ContactNormal;
		Result = Result * CollisionRadius *
			(1.0 - (ContactNormal Dot Axis)) * VSize(AngularVelocity);
		Result = Result + Velocity;
	}
	
	return Result;
}

////////////////////////////////////////////////////////////////////////////////
// 	TravelSurfaceNormalVelocity
//	Traces the ball extents forward according to velocity and cancels out any
// 	velocity parallel to contact normals. This fixes the ball from becoming
//	stuck when it hits angled surfaces.
//
// 	TODO: This solution works at normal speed, but not at slow motion, because
// 	the calculated end trace isn't accurate to the engine's integration.
simulated function TravelSurfaceNormalVelocity(float DeltaSeconds)
{
	local float Magnitude;
	local Vector TraceHit, TraceNormal, TraceEnd, TraceStart, TraceExtent;
	
	if(ContactNormalCount == 0)
	{
		return;
	}
	
	TraceStart = Location;
	TraceEnd = TraceStart + (Velocity * DeltaSeconds);
	TraceExtent.X = CollisionRadius;
	TraceExtent.Y = CollisionRadius;
	TraceExtent.Z = CollisionHeight;
	
	if(Trace(TraceHit, TraceNormal, TraceEnd, TraceStart,, TraceExtent) != None)
	{
		Magnitude = VSize(Velocity);
		Velocity = Velocity - (TraceNormal * (TraceNormal Dot Velocity));
		Velocity = Normal(Velocity) * Magnitude;
	}
}

////////////////////////////////////////////////////////////////////////////////
//	ApplyImpulse
//	Apply an instantaneous change in velocity to the ball. If ContactNormal
//	is provided, then any portion of the velocity that is tangential to the
//	ball will generate rotational velocity.
simulated function ApplyImpulse(Vector Impulse, optional Vector ContactNormal)
{
	local Vector ImpulseCoincident;
	local Vector ImpulsePerp;
	local Vector ImpulseAxis;
	local float FrictionCoeff;
	
	ContactNormalCount = 0;
	
	LastImpulseVector = Impulse;
	LastImpulseContactNormal = ContactNormal;
	
	if(ContactNormal == Vect(0.0, 0.0, 0.0))
	{
		Velocity += Impulse;
	}
	else
	{
		ImpulseCoincident = ContactNormal * (Impulse Dot ContactNormal);
		ImpulsePerp = Impulse - ImpulseCoincident;
		ImpulseAxis = Normal(ContactNormal Cross ImpulsePerp);
		
		FrictionCoeff = FMin(1.0, Region.Zone.ZoneGroundFriction / 16.0);
		
		Velocity += ImpulseCoincident + (ImpulsePerp * FrictionCoeff);
		
		AngularVelocity +=  ImpulseAxis *
			(VSize(ImpulsePerp * (1.0 - FrictionCoeff)) / CollisionRadius);
	}
}

////////////////////////////////////////////////////////////////////////////////
//	ContactSurface
//	Resolves ball collisions with any contacted surface. If the ball needs to
//	bounce, an impulse is generated. If the ball needs to roll or come to rest,
//	then the ContactNormal will be cached.
simulated event HitWall(Vector HitNormal, Actor HitActor)
{ ContactSurface(HitNormal, HitActor); }

simulated event Landed(Vector HitNormal, Actor HitActor)
{ ContactSurface(HitNormal, HitActor); }

// Determines whether the ball will bounce or roll
simulated function ContactSurface(Vector ContactNormal, Actor ContactActor)
{
	local Vector ContactVelocity;
	local Vector ImpulseCoincident, ImpulsePerp;
	
	if(CheckContainsContactNormal(ContactNormal))
	{
		return;
	}
	
	ContactVelocity = CalcVelocityAtContactNormal(ContactNormal);
	
	// If velocity is mostly parallel, then roll
	if(Normal(ContactVelocity) Dot ContactNormal >= 0.707)
	{
		PushContactNormal(ContactNormal); // Roll
	}
	else
	{
		ImpulseCoincident = ContactNormal * (ContactNormal Dot ContactVelocity);
		if(VSize(ImpulseCoincident) >= 128.0) // Velocity required to break roll
		{
			ImpulsePerp = (ContactVelocity - ImpulseCoincident) * -1.0;
			ImpulseCoincident = -1.0 * ImpulseCoincident;
			ImpulseCoincident += ImpulseCoincident * Restitution;
			ApplyImpulse(ImpulsePerp + ImpulseCoincident, ContactNormal);
		}
		else
		{
			PushContactNormal(ContactNormal); // Come to rest
		}
	}
}

simulated function PushContactNormal(Vector ContactNormal)
{
	local int i;
	
	if(ContactNormalCount == MAX_CONTACT_SURFACE_NORMALS
	|| CheckContainsContactNormal(ContactNormal))
	{
		return;
	}
	
	// Push the new normal
	ContactNormals[ContactNormalCount] = ContactNormal;
	++ContactNormalCount;
}

simulated function bool CheckContainsContactNormal(Vector ContactNormal)
{
	local int i;
	
	for(i = 0; i < ContactNormalCount; ++i)
	{
		if(ContactNormals[i] Dot ContactNormal
		>= CONTACT_SURFACE_NORMAL_COINCIDENCE)
		{
			return true;
		}
	}
	return false;
}

////////////////////////////////////////////////////////////////////////////////
//	PruneContactNormals
//	Trace to each cached ContactNormal to see if it is still in contact with
//	the ball. If not, remove it and update the array. Called each Tick.
simulated function PruneContactNormals()
{
	local int OriginalCount;
	local int i, j;

	OriginalCount = ContactNormalCount;
	j = 0;
	for(i = 0; i < OriginalCount; ++i)
	{
		if(!CheckPruneContactNormal(ContactNormals[i]))
		{
			continue;
		}
		ContactNormals[j] = ContactNormals[i];
		++j;
	}
	ContactNormalCount = j;
}

simulated function bool CheckPruneContactNormal(Vector ContactNormal)
{
	local Vector TraceHit, TraceNormal, TraceEnd, TraceStart, TraceExtent;
	
	if(ContactNormal == Vect(0.0, 0.0, 0.0))
	{
		return false;
	}
	
	// If accelerating or moving away from the surface, prune
	if(Acceleration Dot ContactNormal >= 0.001
	|| Velocity Dot ContactNormal >= 0.001)
	{
		return false;
	}
	
	TraceStart = Location;
	TraceEnd = TraceStart + -1.0 * ContactNormal *
		CONTACT_SURFACE_SEPARATION_EPSILON;
	TraceExtent.X = CollisionRadius;
	TraceExtent.Y = CollisionRadius;
	TraceExtent.Z = CollisionHeight;
	
	if(Trace(TraceHit, TraceNormal, TraceEnd, TraceStart,, TraceExtent) != None)
	{
		return TraceNormal Dot ContactNormal >=
			CONTACT_SURFACE_NORMAL_COINCIDENCE;
	}
}

////////////////////////////////////////////////////////////////////////////////
//	Debug
event Debug(Canvas C, int Mode)
{
	local int i;
	
	Super.Debug(C, Mode);
	
	C.DrawText("R_RigidBall:");
	C.CurY -= 8;
	
	Super.Debug(C, Mode);
	
	C.CurX += 12;
	
	C.DrawText("ContactNormals:");
	C.CurY -= 8;
	
	for(i = 0; i < ContactNormalCount; ++i)
	{
		C.DrawText("    [" $ i $ "]: " $ ContactNormals[i]);
		C.CurY -= 8;
	}
	
	C.DrawText("AngularVelocity:" @ AngularVelocity);
	C.CurY -= 8;
	C.DrawText("AngularSpeed:" @ VSize(AngularVelocity) @ "radians/sec");
	C.CurY -= 8;
	
	C.CurX -= 12;
	
	Debug_DrawRotationAxis(C, Mode);
	Debug_DrawContactNormals(C, Mode);
	Debug_DrawVelocityVectors(C, Mode);
	Debug_DrawImpulseVector(C, Mode);
}

function Debug_DrawRotationAxis(Canvas C, int Mode)
{
	local Vector Axis, LineStart, LineEnd;
	
	// Draw rotation axis
	Axis = Normal(AngularVelocity);
	LineStart = Location - Axis * CollisionRadius * 2.0;
	LineEnd = Location + Axis * CollisionRadius * 2.0;
	C.DrawLine3D(LineStart, LineEnd, 0.0, 0.5, 1.0);
}

function Debug_DrawContactNormals(Canvas C, int Mode)
{
	local int i;
	local Vector LineStart, LineEnd;
	local Vector CalcVelocity;
	
	for(i = 0; i < ContactNormalCount; ++i)
	{
		LineStart = Location;
		LineEnd = LineStart + ContactNormals[i] * CollisionRadius * 3.0;
		C.DrawLine3D(LineStart, LineEnd, 1.0, 1.0, 0.0);
	}
}

function Debug_DrawVelocityVectors(Canvas C, int Mode)
{
	local Vector Normals[6];
	local Vector CalcVelocity;
	local Vector LineStart, LineEnd;
	local int i;
	
	Normals[0] = Vect(1.0, 0.0, 0.0);
	Normals[1] = Vect(-1.0, 0.0, 0.0);
	Normals[2] = Vect(0.0, 1.0, 0.0);
	Normals[3] = Vect(0.0, -1.0, 0.0);
	Normals[4] = Vect(0.0, 0.0, 1.0);
	Normals[5] = Vect(0.0, 0.0, -1.0);

	for(i = 0; i < 6; ++i)
	{
		CalcVelocity = CalcVelocityAtContactNormal(Normals[i]);
		LineStart = Location + Normals[i] * (CollisionRadius + 2.0) * -1.0;
		LineEnd = LineStart + Normal(CalcVelocity) *
			FMin(CollisionRadius * 4.0, VSize(CalcVelocity));
		C.DrawLine3D(LineStart, LineEnd, 1.0, 0.0, 0.0);
	}
}

function Debug_DrawImpulseVector(Canvas C, int Mode)
{
	local Vector LineStart, LineEnd;
	
	if(LastImpulseVector == Vect(0.0, 0.0, 0.0))
	{
		return;
	}
	
	if(LastImpulseContactNormal == Vect(0.0, 0.0, 0.0))
	{
		LineStart = Location;
	}
	else
	{
		LineStart = Location + (-1.0 * LastImpulseContactNormal * (CollisionRadius + 4));
	}
	LineEnd = LineStart + Normal(LastImpulseVector) * CollisionRadius * 2.0;
	
	C.DrawLine3D(LineStart, LineEnd, 0.0, 1.0, 0.0);
}

defaultproperties
{
     UtilitiesClass=Class'RMod.R_AUtilities'
     Restitution=0.800000
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_SkeletalMesh
     bCollideWhenPlacing=True
     CollisionRadius=32.000000
     CollisionHeight=32.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bSweepable=True
     bBounce=True
     Mass=5.000000
}
