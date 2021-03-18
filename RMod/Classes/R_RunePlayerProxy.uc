class R_RunePlayerProxy extends RunePlayerProxy;

//=============================================================================
//
// WantsToPickup
//
//=============================================================================

function bool WantsToPickup(Inventory item)
{
	local class<Inventory> ClassA, ClassB;
	local Weapon cur, next, stow;
	local Inventory Inv;

/*		
	if(RunePlayer(Owner).Physics != PHYS_Walking 
		|| (RunePlayer(Owner).Velocity.X * RunePlayer(Owner).Velocity.X + RunePlayer(Owner).Velocity.Y * RunePlayer(Owner).Velocity.Y >= 1000))
	{ // Test:  Only allow RunePlayer(Owner) to pick things up if he's standing still and on the ground
		return(false);
	}
*/
	if(item.IsA('Weapon') && !item.IsA('InvisibleWeapon'))
	{
		cur = RunePlayer(Owner).Weapon;		
		next = Weapon(item);

		if (RunePlayer(Owner).BodyPartMissing(BODYPART_RARM1))
			return false;

		// Disallow if item already held
		if(R_Weapon(Item) != None)	ClassA = R_Weapon(Item).WeaponSubClass;
		else							ClassA = Item.Class;
		
		for(Inv = RunePlayer(Owner).Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if(R_Weapon(Inv) != None)	ClassB = R_Weapon(Inv).WeaponSubClass;
			else							ClassB = Inv.Class;
			
			if(ClassA == ClassB)
			{
				return false;
			}
		}

		stow = RunePlayer(Owner).GetStowedWeapon(GetStowIndex(next));

		// Don't pick up a weapon if it's identical to a stowed weapon
		if(stow != None)
		{
			if(R_Weapon(Stow) != None)	ClassA = R_Weapon(Stow).WeaponSubClass;
			else							ClassA = Stow.Class;
			
			if(R_Weapon(Next) != None)	ClassB = R_Weapon(Next).WeaponSubClass;
			else							ClassB = Next.Class;
			
			if(ClassA == ClassB)
			{
				return false;
			}
		}

		if(cur == None)
		{
			return(true);
		}

		// Don't pick up a weapon if it's identical to the current weapon
		if(R_Weapon(Cur) != None)	ClassA = R_Weapon(Cur).WeaponSubClass;
		else							ClassA = Cur.Class;
		
		if(R_Weapon(Next) != None)	ClassB = R_Weapon(Next).WeaponSubClass;
		else							ClassB = Next.Class;
		
		if(ClassA == ClassB)
		{
			return false;
		}
		
		return(true);
	}
	else if(item.IsA('Shield'))
	{
		if (RunePlayer(Owner).BodyPartMissing(BODYPART_LARM1))
			return false;

		if(RunePlayer(Owner).Weapon != None && RunePlayer(Owner).Weapon.A_Defend == 'None')
		{ // Current weapon held cannot be used with a shield
			return(false);
		}

		if(RunePlayer(Owner).Shield != None && RunePlayer(Owner).Shield.IsA('MagicShield'))
			return(false); // Cannot swap magic shields for other shields

		return(RunePlayer(Owner).Shield == None || Shield(item).Health > RunePlayer(Owner).Shield.Health);
	}	
	else if(item.IsA('Runes'))
	{
		return(Runes(item).PawnWantsRune(Pawn(Owner)));
	}
	else if(item.IsA('Food'))
	{
		if(RunePlayer(Owner).Health < RunePlayer(Owner).MaxHealth ||
			RunePlayer(Owner).BodyPartMissing(BODYPART_LARM1) ||
			RunePlayer(Owner).BodyPartMissing(BODYPART_RARM1))
			return(true);
	}
		
	return(false);
}

defaultproperties
{
}
