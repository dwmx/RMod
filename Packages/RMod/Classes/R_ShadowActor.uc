////////////////////////////////////////////////////////////////////////////////
//	R_ShadowActor
//	Client-side dummy Actor that spawns just to provide a shadow for its
//	owner.
//	Thanks to Slade for this lovely hack.
class R_ShadowActor extends PlayerPawn;

simulated event Tick(float DeltaSeconds)
{
	if(Owner == None)
	{
		Destroy();
		return;
	}
	
	DrawType = Owner.DrawType;
	Skeletal = Owner.Skeletal;
	bHidden = Owner.bHidden;
	DrawScale = Owner.DrawScale;

	SetLocation(Owner.Location);
	SetRotation(Owner.Rotation);
}

// Do nothing
simulated event PreBeginPlay() {}
simulated event PostBeginPlay() {}
simulated event PostNetBeginPlay() {}
simulated event Destroyed() {}
simulated event event PlayerTimeOut() {}
simulated event RenderOverlays(Canvas C) {}
function InitPlayerReplicationInfo() {}
auto state ShadowState {}

defaultproperties
{
     RemoteRole=ROLE_None
     Style=STY_AlphaBlend
     Sprite=Texture'RuneFX.shadow'
     Texture=Texture'Engine.S_Corpse'
     AlphaScale=0.000000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bSweepable=False
}
