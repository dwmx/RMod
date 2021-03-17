//=============================================================================
// GameReplicationInfo.
//=============================================================================
class GameReplicationInfo extends ReplicationInfo
	native;
//	nativereplication;

var string GameName;						// Assigned by GameInfo.
var string GameClass;						// Assigned by GameInfo.
var bool bTeamGame;							// Assigned by GameInfo.
var bool bClassicDeathMessages;
var bool bStopCountDown;
var int  RemainingTime, ElapsedTime, RemainingMinute;
var float SecondCount;

var int NumPlayers;
var int SumFrags;
var float UpdateTimer;

var() globalconfig string ServerName;		// Name of the server, i.e.: Bob's Server.
var() globalconfig string ShortName;		// Abbreviated name of server, i.e.: B's Serv (stupid example)
var() globalconfig string AdminName;		// Name of the server admin.
var() globalconfig string AdminEmail;		// Email address of the server admin.
var() globalconfig int    ServerRegion;		// Region of the game server.(name changed, region collided with actor::region)


var() globalconfig string MOTDLine1;		// Message
var() globalconfig string MOTDLine2;		// Of
var() globalconfig string MOTDLine3;		// The
var() globalconfig string MOTDLine4;		// Day

var string GameEndedComments;				// set by gameinfo when game ends

var PlayerReplicationInfo PRIArray[32];

replication
{
	reliable if ( Role == ROLE_Authority )
		GameName, GameClass, bTeamGame, ServerName, ShortName, AdminName,
		AdminEmail, ServerRegion, MOTDLine1, MOTDLine2, 
		MOTDLine3, MOTDLine4, RemainingMinute, bStopCountDown, GameEndedComments,
		NumPlayers;

	reliable if ( bNetInitial && (Role==ROLE_Authority) )
		RemainingTime, ElapsedTime;
}

simulated function PostBeginPlay()
{
	if( Level.NetMode == NM_Client )
	{
		// clear variables so we don't display our own values if the server has them left blank 
		ServerName = "";
		AdminName = "";
		AdminEmail = "";
		MOTDLine1 = "";
		MOTDLine2 = "";
		MOTDLine3 = "";
		MOTDLine4 = "";
	}

	SecondCount = Level.TimeSeconds;
	SetTimer(0.2, true);
}

simulated function Timer()
{
	local PlayerReplicationInfo PRI;
	local int i, FragAcc;

	if ( Level.NetMode == NM_Client )
	{
		if (Level.TimeSeconds - SecondCount >= Level.TimeDilation)
		{
			ElapsedTime++;
			if ( RemainingMinute != 0 )
			{
				RemainingTime = RemainingMinute;
				RemainingMinute = 0;
			}
			if ( (RemainingTime > 0) && !bStopCountDown )
				RemainingTime--;
			SecondCount += Level.TimeDilation;
		}
	}

	for (i=0; i<32; i++)
		PRIArray[i] = None;
	i=0;
	foreach AllActors(class'PlayerReplicationInfo', PRI)
	{
		if (i<32)
			PRIArray[i++] = PRI;
	}

	// Update various information.
	UpdateTimer = 0;
	for (i=0; i<32; i++)
		if (PRIArray[i] != None)
			FragAcc += PRIArray[i].Score;
	SumFrags = FragAcc;

	if ( Level.Game != None )
		NumPlayers = Level.Game.NumPlayers;
}

simulated function Debug(Canvas canvas, int mode)
{	
	Super.Debug(canvas, mode);

	Canvas.DrawText("GameReplicationInfo:");
	Canvas.CurY -= 8;
	Canvas.DrawText("GameName:  " $ GameName);
	Canvas.CurY -= 8;
	Canvas.DrawText("GameClass: " $ GameClass);
	Canvas.CurY -= 8;
	Canvas.DrawText("bTeamGame: " $ bTeamGame);
	Canvas.CurY -= 8;
	Canvas.DrawText("bClassicDeathMsgs: " $ bClassicDeathMessages);
	Canvas.CurY -= 8;
	Canvas.DrawText("bStopCountDown:    " $ bStopCountDown);
	Canvas.CurY -= 8;
	Canvas.DrawText("RemainingTime:     " $ RemainingTime);
	Canvas.CurY -= 8;
	Canvas.DrawText("ElapsedTime:       " $ ElapsedTime);
	Canvas.CurY -= 8;
	Canvas.DrawText("RemainingMinute:   " $ RemainingMinute);
	Canvas.CurY -= 8;
	Canvas.DrawText("SecondCount:       " $ SecondCount);
	Canvas.CurY -= 8;
	Canvas.DrawText("NumPlayers:        " $ NumPlayers);
	Canvas.CurY -= 8;
	Canvas.DrawText("SumFrags:          " $ SumFrags);
	Canvas.CurY -= 8;
	Canvas.DrawText("UpdateTimer:       " $ UpdateTimer);
	Canvas.CurY -= 8;
	Canvas.DrawText("ServerName:        " $ ServerName);
	Canvas.CurY -= 8;
	Canvas.DrawText("ShortName:         " $ ShortName);
	Canvas.CurY -= 8;
	Canvas.DrawText("AdminName:         " $ AdminName);
	Canvas.CurY -= 8;
	Canvas.DrawText("AdminEmail:        " $ AdminEmail);
	Canvas.CurY -= 8;
	Canvas.DrawText("ServerRegion:      " $ ServerRegion);
	Canvas.CurY -= 8;
	Canvas.DrawText("MOTDLine1:         " $ MOTDLine1);
	Canvas.CurY -= 8;
	Canvas.DrawText("MOTDLine2:         " $ MOTDLine2);
	Canvas.CurY -= 8;
	Canvas.DrawText("MOTDLine3:         " $ MOTDLine3);
	Canvas.CurY -= 8;
	Canvas.DrawText("MOTDLine4:         " $ MOTDLine4);
	Canvas.CurY -= 8;
	Canvas.DrawText("GameEndedComments: " $ GameEndedComments);
	Canvas.CurY -= 8;
}

defaultproperties
{
     bStopCountDown=True
     ServerName="A Rune Server"
     ShortName="Rune Server"
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=4.000000
}
