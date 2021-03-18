class R_Weapon extends Weapon;

var class<Weapon> WeaponSubClass;

replication
{
	reliable if(Role == ROLE_Authority)
		ClientCopyWeaponByClass,
		ClientCopyWeaponByInstance;
}

////////////////////////////////////////////////////////////////////////////////
//	CopyWeaponByClass
//	For filling out this weapon's settings based on a default actor.
//	Used for things like spawning default inventory.
simulated function CopyWeaponByClass(class<Weapon> WC)
{
	class'R_ACopyActor'.Static.CopyByClass(WC, Self);
	class'R_ACopyInventory'.Static.CopyByClass(WC, Self);
	class'R_ACopyWeapon'.Static.CopyByClass(WC, Self);
	
	WeaponSubClass = WC;
	
	ApplyGamePlayWeaponModsBySubClass(WC);
	
	//if(Role == ROLE_Authority)
	//{
	//	ClientCopyWeaponByClass(WC);
	//}
}

simulated function ClientCopyWeaponByClass(class<Weapon> WC)
{
	Log("Server should not call this");
	CopyWeaponByClass(WC);
}

////////////////////////////////////////////////////////////////////////////////
//	CopyWeaponByInstance
//	For filling out this weapon's settings based on an existing actor.
//	Preserves any modified properties of existing actors.
simulated function CopyWeaponByInstance(Weapon W)
{
	class'R_ACopyActor'.Static.CopyByInstance(W, Self);
	class'R_ACopyInventory'.Static.CopyByInstance(W, Self);
	class'R_ACopyWeapon'.Static.CopyByInstance(W, Self);
	
	WeaponSubClass = W.Class;
	
	ApplyGamePlayWeaponModsBySubClass(W.Class);
	
	if(Role == ROLE_Authority)
	{
		ClientCopyWeaponByInstance(W);
	}
}

simulated function ClientCopyWeaponByInstance(Weapon W)
{
	if(Role < ROLE_Authority)
	{
		CopyWeaponByInstance(W);
	}
}

////////////////////////////////////////////////////////////////////////////////
//	ApplyGamePlayWeaponModsBySubClass
//	Gameplay modifications
function ApplyGamePlayWeaponModsBySubClass(class<Weapon> WC)
{
	if(R_GameInfo(Level.Game) != None
	&& R_GameInfo(Level.Game).bRModEnabled)
	{
		switch(WC)
		{
		case class'RuneI.VikingAxe':
			A_AttackBReturn = 'None';	// Enable weaving
			break;
			
		case class'RuneI.SigurdAxe':
			A_AttackBReturn = 'None';	// Enable weaving
			ExtendedLength = 12.0;		// Increase range
			break;
			
		case class'RuneI.DwarfBattleSword':
			A_AttackBReturn = 'None';	// Make DBS faster
			ExtendedLength = 16.0;		// Increase range
			break;
		}
	}
}

function int GetWeaponTier()
{
	switch(WeaponSubClass)
	{
	case class'RuneI.VikingShortSword':		return 1;
	case class'RuneI.RustyMace':			return 1;
	case class'RuneI.HandAxe':				return 1;
	case class'RuneI.RomanSword':			return 2;
	case class'RuneI.BoneClub':				return 2;
	case class'RuneI.GoblinAxe':			return 2;
	case class'RuneI.VikingBroadSword':		return 3;
	case class'RuneI.TrialPitMace':			return 3;
	case class'RuneI.VikingAxe':			return 3;
	case class'RuneI.DwarfWorkSword':		return 4;
	case class'RuneI.DwarfWorkHammer':		return 4;
	case class'RuneI.SigurdAxe':			return 4;
	case class'RuneI.DwarfBattleSword':		return 5;
	case class'RuneI.DwarfBattleHammer':	return 5;
	case class'RuneI.DwarfBattleAxe':		return 5;
	}
	
	return 0;
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local Weapon newWeapon;

	if( Level.Game.ShouldRespawn(self) )
	{
		//Copy = spawn(Class,Other,,,rot(0,0,0));
		Copy = Spawn(Self.Class, Other,,, Rot(0, 0, 0));
		if(R_Weapon(Copy) != None)
		{
			R_Weapon(Copy).CopyWeaponByInstance(Self);
		}
		if (Copy == None)
			log(name@"cannot be spawned in spawncopy");
		Copy.Tag           = Tag;
		Copy.Event         = Event;
		if ( !bWeaponStay )
			GotoState('Sleeping');
	}
	else
		Copy = self;

	Copy.bTossedOut = true;
	Copy.RespawnTime = 0.0;
	Copy.GiveTo( Other );
	Copy.bHidden = false; // BecomeItem in Inventory automatically hides the item
	newWeapon = Weapon(Copy);
//	newWeapon.Instigator = Other;
//	newWeapon.SetSwitchPriority(Other);
//	if ( !Other.bNeverSwitchOnPickup )
//		newWeapon.WeaponSet(Other);
//	newWeapon.AmbientGlow = 0;
	return newWeapon;
}

function int CalculateDamage(Actor Victim)
{
	local int ModDamage;

	ModDamage = Super.CalculateDamage(Victim);
	
	// RMod: Hammers deal double damage to shields
	if(R_GameInfo(Level.Game) != None
	&& R_GameInfo(Level.Game).bRModEnabled
	&& Shield(Victim) != None
	&& MeleeType == MELEE_HAMMER)
	{
		ModDamage *= 2;
	}

    return ModDamage;
}

state Throw
{
	//=========================================================================
	//
	// Touch
	// 
	// Touched an actor, does a simple check to see which joints the weapon struck
	//=========================================================================
	function Touch(Actor Other)
	{
		local int hitjoint;
		local vector HitLoc;
		local int DamageAmount;
		local int LowMask, HighMask;
		local actor HitActor;
		local PlayerPawn P;
		local vector VectOther;
		local float dp;

		if (Other == Owner)
			return;
		if (Owner == None)
			return;	// Already hit wall, no more damage after that
		if (Other.IsA('Inventory') && Other.GetStateName() == 'Pickup' &&
		!Other.IsA('Lizard'))
			return;

		AmbientSound = None;

		HitActor = Other;

		// If a Pawn is facing the weapon, give them a chance to block the throw
		P = PlayerPawn(Other);
		if(P != None && P.AnimProxy != None)
		{
			VectOther = Normal((self.Location - Other.Location) * vect(1, 1, 0));
			dp = vector(P.Rotation) dot VectOther;

			if(dp >= 0.0)
			{
				if(P.Shield != None && P.AnimProxy.GetStateName() == 'Defending')
				{
					HitActor = P.Shield;
				}
				// RMod: Tiers 1-3 cannot be throw blocked
				else if((P.Weapon != None
				&& P.AnimProxy.GetStateName() == 'Attacking')
				|| (R_GameInfo(Level.Game) != None
				&& R_GameInfo(Level.Game).bRModEnabled
				&& GetWeaponTier() >= 4))
				{
					HitActor = P.Weapon;
				}
			}
		}
		
		if (Pawn(HitActor) != None && HitActor.Skeletal != None) {
			hitjoint = HitActor.ClosestJointTo(Location);
			HitLoc = HitActor.GetJointPos(hitjoint);
		} else {
			hitjoint = 0;
			HitLoc = HitActor.Location;
		}
		if (SwipeArrayCheck(HitActor, 0, 0)) {
			DamageAmount = CalculateDamage(HitActor);
			if (DamageAmount != 0) {
				if (HitActor.JointDamaged(DamageAmount, Pawn(Owner), HitLoc, Velocity*Mass, ThrownDamageType, hitjoint))
				{	// Hit something solid, bounce
				}

				SpawnHitEffect(HitLoc, Normal(Location-HitActor.Location), 0, 0, HitActor);

				SetPhysics(PHYS_Falling);
				RotationRate.Yaw = VSize(Velocity) * 2000 / Mass;
				RotationRate.Pitch = VSize(Velocity) * 2000 / Mass;
				Velocity = -0.1 * Velocity;
			}
		}
	}
}

defaultproperties
{
}
