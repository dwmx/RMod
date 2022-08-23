//=============================================================================
// Eel.
//=============================================================================
class Eel expands ScriptPawn;



/* Description:
	Found in underwater holes, they poke their heads out and watch for prey. They use the look joints
	to turn toward their current target and then spring out at them.  After the first attack, the eel
	stays partially extended and attacks from there.  When inactive for a while, can curl up and go
	back to idleA inside the hold.

   TODO:
   	Attack animations need to translate down bones following base_ bones
*/

var bool bCoiled;			// If eel is coiled up inside hole


function PreSetMovement()
{
	bCanJump = false;
	bCanWalk = false;
	bCanSwim = false;
	bCanFly = false;
	MinHitWall = -0.6;
	bCanOpenDoors = false;
	bCanDoSpecial = false;
}

function CheckForEnemies()
{
}

function Texture PainSkin(int BodyPart)
{
}

//============================================================
// Animation functions
//============================================================

function PlayDeath(name DamageType)	          { PlayAnim  ('death', 1.0, 0.1);     }

function PlayWaiting(optional float tween)
{
	if (bCoiled)
		LoopAnim('IdleA', 1.0, 0.1);
	else
		LoopAnim('IdleB', 1.0, 0.1);
}

function PlayAttack()
{
	if (bCoiled)
		PlayAnim('AttackA', 1.0, 0.1);
	else
		PlayAnim('AttackB', 1.0, 0.1);
}


//============================================================
// States
//============================================================

auto State GuardHole
{
	function SeePlayer(actor seen)
	{
		LookTarget = seen;
		Enemy = Pawn(seen);
	}

	function EnemyNotVisible()
	{
		bCoiled = true;
		LookTarget = None;
		
		PlayWaiting();
	}

	function Bump(actor Other)
	{
		Enemy = pawn(Other);
	}
	
	function bool ActorInRange(actor A)
	{
		local rotator angleToTarget;
		local vector ToTarget;
		local int yaw, pitch, yawangle, pitchangle;

		if (Enemy==None)
			return false;

		ToTarget = A.Location - Location;
		if (VSize(ToTarget) > MeleeRange)
			return false;

		angleToTarget = (rotator(ToTarget) - Rotation);
		yaw   = angleToTarget.Yaw;
		pitch = angleToTarget.Pitch;

		if (yaw > 32768)
			yaw = yaw - 65535;
		if (yaw < -32768)
			yaw = yaw + 65535;
		if (pitch > 32768)
			pitch = pitch - 65535;
		if (pitch < -32768)
			pitch = pitch + 65535;
		
		yawangle = MaxBodyAngle.Yaw + MaxHeadAngle.Yaw;
		pitchangle = MaxBodyAngle.Pitch + MaxHeadAngle.Pitch;
		
		return ((yaw >= -yawangle) && (yaw <= yawangle) &&
		        (pitch >= -pitchangle) && (pitch <= pitchangle));
	}

	function AttachRagnar()
	{
/*
		local actor a;
		
		a = spawn(class'testdude');
		if (a!=None)
			AttachActorToJoint(a, JointNamed('Jaw'));
*/
	}
	
Begin:
	bCoiled = true;
	PlayWaiting();
		
WaitUntilInRange:
	if (ActorInRange(Enemy))
	{	// Attack
		PlayAttack();
		FinishAnim();
		
		// Uncoil
		bCoiled = false;
		LookTarget = Enemy;
		
//		AttachRagnar();

//		LoopAnim('IdleA', 1.0, 0.5);
		PlayWaiting();
		Sleep(RandRange(0.5*TimeBetweenAttacks, 1.5*TimeBetweenAttacks));
		Goto('WaitUntilInRange');
	}
	else
	{	// Wait
		Sleep(0.2);
		Goto('WaitUntilInRange');
	}
}





simulated function Debug(Canvas canvas, int mode)
{
	local vector ToEnemy, ToSide, Up;

	Super.Debug(canvas, mode);
	
	Canvas.DrawText("Eel:");
	Canvas.CurY -= 8;
	Canvas.DrawText("bCoiled: "$bCoiled);
	Canvas.CurY -= 8;
}

defaultproperties
{
     bBurnable=False
     MeleeRange=200.000000
     ClassID=21
     HitSound1=Sound'CreaturesSnd.Fish.fish01'
     HitSound2=Sound'CreaturesSnd.Fish.fish01'
     HitSound3=Sound'CreaturesSnd.Fish.fish01'
     Die=Sound'CreaturesSnd.Fish.fish08'
     Die2=Sound'CreaturesSnd.Fish.fish08'
     Die3=Sound'CreaturesSnd.Fish.fish08'
     bCanLook=True
     MaxBodyAngle=(Pitch=8000,Yaw=14500)
     MaxHeadAngle=(Pitch=500,Yaw=500)
     LookDegPerSec=200.000000
     DrawScale=4.000000
     SoundRadius=20
     SoundVolume=157
     SoundPitch=42
     AmbientSound=Sound'CreaturesSnd.Fish.fish02L'
     TransientSoundRadius=800.000000
     CollisionRadius=11.000000
     CollisionHeight=13.000000
     Mass=400.000000
     Skeletal=SkelModel'creatures.eel'
}
