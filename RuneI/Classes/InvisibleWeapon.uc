//=============================================================================
// InvisibleWeapon.
//=============================================================================
class InvisibleWeapon expands Weapon
	abstract;

var Weapon ChainedWeapon;

//=============================================================================
//
// SpawnHitEffect
//
// Spawns an effect based upon what was struck
//=============================================================================
function SpawnHitEffect(vector HitLoc, vector HitNorm, int LowMask, int HighMask, Actor HitActor)
{	
	local int i,j;
	local EMatterType matter;

	// Determine what kind of matter was hit
	if ((HitActor.Skeletal != None) && (LowMask!=0 || HighMask!=0))
	{
		for (j=0; j<HitActor.NumJoints(); j++)
		{
			if (((j <  32) && ((LowMask  & (1 <<  j      )) != 0)) ||
				((j >= 32) && (j < 64) && ((HighMask & (1 << (j - 32))) != 0)) )
			{	// Joint j was hit
				matter = HitActor.MatterForJoint(j);
				break;
			}
		}
	}
	else if(HitActor.IsA('LevelInfo'))
	{	
		matter = HitActor.MatterTrace(HitLoc, Owner.Location, WeaponSweepExtent);
	}
	else
	{
		matter = HitActor.MatterForJoint(0);
	}

	// Create effects
	PlayHitMatterSound(matter);
}


//=============================================================================
//
// ChainOnWeapon
//
//=============================================================================
function ChainOnWeapon(Weapon W)
{
	ChainedWeapon = W;
}

//=============================================================================
//
// DropFrom - destroy instead of drop
//
//=============================================================================
function DropFrom(vector StartLocation)
{
	Destroy();
}

function Destroyed()
{
	if (ChainedWeapon != None)
	{
		ChainedWeapon.Destroy();
		ChainedWeapon=None;
	}
	Super.Destroyed();
}
	

//-----------------------------------------------------------------------------
// Chained Weapon Support
//-----------------------------------------------------------------------------

function EnableSwipeTrail()
{
	Super.EnableSwipeTrail();
	if (ChainedWeapon!=None)
		ChainedWeapon.EnableSwipeTrail();
}

function DisableSwipeTrail()
{
	Super.DisableSwipeTrail();
	if (ChainedWeapon!=None)
		ChainedWeapon.DisableSwipeTrail();
}

function StartAttack()
{
	Super.StartAttack();
	if (ChainedWeapon!=None)
		ChainedWeapon.StartAttack();
}
function FinishAttack()
{
	Super.FinishAttack();
	if (ChainedWeapon!=None)
		ChainedWeapon.FinishAttack();
}

state Swinging
{
	function StartAttack()
	{
		Super.StartAttack();
		if (ChainedWeapon!=None)
			ChainedWeapon.StartAttack();
	}
	function FinishAttack()
	{
		Super.FinishAttack();
		if (ChainedWeapon!=None)
			ChainedWeapon.FinishAttack();
	}
}

state Active
{
	function StartAttack()
	{
		Super.StartAttack();
		if (ChainedWeapon!=None)
			ChainedWeapon.StartAttack();
	}
	function FinishAttack()
	{
		Super.FinishAttack();
		if (ChainedWeapon!=None)
			ChainedWeapon.FinishAttack();
	}
}

defaultproperties
{
     MeleeType=MELEE_HAMMER
     Damage=10
     DamageType=Blunt
     ExtendedLength=20.000000
     SweepVector=(Y=-1.000000)
     A_Taunt=S3_taunt
     DrawType=DT_None
     bSweepable=False
}
