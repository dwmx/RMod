//==============================================================================
//  R_RunePlayer
//  Base player class for all players in RMod.
//  For custom player classes in custom game modes, modify
//  R_GameInfo.RunePlayerClass.
//==============================================================================
class R_RunePlayer extends RunePlayer config(RMod);

//==============================================================================
//  Statics
var Class<R_AUtilities> UtilitiesClass;
var Class<R_AColors> ColorsClass;
var Class<R_AGameOptionsChecker> GameOptionsCheckerClass;
//==============================================================================

//==============================================================================
//  Behavior related classes
//  These classes are spawned at various parts of the gameplay and define
//  different aspects of the RunePlayer's behavior.
var Class<AnimationProxy> SpawnableAnimationProxyClass;
var Class<Actor> SpawnableSeveredHeadClass;
var Class<Actor> SpawnableSeveredLimbClass;
//==============================================================================

//==============================================================================
//  Sub-class variables
//  During the Login event, R_GameInfo calls R_RunePlayer.ApplyRunePlayerSubClass,
//  which extracts runeplayer skin data into these variables.
var Class<RunePlayer> RunePlayerSubClass;       // The RuneI.RunePlayer sub-class
var Class<Actor> RunePlayerSeveredHeadSubClass; // The RuneI.Head sub-class
var Class<Actor> RunePlayerSeveredLimbSubClass; // The RuneI.LimbWeapon sub-class
var byte PolyGroupBodyParts[16];

// PainSkin arrays
const MAX_SKEL_GROUP_SKINS = 16;
struct FSkelGroupSkinArray
{
    var Texture Textures[16];
};
// Indexed by BODYPART consts
var FSkelGroupSkinArray PainSkinArrays[16];
var FSkelGroupSkinArray GoreCapArrays[16];
//==============================================================================

//==============================================================================
//  Networked movement vars adopted from 469b
var R_SavedMove SavedMoves;
var R_SavedMove FreeMoves;
var R_SavedMove PendingMove;

var transient float AccumulatedHTurn, AccumulatedVTurn; // Discarded fractional parts of horizontal (Yaw) and vertical (Pitch) turns
var float LastMessageWindow;
const SmoothAdjustLocationTime = 0.35f;
const MinPosError = 10;
const MaxPosError = 1000;
var transient Vector PreAdjustLocation;
var transient Vector AdjustLocationOffset;
var transient float AdjustLocationAlpha;
var bool OnMover, FakeUpdate, bForceUpdate;
var float LastClientErr, IgnoreUpdateUntil, ForceUpdateUntil, LastStuffUpdate;
var transient float LastClientTimestamp;
//==============================================================================

//==============================================================================
//  Weapon Swipes
//  R_WeaponSwipe grabs these textures and updates itself every
//  time a weapon swing or throw occurs. If no texture is set for the
//  corresponding state, then the weapon swipe won't enable itself.
//  E.g. WeaponSwipeTexture=None will disable normal weapon swipes.
var Texture WeaponSwipeTexture;
var Texture WeaponSwipeBloodlustTexture;
//==============================================================================

//==============================================================================
//  Loadout Menu
var Class<R_LoadoutReplicationInfo> LoadoutReplicationInfoClass;
var R_LoadoutReplicationInfo LoadoutReplicationInfo;
var bool bLoadoutMenuDoNotShow;
//==============================================================================

//==============================================================================
//  Spectator related variables
var Class<HUD> HUDTypeSpectator;
var Class<R_ACamera> SpectatorCameraClass;

var R_ACamera Camera;
var Name PreviousStateName;

// Replicated for spectator POV mode
var private float ViewRotPovPitch;  
var private float ViewRotPovYaw;
//==============================================================================

//==============================================================================
//  Prevent lamers from stupid stuff
struct FSuicideSpamParameters
{
    var float TimeStamp;
    var float CooldownDuration;
};
var FSuicideSpamParameters SuicideSpamParameters;

struct FChatSpamParameters
{
    var float TimeCost;             // Every message costs this much time
    var float TimeAccumulator;      // How much available time the player has
    var float TimeAccumulationMax;  // Maximum accumlated chat time
    var float TimePenalty;          // Time-out for spamming
};
var FChatSpamParameters ChatSpamParameters;

struct FPlayerValidationParameters
{
    var float TimeDilation;
};

//==============================================================================
//  Client Adjustment variables
//  These variables control the frequency and client error threshold for the
//  server to send ClientAdjustPosition updates during ServerMove.
//  This is the client jitter fix
//  Use exec function ToggleRmodDebug to display markers for client adjusts.
//var float ClientAdjustErrorThreshold;
//var float ClientAdjustCooldownSeconds;
var bool bShowRmodDebug;
var R_ClientDebugActor ClientDebugActor;
//==============================================================================

//==============================================================================
//  Authoritative variables replicated to clients

// The authoritative state of this player.
var Name AuthoritativeStateName;
//  Since AnimProxy is not an AutonomousProxy, its more efficient to replicate
//  this variable in R_RunePlayer than in R_RunePlayerProxy.
//  This is used for improved client-side prediction, fixing things like
//  the stuttering ledge grabs.
var Name AuthoritativeAnimProxyStateName;
var bool bAuthoritativeBloodlust; // Necessary for clients to see bloodlust swipe
//==============================================================================

//==============================================================================
//  Rope climbing vars

// Stores the most recently touched rope, so that when the player jumps off,
// they can't re-grab the same rope.
var Actor LastTouchedClimbable;
//==============================================================================

//==============================================================================
//  Abstract Event Listener
var R_AEventListener EventListenerInstance;
//==============================================================================

replication
{
    // (Variables) Server --> All Clients
    // Initial replication only
    reliable if(Role == ROLE_Authority && bNetInitial)
        RunePlayerSubClass;
    
    // (Variables) Server --> All Clients
    reliable if(Role == ROLE_Authority)
        HUDTypeSpectator,
        Camera,
        WeaponSwipeTexture,
        WeaponSwipeBloodlustTexture,
        AuthoritativeStateName,
        bAuthoritativeBloodlust;

    // (Variables) Server --> Owning Client
    reliable if(Role == ROLE_Authority && RemoteRole == ROLE_AutonomousProxy)
        AuthoritativeAnimProxyStateName,
        LoadoutReplicationInfo;

    // (Variables) Server --> All Clients (except Owning Client)
    unreliable if(Role == ROLE_Authority && RemoteRole != ROLE_AutonomousProxy)
        ViewRotPovPitch,
        ViewRotPovYaw;

    unreliable if(RemoteRole == ROLE_AutonomousProxy)
        FakeCAP;

    // (RPCs) Server --> Owning Client
    reliable if(Role == ROLE_Authority && RemoteRole == ROLE_AutonomousProxy)
        ClientReceiveUpdatedGamePassword,
        ClientPreTeleport,
        ClientOpenLoadoutMenu,
        ClientCloseLoadoutMenu;

    // (RPCs) Owning Client --> Server
    reliable if(Role == ROLE_AutonomousProxy)
        ServerResetLevel,
        ServerSpectate,
        ServerTimeLimit,
        ServerTempBan;
        
    reliable if(Role < ROLE_Authority)
        ServerValidatePlayer,
        ServerMove_v2;
    
    unreliable if(Role < ROLE_Authority)
        ServerClientRepVars;
}

/**
*   CheckCanGrabClimbable
*   Returns whether or not the player can currently grab a climbable (rope) actor
*   Note that server will crash if this function returns true when TheRope != None
*/
function bool CheckCanGrabClimbable(R_ClimbableBase ClimbableActor)
{
    // Valid climbable actor check
    if(ClimbableActor == None || TheRope != None)
        return false;
    
    // Physics check
    if(Physics != PHYS_Falling && Physics != PHYS_Swimming)
        return false;
    
    // State check
    if(GetStateName() == 'PlayerRopeClimbing')
        return false;
    
    // Anim proxy state check - only allowed while idle
    if(AnimProxy != None && AnimProxy.GetStateName() != 'Idle')
        return false;
    
    // Never re-grab the most recently grabbed climbable
    // This is initialized in PlayerRopeClimbing.BeginState,
    // and it's cleared in PlayerWalking.BeginState
    if(LastTouchedClimbable == ClimbableActor)
        return false;
    
    return true;
}

/**
*   Touch (override)
*   Overridden to ignore rope if there already is one stored in the TheRope var
*/
function Touch(Actor Other)
{
    local vector HandPos, pos;
    LookTarget = Other;
    
    // RunePlayer.Touch will cause a stack overflow on clients
    Super(PlayerPawn).Touch(Other);

    if(Role == ROLE_Authority)
    {
        if(CheckCanGrabClimbable(R_ClimbableBase(Other)))
        { // Only grab the rope if the player can and if the player is in the air/swimming
            HandPos = Location;
            HandPos.Z += HandOffset;
        
            TheRope = Rope(Other);
            TheRope.ComputeClimbingEndpoints(HandPos.Z);
        
            if (HandPos.Z < TheRope.RopeClimbBottom.Z)
                return;
        
            TheRope.AttachedToRope(self);
        
            // Make sure right on rope
            pos = TheRope.Location;
            pos.Z = Location.Z;
            SetLocation(pos);
        
            Acceleration = vect(0, 0, 0);
            Velocity = vect(0, 0, 0);
            RopeDist = TheRope.RopeClimbTop.Z - HandPos.Z;
        
            GotoState('PlayerRopeClimbing');
        }  
    }
}

/**
*   CanPickup (override)
*   Overridden to prevent duplicate inventory pickups.
*/
function bool CanPickup(Inventory Item)
{
    if(FindInventoryType(Item.Class) != None)
    {
        return false;
    }
    return Super.CanPickup(Item);
}

/**
*   VerifyAdminWithErrorMessage
*   Check if this player has admin rights and send a client message if not.
*/
function bool VerifyAdminWithErrorMessage()
{
    if(bAdmin)
    {
        return true;
    }
    else
    {
        ClientMessage("You need administrator rights");
        return false;
    }
    return false;
}

//==============================================================================
//  Begin Exec Function Overrides
//==============================================================================
/**
*   AdminLogin (override)
*   Overridden to log AdminLogin attempts.
*/
exec function AdminLogin(String Password)
{
    local String PlayerName;

    PlayerName = "";
    if(PlayerReplicationInfo != None)
    {
        PlayerName = PlayerReplicationInfo.PlayerName;
    }

    UtilitiesClass.Static.RModLog
    (
        "AdminLogin attempt from player" @ PlayerName @ "(" $ Self $ "):" @ Password
    );

    Level.Game.AdminLogin(Self, Password);
}

/**
*   AdminLogout (override)
*   Overridden to log AdminLogout attempts.
*/
exec function AdminLogout()
{
    local String PlayerName;

    PlayerName = "";
    if(PlayerReplicationInfo != None)
    {
        PlayerName = PlayerReplicationInfo.PlayerName;
    }

    UtilitiesClass.Static.RModLog
    (
        "AdminLogout attempt from player" @ PlayerName @ "(" $ Self $ ")"
    );

    Level.Game.AdminLogout( Self );
}

/**
*   Admin (override)
*   Overridden to route all admin commands through verification function.
*/
exec function Admin(String CommandLine)
{
    local String Result;

    if(!VerifyAdminWithErrorMessage())
    {
        return;
    }

    Result = ConsoleCommand(CommandLine);
    if(Result != "")
    {
        ClientMessage(Result);
    }
}

/**
*   Throw (override)
*   Overridden to allow player to drop shield with Throw input when they
*   have to currently equipped weapon.
*/
exec function Throw()
{
    if(Weapon == None)
    {
        if(Shield != None)
        {
            DropShield();
        }

        return;
    }
    else
    {
        if( bShowMenu || (Level.Pauser!=""))
        {
            return;
        }
        
        if(AnimProxy != None && AnimProxy.Throw())
        {
            PlayAnim('ATK_ALL_throw1_AA0S', 1.0, 0.1);
        }
    }
    
    
}

/**
*   Powerup (override)
*   Overridden to allow players to manually activate bloodlust by holding the defend
*   key and pressing the rune power button
*/
exec function Powerup()
{
    local bool bManualBloodlustActivationAllowed;
    
    if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) || Health <= 0)
    {
        return;
    }
    
    // Get manual bloodlust game option
    bManualBloodlustActivationAllowed = false;
    if(GameOptionsCheckerClass != None)
    {
        bManualBloodlustActivationAllowed = GameOptionsCheckerClass.Static.GetGameOption_ManualBloodlust(Self);
    }
    
    // Manual bloodlust attempt when alt fire is held
    if(bAltFire == 1 && bManualBloodlustActivationAllowed)
    {
        if(bBloodLust)
        {
            return;
        }
        
        // Try to enable bloodlust manually
        if(bManualBloodlustActivationAllowed && Strength >= 25)
        {
            EnableBloodlust();
        }
        else
        {
            PlaySound(PowerupFail, SLOT_Interface);
            ClientMessage("Not enough STRENGTH", 'NoRunePower');
            return;
        }
    }
    else
    {
        Super.Powerup();
    }
}

/**
*   Use (override)
*   Overridden to handle PlayerRopeClimbing state. See PlayerRopeClimbing.Use
*   for notes on why it's necessary to do this in the Global function.
*/
exec function Use()
{
    if(GetStateName() == 'PlayerRopeClimbing')
    {
        ClimbableFallOff();
    }
    else
    {
        Super.Use();
    }
}

/**
*   Suicide (override)
*   Overridden to prevent suicide-spam server attacks.
*   TODO:
*   It would be a good idea to implement auto-disconnect functionality here
*   when the server detects players spamming suicide.
*/
exec function Suicide()
{
    // Anti spam
    if(Level.TimeSeconds - SuicideSpamParameters.TimeStamp <= SuicideSpamParameters.CooldownDuration)
    {
        return;
    }

    SuicideSpamParameters.TimeStamp = Level.TimeSeconds;
    KilledBy( None );
}

/**
*   CheckAndHandleChatSpam
*   Checks if the player is spamming chat and puts them in cooldown if so.
*   Should be called from any Say functions.
*   Returns whether or not the player is spamming chat.
*/
function bool CheckAndHandleChatSpam()
{
    // Check anti spam
    if(ChatSpamParameters.TimeAccumulator - ChatSpamParameters.TimeCost < 0.0)
    {
        // Put player into spam timeout
        ChatSpamParameters.TimeAccumulator = -ChatSpamParameters.TimePenalty;

        // Tell player to stop spamming
        ClientMessage("Stop spamming." @ int(ChatSpamParameters.TimePenalty) @ "second cooldown.");

        return true;
    }
    else
    {
        ChatSpamParameters.TimeAccumulator -= ChatSpamParameters.TimeCost;
    }

    return false;
}

/**
*   Say (override)
*   Overridden to filter out spectator messages for non-spectator players.
*/
// TODO: This should maybe be moved to a filter function on the HUD
exec function Say( string Msg )
{
    local Pawn P;
    local R_GameInfo RGI;

    // Anti spam
    if(CheckAndHandleChatSpam())
    {
        return;
    }

    if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
    {
        RGI = R_GameInfo(Level.Game);
        for( P=Level.PawnList; P!=None; P=P.nextPawn )
        {
            // Filter spectator messages as necessary
            if(RGI != None
            && !RGI.bAllowSpectatorBroadcastMessage
            && P.PlayerReplicationInfo != None
            && PlayerReplicationInfo.bIsSpectator
            && !P.PlayerReplicationInfo.bIsSpectator)
            {
                continue;
            }

            if( P.bIsPlayer || P.IsA('MessagingSpectator') )
            {
                P.TeamMessage( PlayerReplicationInfo, Msg, 'Say', true );
            }
        }
    }
    return;
}

/**
*   TeamSay (override)
*   Overridden to filter out spectator messages for non-spectator players.
*/
// TODO: This should maybe be moved to a filter function on the HUD
exec function TeamSay( string Msg )
{
    local Pawn P;
    local R_GameInfo RGI;

    if ( !Level.Game.bTeamGame )
    {
        Say(Msg);
        return;
    }

    // Anti spam
    if(CheckAndHandleChatSpam())
    {
        return;
    }

    if ( Msg ~= "Help" )
    {
        CallForHelp();
        return;
    }
            
    if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
    {
        RGI = R_GameInfo(Level.Game);
        for( P=Level.PawnList; P!=None; P=P.nextPawn )
        {
            // Filter spectator messages as necessary
            if(RGI != None
            && !RGI.bAllowSpectatorBroadcastMessage
            && P.PlayerReplicationInfo != None
            && PlayerReplicationInfo.bIsSpectator
            && !P.PlayerReplicationInfo.bIsSpectator)
            {
                continue;
            }

            if( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
            {
                if ( P.IsA('PlayerPawn') )
                {
                    P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
                }
            }
        }
    }
}
//==============================================================================
//  End Exec Function Overrides
//==============================================================================

/**
*   TeamMessage (override)
*   Overridden to fix an 'accessed none' error when this function gets called
*   on a non-player R_RunePlayer, even though bIsPlayer is true.
*   Error occurs when attempting to access the Player variable.
*/
event TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep  )
{
    local Class<LocalMessage> MessageClass;

    if (Type == '')
        Type = 'Event';
    if ( myHUD != None )
    {
        MessageClass = myHUD.DetermineClass(Type);
        MessageClass.Static.ClientReceiveMessage(Self, S, PRI);
    }
    else if(Player != None)
    {
        if (Player.Console != None)
            Player.Console.Message( PRI, S, Type );
        if (bBeep && bMessageBeep)
            PlayBeepSound();
    }
}


//==============================================================================
//  Begin RMod Client Interface
//==============================================================================
/**
*   LogPlayerIDs
*   Print all player IDs to the client's log.
*/
exec function LogPlayerIDs()
{
    local PlayerReplicationInfo PRI;
    
    UtilitiesClass.Static.RModLog("LogPlayerIDs output:");
    foreach AllActors(Class'Engine.PlayerReplicationInfo', PRI)
    {
        UtilitiesClass.Static.RModLog(
            "ID: " $ PRI.PlayerID $ ", " $
            "Name: " $ PRI.PlayerName);
    }
}

/**
*   ResetLevel
*   Performs a soft level reset. Resets the map state without reloading the map.
*   Useful for restarting maps only after all players have loaded in.
*/
exec function ResetLevel(optional int DurationSeconds)
{
    ServerResetLevel(DurationSeconds);
}

function ServerResetLevel(optional int DurationSeconds)
{
    local R_GameInfo GI;
    
    if(!VerifyAdminWithErrorMessage())
    {
        return;
    }
    
    GI = R_GameInfo(Level.Game);
    if(GI == None)
    {
        return;
    }
    
    GI.ResetLevel(DurationSeconds);
}

/**
*   TimeLimit
*   Update the game's time limit on the fly.
*/
exec function TimeLimit(int DurationMinutes)
{
    ServerTimeLimit(DurationMinutes);
}

function ServerTimeLimit(int DurationMinutes)
{
    local R_GameInfo GI;
    
    if(!VerifyAdminWithErrorMessage())
    {
        return;
    }
    
    GI = R_GameInfo(Level.Game);
    if(GI == None)
    {
        return;
    }
    
    GI.PlayerSetTimeLimit(self, DurationMinutes);
}

/**
*   TempBan
*   Temporarily ban a player for some duration.
*/
exec function TempBan(int PlayerID, float DurationSeconds, String Reason)
{
    ServerTempBan(PlayerID, DurationSeconds, Reason);
}

function ServerTempBan(int PlayerID, float DurationSeconds, String Reason)
{
    local R_GameInfo RGI;
    local PlayerPawn PlayerPawn;

    if(!VerifyAdminWithErrorMessage())
    {
        return;
    }

    RGI = R_GameInfo(Level.Game);
    if(RGI == None)
    {
        return;
    }

    PlayerPawn = RGI.GetPlayerPawnByID(PlayerID);
    if(PlayerPawn != None)
    {
        RGI.TempBan(PlayerPawn, DurationSeconds, Reason);
    }
}

/**
*   Loadout
*   Opens the loadout menu when the game mode allows for it
*   R_GameInfo.bLoadoutsEnabled must be true
*/
exec function Loadout()
{
    // Always revert the DoNotShow option when user explicitly calls this function
    bLoadoutMenuDoNotShow = false;
    OpenLoadoutMenu();
}

/**
*   Spectate
*   Allows clients to switch to spectator mode while in-game.
*/
exec function Spectate()
{
    ServerSpectate();
}

function ServerSpectate()
{
    local R_GameInfo GI;
    GI = R_GameInfo(Level.Game);
    if(GI != None)
    {
        GI.RequestSpectate(Self);
    }
}

/**
*   ToggleRmodDebug
*   Spawns an actor for debug visualization
*   See R_ClientDebugActor for more info
*/
exec function ToggleRmodDebug()
{
    bShowRmodDebug = !bShowRmodDebug;
    if(bShowRmodDebug && ClientDebugActor == None)
    {
        ClientDebugActor = Spawn(Class'RMod.R_ClientDebugActor', Self);
    }
    else if(!bShowRmodDebug && ClientDebugActor != None)
    {
        ClientDebugActor.Destroy();
    }
}
//==============================================================================
//  End RMod Client Interface
//==============================================================================


/**
*   PreBeginPlay (override)
*   Overridden to allow player replication info and anim proxy to be spawned
*   based on classes.
*/
event PreBeginPlay()
{
    Enable('Tick');

    if(R_GameInfo(Level.Game) != None)
    {
        PlayerReplicationInfoClass = R_GameInfo(Level.Game).PlayerReplicationInfoClass;
    }

    // Bypass RunePlayer's PreBeginPlay, because it will respawn anim proxy
    Super(PlayerPawn).PreBeginPlay();

    // Spawn Torso Animation proxy
    AnimProxy = Spawn(Self.SpawnableAnimationProxyClass, Self);

    OldCameraStart = Location;
    OldCameraStart.Z += CameraHeight;

    CurrentDist = CameraDist;
    LastTime = 0;
    CurrentTime = 0;
    CurrentRotation = Rotation;

    // Adjust CrouchHeight to new DrawScale
    CrouchHeight = CrouchHeight * DrawScale;
}

/**
*   PostBeginPlay (override)
*   Grab additional data from R_GameInfo at startup
*/
event PostBeginPlay()
{
    local R_GameInfo RGI;

    Super.PostBeginPlay();

    RGI = R_GameInfo(Level.Game);
    if(RGI != None)
    {
        MaxHealth = RGI.DefaultPlayerMaxHealth;
        Health = RGI.DefaultPlayerHealth;
        MaxPower = RGI.DefaultPlayerMaxRunePower;
        RunePower = RGI.DefaultPlayerRunePower;

        HUDTypeSpectator = RGI.HUDTypeSpectator;

        if(RGI.bLoadoutsEnabled)
        {
            SpawnLoadoutReplicationInfo();
        }
    }
}

event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if(Role < ROLE_Authority)
    {
        ValidatePlayer();
    }
}

function ValidatePlayer()
{
    local FPlayerValidationParameters ValidationParams;

    ValidationParams.TimeDilation = Level.TimeDilation;

    ServerValidatePlayer(ValidationParams);
}

function ServerValidatePlayer(FPlayerValidationParameters ValidationParams)
{
    local R_GameInfo RGI;

    RGI = R_GameInfo(Level.Game);
    if(RGI == None)
    {
        UtilitiesClass.Static.RModLog("ServerValidatePlayer failed, RGI is None");
        return;
    }

    if(ValidationParams.TimeDilation != 1.0)
    {
        RGI.ReportValidationFailed(Self, "client-side timedilation =" @ ValidationParams.TimeDilation);
        return;
    }

    RGI.ReportValidationSucceeded(Self);
}

/**
*   PostRender (override)
*   Overridden to render the RMod client debug actor when enabled
*/
event PostRender(Canvas C)
{
    Super.PostRender(C);
    
    if(bShowRmodDebug && ClientDebugActor != None)
    {
        ClientDebugActor.PostRender(C);
    }
}

/**
*   PreRender (override)
*   Overridden to ensure that when the player is not in spectator state,
*   they will use the normal HUD. Spectator state applies a different HUD.
*/
event PreRender(canvas Canvas)
{
	if (bDebug == 1)
	{
		if (myDebugHUD != None)
		{
			myDebugHUD.PreRender(Canvas);
		}
		else if (Viewport(Player) != None)
		{
			myDebugHUD = spawn(Class'Engine.DebugHUD', Self);
		}
	}

	if (myHUD != None && R_RunePlayerHUDSpectator(myHUD) != None)
	{
		myHUD.Destroy();
		myHUD = None;
	}

	if (myHUD == None && HUDType != None)
	{
		myHUD = Spawn(HUDType, Self);
	}
	else if (myHUD != None && myHUD.Class != HUDType)
	{
		myHUD.Destroy();
		myHUD = Spawn(HUDType, Self);
	}

	if (myHUD != None)
	{
		myHUD.PreRender(Canvas);
	}

	if (bClientSideAlpha)
	{
		OldStyle = Style;
		OldScale = AlphaScale;
		Style = STY_AlphaBlend;
		AlphaScale = ClientSideAlphaScale;
	}
}

/**
*   Tick (override)
*   Overridden to perform server-side update of bAuthoritativeBloodlust
*/
event Tick(float DeltaSeconds)
{
    local Rotator NewRotation;
    
    Super.Tick(DeltaSeconds);
    
    // Anti spam update
    ChatSpamParameters.TimeAccumulator += DeltaSeconds;
    ChatSpamParameters.TimeAccumulator = FMin(ChatSpamParameters.TimeAccumulator, ChatSpamParameters.TimeAccumulationMax);

    // Hack - prevents runeplayers from pitching up / down when they change states
    // This isn't the best place for this, but it's the easiest.
    NewRotation = Rotation;
    NewRotation.Pitch = 0;
    NewRotation.Roll = 0;
    SetRotation(NewRotation);
    
    // Replicate authoritative vars if they've changed
    if(Role == ROLE_Authority)
    {
        AuthoritativeStateName = GetStateName();
        bAuthoritativeBloodlust = bBloodlust;
        
        if(AnimProxy != None)
        {
            AuthoritativeAnimProxyStateName = AnimProxy.GetStateName();
        }
    }
    else
    {
        if(AuthoritativeStateName != GetStateName())
        {
            GotoState(AuthoritativeStateName);
        }
    }
}

/**
*   Destroyed (override)
*   Overridden to destroy LRI on RunePlayer destruction.
*   This event being overridden is causing client crashes for some reason,
*   even if the event is empty.
*   For now, the LRI will destroy itself when it no longer has an owner.
*/
//event Destroyed()
//{
//    if(Role == ROLE_Authority && LoadoutReplicationInfo != None)
//    {
//        LoadoutReplicationInfo.Destroy();
//    }
//    
//    Super.Destroyed();
//}

/**
*   PreTeleport (override)
*   Overridden to bypass camera interpolation and make teleporting feel
*   seamless (still needs work).
*/
event bool PreTeleport(Teleporter InTeleporter)
{
    if(!Super.PreTeleport(InTeleporter))
    {
        return false;
    }

    if(Role == ROLE_Authority)
    {
        ClientPreTeleport(InTeleporter);
    }
    DoPreTeleport(InTeleporter);
    return true;
}

function ClientPreTeleport(Teleporter InTeleporter)
{
    DoPreTeleport(InTeleporter);
}

/**
*   DoPreTeleport
*   Runs on both server and client. Updates all variables involved
*   in camera interpolation to make teleporting feel seamless.
*/
function DoPreTeleport(Teleporter InTeleporter)
{
    local Rotator NewRotation;
    local Vector NewLocation;
    local Rotator NewViewRotation;

    // Client-side prediction
    if(Role < ROLE_Authority)
    {
        NewRotation = InTeleporter.Rotation;
        NewRotation.Pitch = 0;
        NewRotation.Roll = 0;

        NewLocation = InTeleporter.Location;

        OldCameraStart = (OldCameraStart - Location) + NewLocation;
        SavedCameraLoc = (SavedCameraLoc - Location) + NewLocation;
        
        NewViewRotation = NewRotation;
        NewViewRotation.Pitch = ViewRotation.Pitch;

        ViewLocation = SavedCameraLoc;
        ViewRotation = NewViewRotation;

        SetLocation(NewLocation);
        SetRotation(NewRotation);
    }
}



/**
*   ClientReceiveUpdatedGamePassword
*   Called from R_GameInfo when game password is updated. This allows
*   administrators to password the server without losing everyone on
*   map change. Useful for competitive games.
*/
function ClientReceiveUpdatedGamePassword(String NewGamePassword)
{
    UpdateURL("Password", NewGamePassword, false);
    ClientMessage("Local password has been updated:" @ NewGamePassword);
}

/**
*   DiscardInventory
*   Clear this player's entire inventory. GameInfo has a DiscardInventory
*   function of its own and I don't fully remember why this is here.
*/
function DiscardInventory()
{
    local Inventory Curr;
    local Inventory Next;
    
    for(Curr = Self.Inventory; Curr != None; Curr = Next)
    {
        Next = Curr.Inventory;
        DeleteInventory(Curr);
        Curr.Destroy();
    }
    
    Self.Weapon = None;
    Self.SelectedItem = None;
    Self.Shield = None;
    
    Self.StowSpot[0] = None;
    Self.StowSpot[1] = None;
    Self.StowSpot[2] = None;
}

/**
*   ChangeName (override)
*   Overridden to cause GameInfo to broadcast a message
*   when players change their names.
*/
function ChangeName(coerce String S)
{
    // Last arg = true causes GameInfo to broadcast a message
    Level.Game.ChangeName(Self, S, true);
}

//==============================================================================
//  Begin Sub-Class Functions
//==============================================================================
/**
*   ApplyRunePlayerSubClass
*   The following functions are responsible for extracting all custom skin-based
*   data from the provided RunePlayer class, and applying it to this instance.
*   This is called during the login sequence from R_GameInfo.
*/
function ApplyRunePlayerSubClass(Class<RunePlayer> SubClass)
{
    local RunePlayer Dummy;
    local int i, j;
    
    Self.RunePlayerSubClass = SubClass;
    ApplyRunePlayerSubClass_ExtractDefaults(SubClass);
    
    // Spawn a Dummy instance to get info from functions
    if(Role == ROLE_Authority
    && R_GameInfo(Level.Game) != None
    && SubClass != R_GameInfo(Level.Game).SpectatorMarkerClass)
    {
        // Disable collision so Dummy pawn doesn't explode
        Self.SetCollision(false, false, false);
        Dummy = Spawn(SubClass, self);
        if(Dummy != None)
        {
            Dummy.SetCollision(false, false, false);
            Dummy.bHidden = true;
            Dummy.RemoteRole = ROLE_None;

            ApplyRunePlayerSubClass_ExtractBodyPartData(SubClass, Dummy);
            ApplyRunePlayerSubClass_ExtractPainSkinData(SubClass, Dummy);
            ApplyRunePlayerSubClass_ExtractGoreCapData(SubClass, Dummy);
            
            // Destroy Dummy and turn collision back on
            //      When you spawn a PlayerPawn, GameInfo.Login does not get called,
            //      but GameInfo.Logout DOES get called when the pawn is destroyed.
            //      This is the cause of the negative player count bug.
            //      R_GameInfo looks for the dummy tag and ignores the destroyed
            //      pawn at GameInfo.Logout to bypass the issue
            ApplyDummyTag(Dummy);
            Dummy.Destroy();
        }
        Self.SetCollision(true, true, true);
    }

    // Extract the menu name so this looks correct in server browser
    ApplyRunePlayerSubClass_ExtractMenuName(SubClass);
}

/**
*   ApplyDummyTag
*   Apply the tag that R_GameInfo.Logout will look for when ignoring dummies.
*/
static function ApplyDummyTag(Actor A)
{
    A.Tag = 'RMODDUMMY';
}

/**
*   CheckForDummyTag
*   Check if the provided actor has the dummy tag applied.
*/
static function bool CheckForDummyTag(Actor A)
{
    if(A.Tag == 'RMODDUMMY')
    {
        return true;
    }
    return false;
}

/**
*   ApplyRunePlayerSubClass_ExtractDefaults
*   Extract all relevant default properties from the RunePlayer class.
*/
function ApplyRunePlayerSubClass_ExtractDefaults(Class<RunePlayer> SubClass)
{
    local int i;

    Self.WeaponPickupSound          = SubClass.Default.WeaponPickupSound;
    Self.WeaponThrowSound           = SubClass.Default.WeaponThrowSound;
    Self.WeaponDropSound            = SubClass.Default.WeaponDropSound;
    for(i = 0; i < 3; ++i)
        Self.JumpGruntSound[i]      = SubClass.Default.JumpGruntSound[i];
    Self.JumpSound                  = SubClass.Default.JumpSound;
    Self.LandGrunt                  = SubClass.Default.LandGrunt;
    Self.FallingDeathSound          = SubClass.Default.FallingDeathSound;
    Self.FallingScreamSound         = SubClass.Default.FallingScreamSound;
    Self.UnderWaterDeathSound       = SubClass.Default.UnderWaterDeathSound;
    Self.EdgeGrabSound              = SubClass.Default.EdgeGrabSound;
    Self.StepUpSound                = SubClass.Default.StepUpSound;
    Self.KickSound                  = SubClass.Default.KickSound;
    for(i = 0; i < 3; ++i)
        Self.HitSoundLow[i]         = SubClass.Default.HitSoundLow[i];
    for(i = 0; i < 3; ++i)
        Self.HitSoundMed[i]         = SubClass.Default.HitSoundMed[i];
    for(i = 0; i < 3; ++i)
        Self.HitSoundHigh[i]        = SubClass.Default.HitSoundHigh[i];
    for(i = 0; i < 6; ++i)
        Self.UnderWaterAmbient[i]   = SubClass.Default.UnderWaterAmbient[i];
    Self.BerserkSoundStart          = SubClass.Default.BerserkSoundStart;
    Self.BerserkSoundEnd            = SubClass.Default.BerserkSoundEnd;
    Self.BerserkSoundLoop           = SubClass.Default.BerserkSoundLoop;
    for(i = 0; i < 6; ++i)
        Self.BerserkYellSound[i]    = SubClass.Default.BerserkYellSound[i];
    Self.CrouchSound                = SubClass.Default.CrouchSound;
    for(i = 0; i < 3; ++i)
        Self.RopeClimbSound[i]      = SubClass.Default.RopeClimbSound[i];
    Self.Die                        = SubClass.Default.Die;
    Self.Die2                       = SubClass.Default.Die2;
    Self.Die3                       = SubClass.Default.Die3;
    Self.MaxMouthRot                = SubClass.Default.MaxMouthRot;
    Self.MaxMouthRotRate            = SubClass.Default.MaxMouthRotRate;
    Self.SkelMesh                   = SubClass.Default.SkelMesh;
    for(i = 0; i < 16; ++i)
        Self.SkelGroupSkins[i]      = SubClass.Default.SkelGroupSkins[i];
    for(i = 0; i < 16; ++i)
        Self.SkelGroupFlags[i]      = SubClass.Default.SkelGroupFlags[i];
    for(i = 0; i < 50; ++i)
        Self.JointFlags[i]          = SubClass.Default.JointFlags[i];
    for(i = 0; i < 50; ++i)
        Self.JointChild[i]          = SubClass.Default.JointChild[i];
    Self.SubstituteMesh             = SubClass.Default.SubstituteMesh;
}

/**
*   ApplyRunePlayerSubClass_ExtractBodyPartData
*   Extracts the classes used for severed limb body parts on the provided class.
*   This data cannot be extracted (that I'm aware of) from the class, so
*   it requires an instance of the RunePlayer.
*/
function ApplyRunePlayerSubClass_ExtractBodyPartData(Class<RunePlayer> SubClass, RunePlayer SubClassInstance)
{
    local int i;

    for(i = 0; i < 16; ++i)
    {
        PolyGroupBodyParts[i] = SubClassInstance.BodyPartForPolyGroup(i);
    }

    RunePlayerSeveredHeadSubClass = SubClassInstance.SeveredLimbClass(BODYPART_HEAD);
    RunePlayerSeveredLimbSubClass = SubClassInstance.SeveredLimbClass(BODYPART_LARM1);
}

/**
*   ApplyRunePlayerSubClass_ExtractPainSkinData
*   Extract the pain skin textures from the provided RunePlayer class.
*/
function ApplyRunePlayerSubClass_ExtractPainSkinData(Class<RunePlayer> SubClass, RunePlayer SubClassInstance)
{
    local int i, j;

    // Initialize pain skins
    for(i = 0; i < NUM_BODYPARTS; ++i)
    {
        for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
        {
            PainSkinArrays[i].Textures[j] = None;
        }
    }

    // Extract from subclass
    for(i = 0; i < NUM_BODYPARTS; ++i)
    {
        for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
        {
            SubClassInstance.SkelGroupSkins[i] = None;
        }

        SubClassInstance.PainSkin(i);

        for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
        {
            PainSkinArrays[i].Textures[j] = SubClassInstance.SkelGroupSkins[j];
        }
    }
}

/**
*   ApplyRunePlayerSubClass_ExtractGoreCapData
*   Extract gore cap textures from the provided RunePlayer class.
*/
function ApplyRunePlayerSubClass_ExtractGoreCapData(Class<RunePlayer> SubClass, RunePlayer SubClassInstance)
{
    local int i, j;

    // Initialize gore cap skins
    for(i = 0; i < NUM_BODYPARTS; ++i)
    {
        for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
        {
            GoreCapArrays[i].Textures[j] = None;
        }
    }

    // Extract from subclass
    for(i = 0; i < NUM_BODYPARTS; ++i)
    {
        for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
        {
            SubClassInstance.SkelGroupSkins[i] = None;
        }

        SubClassInstance.ApplyGoreCap(i);

        for(j = 0; j < MAX_SKEL_GROUP_SKINS; ++j)
        {
            GoreCapArrays[i].Textures[j] = SubClassInstance.SkelGroupSkins[j];
        }
    }
}

/**
*   ApplyRunePlayerSubClass_ExtractMenuName
*   Attempts to extract the menu name for the provided RunePlayer class,
*   so that when viewed from the server browser, players still see the original
*   name of the skin being used instead of R_RunePlayer.
*/
function ApplyRunePlayerSubClass_ExtractMenuName(Class<RunePlayer> SubClass)
{
    local String ClassString;
    local String EntryString, DescriptionString;
    local int i;

    ClassString = Level.GetNextInt("RuneI.RunePlayer", 0);
    for(i = 0; ClassString != ""; ClassString = Level.GetNextInt("RuneI.RunePlayer", ++i))
    {
        if(ClassString == String(SubClass))
        {
            Level.GetNextIntDesc("RuneI.RunePlayer", i, EntryString, DescriptionString);
            MenuName = DescriptionString;
            return;
        }
    }

    MenuName = "RMod Rune Player";
}
//==============================================================================
//  End Sub-Class Functions
//==============================================================================


//==============================================================================
//  Begin animation function overrides
//==============================================================================
/***
*   PlayMoving (override)
*   Overridden to fix the crouching 2-hand backward-45-right animations.
*   Original issue caused player to enter into the BaseFrame pose because the animation name was invalid.
*/
function PlayMoving(optional float tween)
{
    local name LowerName, UpperName;
    local bool bDefending;
    local float dp;
    local vector X, Y, Z;
    local bool bRight;
    local MovementDir_e dir;

    if (health <= 0)
        return;
    
    if (Role == ROLE_AutonomousProxy && IsAnimating()) { // 108  fix client-side leg animations
        if (AnimSequence == 'neutral_kick' ||
            AnimSequence == 'PumpTrigger' ||
            AnimSequence == 'LeverTrigger' ||
            AnimSequence == 'S3_Taunt')
                return;

        if (Weapon != None) {
            if (AnimSequence == Weapon.A_JumpAttack ||
                AnimSequence == Weapon.A_Taunt ||
                AnimSequence == Weapon.A_PumpTrigger ||
                AnimSequence == Weapon.A_LeverTrigger)
                    return;
        }
    }
    
    if(AnimProxy != None)
        bDefending = (AnimProxy.GetStateName() == 'Defending');
    else
        bDefending = false;

    // Determine the direction the player is attempting to move
    GetAxes(Rotation, X, Y, Z);
    dp = vector(Rotation) dot Normal(Acceleration);

    if(Normal(Acceleration) dot Y >= 0)
    {
        bRight = true;
    }

    if(dp > 0.9)
    { // Distinctly forward
        dir = MD_FORWARD;
    }
    else if(dp > 0.5)
    { // forward left/right
        if(bRight)
        {
            if (!bMirrored)
                dir = MD_FORWARDRIGHT;
            else
                dir = MD_FORWARDLEFT;
        }
        else
        {
            if (!bMirrored)
                dir = MD_FORWARDLEFT;
            else
                dir = MD_FORWARDRIGHT;
        }
    }
    else if(dp < -0.9)
    { // Distinctly backward
        dir = MD_BACKWARD;      
    }
    else if(dp < -0.5)
    { // backward left/right
        if(bRight)
        {
            if (!bMirrored)
                dir = MD_BACKWARDRIGHT;
            else
                dir = MD_BACKWARDLEFT;
        }
        else
        {
            if (!bMirrored)
                dir = MD_BACKWARDLEFT;
            else
                dir = MD_BACKWARDRIGHT;
        }
    }
    else if(bRight)
    { // Strafe right
        if (!bMirrored)
            dir = MD_RIGHT;
        else
            dir = MD_LEFT;
    }
    else
    { // Strafe left
        if (!bMirrored)
            dir = MD_LEFT;
        else
            dir = MD_RIGHT;
    }

    // If Attacking and running foward or backward, then let the upper body handle the leg motion
    if(AnimProxy != None && AnimProxy.GetStateName() == 'Attacking')
    {
        if(GetGroup(AnimSequence) == 'JumpAttack')
            return;
        if((dir == MD_FORWARD || dir == MD_BACKWARD) && (GetGroup(AnimSequence) == 'AttackMoving'
            && AnimSequence != 'ghostthrow'))
            return;
    }

    // Set the proper animation based upon the motion
    LowerName = 'MOV_ALL_run1_AA0N';

    if(Weapon == None)
    { // Explore mode
        if(!bIsCrouching)
        {
            switch(dir)
            {
            case MD_FORWARD:
                LowerName = 'MOV_ALL_run1_AA0N';
                break;
            case MD_FORWARDRIGHT:
                LowerName = 'MOV_ALL_rstrafe1_AA0S';
                break;
            case MD_FORWARDLEFT:
                LowerName = 'MOV_ALL_lstrafe1_AA0S';
                break;
            case MD_BACKWARD:
                LowerName = 'MOV_ALL_runback1_AA0S';
                break;
            case MD_BACKWARDRIGHT:
                LowerName = 'MOV_ALL_lstrafe1_AA0S';
                break;
            case MD_BACKWARDLEFT:
                LowerName = 'MOV_ALL_rstrafe1_AA0S';
                break;
            case MD_RIGHT:
                LowerName = 'MOV_ALL_rstrafe1_AN0N';
                break;
            case MD_LEFT:
                LowerName = 'MOV_ALL_lstrafe1_AN0N';
                break;
            default:
                break;
            }

            if(LowerName == 'MOV_ALL_run1_AA0N')
            {
                // Upper-body animation
                if(Shield == None)
                {
                    UpperName = 'MOV_ALL_run1_AN0N'; 
                }
                else
                {
                    UpperName = 'MOV_ALL_run1_AN0S';
                }
            }
            else
            { // Strafing, so match the upper-body with the lower-body
                UpperName = LowerName;
            }
        }
        else
        { // Crouching
            switch(dir)
            {
            case MD_FORWARD:
                LowerName = 'crouch_walkforward';
                break;
            case MD_FORWARDRIGHT:
                LowerName = 'crouch_walkforward45Right';
                break;
            case MD_FORWARDLEFT:
                LowerName = 'crouch_walkforward45Left';
                break;
            case MD_BACKWARD:
                LowerName = 'crouch_walkbackward';
                break;
            case MD_BACKWARDRIGHT:
                LowerName = 'crouch_walkbackward45Right';
                break;
            case MD_BACKWARDLEFT:
                LowerName = 'crouch_walkbackward45Left';
                break;
            case MD_RIGHT:
                LowerName = 'crouch_straferight';
                break;
            case MD_LEFT:
                LowerName = 'crouch_strafeleft';
                break;
            default:
                break;
            }

            UpperName = LowerName;
        }
    }
    else
    { // Combat Mode
        if(!bIsCrouching)
        {
            switch(dir)
            {
            case MD_FORWARD:
                if(!bDefending)
                {
                    if(AnimProxy.GetStateName() == 'Attacking')
                    {
                        LowerName = Weapon.A_ForwardAttack;
                    }
                    else
                    {
                        LowerName = Weapon.A_Forward;
                    }
                }
                else
                    LowerName = 'weapon_DefendWalk'; //Weapon.ForwardAnim;
                break;
            case MD_FORWARDRIGHT:
                if(!bDefending)
                    LowerName = Weapon.A_Forward45Right;
                else
                    LowerName = 'weapon_DefendWalk45Right';
                break;
            case MD_FORWARDLEFT:
                if(!bDefending)
                    LowerName = Weapon.A_Forward45Left;
                else
                    LowerName = 'weapon_DefendWalk45Left';
                break;
            case MD_BACKWARD:
                if(!bDefending)
                    LowerName = Weapon.A_Backward;
                else
                    LowerName = 'weapon_DefendBackup';
                break;
            case MD_BACKWARDRIGHT:
                if(!bDefending)
                    LowerName = Weapon.A_Backward45Right;
                else
                    LowerName = 'weapon_DefendBackup45Right';
                break;
            case MD_BACKWARDLEFT:
                if(!bDefending)
                    LowerName = Weapon.A_Backward45Left;
                else
                    LowerName = 'weapon_DefendBackup45Left';
                break;
            case MD_RIGHT:
                if(!bDefending)
                    LowerName = Weapon.A_StrafeRight;
                else
                    LowerName = Weapon.A_StrafeRight;
                break;
            case MD_LEFT:
                if(!bDefending)
                    LowerName = Weapon.A_StrafeLeft;
                else
                    LowerName = Weapon.A_StrafeLeft;
                break;
            default:
                break;
            }
        }
        else
        { // Crouch
            switch(dir)
            {
            case MD_FORWARD:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_walkforward2hands';
                else
                    LowerName = 'crouch_walkforward';
                break;
            case MD_FORWARDRIGHT:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_walkforward45Right2hands';
                else
                    LowerName = 'crouch_walkforward45Right';
                break;
            case MD_FORWARDLEFT:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_walkforward45Left2hands';
                else
                    LowerName = 'crouch_walkforward45Left';
                break;
            case MD_BACKWARD:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_walkbackward2hands';
                else
                    LowerName = 'crouch_walkbackward';
                break;
            case MD_BACKWARDRIGHT:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_walkbackward45Right2hand';
                else
                    LowerName = 'crouch_walkbackward45Right';
                break;
            case MD_BACKWARDLEFT:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_walkbackward45Left2hands';
                else
                    LowerName = 'crouch_walkbackward45Left';
                break;
            case MD_RIGHT:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_straferight2hands';
                else
                    LowerName = 'crouch_straferight';
                break;
            case MD_LEFT:
                if(Weapon.bCrouchTwoHands)
                    LowerName = 'crouch_strafeleft2hands';
                else
                    LowerName = 'crouch_strafeleft';
                break;
            default:
                break;
            }
        }

        UpperName = LowerName;
    }

    LoopAnim(LowerName, 1.0, 0.1);

    if(AnimProxy != None)
        AnimProxy.TryLoopAnim(UpperName, 1.0, 0.1);
}
//==============================================================================
//  End animation function overrides
//==============================================================================

/**
*   GetWeaponSwipeTexture
*   Return the texture this player wishes to use as their weapon swipe texture
*/
simulated function Texture GetWeaponSwipeTexture()
{
    if(bAuthoritativeBloodlust)
    {
        return WeaponSwipeBloodlustTexture;
    }
    else
    {
        return WeaponSwipeTexture;
    }
}
simulated function float GetWeaponSwipeSpeed()
{
    if(bAuthoritativeBloodlust)
    {
        return 3.0;
    }
    else
    {
        return 7.0;
    }
    
}


//==============================================================================
//  Begin 469b movement adaptation for Rune
//==============================================================================
/**
*   ClientAdjustPosition (override)
*   469b movement adaptation for Rune
*/
function ClientAdjustPosition
(
    float TimeStamp, 
    name newState, 
    EPhysics newPhysics,
    float NewLocX, 
    float NewLocY, 
    float NewLocZ, 
    float NewVelX, 
    float NewVelY, 
    float NewVelZ,
    Actor NewBase
)
{
    local Vector OldLoc, NewLocation, NewVelocity;
    local R_SavedMove CurrentMove;
    local Vector DebugLineBegin, DebugLineEnd;

    if (CurrentTimeStamp > TimeStamp)
        return;

    CurrentTimeStamp = TimeStamp;

    NewLocation.X = NewLocX;
    NewLocation.Y = NewLocY;
    NewLocation.Z = NewLocZ;
    NewVelocity.X = NewVelX;
    NewVelocity.Y = NewVelY;
    NewVelocity.Z = NewVelZ;

    // Higor: keep track of Position prior to adjustment
    // and stop current smoothed adjustment (if in progress).
    PreAdjustLocation = Location;
    if (AdjustLocationAlpha > 0)
    {
        AdjustLocationAlpha = 0;
        AdjustLocationOffset = vect(0, 0, 0);
    }

    // stijn: Remove acknowledged moves from the savedmoves list
    CurrentMove = SavedMoves;
    while (CurrentMove != None)
    {
        if (CurrentMove.TimeStamp <= CurrentTimeStamp)
        {
            SavedMoves = CurrentMove.NextMove;
            CurrentMove.NextMove = FreeMoves;
            FreeMoves = CurrentMove;
            FreeMoves.Clear();
            CurrentMove = SavedMoves;
        }
        else
        {
            // not yet acknowledged. break out of the loop
            CurrentMove = None;
        }
    }

    SetBase(NewBase);
    if (Mover(NewBase) != None)
        NewLocation += NewBase.Location;

    //log("Client "$Role$" adjust "$self$" stamp "$TimeStamp$" location "$Location);
    OldLoc = Location;
    bCanTeleport = false;
    SetLocation(NewLocation);
    bCanTeleport = true;
    Velocity = NewVelocity;

    SetPhysics(newPhysics);
    if (!IsInState(newState))
    {
        //log("CAP: GotoState("$newState$")");
        GotoState(newState);
    }

    bUpdatePosition = true;
    
    // Draw debug visualizers
    if(bShowRmodDebug && ClientDebugActor != None)
    {
        DebugLineBegin = Location;
        DebugLineEnd = DebugLineBegin;
        DebugLineEnd.Z += 96.0;
        ClientDebugActor.DrawLineSegmentForDuration(DebugLineBegin, DebugLineEnd, ColorsClass.Static.ColorRed(), 5.0);
        
        DebugLineBegin.X = NewLocX;
        DebugLineBegin.Y = NewLocY;
        DebugLineBegin.Z = NewLocZ;
        DebugLineEnd = DebugLineBegin;
        DebugLineEnd.Z += 96.0;
        ClientDebugActor.DrawLineSegmentForDuration(DebugLineBegin, DebugLineEnd, ColorsClass.Static.ColorGreen(), 5.0);
    }
}

/**
*   ReplicateMove (override)
*   469b movement adaptation for Rune
*/
function ReplicateMove(
    float DeltaTime,
    vector NewAccel,
    eDodgeDir DodgeMove,
    rotator DeltaRot)
{
    local R_SavedMove NewMove, OldMove, LastMove;
    local float TotalTime, NetMoveDelta;

    local float AdjustAlpha;

    // Higor: process smooth adjustment.
    if (AdjustLocationAlpha > 0)
    {
        AdjustAlpha = fMin(AdjustLocationAlpha, DeltaTime / SmoothAdjustLocationTime);
        MoveSmooth(AdjustLocationOffset * AdjustAlpha);
        AdjustLocationAlpha -= AdjustAlpha;
    }

    // Prevent some RunePlayer specific variables from replicating to server
    PreventUndesiredClientVarReplication();

    NetMoveDelta = FMax(64.0 / Player.CurrentNetSpeed, 0.011);

    // if am network client and am carrying flag -
    //  make its position look good client side
    if ((PlayerReplicationInfo != None) && (PlayerReplicationInfo.HasFlag != None))
        PlayerReplicationInfo.HasFlag.FollowHolder(self);

    // Get a SavedMove actor to store the movement in.
    if (PendingMove != None)
    {
        if (PendingMove.CanMergeAccel(NewAccel))
        {
            //add this move to the pending move
            PendingMove.TimeStamp = Level.TimeSeconds;
            if (VSize(NewAccel) > 3072)
                NewAccel = 3072 * Normal(NewAccel);
            TotalTime = DeltaTime + PendingMove.Delta;
            // Set this move's data.
            if (PendingMove.DodgeMove == DODGE_None)
                PendingMove.DodgeMove = DodgeMove;
            PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration) / TotalTime;
            PendingMove.SetRotation(Rotation);
            PendingMove.SavedViewRotation = ViewRotation;
            PendingMove.bRun = (bRun > 0);
            PendingMove.bDuck = (bDuck > 0);
            PendingMove.bPressedJump = bPressedJump || PendingMove.bPressedJump;
            PendingMove.bFire = PendingMove.bFire || bJustFired || (bFire != 0);
            PendingMove.bForceFire = PendingMove.bForceFire || bJustFired;
            PendingMove.bAltFire = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
            PendingMove.bForceAltFire = PendingMove.bForceAltFire || bJustFired;
            PendingMove.Delta = TotalTime;
            PendingMove.MergeCount++;
        }
        else
        {
            // Burst old move and remove from Pending
            // Log("Bursting move"@Level.TimeSeconds);
            SendServerMove(PendingMove);
            ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
            if (SavedMoves == None)
                SavedMoves = PendingMove;
            else
            {
                for (LastMove = SavedMoves; LastMove.NextMove != None; LastMove = LastMove.NextMove);
                LastMove.NextMove = PendingMove;
            }
            PendingMove = None;
        }
    }
    if (SavedMoves != None)
    {
        NewMove = SavedMoves;
        while (NewMove.NextMove != None)
        {
            // find most recent interesting (and unacknowledged) move to send redundantly
            if (NewMove.CanSendRedundantly(NewAccel))
                OldMove = NewMove;
            NewMove = NewMove.NextMove;
        }
        if (NewMove.CanSendRedundantly(NewAccel))
            OldMove = NewMove;
    }

    LastMove = NewMove;
    NewMove = NGetFreeMove();
    NewMove.Delta = DeltaTime;
    if (VSize(NewAccel) > 3072)
        NewAccel = 3072 * Normal(NewAccel);
    NewMove.Acceleration = NewAccel;
    NewAccel = Acceleration;

    // Set this move's data.
    NewMove.DodgeMove = DodgeMove;
    NewMove.TimeStamp = Level.TimeSeconds;
    NewMove.bRun = (bRun > 0);
    NewMove.bDuck = (bDuck > 0);
    NewMove.bPressedJump = bPressedJump;
    NewMove.bFire = (bJustFired || (bFire != 0));
    NewMove.bForceFire = bJustFired;
    NewMove.bAltFire = (bJustAltFired || (bAltFire != 0));
    NewMove.bForceAltFire = bJustAltFired;

    bJustFired = false;
    bJustAltFired = false;

    // Simulate the movement locally.
    ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot);
    AutonomousPhysics(NewMove.Delta);

    // Decide whether to hold off on move
    // send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
    // on client side, save extra buffered time in LastUpdateTime
    if (PendingMove == None)
        PendingMove = NewMove;
    else
    {
        NewMove.NextMove = FreeMoves;
        FreeMoves = NewMove;
        FreeMoves.Clear();
        NewMove = PendingMove;
    }

    NewMove.SetRotation(Rotation);
    NewMove.SavedViewRotation = ViewRotation;
    NewMove.SavedLocation = Location;
    NewMove.SavedVelocity = Velocity;

    if (PendingMove.CanBuffer(NewAccel) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime))
    {
        // save as pending move
        return;
    }
    else
    {
        ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
        if (SavedMoves == None)
            SavedMoves = PendingMove;
        else
            LastMove.NextMove = PendingMove;
        PendingMove = None;
    }

    if (NewMove.bPressedJump)
        bJumpStatus = !bJumpStatus;

    SendServerMove(NewMove, OldMove);
    SendServerClientRepVars();
}

/**
*   SendServerMove
*   469b movement adaptation for Rune
*/
function SendServerMove(R_SavedMove Move, optional R_SavedMove OldMove)
{
    local byte ClientRoll;
    local float OldTimeDelta;
    local int OldAccel;
    local byte MoveFlags;
    local int View;
    local EDodgeDir DodgeMove;
    ClientRoll = (Rotation.Roll >> 8) & 255;
    View = (32767 & (Move.SavedViewRotation.Pitch/2)) * 32768 + (32767 & (Move.SavedViewRotation.Yaw/2));

    // check if need to redundantly send previous move
    if (OldMove != None)
    {
        // log("Redundant send timestamp "$OldMove.TimeStamp$" accel "$OldMove.Acceleration$" at "$Level.Timeseconds$" New accel "$NewAccel);
        // old move important to replicate redundantly
        OldTimeDelta = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
        OldAccel = OldMove.CompressOld();
    }

    // There's no need to send DODGE_Active, Dodge() sets it.
    DodgeMove = Move.DodgeMove;
    if (DodgeMove == DODGE_Active)
        DodgeMove = DODGE_None;

    MoveFlags = Move.CompressFlags();
    MoveFlags += int(bJumpStatus) * 128;
    ServerMove_v2(
        Move.TimeStamp,
        Move.Acceleration * 10,
        Location,
        Velocity,
        MoveFlags,
        DodgeMove,
        ClientRoll,
        View,
        Move.MergeCount,
        OldTimeDelta,
        OldAccel);
}

/**
*   ServerMove_v2
*   469b movement adaptation for Rune
*/
function ServerMove_v2(
    float TimeStamp,
    Vector InAccel,
    Vector ClientLoc,
    Vector ClientVel,
    byte MoveFlags,
    EDodgeDir DodgeMove,
    byte ClientRoll,
    int View,
    int MergeCount,
    optional byte OldTimeDelta,
    optional int OldAccel)
{
    local float DeltaTime;
    local rotator DeltaRot, Rot;
    local vector Accel;
    local int maxPitch, ViewPitch, ViewYaw;
    local bool NewbPressedJump;
    local bool NewbRun, NewbDuck, NewbJumpStatus, bFired, bAltFired, bForceFire, bForceAltFire;

    // If this move is outdated, discard it.
    if (CurrentTimeStamp >= TimeStamp)
        return;

    if(MergeCount > 31)
        return;
    
    // Update bReadyToPlay for clients
    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.bReadyToPlay = bReadyToPlay;

    // Decompress move flags.
    NewbRun = (MoveFlags & 1) != 0;
    NewbDuck = (MoveFlags & 2) != 0;
    bFired = (MoveFlags & 4) != 0;
    bAltFired = (MoveFlags & 8) != 0;
    bForceFire = (MoveFlags & 16) != 0;
    bForceAltFire = (MoveFlags & 32) != 0;
    NewbJumpStatus = (MoveFlags & 128) != 0;

    // if OldTimeDelta corresponds to a lost packet, process it first
    if (OldTimeDelta != 0)
        OldServerMove(TimeStamp, NewbJumpStatus, OldTimeDelta, OldAccel);

    // View components
    ViewPitch = View / 32768;
    ViewYaw = 2 * (View - 32768 * ViewPitch);
    ViewPitch *= 2;

    // Make acceleration.
    Accel = InAccel / 10;
    NewbPressedJump = (bJumpStatus != NewbJumpStatus);
    bJumpStatus = NewbJumpStatus;
    // handle firing and alt-firing
    if (bFired)
    {
        if ((bForceFire && (Weapon != None)) || bFire == 0)
            Fire(0);

        bFire = 1;
    }
    else
        bFire = 0;

    if (bAltFired)
    {
        if (bAltFire == 0 || (bForceAltFire && (Weapon != None)))
            AltFire(0);

        bAltFire = 1;
    }
    else
        bAltFire = 0;
    // Save move parameters.
    DeltaTime = TimeStamp - CurrentTimeStamp;
    if (ServerTimeStamp > 0)
    {
        // allow 1% error
        TimeMargin = FMax(0, TimeMargin + DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp));
        if (TimeMargin > MaxTimeMargin)
        {
            // player is too far ahead
            TimeMargin -= DeltaTime;
            if (TimeMargin < 0.5)
                MaxTimeMargin = Default.MaxTimeMargin;
            else
                MaxTimeMargin = 0.5;
            DeltaTime = 0;
        }
    }
    CurrentTimeStamp = TimeStamp;
    ServerTimeStamp = Level.TimeSeconds;
    Rot.Roll = 256 * ClientRoll;
    Rot.Yaw = ViewYaw;
    if ((Physics == PHYS_Swimming) || (Physics == PHYS_Flying))
        maxPitch = 2;
    else
        maxPitch = 1;
    If((ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch))
    {
        If(ViewPitch < 32768)
            Rot.Pitch = maxPitch * RotationRate.Pitch;
        else Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
    }
    else 
        Rot.Pitch = ViewPitch;
    DeltaRot = (Rotation - Rot);
    ViewRotation.Pitch = ViewPitch;
    ViewRotation.Yaw = ViewYaw;
    ViewRotation.Roll = 0;
    SetRotation(Rot);

    // Perform actual movement, reproduced step by step as on client (approximate)
    if ((Level.Pauser == "") && (DeltaTime > 0))
    {
        DeltaTime /= MergeCount + 1;
        while ( MergeCount > 0 )
        {
            MoveAutonomous( DeltaTime, NewbRun, NewbDuck, false, DODGE_None, Accel, rot(0,0,0) );
            MergeCount--;
        }
        // Important input is usually the cause for buffer breakup, so it happens last on the client.
        MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, Accel, DeltaRot);
    }

    LastClientTimeStamp = TimeStamp;
    CheckClientError(TimeStamp, ClientLoc, ClientVel);
    
    // Update vars for POV spectating
    ViewRotPovPitch = ViewRotation.Pitch;
    ViewRotPovYaw = ViewRotation.Yaw;
}

/**
*   CheckClientError
*   469b movement adaptation for Rune
*/
function CheckClientError(float TimeStamp, vector ClientLoc, vector ClientVel)
{
    local float ClientErr;
    local vector ClientLocation, LocDiff;
    local bool bTooLong, bOnMover, bMoveSmooth;
    local Pawn P;

    if (TimeStamp == 0 )
        return;

    LocDiff = Location - ClientLoc;
    ClientErr = LocDiff Dot LocDiff;

    if (Player.CurrentNetSpeed == 0)
        bTooLong = ServerTimeStamp - LastUpdateTime > 0.025;
    else
        bTooLong = ServerTimeStamp - LastUpdateTime > 500.0/Player.CurrentNetSpeed;
    
    if (!bTooLong)
        bTooLong = ClientErr > MinPosError;
    
    if (!bTooLong)
        return;     

    // PlayerReplicationInfo.Ping = int(ConsoleCommand("GETPING"));
    bOnMover = Mover(Base) != None;
    if (bOnMover && OnMover)
    {
        IgnoreUpdateUntil = ServerTimeStamp + 0.15;
    }
    else if (IgnoreUpdateUntil > 0)
    {
        if (IgnoreUpdateUntil > ServerTimeStamp && (Base == None ||  !bOnMover || bOnMover != OnMover) && Physics != PHYS_Falling)
            IgnoreUpdateUntil = 0;

        bForceUpdate = false;
    }

    LastUpdateTime = ServerTimeStamp;

    if (ForceUpdateUntil > 0 || IgnoreUpdateUntil == 0 && ClientErr > MaxPosError)
    {
        bForceUpdate = true;
        if (ServerTimeStamp > ForceUpdateUntil)
            ForceUpdateUntil = 0;
    }
    
    // Always perform client adjust when state changes
    if(GetStateName() != PreviousStateName)
    {
        PreviousStateName = GetStateName();
        bForceUpdate = true;
    }

    if(bForceUpdate)
    {
        bForceUpdate = false;       

        if (bOnMover)
            ClientLocation = Location - Base.Location;
        else
            ClientLocation = Location;

        // Make sure Z is rounded up.
        if (Base != None && Base != Level)
            ClientLocation.Z += float(int(Base.Location.Z + 0.9)) - Base.Location.Z;

        ClientAdjustPosition(
            TimeStamp,
            GetStateName(),
            Physics,
            ClientLocation.X,
            ClientLocation.Y,
            ClientLocation.Z,
            Velocity.X,
            Velocity.Y,
            Velocity.Z,
            Base);

        LastClientErr = 0;      
        FakeUpdate = false;
        PreventUndesiredClientVarReplication();
        return;
    }

    if (ClientErr > MinPosError)
    {
        if (LastClientErr == 0 || ClientErr < LastClientErr)    
        {   
            LastClientErr = ClientErr;
        }
        else if(!bOnMover)
        {
            bMoveSmooth = FastTrace(ClientLoc);
            if (!bMoveSmooth)
            {
                for (P = Level.PawnList; P != None; P = P.NextPawn)
                {
                    if (P.bCollideActors && P.bCollideWorld && P.bBlockActors && P != Self && VSize(P.Location - ClientLoc) < ((P.CollisionRadius + CollisionRadius) * CollisionHeight))
                    {
                        bMoveSmooth = true;
                        break;
                    }
                }
            }
            
            if (bMoveSmooth)
            {
                if( MoveSmooth(ClientLoc - Location))
                    Velocity = ClientVel;
                LastClientErr = 0;
            }
            else
            {               
                bCanTeleport = false;
                if (SetLocation(ClientLoc))
                    Velocity = ClientVel;
                bCanTeleport = true;

                LastClientErr = 0;
            }
        }
    }

    FakeCAP(TimeStamp);
}

/**
*   OldServerMove
*   469b movement adaptation for Rune
*/
final function OldServerMove(float TimeStamp, bool NewbJumpStatus, byte OldTimeDelta, int OldAccel)
{
    local float OldTimeStamp;
    local bool OldbRun, OldbDuck, NewbPressedJump;
    local vector Accel;
    local EDodgeDir OldDodgeMove;

    OldTimeStamp = TimeStamp - float(OldTimeDelta) / 500 - 0.001;
    if (CurrentTimeStamp < OldTimeStamp - 0.001)
    {
        // split out components of lost move (approx)
        Accel.X = DecompressAccel(OldAccel >>> 23);
        Accel.Y = DecompressAccel((OldAccel >>> 15) & 255);
        Accel.Z = DecompressAccel((OldAccel >>> 7) & 255);
        Accel *= 20;
        OldbRun = ((OldAccel & 64) != 0);
        OldbDuck = ((OldAccel & 32) != 0);
        NewbPressedJump = ((OldAccel & 16) != 0);
        if (NewbPressedJump)
            bJumpStatus = NewbJumpStatus;
        switch (OldAccel & 7)
        {
        case 0:
            OldDodgeMove = DODGE_None;
            break;
        case 1:
            OldDodgeMove = DODGE_Left;
            break;
        case 2:
            OldDodgeMove = DODGE_Right;
            break;
        case 3:
            OldDodgeMove = DODGE_Forward;
            break;
        case 4:
            OldDodgeMove = DODGE_Back;
            break;
        }
        //      log("Recovered move from "$OldTimeStamp$" acceleration "$Accel$" from "$OldAccel);
        MoveAutonomous(OldTimeStamp - CurrentTimeStamp, OldbRun, OldbDuck, NewbPressedJump, OldDodgeMove, Accel, rot(0, 0, 0));
        CurrentTimeStamp = OldTimeStamp;
    }
}

/**
*   FakeCAP
*   469b movement adaptation for Rune
*/
function FakeCAP(float TimeStamp)
{
    if (CurrentTimeStamp > TimeStamp )
        return;
    CurrentTimeStamp = TimeStamp;

    FakeUpdate = true;
    bUpdatePosition = true;
}

/**
*   NGetFreeMove
*   469b movement adaptation for Rune
*/
function R_SavedMove NGetFreeMove()
{
    local R_SavedMove s;
    if (FreeMoves == None)
        return Spawn(class 'RMod.R_SavedMove', self);
    else
    {
        s = FreeMoves;
        FreeMoves = FreeMoves.NextMove;
        s.NextMove = None;
        if (s.Owner != self)
            s.SetOwner(self);
        return s;
    }
}

/**
*   DecompressAccel
*   469b movement adaptation for Rune
*/
final function float DecompressAccel(int C)
{
    if (C > 127)
        C = -1 * (C - 128);
    return C;
}

/**
*   PreventUndesiredClientVarReplication
*   Prevent the undesired replication of some variables from client to server
*/
function PreventUndesiredClientVarReplication()
{
    if (AmbientGlow != 0)           AmbientGlow = 0;
    if (ScaleGlow != 1.0)           ScaleGlow = 1.0;
    if (bUnlit)                     bUnlit = false;
    if (bMeshEnviroMap)             bMeshEnviroMap = false;
    if (PrePivot != vect(0, 0, 0))  PrePivot = vect(0, 0, 0);
}

/**
*   ClientUpdatePosition (override)
*   469b movement adaptation for Rune
*/
function ClientUpdatePosition()
{
    local R_SavedMove CurrentMove;
    local int realbRun, realbDuck;
    local bool bRealJump;
    local rotator RealViewRotation, RealRotation;

    local float AdjustDistance;
    local vector PostAdjustLocation;

    bUpdatePosition = false;
    realbRun = bRun;
    realbDuck = bDuck;
    bRealJump = bPressedJump;
    RealRotation = Rotation;
    RealViewRotation = ViewRotation;
    CurrentMove = SavedMoves;
    bUpdating = true;

    while (CurrentMove != None)
    {
        if (CurrentMove.TimeStamp <= CurrentTimeStamp)
        {
            SavedMoves = CurrentMove.NextMove;
            CurrentMove.NextMove = FreeMoves;
            FreeMoves = CurrentMove;
            FreeMoves.Clear();
            CurrentMove = SavedMoves;
        }
        else
        {
            if(!FakeUpdate)         
                ClientReplayMove(CurrentMove);          

            CurrentMove = CurrentMove.NextMove;
        }
    }

    // stijn: The original code was not replaying the pending move
    // here. This was a huge oversight and caused non-stop resynchronizations
    // because the playerpawn position would be off constantly until the player
    // stopped moving!
    if(!FakeUpdate)
    {
        if (PendingMove != none)
            ClientReplayMove(PendingMove);

        // Higor: evaluate location adjustment and see if we should either
        // - Discard it
        // - Negate and process over a certain amount of time.
        // - Keep adjustment as is (instant relocation)
        AdjustLocationOffset = (Location - PreAdjustLocation);
        AdjustDistance = VSize(AdjustLocationOffset);
        AdjustLocationAlpha = 0;
        if (AdjustDistance < VSize(Acceleration)) //Only do this if player is trying to move
        {
            if (AdjustDistance < 2)
            {
                // Discard
                MoveSmooth(-AdjustLocationOffset);
            }
            else if ((AdjustDistance < 50) && FastTrace(Location, PreAdjustLocation))
            {
                // Undo adjustment and re-enact smoothly
                PostAdjustLocation = Location;
                MoveSmooth(-AdjustLocationOffset);
                AdjustLocationOffset = PostAdjustLocation - Location;
                AdjustLocationAlpha = 1;
            }
        }
    }

    bUpdating = false;
    bDuck = realbDuck;
    bRun = realbRun;
    bPressedJump = bRealJump;
    SetRotation(RealRotation);
    ViewRotation = RealViewRotation;
    FakeUpdate = false;
    //log("Client adjusted "$self$" stamp "$CurrentTimeStamp$" location "$Location$" dodge "$DodgeDir);
}

/**
*   ClientReplayMove
*   469b movement adaptation for Rune
*/
function ClientReplayMove(R_SavedMove Move)
{
    local int i;
    local float DeltaTime;

    SetRotation(Move.Rotation);
    ViewRotation = Move.SavedViewRotation;
    // Replay the move in the same amount of ticks they were created+merged.
    // Important input needs to be processed last (as it's usually the cause of buffer breakup)
    DeltaTime = Move.Delta;
    DeltaTime /= Move.MergeCount + 1;
    for ( i=0; i<Move.MergeCount; i++)
        MoveAutonomous( DeltaTime, Move.bRun, Move.bDuck, false, DODGE_None, Move.Acceleration, rot(0,0,0));

    MoveAutonomous(DeltaTime, Move.bRun, Move.bDuck, Move.bPressedJump, Move.DodgeMove, Move.Acceleration, rot(0, 0, 0));
    Move.SavedLocation = Location;
    Move.SavedVelocity = Velocity;
}

/**
*   EncroachingOn (override)
*   469b movement adaptation for Rune
*/
event bool EncroachingOn(actor Other)
{
    if ((Other.Brush != None) || (Brush(Other) != None))
        return true;

    if (!bCanTeleport && (Pawn(Other) != None) && (Level.NetMode == NM_Client))
        return false; // Allow relocating inside pawns during ClientAdjustPosition

    if ((!bIsPlayer || bWarping) && (Pawn(Other) != None))
        return true;

    return false;
}

/**
*   AccumulatedPlayerTurn
*   469b movement adaptation for Rune
*/
function int AccumulatedPlayerTurn(float CurrentTurn, out float AccumulatedTurn)
{
    local int IntTurn;

    CurrentTurn += AccumulatedTurn;
    IntTurn = CurrentTurn;
    AccumulatedTurn = CurrentTurn - IntTurn;
    return IntTurn;
}

/**
*   UpdateRotation (override)
*   469b movement adaptation for Rune
*/
function UpdateRotation(float DeltaTime, float maxPitch)
{
    local rotator newRotation;

    DesiredRotation = ViewRotation; //save old rotation
    ViewRotation.Pitch += AccumulatedPlayerTurn(32.0 * DeltaTime * aLookUp, AccumulatedVTurn);
    ViewRotation.Pitch = ViewRotation.Pitch & 65535;
    If((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
    {
        If(aLookUp > 0)
            ViewRotation.Pitch = 18000;
        else ViewRotation.Pitch = 49152;
    }
    ViewRotation.Yaw += AccumulatedPlayerTurn(32.0 * DeltaTime * aTurn, AccumulatedHTurn);
    //  ViewShake(deltaTime); // RUNE:  ViewShake is handled in the Camera code
    ViewFlash(deltaTime);

    newRotation = Rotation;
    newRotation.Yaw = ViewRotation.Yaw;
    newRotation.Pitch = ViewRotation.Pitch;
    If((newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch))
    {
        If(ViewRotation.Pitch < 32768)
            newRotation.Pitch = maxPitch * RotationRate.Pitch;
        else newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
    }
    setRotation(newRotation);
}

/**
*   PlayerTickEvents
*   469b movement adaptation for Rune
*/
function PlayerTickEvents()
{
    if (Player.CurrentNetSpeed != 0 && Level.TimeSeconds - LastStuffUpdate > 500.0/Player.CurrentNetSpeed)  
        LastStuffUpdate = CurrentTime;  
}

/**
*   PlayerTick (override)
*   469b movement adaptation for Rune
*/
event PlayerTick( float Time )
{
    PlayerTickEvents();
}
//==============================================================================
//  End 469b movement adaptation for Rune
//==============================================================================

function SendServerClientRepVars()
{
    local Class<Console> ConsoleClass;
    local float LevelTimeDilation;
    
    ConsoleClass = None;
    if(Player != None)
    {
        ConsoleClass = Player.Console.Class;
    }
    
    LevelTimeDilation = -1.0;
    if(Level != None)
    {
        LevelTimeDilation = Level.TimeDilation;
    }
    
    ServerClientRepVars(ConsoleClass, LevelTimeDilation);
}

function ServerClientRepVars(
    Class<Console> ConsoleClass,
    float LevelTimeDilation)
{
    if(EventListenerInstance != None)
    {
        EventListenerInstance.ReceiveEvent_ClassPayload(Self, "PostServerClientRepVars_ConsoleClass", ConsoleClass);
        EventListenerInstance.ReceiveEvent_FloatPayload(Self, "PostServerClientRepVars_TimeDilation", LevelTimeDilation);
    }
}

/**
*   JointDamaged (override)
*   Overridden to keep track of Damage dealt statistics.
*/
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
    local R_GameInfo RGI;
    local int PreviousHealth;
    local int DamageDealt;
    local R_PlayerReplicationInfo RPRI;
    local bool bResult;

    // Check if current game mode has global invulnerability enabled - return if so
    if(Role == ROLE_Authority)
    {
        RGI = R_GameInfo(Level.Game);
        if(RGI != None && !RGI.CheckIsGameDamageEnabled())
        {
            return false;
        }
    }

    PreviousHealth = Health;
    bResult = Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);

    if(Health < 0)
    {
        DamageDealt = PreviousHealth;
    }
    else
    {
        DamageDealt = PreviousHealth - Health;
    }

    if(EventInstigator != None && EventInstigator.PlayerReplicationInfo != None)
    {
        RPRI = R_PlayerReplicationInfo(EventInstigator.PlayerReplicationInfo);
        if(RPRI != None)
        {
            RPRI.DamageDealt += DamageDealt;
        }
    }
}

/**
*   PlayTakeHit (override)
*   Overridden to avoid playing client flashes in response to shield hit stun
*/
function PlayTakeHit(float TweenTime, int Damage, Vector HitLoc, Name DamageType, Vector Momentum, int BodyPart)
{
    local float rnd;
    local float time;

    if(DamageType != 'ShieldHit')
    {
        rnd = FClamp(Damage, 10, 40);
        if (DamageType == 'burned')
        {
            ClientFlash(-0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
        }
        else if (DamageType == 'corroded')
        {
            ClientFlash(-0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
        }
        else if (DamageType == 'drowned')
        {
            ClientFlash(-0.390, vect(312.5,468.75,468.75));
        }
        else
        {
            ClientFlash(-0.017 * rnd, rnd * vect(24, 4, 4));
        }
    }

    time = 0.15 + 0.005 * Damage;
    ShakeView(time, Damage * 10, time * 0.5);

    // Bypass RunePlayer.PlayTakeHit to avoid client flash
    Super(PlayerPawn).PlayTakeHit(TweenTime, Damage, HitLoc, DamageType, Momentum, BodyPart);
}

/**
*   SetSkinActor (override)
*   Overridden to apply skin actor in the context of the sub class that would
*   have been saved during the call to ApplyRunePlayerSubClass.
*/
static function SetSkinActor(Actor SkinActor, int NewSkin)
{
    local R_RunePlayer RP;
    local Class<RunePlayer> RPSubClass;
    local int i;
    
    RP = R_RunePlayer(SkinActor);
    if(RP == None)
    {
        Class'RuneI.RunePlayer'.Static.SetSkinActor(SkinActor, NewSkin);
        return;
    }
    
    RPSubClass = RP.RunePlayerSubClass;
    if(RPSubClass == None)
    {
        RPSubClass = Class'RMod.R_RunePlayer';
    }
    
    for(i = 0; i < 16; ++i)
    {
        RP.SkelGroupSkins[i] = RPSubClass.Default.SkelGroupSkins[i];
    }
}

/**
*   PainSkin (override)
*   Overridden to apply the pain skin that was extracted in ApplyRunePlayerSubClass.
*/
function Texture PainSkin(int BodyPart)
{
    local Texture PainTexture;
    local int i;

    if(BodyPart < 0 || BodyPart >= NUM_BODYPARTS)
    {
        return None;
    }

    for(i = 0; i < MAX_SKEL_GROUP_SKINS; ++i)
    {
        PainTexture = PainSkinArrays[BodyPart].Textures[i];
        if(PainTexture != None)
        {
            SkelGroupSkins[i] = PainTexture;
        }
    }
    
    return None;
}

/**
*   ApplyGoreCap (override)
*   Overridden to apply the gore cap that was extracted in ApplyRunePlayerSubClass.
*/
function ApplyGoreCap(int BodyPart)
{
    local Texture GoreTexture;
    local int i;

    if(BodyPart < 0 || BodyPart >= NUM_BODYPARTS)
    {
        return;
    }

    for(i = 0; i < MAX_SKEL_GROUP_SKINS; ++i)
    {
        GoreTexture = GoreCapArrays[BodyPart].Textures[i];
        if(GoreTexture != None)
        {
            SkelGroupSkins[i] = GoreTexture;
            SkelGroupFlags[i] = SkelGroupFlags[i] & ~POLYFLAG_INVISIBLE;
        }
    }
}

/**
*   BodyPartForPolyGroup (override)
*   Overridden to return the body part that was extracted in ApplyRunePlayerSubClass.
*/
function int BodyPartForPolyGroup(int PolyGroup)
{
    if(PolyGroup < 0 || PolyGroup >= 16)
    {
        return BODYPART_BODY;
    }

    return PolyGroupBodyParts[PolyGroup];
}

/**
*   SeveredLimbClass (override)
*   Overridden to return the body part sub-class that was extracted in
*   ApplyRunePlayerSubClass. Originally, this class was spawned directly by
*   LimbSevered, but now the returned class is used to apply default properties
*   to the spawned RMod body part in LimbSevered.
*/
function Class<Actor> SeveredLimbClass(int BodyPart)
{
    switch(BodyPart)
    {
        case BODYPART_LARM1:
        case BODYPART_RARM1:
            return Self.RunePlayerSeveredLimbSubClass;
        case BODYPART_HEAD:
            return Self.RunePlayerSeveredHeadSubClass;
    }

    return None;
}

/**
*   LimbSevered (override)
*   Overridden to spawn RMod body part classes and apply the original
*   body part class as a sub-class.
*/
function LimbSevered(int BodyPart, Vector Momentum)
{
    local int JointIndex;
    local Vector JointPosition;
    local Class<Actor> BodyPartSpawnClass, BodyPartSubClass;
    local Actor SpawnedBodyPartActor, SpawnedEffectActor;
    local Vector X,Y,Z;
    local Vector PartVelocity;
    
    GetAxes(Rotation, X, Y, Z);

    switch(BodyPart)
    {
        case BODYPART_LARM1:
            BodyPartSpawnClass = SpawnableSeveredLimbClass;
            DropShield();
            JointIndex = JointNamed('lshouldb');
            PartVelocity = -Y * 100 + Vect(0.0, 0.0, 175.0);
            break;
    
        case BODYPART_RARM1:
            BodyPartSpawnClass = SpawnableSeveredLimbClass;
            LastHeldWeapon = None; // No retrieving
            DropWeapon();
            JointIndex = JointNamed('rshouldb');
            PartVelocity = Y * 100 + Vect(0.0, 0.0, 175.0);
            break;
            
        case BODYPART_HEAD:
            BodyPartSpawnClass = SpawnableSeveredHeadClass;
            JointIndex = JointNamed('head');
            PartVelocity = (Momentum / Mass) * 20.0 + Vect(0.0, 0.0, 300.0);
            break;
    }

    ApplyGoreCap(BodyPart);
    JointPosition = GetJointPos(JointIndex);
    
    if(BodyPartSpawnClass != None)
    {
        BodyPartSubClass = SeveredLimbClass(BodyPart);
        SpawnedBodyPartActor = Spawn(BodyPartSpawnClass,,, JointPosition, Rotation);
        if(SpawnedBodyPartActor != None)
        {
            if(R_AWeapon_BodyPart(SpawnedBodyPartActor) != None)
            {
                R_AWeapon_BodyPart(SpawnedBodyPartActor).ApplyBodyPartSubClass(BodyPartSubClass);
            }
            SpawnedBodyPartActor.DrawScale = 1.0;
            SpawnedBodyPartActor.Velocity = PartVelocity;
            SpawnedBodyPartActor.GotoState('Drop');
        }
    }
    
    // Attach blood spurt effect on the sever location
    SpawnedEffectActor = Spawn(Class'RuneI.BloodSpurt', Self,, JointPosition, Rotation);
    if(SpawnedEffectActor != None)
    {
        AttachActorToJoint(SpawnedEffectActor, JointIndex);
    }

    SetMovementMode(); // Set combat or exploration mode (player could lose an arm)
}


/**
*   GetViewRotPov
*   Get the point-of-view view rotation for this player. Called by other
*   players who are in spectator state.
*   Note that this needs to be simulated because it's going to be called
*   client-side by non-owning clients.
*/
simulated function Rotator GetViewRotPov()
{
    local Rotator ViewRotPov;
    
    ViewRotPov.Pitch = ViewRotPovPitch;
    ViewRotPov.Yaw = ViewRotPovYaw;
    ViewRotPov.Roll = 0;
    return ViewRotPov;
}

/**
*   BoostStrength (override)
*   Overridden to call EnableBloodlust
*/
function BoostStrength(int amount)
{
    if(bBloodLust)
        return;

    Strength = Clamp(Strength + Amount, 0, MaxStrength);
    
    if (Strength >= MaxStrength)
    {
        EnableBloodlust();
    }
}

/**
*   EnableBloodlust
*   Enable bloodlust and play effects
*/
function bool EnableBloodlust()
{
    bBloodlust = true;

    PlaySound(BerserkSoundStart, SLOT_None, 1.0);
    AmbientSound = BerserkSoundLoop;

    DesiredPolyColorAdjust.X = 255;
    DesiredPolyColorAdjust.Y = 128;
    DesiredPolyColorAdjust.Z = 128;
    Spawn(Class'BloodlustStart', self,, Location, Rotation);

    if(BloodLustEyes != None)
        BloodLustEyes.bHidden = false;

    ShakeView(1, 100, 0.25);
}

/**
*   DoTryPlayTorsoAnim (override)
*   This function's name is confusing, but what it actually means is:
*   "Try to play the AnimProxy's current animation on the RunePlayer",
*   which effectively means:
*   "Whatever animation is playing on the torso, try to play that
*   animation on the legs as well".
*   This fixes the client-side leg animations by force-playing the specified
*   animation. Note that 'simulated' serves no purpose here, and it's only
*   marked simulated because the original function is marked simulated
*/
simulated function DoTryPlayTorsoAnim(Name TorsoAnim, float speed, float tween)
{
    if(Role == ROLE_AutonomousProxy || Level.NetMode == NM_Standalone)
    {
        if(TorsoAnim == 'neutral_kick'
        || TorsoAnim == 'PumpTrigger'
        || TorsoAnim == 'LevelTrigger'
        || TorsoAnim == 'S3_Taunt')
        {
            PlayAnim(TorsoAnim, speed, tween);
            return;
        }

        if(Weapon != None)
        {
            if(TorsoAnim == Weapon.A_JumpAttack
            || TorsoAnim == Weapon.A_Taunt
            || TorsoAnim == Weapon.A_PumpTrigger
            || TorsoAnim == Weapon.A_LeverTrigger)
            {
                PlayAnim(TorsoAnim, speed, tween);
                return;
            }

            if(Physics == PHYS_Walking && VSize2D(Acceleration) < 1000.0f)
            {
                PlayAnim(TorsoAnim, speed, tween);
                return;
            }
        }
    }

    Super.DoTryPlayTorsoAnim(TorsoAnim, speed, tween);
}

/**
*   WeaponActivate (override)
*   Called from AnimProxy Attack functions
*/
function WeaponActivate()
{
    if(Weapon != None)
    {
        Weapon.StartAttack();
    }
}

/**
*   WeaponDeactivate (override)
*   Called from AnimProxy Attack functions
*/
function WeaponDeactivate()
{
    if(Weapon != None)
    {
        Weapon.FinishAttack();
    }
}

/**
*   ShieldActivate
*   Called from R_RunePlayerProxy Attack functions
*   New function that enables collision for shield bash attack
*/
function ShieldActivate()
{
    if(R_AShield(Shield) != None)
    {
        R_AShield(Shield).StartAttack();
    }
}

/**
*   ShieldDeactivate
*   Called from R_RunePlayerProxy Attack functions
*   New function that disables collision for shield bash attack
*/
function ShieldDeactivate()
{
    if(R_AShield(Shield) != None)
    {
        R_AShield(Shield).FinishAttack();
    }
}

/**
*   CheckIsPerformingShieldAttack
*   Returns true if this R_RunePlayer is currently performing a shield attack,
*   false otherwise.
*/
function bool CheckIsPerformingShieldAttack()
{
    if(Shield != None
    && Shield.GetStateName() == 'Swinging'
    && AnimProxy != None
    && AnimProxy.GetStateName() == 'Attacking')
    {
        return true;
    }
    return false;
}

/**
*   CheckCanRestart
*   Returns whether or not this player is allowed to manually restart.
*   This function includes the original bCanRestart check, but adds an
*   additional check to R_GameInfo.CheckAllowRestart, to allow game modes
*   to add their own conditional logic for blocking player restarts.
*/
function bool CheckCanRestart()
{
    local R_GameInfo RGI;

    if(!bCanRestart)
    {
        return false;
    }

    RGI = R_GameInfo(Level.Game);
    if(RGI != None && !RGI.CheckAllowRestart(Self))
    {
        return false;
    }

    return true;
}

/**
*   CheckShouldSpectateAfterDying
*   Dying state calls this function to see whether the player should enter
*   into spectator state after dying. This is useful for game types like Arena,
*   to allow players to spectate other players while dead.
*/
function bool CheckShouldSpectateAfterDying()
{
    // If unable to restart, then go into spectator mode
    return !CheckCanRestart();
}

/**
*   ClientSetLocation (override)
*   Overridden to prevent this function from updating the client's ViewRotation.
*/
function ClientSetLocation(Vector NewLocation, Rotator NewRotation)
{
    // Only Yaw
    NewRotation.Roll = 0;
    NewRotation.Pitch = 0;
    SetRotation(NewRotation);
    SetLocation(NewLocation);
}

//==============================================================================
//  State PlayerWalking (override)
//
//  Overridden for 469b movement adaptation
//==============================================================================
state PlayerWalking
{
    /**
    *   BeginState (override)
    *   Overridden to reset the LastTouchedClimbable var, so that this player can
    *   grab that rope again.
    */
    event BeginState()
    {
        Super.BeginState();
        
        LastTouchedClimbable = None;
    }
    
    /**
    *   PlayerTick (override)
    *   Overridden for 469b movement adaptation.
    */
    event PlayerTick(float DeltaTime)
    {
        local float ZDist;

        PlayerTickEvents();

        if (bUpdatePosition)
            ClientUpdatePosition();

        //
        // stijn: if the server corrected our position in the middle of
        // a dodge, we might end up in DODGE_Active state with our
        // Physics set to PHYS_Walking. If this happened before 469,
        // the player would not be able to dodge again until triggering
        // a landed event (which usually meant you had to jump).
        // Here, we just wait for the dodge animation to play out and
        // then manually force a dodgedir reset.
        //
        if (DodgeDir == DODGE_Active &&
            Physics != PHYS_Falling &&
            GetAnimGroup(AnimSequence) != 'Dodge' &&
            GetAnimGroup(AnimSequence) != 'Jumping')
        {
            DodgeDir = DODGE_None;
            DodgeClickTimer = DodgeClickTime;
        }

        PlayerMove(DeltaTime);

        // Check to player falling death scream
        if (!bPlayedFallingSound && Physics == PHYS_Falling && Velocity.Z < -1300)
        { // Play death scream
            bPlayedFallingSound = true;
            PlaySound(FallingScreamSound, SLOT_Talk, , true);
        }

        // Update ZTarget (only if in single-player)
        if (ZTarget != None && Level.Netmode == NM_Standalone)
        {
            ZDist = VSize(ZTarget.Location - Location);
            if (ZTarget.Health <= 0 || ZDist > ZTARGET_DIST)
            {
                ZTarget = None;
            }
            else
            {
                if (ZTargetDecal == None)               
                    ZTargetDecal = Spawn(class 'ZTargetDecal', ZTarget, , Location, Rotation);              

                ZTargetDecal.SetOwner(ZTarget);
                ZTargetDecal.Update(None);
            }
        }
    }
    
    /**
    *   GrabEdge (override)
    *   Overridden to prevent client-side stuttering when attacking and grabbing ledge
    *   at the same time.
    */
    function bool GrabEdge(float GrabDistance, vector GrabNormal)
    {
        // Only grab ledge in Idle state
        // AuthoritativeAnimProxyStateName is used instead of AnimProxy.GetStateName() so that
        // clients can more accurately predict edge grabs, preventing edge grab stuttering.
        if(AuthoritativeAnimProxyStateName == 'Idle')
        {
            GrabLocationUp.X = Location.X;
            GrabLocationUp.Y = Location.Y;
            GrabLocationUp.Z = Location.Z + GrabDistance + 8;
        
            GrabLocationIn.X = Location.X + GrabNormal.X * (CollisionRadius + 4);
            GrabLocationIn.Y = Location.Y + GrabNormal.Y * (CollisionRadius + 4);
            GrabLocationIn.Z = GrabLocationUp.Z + CollisionHeight;
        
            SetRotation(rotator(GrabNormal));
            ViewRotation.Yaw = Rotation.Yaw; // Align View with Player position while grabbing edge

            // Save the final distance (used for choosing the correct anim)
            GrabLocationDist = GrabLocationUp.Z - Location.Z;

            // Final, absolute check if the player can fit in the new location.
            // if the player fits, then it is a valid edge grab
            if(SetLocation(GrabLocationIn))
            {
                if(AnimProxy != None)
                    AnimProxy.GotoState('EdgeHanging');         
                GotoState('EdgeHanging');

                return true;
            }
        }
        
        return false;
    }
}

//==============================================================================
//  State EdgeHanging (override)
//
//==============================================================================
state EdgeHanging
{
    /**
    *   ProcessMove (override)
    *   Overridden to prevent players from jump-mashing out of edge climb
    */
    function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)   
    {
        Acceleration = Vect(0.0, 0.0, 0.0);
        Velocity = Vect(0.0, 0.0, 0.0);
    }
}

state PlayerValidation
{
    event BeginState()
    {
        Self.SetCollision(false, false, false);
        Self.bCollideWorld = false;
        Self.DrawType = DT_None;
        Self.bAlwaysRelevant = false;
        Self.SetPhysics(PHYS_None);

        if(PlayerReplicationInfo != None)
        {
            PlayerReplicationInfo.bIsSpectator = true;
        }
    }

    event EndState()
    {
        Self.SetCollision(true, true, true);
        Self.bCollideWorld = Self.Default.bCollideWorld;
        Self.DrawType = Self.Default.DrawType;
        Self.bAlwaysRelevant = Self.Default.bAlwaysRelevant;

        if(PlayerReplicationInfo != None)
        {
            PlayerReplicationInfo.bIsSpectator = false;
        }
    }
}

//==============================================================================
//  State PlayerSpectating (override)
//
//  Originally, this state is unused, and spectator functionality is implemented
//  in the Spectator pawn class. RMod does not use a Spectator pawn, but
//  instead uses this state for all spectator functionality.
//
//  This state spawns a new R_ACamera actor and routes most view-related
//  functionality through it. For custom view functionality, extend the
//  R_ACamera class and set the R_RunePlayer.SpectatorCameraClass variable.
//==============================================================================
state PlayerSpectating
{
    event BeginState()
    {
        Self.SetCollision(false, false, false);
        Self.bCollideWorld = false;
        Self.DrawType = DT_None;
        //Self.bHidden = true;
        Self.bAlwaysRelevant = false;
        Self.SetPhysics(PHYS_None);
        //Self.PlayerReplicationInfo.bIsSpectator = true;
        
        if(Role == ROLE_Authority)
        {
            Level.Game.DiscardInventory(Self);
            
            if(Camera != None)
            {
                Camera.Destroy();
            }
            Camera = Spawn(Self.SpectatorCameraClass, Self);
        }
    }

    event EndState()
    {
        Self.SetCollision(true, true, true);
        Self.bCollideWorld = Self.Default.bCollideWorld;
        Self.DrawType = Self.Default.DrawType;
        //Self.bHidden = Self.Default.bHidden;
        Self.bAlwaysRelevant = Self.Default.bAlwaysRelevant;
        //Self.PlayerReplicationInfo.bIsSpectator = false;

        if(Role == ROLE_Authority)
        {
            if(Camera != None)
            {
                Camera.Destroy();
            }
        }
    }
    
    event PlayerCalcView(
        out Actor ViewActor,
        out vector CameraLocation,
        out rotator CameraRotation)
    {
        if(Self.Camera != None)
        {
            Self.Camera.PlayerCalcView(
                ViewActor,
                CameraLocation,
                CameraRotation);
            Self.SavedCameraRot = CameraRotation;
            Self.SavedCameraLoc = CameraLocation;
            Self.ViewLocation = CameraLocation;
        }
    }
    
    event PreRender( canvas Canvas )
    {
        if (bDebug==1)
        {
            if (myDebugHUD   != None)
                myDebugHUD.PreRender(Canvas);
            else if ( Viewport(Player) != None )
                myDebugHUD = spawn(Class'Engine.DebugHUD', self);
        }
    
        // Ensure spectator hud is in use
        if(myHUD == None || (myHUD != None && HUDTypeSpectator != None && myHUD.Class != HUDTypeSpectator))
        {
            if(myHUD == None)
            {
                myHUD.Destroy();
            }
            myHUD = Spawn(HUDTypeSpectator, Self);
        }

        if(myHUD != None)
        {
            myHUD.PreRender(Canvas);
        }
    
        if (bClientSideAlpha)
        {
            OldStyle = Style;
            OldScale = AlphaScale;
            Style = STY_AlphaBlend;
            AlphaScale = ClientSideAlphaScale;
        }
    }

    event PostRender(Canvas C)
    {
        Global.PostRender(C);
        if(Self.Camera != None)
        {
            Self.Camera.PostRender(C);
        }
    }
    
    event PlayerInput(float DeltaSeconds)
    {
        Super.PlayerInput(DeltaSeconds);
        if(Self.Camera != None)
        {
            Self.Camera.Input_MouseAxis(aMouseX, aMouseY);
        }
    }
    
    // Use cycles camera modes
    exec function Use()
    {
        if(Self.Camera != None)
        {
            Self.Camera.Input_Use();
        }
    }
    
    // Fire cycles view targets
    exec function Fire(optional float F)
    {
        if(Self.Camera != None)
        {
            Self.Camera.Input_Fire();
        }
    }
    
    exec function CameraIn()
    {
        if(Self.Camera != None)
        {
            Self.Camera.Input_CameraIn();
        }
    }
    
    exec function CameraOut()
    {
        if(Self.Camera != None)
        {
            Self.Camera.Input_CameraOut();
        }
    }
    
    /**
    *   ServerReStartPlayer (override)
    *   Overridden to add R_GameInfo player restart logic
    */
    function ServerReStartPlayer()
    {
        local R_GameInfo RGI;

        if(!CheckCanRestart())
        {
            return;
        }

        // Begin PlayerPawn.ServerReStartPlayer
        if ( Level.NetMode == NM_Client )
        {
            return;
        }
        if (Level.Game.bGameEnded)
        {
            return;
        }
        if( Level.Game.RestartPlayer(self) )
        {
            ServerTimeStamp = 0;
            TimeMargin = 0;
            Enemy = None;
            Level.Game.StartPlayer(self);
            ClientReStart();
        }
        else
        {
            Log("Restartplayer failed");
        }
        // End PlayerPawn.ServerReStartPlayer

        PlayerRestart();
    }
}

//==============================================================================
//  State Dying (override)
//  This state is overridden to allow players to enter into temporary spectator
//  mode when they die in game types where they can't immediately respawn,
//  like Arena.
//  Respawning can be blocked by either the R_GameInfo, or by the R_RunePlayer
//  according to R_RunePlayer.CheckCanRestart.
//==============================================================================
state Dying
{
    function AnimEnd()
    {
        Super.AnimEnd();
        if(CheckShouldSpectateAfterDying())
        {
            GotoState('PlayerSpectating');
        }
    }

    /**
    *   ServerReStartPlayer (override)
    *   Overridden to add R_GameInfo player restart logic
    */
    function ServerReStartPlayer()
    {
        local R_GameInfo RGI;

        if(!CheckCanRestart())
        {
            return;
        }

        // Begin PlayerPawn.ServerReStartPlayer
        if ( Level.NetMode == NM_Client )
        {
            return;
        }
        if (Level.Game.bGameEnded)
        {
            return;
        }
        if( Level.Game.RestartPlayer(self) )
        {
            ServerTimeStamp = 0;
            TimeMargin = 0;
            Enemy = None;
            Level.Game.StartPlayer(self);
            ClientReStart();
        }
        else
        {
            Log("Restartplayer failed");
        }
        // End PlayerPawn.ServerReStartPlayer

        PlayerRestart();
    }
}

//==============================================================================
//  State GameEnded (override)
//  Overridden to prevent throwing at end game
//==============================================================================
state GameEnded
{
    ignores Throw;
}

//==============================================================================
//  State PlayerRopeClimbing (override)
//  Overridden to implement multiplayer compatibility with Rope actors
//==============================================================================
function ClimbableLeapOff() {}   // Global definition, defined in state
function ClimbableFallOff() {}

state PlayerRopeClimbing
{
    /**
    *   BeginState (override)
    *   Overridden to update LastTouchedClimbable variable. This gets reset in
    *   PlayerWalking.BeginState.
    */
    event BeginState()
    {
        local Vector NewLocation;
        
        Super.BeginState();
        
        if(TheRope != None)
        {
            NewLocation.X = TheRope.Location.X;
            NewLocation.Y = TheRope.Location.Y;
            NewLocation.Z = Self.Location.Z;
            SetLocation(NewLocation);
            LastTouchedClimbable = TheRope;
        }
    }
    
    event EndState()
    {
        Super.EndState();
    }
    
    /**
    *   ServerMove (override)
    *   Overridden to bypass RunePlayer.PlayerRopeClimbing.ServerMove.
    *   469b movement takes over the replicated movement.
    */
    function ServerMove
    (
        float TimeStamp, 
        vector Accel, 
        vector ClientLoc,
        bool NewbRun,
        bool NewbDuck,
        bool NewbJumpStatus, 
        bool bFired,
        bool bAltFired,
        bool bForceFire,
        bool bForceAltFire,
        eDodgeDir DodgeMove, 
        byte ClientRoll, 
        int View,
        optional byte OldTimeDelta,
        optional int OldAccel
    )
    {}
    
    /**
    *   PlayerMove (override)
    *   Overridden to strip out logic which should be performed in ProcessMove.
    */
    function PlayerMove( float DeltaTime)
    {
        local vector NewAccel;
        local vector HandPos;
        local vector X,Y,Z;
        local vector RopeVector, VelocityLookahead, RopeDir, NewLocation;
        local Rotator OldRotation;

        if(TheRope == None)
            return;

        // Mangle controls
        //aForward *= 0.00;
        aStrafe  *= 0.00;
        aLookup  *= 0.24;
        aTurn    *= 0.24;

        if(aUp > 0)
        { // Move slightly slower going up than going down
            aForward *= 0.056;
        }
        else
        {
            aForward *= 0.084;
        }

        NewAccel.X = 0.0;
        NewAccel.Y = 0.0;
        NewAccel.Z = aForward * 1.5;

        // Update view rotation
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
        bPressedJump = false;
    }
    
    /**
    *   ProcessMove (override)
    *   This function performs server-authoritative and client-simulated movement.
    *   Overridden to move the related logic out of PlayerMove to here.
    */
    function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)   
    {
        if (Physics != PHYS_Flying)
        {
            SetPhysics(PHYS_Flying);
        }
        
        Acceleration.X = 0.0;
        Acceleration.Y = 0.0;
        Velocity.X = 0.0;
        Velocity.Y = 0.0;
        Velocity += NewAccel * DeltaTime;
        
        // Braking deceleration
        if(NewAccel.Z == 0.0)
        {
            if(Velocity.Z > 0.0)
            {
                // Up decelerates faster
                Velocity.Z = Velocity.Z - (Velocity.Z * 0.95 * DeltaTime);
            }
            else if(Velocity.Z < 0.0)
            {
                // Down is a little slidey
                Velocity.Z = Velocity.Z - (Velocity.Z * 0.05 * DeltaTime);
            }
        }
        
        Velocity.Z = FClamp(Velocity.Z, -700.0, 700.0);
        
        // Clamp Z location to rope top / bottom
        if(TheRope != None)
        {
            if (Location.Z <= TheRope.RopeClimbBottom.Z)
            {   // Hit Bottom
                if (Location.Z < TheRope.RopeClimbBottom.Z)
                {
                    SetLocation(TheRope.RopeClimbBottom);
                }
                Velocity.Z = Max(0, Velocity.Z);
            }
            else if (Location.Z >= TheRope.RopeClimbTop.Z)
            {   // Hit Top
                if (Location.Z > TheRope.RopeClimbTop.Z)
                {
                    SetLocation(TheRope.RopeClimbTop);
                }
                Velocity.Z = Min(0, Velocity.Z);
            }
        }
        
        PlayRopeClimb();
        
        if(bPressedJump)
        {
            ClimbableLeapOff();
        }
    }
    
    /**
    *   Jump (override)
    *   Overridden to allow player to jump off rope by pressing the jump key
    */
    exec function Jump(optional float f)
    {
        bPressedJump = true;
    }
    
    /**
    *   Use (override)
    *   Overridden to ignore the RunePlayer Use function in this state, and
    *   call Global Use, which handles the PlayerRopeClimbing state.
    *   This is necessary because apparently, the Use function doesn't replicate
    *   correctly to the server from within this state.
    */
    exec function Use()
    {
        Global.Use();
    }
    
    /**
    *   ClimbableLeapOff
    *   Replacement function for LeapOff, which is only state-defined in RunePlayer.
    *   A Globally defined function is needed for Global.Use to call.
    */
    function ClimbableLeapOff()
    { // Release in the direction Ragnar is currently facing (when the Use key is pressed)
        local Vector SavedRopeLocation;
        local Vector X, Y, Z;
        local Vector Deviation;
        local float JumpForce;

        SavedRopeLocation = Vect(0.0, 0.0, 0.0);
        if(TheRope != None)
        {
            SavedRopeLocation = TheRope.Location;
        }
        
        DisconnectFromClimbable();

        Deviation = (Location - SavedRopeLocation);
        if (VSize2D(Deviation) > 50)
            JumpForce = 0.5;
        else
            JumpForce = 0.25;
        GetAxes(Rotation, X, Y, Z);
        AddVelocity(X * 350 );

        PlayRopeLeapOff();
    }
    
    /**
    *   ClimbableFallOff
    *   Replacement function for FallOff, which is only state-defined in RunePlayer
    */
    function ClimbableFallOff()
    {
        local Vector X, Y, Z;

        DisconnectFromClimbable();

        GetAxes(Rotation, X, Y, Z);
        Velocity = -X * 50;
        
        PlayRopeLeapOff();
    }
    
    /**
    *   DisconnectFromClimbable
    *   Common function called from ClimbableLeapOff and ClimbableFallOff
    */
    function DisconnectFromClimbable()
    {
        SetPhysics(PHYS_Falling);
        if(TheRope != None)
        {
            TheRope.DetachFromRope(Self);
            TheRope = None;
        }
        
        if (Region.Zone.bWaterZone)
        {
            SetPhysics(PHYS_Swimming);
            GotoState('PlayerSwimming');
        }
        else
        {
            if(AnimProxy != None)
                AnimProxy.GotoState('Idle');

            GotoState('PlayerWalking');
        }
    }
}


//==============================================================================
//  State ClientDisconnected
//==============================================================================
state ClientDisconnected
{
    ignores Tick, PlayerTick;
}


//==============================================================================
//  Begin Loadout Menu Functions
//==============================================================================
/**
*   SpawnLoadoutReplicationInfo
*   Called during PostBeginPlay on the Server
*   Spawns the loadout replication info
*/
function SpawnLoadoutReplicationInfo()
{
    if(Role == ROLE_Authority && LoadoutReplicationInfoClass != None)
    {
        LoadoutReplicationInfo = Spawn(LoadoutReplicationInfoClass, Self);
    }
}

/**
*   OpenLoadoutMenu
*   In game modes where it is allowed, this function will display the loadout
*   menu on the player's screen.
*   R_GameInfo.bLoadoutsEnabled must be true
*/
function OpenLoadoutMenu()
{
    local R_GameReplicationInfo RGRI;
    local WindowConsole WC;
    local UWindowWindow Window;
    local bool bLoadoutsEnabled;

    // Checks whether or not the DoNotShow option was selected
    // This can be reverted by called the 'loadout' command
    if(bLoadoutMenuDoNotShow)
    {
        return;
    }

    bLoadoutsEnabled = false;

    // Verify that loadout is enabled for the current game
    RGRI = R_GameReplicationInfo(GameReplicationInfo);
    if(RGRI != None)
    {
        bLoadoutsEnabled = RGRI.bLoadoutsEnabled;
    }

    if(!bLoadoutsEnabled)
    {
        ClientMessage("Loadouts are not enabled for the current game mode");
        return;
    }

    WC = WindowConsole(Player.Console);
    if(WC == None)
    {
        UtilitiesClass.Static.RModLog("Failed to open loadout menu -- Invalid console");
        return;
    }

    if(WC.IsInState('UWINDOW') && !WC.bShowConsole)
    {
        // Player is in main menu
        return;
    }

    if(!WC.bCreatedRoot || WC.Root == None)
    {
        WC.CreateRootWindow(None);
    }

    WC.bQuickKeyEnable = true;
    WC.LaunchUWindow();

    // If loadout menu is already open, return
    Window = WC.Root.FindChildWindow(Class'RMod.R_LoadoutWindow');
    if(Window != None)
    {
        return;
    }
    else
    {
        Window = WC.Root.CreateWindow(Class'RMod.R_LoadoutWindow', 128, 256, 400, 128);
        if(WC.bShowConsole)
        {
            WC.HideConsole();
        }

        Window.bLeaveOnScreen = true;
        Window.ShowWindow();
    }
}

/**
*   CloseLoadoutMenu
*   Closes the loadout menu if it is currently open.
*/
function CloseLoadoutMenu()
{
    local WindowConsole WC;
    local UWindowWindow Window;

    WC = WindowConsole(Player.Console);
    if(WC == None)
    {
        UtilitiesClass.Static.RModLog("Failed to close loadout menu -- Invalid console");
        return;
    }

    Window = WC.Root.FindChildWindow(Class'RMod.R_LoadoutWindow');
    if(Window != None)
    {
        Window.Close();
    }
}

/**
*   ClientOpenLoadoutMenu
*   RPC sent from Server --> Owning Client when the game is requesting
*   players to open their loadout menus.
*/
function ClientOpenLoadoutMenu()
{
    OpenLoadoutMenu();
}

/**
*   ClientCloseLoadoutMenu
*   RPC sent from Server --> Owning Client when the game is requesting
*   players to close their loadout menus.
*/
function ClientCloseLoadoutMenu()
{
    CloseLoadoutMenu();
}

//==============================================================================
//  End Loadout Menu Functions
//==============================================================================

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
    ColorsClass=Class'RMod.R_AColors'
    GameOptionsCheckerClass=Class'RMod.R_AGameOptionsChecker'
    SpawnableAnimationProxyClass=Class'RMod.R_RunePlayerProxy'
    SpawnableSeveredHeadClass=Class'RMod.R_Weapon_BodyPart_Head'
    SpawnableSeveredLimbClass=Class'RMod.R_Weapon_BodyPart_Limb'
    SpectatorCameraClass=Class'RMod.R_Camera_Spectator'
    LoadoutReplicationInfoClass='RMod.R_LoadoutReplicationInfo'
    bMessageBeep=True
    WeaponSwipeTexture=None
    WeaponSwipeBloodlustTexture=Texture'RuneFX.swipe_red'
    bAlwaysRelevant=True
    bRotateTorso=False
    bLoadoutMenuDoNotShow=False
    bShowRmodDebug=False
    SuicideSpamParameters=(TimeStamp=0.0,CooldownDuration=5.0)
    ChatSpamParameters=(TimeCost=1.0,TimeAccumulator=20.0,TimeAccumulationMax=20.0,TimePenalty=5.0)
}
