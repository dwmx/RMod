//=============================================================================
// RagnarFlight.
//=============================================================================
class RagnarFlight expands RunePlayer;

var Effects Rag;	// Ragnar effect sitting on back


function PreBeginPlay()
{
	Rag = Spawn(class'RagnarOnBeetle');
	if(Rag != None)
	{
		AttachActorToJoint(Rag, JointNamed('attach_shell'));
		Rag.GotoState('BeetleProxyFlying');
	}

	Super.PreBeginPlay();

	CameraDist = 180;
	CameraRotSpeed = rot(10, 10, 10);
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	LoopAnim('flya', 1.0);
}

function Texture PainSkin(int BodyPart)
{
	return None;
}

function bool JointDamaged(int Damage, Pawn Instigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	return true;
}

function ClientReStart()
{
	Super.ClientReStart();

	LoopAnim('flya', 1.0);
}

exec function Fire( optional float F )		{}
exec function AltFire( optional float F )	{}
exec function Use()							{}
exec function Throw()						{}
exec function Powerup()						{}
exec function Taunt()						{}
exec function SwitchWeapon(byte F)			{}
exec function Walk()						{}
exec function Fly()							{}
//exec function Ghost()						{}

function bool CanBeStatued()				{	return false;	}
function bool CanGotoPainState()			{	return(false);	}

function ZoneChange( ZoneInfo NewZone )				{}
function AnimEnd()									{}
function Landed(vector HitNormal, actor HitActor)	{}

function PlayWaiting(optional float tween)		{	LoopAnim('flya', 1.0);	}
function PlayMoving(optional float tween)		{	LoopAnim('flya', 1.0);	}
function PlayInAir(optional float tween)		{	LoopAnim('flya', 1.0);	}
function PlaySwimming()							{	LoopAnim('flya', 1.0);	}
function PlayJump()								{	LoopAnim('flya', 1.0);	}
function PlayChatting()							{	LoopAnim('flya', 1.0);	}


// States - aren't used (is set to state '' when playerpathing

state PlayerFlying
{
begin:
	GotoState('PlayerWalking');
}

auto state PlayerWalking
{
ignores Bump, GrabEdge, Jump, Touch;

	exec function Fire( optional float F )		{}
	exec function AltFire( optional float F )	{}
	exec function Use()							{}
	exec function Throw()						{}
	exec function Powerup()						{}
	exec function Taunt()						{}
	exec function SwitchWeapon(byte F)			{}

	function bool CanBeStatued()		{	return false;	}
	function bool CanGotoPainState()	{	return(false);	}

	function ZoneChange( ZoneInfo NewZone )				{}
	function AnimEnd()									{}
	function Landed(vector HitNormal, actor HitActor)	{}

	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
	}

	event PlayerTick( float DeltaTime )
	{
		StrengthDecay(DeltaTime);

		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	function ServerMove
	(
		float TimeStamp, 
		vector Accel, 
		vector ClientLoc,
		bool NewbRun,
		bool NewbDuck,
		bool NewbJumpStatus, 
		bool bFired,
		bool bAltFired,
		bool bForceFire,
		bool bForceAltFire,
		eDodgeDir DodgeMove, 
		byte ClientRoll, 
		int View,
		optional byte OldTimeDelta,
		optional int OldAccel
	)
	{
		Global.ServerMove(TimeStamp, Accel, ClientLoc, NewbRun, NewbDuck, NewbJumpStatus,
							bFired, bAltFired, bForceFire, bForceAltFire, DodgeMove, ClientRoll, (32767 & (Rotation.Pitch/2)) * 32768 + (32767 & (Rotation.Yaw/2)));
	}
	function PlayerMove( float DeltaTime)
	{
		local rotator currentRot;
		local vector NewAccel;

		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		if ( !IsAnimating() && (aForward != 0) || (aStrafe != 0) )
			NewAccel = vect(0,0,1);
		else
			NewAccel = vect(0,0,0);

		// Update view rotation.
		currentRot = Rotation;
		UpdateRotation(DeltaTime, 1);
		SetRotation(currentRot);

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		bPressedJump = false;
	}

	function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
	{
	}
	
	function PlayDying(name DamageType, vector HitLocation)
	{
	}
	
	function ChangedWeapon()
	{
	}

	function EndState()
	{
//		slog("ended pw");
	}

	function BeginState()
	{
//		slog("started pw");
		LoopAnim('flya', 1.0);
		SetPhysics(PHYS_Falling);
	}

begin:
}

exec function CameraIn()
{
}

exec function CameraOut()
{
}

defaultproperties
{
     bCanLook=False
     InitialState=BeetleControl
     CollisionRadius=50.000000
     CollisionHeight=50.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     Skeletal=SkelModel'creatures.Beetle'
}
