//=============================================================================
// EatenLizard.
//=============================================================================
class EatenLizard expands DiscardedHealth;

simulated function HitWall(vector HitNormal, actor Wall)
{
	local int i;
	local Debris d;
	local vector loc;
	
	Super.HitWall(HitNormal, Wall);

	PlaySound(Sound'OtherSnd.Pickups.pickupmeatsmash01', SLOT_Pain);

	for(i = 0; i < 10; i++)
	{
		loc = Location + VRand() * 8;
		d = Spawn(Class'DebrisFlesh',,, loc);
		if(d != None)
		{
			d.SetSize(0.2 + FRand() * 0.2);
			d.SetTexture(SkelGroupSkins[0]);
			d.Velocity = HitNormal * 175 + VRand() * 85;
		}
	}
	
	Destroy();
}
	
simulated function Landed(vector HitNormal, actor HitActor)
{
	HitWall(HitNormal, HitActor);
}

defaultproperties
{
     DrawScale=0.800000
     DesiredFatness=110
     CollisionRadius=5.000000
     bCollideWorld=False
     Skeletal=SkelModel'creatures.Lizard'
}
