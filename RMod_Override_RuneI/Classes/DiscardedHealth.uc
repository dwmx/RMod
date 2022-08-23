//=============================================================================
// DiscardedHealth.
//=============================================================================
class DiscardedHealth expands Debris;

function InventorySpecial1()
{
}

function InventorySpecial2()
{ // Drop the refuse (bone or empty stein)
	local Pawn P;
	local actor junk;

	if(Owner == None)
		return;
		
	P = Pawn(Owner);
	junk = P.DetachActorFromJoint(P.JointNamed(P.WeaponJoint));

	if(junk != None)
	{	
		junk.Velocity = DropVelocity(P);
		junk.SetPhysics(PHYS_Falling);
		junk.bCollideWorld = true;
	}
}

function InventorySpecial3()
{
}

function vector DropVelocity(Pawn P)
{
	local vector X, Y, Z;
	local vector vel;

	GetAxes(P.Rotation, X, Y, Z);
	vel = -X * 150 + Y * 30 + vect(0, 0, 100);

	return(vel);
}

defaultproperties
{
}
