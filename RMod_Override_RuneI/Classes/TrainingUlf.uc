//=============================================================================
// TrainingUlf.
//=============================================================================
class TrainingUlf expands Ulf;

var() Sound UlfTaunt[4];
var() Sound UlfOuch[4];
var() Sound UlfDeadMessage;

var int OuchCount;
var int PrevHealth;

//===================================================================
//
// PlayDeath
//
//===================================================================

function PlayDeath(name DamageType)           
{ 
	PlayAnim('z_knockdown', 1.0, 0.1);
}

//===================================================================
//
// WeaponActivate
//
//===================================================================

function WeaponActivate()
{	
	// This is a training NPC, so he should NOT be able to kill the player
	// if Ragnar's health gets too low, don't do as much damage anymore
	if(Enemy.Health < 10)
		Weapon.Damage = 0; 
	else if(Enemy.Health < 25)
		Weapon.Damage = 2;	
	else
		Weapon.Damage = 5;

	PrevHealth = Enemy.Health;

	Super.WeaponActivate();
}

//===================================================================
//
// WeaponDeactivate
//
//===================================================================

function WeaponDeactivate()
{
	if(Enemy.Health < PrevHealth && FRand() < 0.8)
	{ // TrainingUlf has hurt the player in this swipe, play a taunt
		PlaySound(UlfTaunt[Rand(4)], SLOT_Talk);
	}

	Super.WeaponDeactivate();
}

//------------------------------------------------------------
//
// Died
//
// Pawn has run out of health, kill him properly
//------------------------------------------------------------
function Died(pawn Killer, name damageType, vector HitLocation)
{
	local actor A;

	if ( bDeleteMe ) return; //already destroyed
	Health = Min(0, Health);
	
	if (Killer != None)
		Killer.Killed(Killer, self, damageType);
	Level.Game.Killed(Killer, self, damageType);
	DropWeapon();
	DropShield();
	Level.Game.DiscardInventory(self);	// Delete the rest of the inventory

	GotoState('Dying');
}

//------------------------------------------------------------
//
// Pain
//
//------------------------------------------------------------
state Pain
{
	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when already in pain
		return(false);
	}

Begin:

	if(PainDelay < 0)
	{ // If PainDelay is negative, the painstate waits until the anim has completed
		FinishAnim();
	}
	else
	{ // Otherwise, just use the PainDelay
		Sleep(PainDelay);
	}

	if(OuchCount < 4 && FRand() < 0.75)
	{
		PlaySound(UlfOuch[OuchCount], SLOT_Talk);
		OuchCount++;
	}
	
	GotoState(NextStateAfterPain);
}

//============================================================
//
// Dying
//
//============================================================
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed, JointDamaged;

Begin:
	Acceleration = vect(0, 0, 0);
	Velocity = vect(0, 0, 0);
	bLookFocusPlayer = true;
	LookTarget = Enemy;

	Goto('PreDeath');

PreDeath:
	Goto('Death');

Death:
	PlayAnim('cine_vil_kneeldown', 1.0, 0.15);
	FinishAnim();
	Sleep(0.5);
	PlaySound(UlfDeadMessage, SLOT_Talk);
	Sleep(1.0);
	PlayAnim('cine_vil_standup', 1.0, 0.15);
	FinishAnim();

	// Talk for a bit....
	LoopAnim('cine_vil_talkingA', 1.0, 0.1);
	Sleep(1.5);
	LoopAnim('cine_vil_talkingB', 1.0, 0.1);
	Sleep(1.5);
	LoopAnim('cine_vil_talkingC', 1.0, 0.1);
	Sleep(1.5);
	LoopAnim('cine_vil_talkingB', 1.0, 0.1);
	Sleep(1.5);
	LoopAnim('cine_vil_talkingA', 1.0, 0.1);
	Sleep(1.5);
	LoopAnim('cine_vil_talkingC', 1.0, 0.1);
	Sleep(1.0);

	// Trigger any Events... this is overridden to happen here instead of at the moment of "death"
	FireEvent(Event);

	// Hide TrainingUlf's enemy (which would be Ragnar), as other scripting will happen after TrainingUlf
	Enemy.bHidden = true;
	Enemy.SetCollision(false, false, false);
	Destroy(); // Finally, destroy this training Ulf

	Goto('PostDeath');

PostDeath:
}

simulated function Debug(Canvas canvas, int mode)
{
	local vector offset;
	
	Super.Debug(canvas, mode);
	
	Canvas.DrawText("	TrainingUlf:");
	Canvas.CurY -= 8;
	Canvas.DrawText("	Enemy:" $Enemy);
	Canvas.CurY -= 8;
}

defaultproperties
{
     Health=300
     BodyPartHealth(1)=999
     BodyPartHealth(3)=999
     BodyPartHealth(5)=999
     StabJoint=	
}
