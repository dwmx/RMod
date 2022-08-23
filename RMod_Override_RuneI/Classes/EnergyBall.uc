//=============================================================================
// EnergyBall.
//=============================================================================
class EnergyBall expands Projectile;



simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	Other.JointDamaged(Damage, Instigator, HitLocation, MomentumTransfer*Normal(Velocity), MyDamageType, 0);
	Explode(HitLocation, -Normal(Velocity));
}

simulated function Landed(vector HitNormal, actor HitActor)
{
	Explode(Location, HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Destroy();
}

defaultproperties
{
     MaxSpeed=10000.000000
     Damage=20.000000
     MyDamageType=Blunt
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=FireTexture'RuneFX.DarkDwarfEnergyBall'
     DrawScale=0.750000
     ScaleGlow=2.000000
     AmbientGlow=50
     CollisionRadius=20.000000
     CollisionHeight=20.000000
}
