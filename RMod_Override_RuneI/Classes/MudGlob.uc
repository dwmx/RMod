//=============================================================================
// MudGlob.
//=============================================================================
class MudGlob expands Effects;

var float MudZ;

event ZoneChange(ZoneInfo newZone)
{
	local ParticleSystem p;
	local vector v;
	local actor a;

	if(newZone.bWaterZone == false)
		return;

//	PlaySound(Sound'EnvironmentalSnd.Mud.MudSplat',, 0.1+FRand()*0.1,,
//		1024, 0.8+FRand()*0.4);

	v = Location;
	v.z = MudZ;
	p = Spawn(class'MudRipple',,, v);
	if(p != None)
	{
		p.ScaleMin = 0.4;
		p.ScaleMax = 0.5;
	}

	a = Spawn(class'MudSplat',,, v);
	if(a != None)
		a.SetRotation(Rotator(Vect(0, 0, 1)));

	Destroy();
}

event Tick(float deltaTime)
{
	Velocity.Z += 370*deltaTime;
}

defaultproperties
{
     Physics=PHYS_Falling
     LifeSpan=4.000000
     DrawType=DT_Sprite
     Texture=Texture'RuneFX.Mudblob1'
     DrawScale=0.150000
     ScaleGlow=1.400000
     bShadowCast=False
     CollisionRadius=4.000000
     CollisionHeight=3.000000
     bCollideWorld=True
}
