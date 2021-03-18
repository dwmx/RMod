//=============================================================================
// RuneCarcass.
//=============================================================================
class RuneCarcass extends Carcass;

var   ZoneInfo DeathZone;
var(Advanced) bool        bBurnable;			// RUNE: Can be set on fire
var int GibCount;
var name StabJoint; // RUNE:  For skewer death on pawns
var bool bWasPlayer;

function Initfor(actor Other)
{
	local int i;
	local actor A;

	bDecorative = false;
	if ( !bDecorative )
	{
		DeathZone = Region.Zone;
		DeathZone.NumCarcasses++;
	}

	Skeletal = Other.Skeletal;
	SkelMesh = Other.SkelMesh;
	SubstituteMesh = Other.SubstituteMesh; // RUNE:  substitute mesh code
	DrawScale		= Other.DrawScale;
	ScaleGlow		= Other.ScaleGlow;
	Fatness			= Other.Fatness;
	DesiredFatness	= Other.DesiredFatness;
	DesiredColorAdjust = Other.DesiredColorAdjust;

	AnimSequence	= Other.AnimSequence;
	AnimFrame		= Other.AnimFrame;
	AnimRate		= Other.AnimRate;
	TweenRate		= Other.TweenRate;
	AnimMinRate		= Other.AnimMinRate;
	AnimLast		= Other.AnimLast;
	bAnimLoop		= Other.bAnimLoop;
	SimAnim.X		= 10000 * AnimFrame;
	SimAnim.Y		= 5000 * AnimRate;
	SimAnim.Z		= 1000 * TweenRate;
	SimAnim.W		= 10000 * AnimLast;
	bAnimFinished	= Other.bAnimFinished;
	Velocity		= Other.Velocity;
	bMirrored		= Other.bMirrored;
	PrePivot		= Other.PrePivot;

	SetPhysics(Other.Physics);

	if (Pawn(Other)!=None)
	{
		GibCount		= Pawn(Other).GibCount;
		StabJoint		= Pawn(Other).StabJoint;
	}

	for (i=0; i<16; i++)
	{
		SkelGroupSkins[i] = Other.SkelGroupSkins[i];
		SkelGroupFlags[i] = Other.SkelGroupFlags[i];
	}

	// Transfer all attachments
	for (i=0; i<NumJoints(); i++)
	{
		if (Other.ActorAttachedTo(i) != None)
		{
			A = Other.DetachActorFromJoint(i);
			AttachActorToJoint(A, i);
		}
	}

//	for (i=0; i<NumJoints(); i++)
//	{
//		JointFlags[i] = Other.JointFlags[i];
//	}

	if (Pawn(Other)!=None && !Pawn(Other).bIsPlayer)
	{
		SetCollisionSize(Other.CollisionRadius, Other.CollisionHeight);
	}
	else
	{
		SetCollisionSize(Other.CollisionRadius, Other.CollisionHeight);
		bWasPlayer=true;
	}
}

function UpdateRotation()
{
	local rotator NewRotation;
	local vector X,Y,Z, result;
	local vector HitLoc, GroundNormal;
	local actor A;

	A = Trace(HitLoc, GroundNormal, Location-vect(0,0,100), Location, false);
	if (A!=None)
	{
		// Adjust rotation so corpse is aligned to ground
		GetAxes(Rotation, X,Y,Z);
		result = Y cross GroundNormal;

		//TODO: Change to desired rotation for smooth rotation

		NewRotation.Yaw = Rotation.Yaw;
		NewRotation.Pitch = rotator(result).Pitch;
		NewRotation.Roll = rotator(result cross GroundNormal).Pitch;

		SetRotation(NewRotation);
	}
}

// Called after death anim ends (on ground)
function UpdateCollisionCyllinder()
{
	local vector newloc;
	local float offset;

	if (!bWasPlayer)
		return;

	SetCollision(false, false, false);
	bCollideWorld = false;

	// Adjust so corpse is lying on ground
	offset = CollisionHeight - default.CollisionHeight;
	newloc = Location;
	newloc.Z -= offset;
	SetCollisionSize(CollisionRadius, default.CollisionHeight);
	SetLocation(newloc);
	PrePivot.Z += offset;

	UpdateRotation();

	SetCollision(true, false, false);	// Allow to clip through other corpses
	bCollideWorld = true;
}

function BaseChange()
{
	if((Base == None) && (Physics == PHYS_None))
		SetPhysics(PHYS_Falling);
}

function Destroyed()
{
	if ( !bDecorative )
		DeathZone.NumCarcasses--;
	Super.Destroyed();
}


function SetOnFire(Pawn EventInstigator, int joint)
{
	local PawnFire F;

	if (bBurnable)
	{
		if (ActorAttachedTo(joint) == None)
		{
			F = Spawn(class'PawnFire',EventInstigator);
			AttachActorToJoint(F, joint);
		}
	}
}


//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_FLESH;
}


function ApplyPainToJoint(int joint, vector momentum)
{
	if ((JointFlags[joint] & JOINT_FLAG_ACCELERATIVE) != 0)
	{
		//slog("moving"@GetJointName(joint));
		ApplyJointForce(joint, Momentum);
	}
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{	// Do spasm
//		ApplyPainToJoint(joint, Momentum);
	if (bDeleteMe)
		return true;

	Super(Actor).JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);	// this for fire
	return Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
}

function SpawnBodyGibs(vector momentum)
{
	local int i, NumSourceGroups;
	local debris Gib;
	local vector loc;
	local float scale;
	local int numchunks;

	if (class'GameInfo'.Default.bLowGore )
		return;

	// Find appropriate size of chunks
	scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (GibCount*500);
	scale = scale ** 0.3333333;

	for (NumSourceGroups=1; NumSourceGroups<16; NumSourceGroups++)
	{
		if (SkelGroupSkins[NumSourceGroups] == None)
			break;
	}

	numchunks = GibCount * Level.Game.DebrisPercentage;
	for (i = 0; i < numchunks; i++)
	{
		loc = VRand();
		loc.X *= CollisionRadius;
		loc.Y *= CollisionRadius;
		loc.Z *= CollisionHeight;
		loc += Location;

		Gib = spawn(class'DebrisFlesh',,, loc,);
		if (Gib != None)
		{
			Gib.SetSize(scale);
			Gib.SetMomentum(Momentum);
			if (FRand()<0.3)
				Gib.SetTexture(SkelGroupSkins[i%NumSourceGroups]);
		}
	}
}

function ChunkUp(int Damage)
{
	SpawnBodyGibs(Velocity);
	destroy();
}

//------------------------------------------------------------
//
// RemovedStabbedWeapon
//
//------------------------------------------------------------

function RemovedStabbedWeapon()
{
	local actor A;
	local int JointIndex;

	if(StabJoint == '')
		return;

	JointIndex = JointNamed(StabJoint);
	A = DetachActorFromJoint(JointIndex);

	if(A != None && A.IsA('Weapon'))
	{
		Weapon(A).RemoveStab(self, JointIndex);
		Weapon(A).StabbedActor = self;
	}
}

simulated function Debug(Canvas canvas, int mode)
{
	local int pitch, yaw, roll;

	Super.Debug(canvas, mode);

	Canvas.DrawText("RuneCarcass:");
	Canvas.CurY -= 8;

	Canvas.DrawText("  Base:"@Base);
	Canvas.CurY -= 8;

	Canvas.DrawText("  Rotation:     "@Rotation);
	Canvas.CurY -= 8;

	if (Base != None)
	{
		Canvas.DrawText("  Base Rotation:"@Base.Rotation);
		Canvas.CurY -= 8;
	}

	Canvas.DrawText("  RotationRate: P="$RotationRate.pitch$" Y="$RotationRate.yaw$" R="$RotationRate.roll);
	Canvas.CurY -= 8;

	Canvas.DrawText("  DesiredRotation: P="$desiredrotation.pitch$" Y="$desiredrotation.yaw$" R="$desiredrotation.roll);
	Canvas.CurY -= 8;

	Canvas.DrawText("  bRotateToDesired: "$bRotateToDesired);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bFixedRotationDir: "$bFixedRotationDir);
	Canvas.CurY -= 8;		
}

defaultproperties
{
     bBurnable=True
     Physics=PHYS_None
     DrawType=DT_SkeletalMesh
     LODPercentMax=0.600000
     LODCurve=LOD_CURVE_AGGRESSIVE
     bSweepable=True
}
