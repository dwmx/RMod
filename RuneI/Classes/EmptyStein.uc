//=============================================================================
// EmptyStein.
//=============================================================================
class EmptyStein expands DiscardedHealth;


function vector DropVelocity(Pawn P)
{
	local vector X, Y, Z;
	local vector vel;

	GetAxes(P.Rotation, X, Y, Z);
	vel = Y * 150 + vect(0, 0, -400);

	return(vel);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local int i;
	local Debris d;
	local vector loc;

	Super.HitWall(HitNormal, Wall);

	PlaySound(Sound'OtherSnd.Pickups.pickupsteinsmash01', SLOT_Pain);
	
	for(i = 0; i < 10; i++)
	{
		loc = Location + VRand() * 8;
		d = Spawn(Class'DebrisStone',,, loc);
		if(d != None)
		{
			d.SetSize(0.2 + FRand() * 0.2);
			d.SetTexture(SkelGroupSkins[0]);
			d.Velocity = HitNormal * 175 + VRand() * 85;
		}
	}
	
	Destroy();
}
	

defaultproperties
{
     bLookFocusPlayer=True
     CollisionRadius=5.000000
     bCollideWorld=False
     Skeletal=SkelModel'objects.Stein'
}
