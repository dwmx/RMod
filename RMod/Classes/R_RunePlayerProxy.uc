class R_RunePlayerProxy extends RunePlayerProxy;

/**
*	EAttackType
*	Enumerator for keeping track of what the player is attacking with while
*	inside of the attack state
*/
enum EAttackType
{
	AT_None,			// No current attack
	AT_WeaponAttack,	// Attacking with weapon
	AT_ShieldAttack		// Attacking with shield
};
var EAttackType CurrentAttackType;

var Name PendingRecoveryAnimation;

function SetCurrentAttackType(EAttackType AttackType)
{
	CurrentAttackType = AttackType;
}

/**
*	FrameNotify (override)
*	Overridden to pass frame notifies to shield as well as weapon
*/
simulated event FrameNotify(int framepassed)
{
	local R_RunePlayer RPOwner;
	
	RPOwner = R_RunePlayer(Owner);
	if(RPOwner != None)
	{
		if(RPOwner.Weapon != None)
		{
			RPOwner.Weapon.FrameNotify(framepassed);
		}
		if(R_AShield(RPOwner.Shield) != None)
		{
			R_AShield(RPOwner.Shield).FrameNotify(framepassed);
		}
	}
}

/**
*	ShieldActivate
*	Called from attack state when the shield is used to perform an attack
*/
function ShieldActivate()
{
	local R_RunePlayer RPOwner;
	local R_AShield OwnerShield;
	
	RPOwner = R_RunePlayer(Owner);
	if(RPOwner != None)
	{
		OwnerShield = R_AShield(RPOwner.Shield);
		if(OwnerShield != None)
		{
			RPOwner.ShieldActivate();
			OwnerShield.PlaySwipeSound();
			OwnerShield.ShieldFire();
		}
	}
}

function ShieldDeactivate()
{
	local R_RunePlayer RPOwner;
	local R_AShield OwnerShield;
	
	RPOwner = R_RunePlayer(Owner);
	if(RPOwner != None)
	{
		OwnerShield = R_AShield(RPOwner.Shield);
		if(OwnerShield != None)
		{
			RPOwner.ShieldDeactivate();
		}
	}
}

auto state Idle
{
	/**
	*	Attack (override)
	*	Overridden to update attack state when triggered
	*/
	function bool Attack()
	{
		local bool bResult;
		
		SetCurrentAttackType(AT_WeaponAttack);
		bResult = Super.Attack();
		
		// If super failed, reset attack state
		if(!bResult)
		{
			SetCurrentAttackType(AT_None);
		}
		
		return bResult;
	}
}

state Defending
{
	/**
	*	Attack (override)
	*	Player wants to attack from the shield defend state, so perform a shield bash
	*/
	function bool Attack()
	{
		SetCurrentAttackType(AT_ShieldAttack);
		TorsoAnim = 'H3_DefendAttack';
		GotoState('Attacking');
		return true;
	}
}

/**
*	SwipeEffectStart (override)
*	Overridden to enable swipe effect based on attack type
*/
function SwipeEffectStart()
{
	switch(CurrentAttackType)
	{
	case AT_WeaponAttack:
		// TODO: Enable weapon swipe
		break;
		
	case AT_ShieldAttack:
		// TODO: Enable shield swipe
		break;
	}
}

/**
*	SwipeEffectEnd (override)
*	Overridden to disable swipe effect based on attack type
*/
function SwipeEffectEnd()
{
	switch(CurrentAttackType)
	{
	case AT_WeaponAttack:
		// TODO: Disable weapon swipe
		break;
		
	case AT_ShieldAttack:
		// TODO: Disable shield swipe
		break;
	}
}

state Attacking
{
	event BeginState()
	{
		SwipeEffectStart();
	}
	
	event EndState()
	{
		// Make sure that both shield and weapon attack are disabled
		WeaponDeactivate();
		ShieldDeactivate();
		SwipeEffectEnd();
		SetCurrentAttackType(AT_None);
	}
	
	/**
	*	StopAttack (override)
	*	Overridden to disable shield attack
	*/
	function StopAttack()
	{
		WeaponDeactivate();
		ShieldDeactivate();
		SyncAnimation(0.3);
		SwipeEffectEnd();
		SetCurrentAttackType(AT_None);
		
		GotoState('Idle');
	}
	
	/**
	*	SelectRecoveryAnimationForAttackAnimation
	*	Async attack code gets the recovery animation from this function for each attack
	*/
	function Name SelectRecoveryAnimationForAttackAnimation(Name AttackAnimation)
	{
		local R_RunePlayer RPOwner;
		local Weapon OwnerWeapon;
		
		RPOwner = R_RunePlayer(Owner);
		if(RPOwner != None)
		{
			if(CurrentAttackType == AT_WeaponAttack)
			{
				OwnerWeapon = RPOwner.Weapon;
				if(OwnerWeapon != None)
				{
					switch(AttackAnimation)
					{
					// Forward attacks
					case OwnerWeapon.A_AttackA:	return OwnerWeapon.A_AttackAReturn;
					case OwnerWeapon.A_AttackB:	return OwnerWeapon.A_AttackBReturn;
					case OwnerWeapon.A_AttackC:	return OwnerWeapon.A_AttackCReturn;
					case OwnerWeapon.A_AttackD:	return OwnerWeapon.A_AttackDReturn;
					
					// Neutral attacks
					case OwnerWeapon.A_AttackStandA:	return OwnerWeapon.A_AttackStandAReturn;
					case OwnerWeapon.A_AttackStandB:	return OwnerWeapon.A_AttackStandBReturn;
					
					// Back attacks
					case OwnerWeapon.A_AttackBackupA:	return OwnerWeapon.A_AttackBackupAReturn;
					case OwnerWeapon.A_AttackBackupB:	return OwnerWeapon.A_AttackBackupBReturn;
					}
				}
			}
		}
		
		return 'None';
	}

Begin:
	if(CurrentAttackType == AT_WeaponAttack)
	{
		goto('DoWeaponAttack');
	}
	else if(CurrentAttackType == AT_ShieldAttack)
	{
		goto('DoShieldAttack');
	}

/**
*	Cleanup of original weapon combo attack async code
*/
DoWeaponAttack:
	PlayAttack(0.1);
	Sleep(0.1);
	WeaponActivate();
	PendingRecoveryAnimation = SelectRecoveryAnimationForAttackAnimation(TorsoAnim);
	TorsoAnim = 'None';
	FinishAnim();
	WeaponDeactivate();
DoWeaponComboAttack:
	if(TorsoAnim != 'None')
	{
		PlayAttack(0.0);
		PendingRecoveryAnimation = SelectRecoveryAnimationForAttackAnimation(TorsoAnim);
		TorsoAnim = 'None';
		FinishAnim();
		WeaponDeactivate();
		goto('DoWeaponComboAttack');
	}
	goto('DoAttackRecovery');

/**
*	New shield attack async code
*/
DoShieldAttack:
	PlayAttack(0.1);
	Sleep(0.1);
	ShieldActivate();
	PendingRecoveryAnimation = SelectRecoveryAnimationForAttackAnimation(TorsoAnim);
	TorsoAnim = 'None';
	FinishAnim();
	ShieldDeactivate();
	goto('DoAttackRecovery');

/**
*	Attempt to play recovery animation for the most recent attack
*/
DoAttackRecovery:
	if(PendingRecoveryAnimation != 'None')
	{
		TorsoAnim = PendingRecoveryAnimation;
		PlayAttack(0.0);
		TorsoAnim = 'None';
		FinishAnim();
	}
	goto('Done');

Done:
	SyncAnimation(0.01);
	GotoState('Idle');
}

defaultproperties
{
	//ComboSpeed=1.5
}
