//=============================================================================
// LevelInfo contains information about the current level. There should 
// be one per level and it should be actor 0. UnrealEd creates each level's 
// LevelInfo automatically so you should never have to place one
// manually.
//
// The ZoneInfo properties in the LevelInfo are used to define
// the properties of all zones which don't themselves have ZoneInfo.
//=============================================================================
class LevelInfo extends ZoneInfo
	native;
//	nativereplication;

// Textures.
#exec Texture Import File=Textures\DefaultTexture.pcx

//-----------------------------------------------------------------------------
// Level time.

// Time passage.
var() float TimeDilation;          // Normally 1 - scales real time passage.

// Current time.
var           float	TimeSeconds;   // Time in seconds since level began play.
var transient int   Year;          // Year.
var transient int   Month;         // Month.
var transient int   Day;           // Day of month.
var transient int   DayOfWeek;     // Day of week.
var transient int   Hour;          // Hour.
var transient int   Minute;        // Minute.
var transient int   Second;        // Second.
var transient int   Millisecond;   // Millisecond.

//-----------------------------------------------------------------------------
// Text info about level.

var() localized string Title;
var()           string Author;		    // Who built it.
var() localized string IdealPlayerCount;// Ideal number of players for this level. I.E.: 6-8
var() int	RecommendedEnemies;			// number of enemy bots recommended (used by rated games)
var() int	RecommendedTeammates;		// number of friendly bots recommended (used by rated games)
var() localized string LevelEnterText;  // Message to tell players when they enter.
var()           string LocalizedPkg;    // Package to look in for localizations.
var             string Pauser;          // If paused, name of person pausing the game.
var levelsummary Summary;

//-----------------------------------------------------------------------------
// Flags affecting the level.

var() bool           bLonePlayer;     // No multiplayer coordination, i.e. for entranceways.
var bool             bBegunPlay;      // Whether gameplay has begun.
var bool             bPlayersOnly;    // Only update players.
var bool             bHighDetailMode; // Client high-detail mode.
var bool			 bDropDetail;	  // frame rate is below DesiredFrameRate, so drop high detail actors
var bool			 bAggressiveLOD;  // frame rate is well below DesiredFrameRate, so make LOD more aggressive
var bool             bStartup;        // Starting gameplay.
var() bool			 bHumansOnly;	  // Only allow "human" player pawns in this level
var bool			 bNoCheating;	  
var bool			 bAllowFOV;
var() bool 			 bFadeIn;		  // Start completely black and fade in
var() float			 FadeRate;		  // Time to fade in

//-----------------------------------------------------------------------------
// Audio properties.

var(Audio) const music  Song;          // Default song for level.
var(Audio) const byte   SongSection;   // Default song order for level.
var(Audio) const byte   CdTrack;       // Default CD track for level.
var(Audio) const float	CdTrackLength; // RUNE:  Length before the CD Track should repeat (0 = NoRepeat)
var(Audio) float        PlayerDoppler; // Player doppler shift, 0=none, 1=full.

//-----------------------------------------------------------------------------
// Miscellaneous information.

var() float Brightness;
var() texture Screenshot;
var texture DefaultTexture;
var int HubStackLevel;
var transient enum ELevelAction
{
	LEVACT_None,
	LEVACT_Loading,
	LEVACT_Saving,
	LEVACT_Connecting,
	LEVACT_Precaching
} LevelAction;

//-----------------------------------------------------------------------------
// Renderer Management.
var() bool bNeverPrecache;

//-----------------------------------------------------------------------------
// Networking.

var enum ENetMode
{
	NM_Standalone,        // Standalone game.
	NM_DedicatedServer,   // Dedicated server, no local client.
	NM_ListenServer,      // Listen server.
	NM_Client             // Client only, no local server.
} NetMode;
var string ComputerName;  // Machine's name according to the OS.
var string EngineVersion; // Engine version.
var string MinNetVersion; // Min engine version that is net compatible.
var string GameVersion;				// RUNE: Game version
var localized string BuildNumber;	// RUNE: Build number: engine.int

//-----------------------------------------------------------------------------
// Gameplay rules

var() class<gameinfo> DefaultGameType;
var GameInfo Game;

//-----------------------------------------------------------------------------
// Navigation point and Pawn lists (chained using nextNavigationPoint and nextPawn).

var const NavigationPoint NavigationPointList;
var const Pawn PawnList;

//-----------------------------------------------------------------------------
// Server related.

var string NextURL;
var bool bNextItems;
var float NextSwitchCountdown;

//-----------------------------------------------------------------------------
// Actor Performance Management

var int AIProfile[8]; // TEMP statistics
var float AvgAITime;	//moving average of Actor time

//-----------------------------------------------------------------------------
// Physics control

var() bool bCheckWalkSurfaces; // enable texture-specific physics code for Pawns.

//-----------------------------------------------------------------------------
// Spawn notification list
var SpawnNotify SpawnNotify;

//-----------------------------------------------------------------------------
// Functions.

//
// Return the URL of this level on the local machine.
//
native simulated function string GetLocalURL();

//
// Return the URL of this level, which may possibly
// exist on a remote machine.
//
native simulated function string GetAddressURL();

//
// Jump the server to a new level.
//
event ServerTravel( string URL, bool bItems )
{
	if( NextURL=="" )
	{
		bNextItems          = bItems;
		NextURL             = URL;
		if( Game!=None )
			Game.ProcessServerTravel( URL, bItems );
		else
			NextSwitchCountdown = 0;
	}
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_STONE;
}

// RUNE:  CD Audio restart functionality
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Restart CD music every <blah> minutes (right now, 10 seconds)
	if(CdTrack != 255)
	{
		Spawn(class'CDThinker');
	}
}

//-----------------------------------------------------------------------------
// Network replication.

replication
{
	reliable if( Role==ROLE_Authority )
		Pauser, TimeDilation, bNoCheating, bAllowFOV;
}

simulated function Debug(Canvas canvas, int mode)
{
	Super.Debug(canvas, mode);

	Canvas.DrawText("LevelInfo:");
	Canvas.CurY -= 8;
	Canvas.DrawText("  Game:                " $ Game);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bLonePlayer:         " $ bLonePlayer);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bBegunPlay:          " $ bBegunPlay);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bPlayersOnly:        " $ bPlayersOnly);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bHighDetailMode:     " $ bHighDetailMode);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bDropDetail:         " $ bDropDetail);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bAggressiveLOD:      " $ bAggressiveLOD);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bStartup:            " $ bStartup);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bHumansOnly:         " $ bHumansOnly);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bNoCheating:         " $ bNoCheating);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bAllowFOV:           " $ bAllowFOV);
	Canvas.CurY -= 8;
	Canvas.DrawText("  DefaultGameType:     " $ DefaultGameType);
	Canvas.CurY -= 8;
	Canvas.DrawText("  NavPointList:        " $ NavigationPointList);
	Canvas.CurY -= 8;
	Canvas.DrawText("  PawnList:            " $ PawnList);
	Canvas.CurY -= 8;
	Canvas.DrawText("  NextURL:             " $ NextURL);
	Canvas.CurY -= 8;
	Canvas.DrawText("  bNextItems:          " $ bNextItems);
	Canvas.CurY -= 8;
	Canvas.DrawText("  NextSwitchCountdown: " $ NextSwitchCountdown);

}

defaultproperties
{
     TimeDilation=1.000000
     Title="Untitled"
     bHighDetailMode=True
     FadeRate=1.000000
     CdTrack=255
     Brightness=1.000000
     DefaultTexture=Texture'Engine.DefaultTexture'
     bHiddenEd=True
     bSweepable=True
}
