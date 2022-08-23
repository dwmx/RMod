//=============================================================================
// Fire.
//=============================================================================
class Fire expands ParticleSystem;

//============================================================================
//
// CanBeUsed
//
// Whether the actor can be used.
//============================================================================

function bool CanBeUsed(Actor Other)
{
	local Weapon W;

	if(Other == None || !Other.IsA('PlayerPawn'))
		return(false);

	W = PlayerPawn(Other).Weapon;

	// Fire can only be used if the player is facing it
	if(!Other.ActorInSector(self, ANGLE_45))
		return(false);

	if(W != None && W.IsA('Torch') && Torch(W).TorchFire == None)
		return(true);
	else
		return(false);
}

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(8);
}

defaultproperties
{
     ParticleCount=20
     ParticleTexture(0)=Texture'RuneFX.flame_orange'
     ShapeVector=(X=7.000000,Y=7.000000,Z=2.000000)
     VelocityMin=(X=0.300000,Y=0.300000,Z=80.000000)
     VelocityMax=(X=2.500000,Y=2.500000,Z=150.000000)
     ScaleMin=0.700000
     ScaleMax=1.000000
     ScaleDeltaX=0.900000
     ScaleDeltaY=1.200000
     LifeSpanMin=0.200000
     LifeSpanMax=0.500000
     AlphaStart=60
     bAlphaFade=True
     bApplyGravity=True
     GravityScale=-0.100000
     bApplyZoneVelocity=True
     ZoneVelocityScale=0.750000
     bConvergeX=True
     bConvergeY=True
     SpawnOverTime=0.500000
     Style=STY_Translucent
     bUnlit=True
     SoundRadius=14
     AmbientSound=Sound'EnvironmentalSnd.Fire.fire04L'
}
