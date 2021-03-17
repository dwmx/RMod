//=============================================================================
// Spectator.
//=============================================================================
class Spectator extends PlayerPawn;

var bool bChaseCam;


replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && Role==ROLE_Authority )
		bChaseCam;
}


function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.bIsSpectator = true;
}

event FootZoneChange(ZoneInfo newFootZone)
{
}
	
event HeadZoneChange(ZoneInfo newHeadZone)
{
}

event PainTimer()
{
}

event PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
/*	if (bDebug==1)
	{
		if ( myDebugHud != None )
			myDebugHud.PostRender(Canvas);
		else if ( Viewport(Player) != None )
			myDebugHud = spawn(class'Engine.DebugHUD', self);
	}

	// Draw scoreboard (if active)
	if ( bShowScores )
	{
		if ( (Scoring == None) && (ScoringType != None) )
			Scoring = Spawn(ScoringType, self);
		if ( Scoring != None )
		{ 
			Scoring.ShowScores(Canvas);
		}
	}
*/
	if (ViewTarget==None)
		bBehindView = false;
	else
		bBehindView = bChaseCam;
}

exec function Walk()
{	
}

exec function BehindView( Bool B )
{	// In this function, the bool B is ignored, so that this function acts as a toggle
	bChaseCam = !bChaseCam;
}

exec function CameraIn()
{
	bChaseCam = false;
}

exec function CameraOut()
{
	bChaseCam = true;
}

function ChangeTeam( int N )
{
	Level.Game.ChangeTeam(self, N);
}

exec function Taunt()
{
}

exec function CallForHelp()
{
}

exec function Suicide()
{
}

exec function Fly()
{
	UnderWaterTime = -1;	
	SetCollision(false, false, false);
	bCollideWorld = true;
	GotoState('CheatFlying');

	ClientRestart();
}

function ServerChangeSkin( int SkinIndex )
{
}

function ClientReStart()
{
	//log("client restart");
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;
	
	GotoState('CheatFlying');
}

function PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'dropped', Location);
}

exec function Grab()
{
}

// Send a message to all players.
exec function Say( string S )
{
	if ( Len(S) > 63 )
		S = Left(S,63);
	if ( !Level.Game.bMuteSpectators )
		BroadcastMessage( PlayerReplicationInfo.PlayerName$":"$S, true );
}

//=============================================================================
// functions.

exec function RestartLevel()
{
}

// This pawn was possessed by a player.
function Possess()
{
	bIsPlayer = true;
	DodgeClickTime = FMin(0.3, DodgeClickTime);
	EyeHeight = BaseEyeHeight;
	NetPriority = 2;
	Weapon = None;
	Inventory = None;
	Fly();
}


//=============================================================================
// Inventory-related input notifications.

// The player wants to switch to weapon group numer I.
exec function SwitchWeapon (byte F )
{
}

exec function NextItem()
{
}

exec function PrevItem()
{
}

exec function Fire( optional float F )
{
	bBehindView = bChaseCam;
	if (Level.NetMode != NM_Client)
		ViewPlayerNum(-1);
	if ( ViewTarget == None )
		bBehindView = false;
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	bBehindView = false;
	if (Level.NetMode != NM_Client)
	{
		Viewtarget = None;
		ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}
}

//=================================================================================

function bool JointDamaged( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType, int joint)
{
	return true;
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);

	Canvas.DrawText("RunePlayer:");
	Canvas.CurY -= 8;
	Canvas.DrawText(" bChaseCam:" @ bChaseCam);
	Canvas.CurY -= 8;
}

defaultproperties
{
     bChaseCam=True
     AirSpeed=400.000000
     Visibility=0
     AttitudeToPlayer=ATTITUDE_Friendly
     MenuName="Spectator"
     bHidden=True
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
}
