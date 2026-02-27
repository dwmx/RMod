//==============================================================================
//	R_ArpgPawn
//	Base Pawn class for RArpg
//==============================================================================
class R_ArpgPawn extends PlayerPawn abstract;

const CanvasLib = Class'RBase.R_ACanvasLibrary';
const ArpgLib = Class'RArpgCore.R_ArpgLibrary';

var private Class<R_ArpgAnimationSet> AnimationSetDefaultClass;
var private R_ArpgAnimationSet AnimationSet;

var private Vector MovementInput;
var private Vector LookDirection;

var private R_ArpgSkill Skills[8];

var private float Experience;
var private int Level;

var private bool bLockDirection;

var private bool bBlockMovementInput;

var private bool bShouldDrawHealth;

var Class<R_ArpgTraceProxy> TraceProxyClass;

replication
{
	reliable if(Role == ROLE_Authority && bNetOwner)
		Skills;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	Spawn(TraceProxyClass, Self);
}

function R_ArpgItemContainerSet GetInventorySet()
{
	return None;
}

function SetBlockMovementInput(bool bNewBlockMovementInput)
{
	bBlockMovementInput = bNewBlockMovementInput;
}

function IncrementExperience(float Amount)
{
	SetExperience(Experience + Amount);
}

function SetExperience(float NewExperience)
{
	Experience = NewExperience;
}

function float GetExperience()
{
	return Experience;
}

function AddSkill(Class<R_ArpgSkill> SkillClass)
{
	local R_ArpgSkill Skill;
	local int i;
	
	for(i = 0; i < ArrayCount(Skills); ++i)
	{
		if(Skills[i] == None)
		{
			Skill = Spawn(SkillClass, Self);
			Skills[i] = Skill;
		}
	}
}

function R_ArpgSkill GetSkill(int Index)
{
	return Skills[Index];
}

function SetLockDirection(bool bNewLockDirection)
{
	bLockDirection = bNewLockDirection;
}

function SetLookDirection(Vector NewLookDirection)
{
	local Rotator NewRotation;

	if(bLockDirection)
	{
		return;
	}

	LookDirection = NewLookDirection;

	NewRotation = Rotator(LookDirection);
	NewRotation.Pitch = 0;
	NewRotation.Roll = 9000;

	SetRotation(NewRotation);
}

function Vector GetLookDirection()
{
	return LookDirection;
}

function AddMovementInput(Vector InputVector)
{
	MovementInput += InputVector;
}

event Tick(float DeltaSeconds)
{
	//aForward = MovementInput.X;
	//aStrafe = MovementInput.Y;
	PlayerTick(DeltaSeconds);
}

function R_ArpgAnimationSet GetAnimationSet()
{
	if(AnimationSet == None)
	{
		if(AnimationSetDefaultClass == None)
		{
			return None;
		}
		AnimationSet = new(Self) AnimationSetDefaultClass;
	}
	return AnimationSet;
}

function PlayWaiting(optional float tween)
{
	local R_ArpgAnimationSet AnimSet;

	AnimSet = GetAnimationSet();
	if(AnimSet != None)
	{
		LoopAnim(AnimSet.Idle, 1.0, 0.1);
	}
}

function PlayMoving(optional float Tween)
{
	local R_ArpgAnimationSet AnimSet;

	AnimSet = GetAnimationSet();
	if(AnimSet != None)
	{
		LoopAnim(AnimSet.Forward, 1.0, 0.1);
	}
}

function UpdateRotation(float DeltaTime, float maxPitch)
{}

/*
auto state Neutral
{
	event BeginState()
	{
		SetPhysics(PHYS_Falling);
	}
}
	*/

function Input_Fire()
{
	Attack();
}

function Attack()
{
	local Vector Start, End;
	local Vector HitLocation, HitNormal;
	local Actor HitActor;

	PlayAnim('S3_AttackA', 1.0, 0.1);

	Start = Location;
	End = Location + Vector(Rotation) * 64.0;

	HitActor = Trace(HitLocation, HitNormal, End, Start, true);

	if(HitActor != None)
	{
		HitActor.JointDamaged(30, Self, HitLocation, Vect(0,0,0), '', 0);
	}
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	Super.Died(Killer, DamageType, HitLocation);
	Destroy();
}

function AnimEnd()
{
	PlayMoving();
}

state PlayerWalking
{
	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;

		if(!bBlockMovementInput)
		{
			NewAccel = MovementInput * 300.0;
			NewAccel.Z = 0.0;
		}
		else
		{
			NewAccel = Acceleration;
			NewAccel.Z = 0.0;
		}
		MovementInput = Vect(0,0,0);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		//bPressedJump = bSaveJump;
	}
}

simulated function DrawInWorldHUD(Canvas C)
{
	if(bShouldDrawHealth)
	{
		DrawHealthBar(C);
	}
}

simulated function DrawHealthBar(Canvas C)
{
	local Vector ScreenSpaceLocation;
	local Vector Extent1, Extent2;
	local float Width, Height;
	local float HealthRatio;

	if(Health <= 0)
	{
		return;
	}

	// This is the height and width at desired resolution 1920x1080
	// Bar size will scale linearly as resolution increases or decreases
	Width = 64.0 * (C.ClipX / 1920.0);
	Height = 4.0 * (C.ClipY / 1080.0);

	HealthRatio = float(Health) / float(MaxHealth);

	C.Reset();
	CanvasLib.Static.GetScreenSpaceLocationAboveActor(C, Self, ScreenSpaceLocation, 16.0);

	Extent1 = ScreenSpaceLocation;
	Extent2 = ScreenSpaceLocation;

	Extent1.X -= Width / 2.0;
	Extent1.Y -= Height / 2.0;
	Extent2.Y += Height / 2.0;

	// Backdrop
	Extent2.X = Extent1.X + Width;
	CanvasLib.Static.DrawBoxSolid(C, Extent1, Extent2, 0.0, 0.0, 0.0, 1.0);

	// Health
	Extent2.X = Extent1.X + Width * HealthRatio;
	CanvasLib.Static.DrawBoxSolid(C, Extent1, Extent2, 1.0, 0.0, 0.0, 1.0);
}

defaultproperties
{
	//RemoteRole=ROLE_AutonomousProxy
	RemoteRole=ROLE_SimulatedProxy
	InitialState=PlayerWalking
	DrawType=DT_SkeletalMesh
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	Mass=50.000000
    Buoyancy=35.000000
	AnimationSetDefaultClass=Class'RArpg.R_ArpgAnimationSet_Ragnar_BattleAxe'
	bLockDirection=false
	bBlockMovementInput=false
	bShouldDrawHealth=true
	TraceProxyClass=Class'RArpg.R_ArpgTraceProxy'
}