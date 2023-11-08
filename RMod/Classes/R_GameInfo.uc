//==============================================================================
//  R_GameInfo
//  Base GameInfo class for all RMod game types.
//==============================================================================
class R_GameInfo extends RuneI.RuneMultiPlayer config(RMod);

var config Class<RunePlayer> RunePlayerClass;
var Class<RunePlayer> SpectatorMarkerClass;
var config Class<PlayerReplicationInfo> PlayerReplicationInfoClass;
var config class<R_AColors> ColorsClass;

var Class<R_AUtilities> UtilitiesClass;
var config Class<R_AActorSubstitution> ActorSubstitutionClass;

// Temporary ban management
var Class<R_TempBanManager> TempBanManagerClass;
var R_TempBanManager TempBanManager;

// Persistent score tracking
var Class<R_PersistentScoreManager> PersistentScoreManagerClass;
var R_PersistentScoreManager PersistentScoreManager;
var config bool bEnablePersistentScoreTracking;

// RMod Game Options
var config Class<R_GameOptions> GameOptionsClass;
var R_GameOptions GameOptions;

// Loadout options, spawned when loadout option is enabled
var config Class<R_LoadoutOptionReplicationInfo> LoadoutOptionReplicationInfoClass;
var R_LoadoutOptionReplicationInfo LoadoutOptionReplicationInfo;
var config bool bLoadoutsEnabled;

var private String OldGamePassword;

var Class<HUD> HUDTypeSpectator;
var bool bAllowSpectatorBroadcastMessage;

var config bool bRemoveNativeWeapons;
var config bool bRemoveNativeShields;
var config bool bRemoveNativeRunes;
var config bool bRemoveNativeFoods;

// Used at level start to mark actors which stay during level reset
var bool bMarkSpawnedActorsAsNativeToLevel;

// PlayerRestart variables
var config int DefaultPlayerHealth;
var config int DefaultPlayerMaxHealth;
var config int DefaultPlayerRunePower;
var config int DefaultPlayerMaxRunePower;

event Tick(float DeltaSeconds)
{
	local String CurrentGamePassword;
	local R_RunePlayer RP;

	// Game password updates
	CurrentGamePassword = ConsoleCommand("Get Engine.GameInfo GamePassword");

	// Watch for changes and send updates to players
	if(OldGamePassword != CurrentGamePassword)
	{
		OldGamePassword = CurrentGamePassword;
		foreach AllActors(class'RMod.R_RunePlayer', RP)
		{
			RP.ClientReceiveUpdatedGamePassword(CurrentGamePassword);
		}
	}
}

function bool CheckMapExists(String MapString)
{
	if(MapString == ""
	|| LevelInfo(DynamicLoadObject(
		MapString$".LevelInfo0", class'LevelInfo')) == None)
	{
		return false;
	}
	return true;
}

function PlayerSetTimeLimit(PlayerPawn P, int DurationMinutes)
{
	local R_RunePlayer RP;
	local R_GameReplicationInfo GRI;
	
	TimeLimit = DurationMinutes;
	RemainingTime = TimeLimit * 60;
	
	GRI = R_GameReplicationInfo(GameReplicationInfo);
	if(GRI != None)
	{
		GRI.UpdateTimeLimit(RemainingTime);
	}
	
	SaveConfig();
	
	BroadcastMessage("TimeLimit has been set to " $ DurationMinutes $ " minutes.");
}

event BeginPlay()
{
    Super.BeginPlay();
    SaveConfig();
}

event PostBeginPlay()
{
	local String CurrentGamePassword;
    local R_GameReplicationInfo RGRI;
    
	Super.PostBeginPlay();
	
	// Actors spawned after this point are not a part of the level's original
	// state, so they won't be respawned on level reset
	bMarkSpawnedActorsAsNativeToLevel = false;

	CurrentGamePassword = ConsoleCommand("Get Engine.GameInfo GamePassword");
	OldGamePassword = CurrentGamePassword;

    if(bLoadoutsEnabled)
    {
        SpawnLoadoutOptionReplicationInfo();
    }

    SpawnTempBanManager();
    SpawnPersistentScoreManager();
    SpawnGameOptions();

    RGRI = R_GameReplicationInfo(GameReplicationInfo);
    if(RGRI != None)
    {
        RGRI.bLoadoutsEnabled = bLoadoutsEnabled;
    }
}

function SpawnLoadoutOptionReplicationInfo()
{
    if(LoadoutOptionReplicationInfoClass != None)
    {
        LoadoutOptionReplicationInfo = Spawn(LoadoutOptionReplicationInfoClass);
        UtilitiesClass.Static.RModLog("Spawned LoadoutOptionReplicationInfo from class" @ LoadoutOptionReplicationInfoClass);
    }
    else
    {
        UtilitiesClass.Static.RModWarn("Failed to spawn LoadoutOptionReplicationInfo, no class specified");
    }
}

function SpawnTempBanManager()
{
    if(TempBanManagerClass != None)
    {
        TempBanManager = New(None) TempBanManagerClass;
    }

    if(TempBanManager != None)
    {
        UtilitiesClass.Static.RModLog("Temp ban manager spawned from class" @ TempBanManagerClass);
        TempBanManager.Initialize(Self);
    }
}

function SpawnPersistentScoreManager()
{
    if(!bEnablePersistentScoreTracking)
    {
        UtilitiesClass.Static.RModLog("Persistent score tracking disabled");
        return;
    }

    if(PersistentScoreManagerClass != None)
    {
        PersistentScoreManager = New(None) PersistentScoreManagerClass;
    }

    if(PersistentScoreManager != None)
    {
        UtilitiesClass.Static.RModLog("Spawned persistent score manager from class" @ PersistentScoreManagerClass);
        PersistentScoreManager.Initialize(Self);
    }
    else
    {
        UtilitiesClass.Static.RModWarn("Failed to spawn persistent score manager");
    }
}

function SpawnGameOptions()
{
    local R_GameReplicationInfo RGRI;

    // Spawn Game Options
    if(GameOptionsClass != None)
    {
        GameOptions = Spawn(GameOptionsClass);
        if(GameOptions != None)
        {
            RGRI = R_GameReplicationInfo(GameReplicationInfo);
            if(RGRI != None)
            {
                RGRI.GameOptions = GameOptions;
            }
        }
    }
}

/**
*   ReplicateCurrentGameState
*   Replicate the name of the current game state via game rep info.
*   This is useful info for clients.
*/
function ReplicateCurrentGameState()
{
    local R_GameReplicationInfo RGRI;

    RGRI = R_GameReplicationInfo(GameReplicationInfo);
    if(RGRI != None)
    {
        RGRI.GameStateName = GetStateName();
    }
}

/////////////////////////////////////////////////////////////////////////////////
//	NativeLevelCleanup
//	Remove all non-essential actors in the level that were not there at startup
final function MarkActorAsNativeToLevel(Actor A)	{ A.bDifficulty3 = true; }
final function MarkActorAsNotNativeToLevel(Actor A)	{ A.bDifficulty3 = false; }
final function bool CheckActorNativeToLevel(Actor A){ return A.bDifficulty3; }

// Check up the actor's owner hierarchy, return true if any owner is native
final function bool RecursiveCheckActorNativeToLevel(Actor A)
{
	local Actor AOwner;
	
	AOwner = A;
	while(AOwner != None)
	{
		if(CheckActorNativeToLevel(AOwner))
		{
			return true;
		}
		AOwner = AOwner.Owner;
	}
	return false;
}

// Check up the actors owner hierarchy, return true if any owner is a player
final function bool RecursiveCheckOwnedByPlayer(Actor A)
{
	local Actor AOwner;
	
	AOwner = A;
	while(AOwner != None)
	{
		if(PlayerPawn(AOwner) != None)
		{
			return true;
		}
		AOwner = AOwner.Owner;
	}
	return false;
}

// Authoritative function determining whether or not to destroy an actor
final function bool CheckShouldNativeLevelCleanupDestroyActor(Actor A)
{
	// Do not destroy info actors
	if(Info(A) != None)
	{
		return false;
	}
	
	// Don't destroy players or anything owned by players (anim proxy)
	if(RecursiveCheckOwnedByPlayer(A))
	{
		return false;
	}
	
	// Don't destroy anything that has been marked native or has a native owner
	if(RecursiveCheckActorNativeToLevel(A))
	{
		return false;
	}
	
	return true;
}

// Restore a given actor to its native state
final function RestoreActorToNativeState(Actor A)
{
	if(Inventory(A) != None && A.Owner == None)
	{
		Inventory(A).GotoState('Pickup');
		return;
	}
}

// Restore the level to its native state
final function NativeLevelCleanup()
{
	local Actor A;
	local Actor AOwner;
	
	UtilitiesClass.Static.RModLog("Performing native level cleanup");
	
	foreach AllActors(class'Engine.Actor', A)
	{
		if(CheckShouldNativeLevelCleanupDestroyActor(A))
		{
			A.Destroy();
		}
		else
		{
			RestoreActorToNativeState(A);
		}
	}
}

function ResetGameReplicationInfo()
{
	local PlayerPawn P;
	local RuneMultiPlayer RMP;
	local int i;
	
	UtilitiesClass.Static.RModLog("Reinitializing game replication info");
	
	RMP = RuneMultiPlayer(Level.Game);
	if(RMP != None)
	{
		RMP.RemainingTime = 60 * RMP.TimeLimit;
		
		// Reinitialize game replication info
		if(Level.Game.GameReplicationInfo != None)
		{
			Level.Game.GameReplicationInfo.Destroy();
		}
		
		if(Level.Game.GameReplicationInfoClass != None)
		{
			Level.Game.GameReplicationInfo = Spawn(Level.Game.GameReplicationInfoClass);
		}
		else
		{
			Level.Game.GameReplicationInfo = Spawn(class'Engine.GameReplicationInfo');
		}
		
		Level.Game.GameReplicationInfo.RemainingTime = RMP.RemainingTime;
		Level.Game.InitGameReplicationInfo();
		
		foreach AllActors(class'Engine.PlayerPawn', P)
		{
			P.GameReplicationInfo = Level.Game.GameReplicationInfo;
		}
	}
}

function ResetPlayerReplicationInfos()
{
	local PlayerReplicationInfo PRI;
	
	UtilitiesClass.Static.RModLog("Resetting all player replication infos");
	
	foreach AllActors(class'Engine.PlayerReplicationInfo', PRI)
	{
		if(R_PlayerReplicationInfo(PRI) != None)
		{
			R_PlayerReplicationInfo(PRI).ResetPlayerReplicationInfo();
		}
		else
		{
			PRI.Score = 0;
			PRI.Deaths = 0;
			PRI.bFirstBlood = false;
			PRI.MaxSpree = 0;
			PRI.HeadKills = 0;
		}
		
	}
}

function ResetTeamReplicationInfos()
{
	local TeamInfo TRI;
	
	UtilitiesClass.Static.RModLog("Resetting all team replication infos");
	
	foreach AllActors(class'RuneI.TeamInfo', TRI)
	{
		TRI.Score = 0;
	}
}

function ResetPlayerPawnStatistics()
{
	local PlayerPawn P;
	
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		P.DieCount = 0;
		P.ItemCount = 0;
		P.KillCount = 0;
		P.SecretCount = 0;
		P.Spree = 0;
	}
}

// Performs a hard level reset - resets all stats, restarts players, restores level
function ResetLevel(optional int DelaySeconds)
{
	local PlayerPawn P;
	local R_GameResetAgent GRA;
	
	DelaySeconds = Clamp(DelaySeconds, 0, 10);
	if(DelaySeconds > 0)
	{
		// GameResetAgent will call back after countdown
		GRA = Spawn(class'RMod.R_GameResetAgent');
		if(GRA != None)
		{
			GRA.DurationSeconds = DelaySeconds;
		}
		return;
	}
	
	UtilitiesClass.Static.RModLog("Resetting level");
	
	// Remove non-native actors
	NativeLevelCleanup();

	// Reset game stats
	ResetGameReplicationInfo();
	ResetPlayerReplicationInfos();
	ResetTeamReplicationInfos();
	ResetPlayerPawnStatistics();

	// Restart all players
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		// Do not restart spectators
		if(Spectator(P) != None
		|| P.PlayerReplicationInfo.bIsSpectator)
		{
			continue;
		}
		
		Level.Game.RestartPlayer(P);
	}
}

// Performs a soft level reset - same as ResetLevel, but stats stay
// This is for game types where resetting the level is a part of the game
function ResetLevelSoft(optional int DelaySeconds)
{
	local PlayerPawn P;
	local R_GameResetAgent GRA;
	
	DelaySeconds = Clamp(DelaySeconds, 0, 10);
	if(DelaySeconds > 0)
	{
		// GameResetAgent will call back after countdown
		GRA = Spawn(class'RMod.R_GameResetAgent');
		if(GRA != None)
		{
			GRA.DurationSeconds = DelaySeconds;
		}
		return;
	}
	
	UtilitiesClass.Static.RModLog("Soft-Resetting level");
	
	// Remove non-native actors
	NativeLevelCleanup();

	// Restart all players
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		// Do not restart spectators
		if(Spectator(P) != None
		|| P.PlayerReplicationInfo.bIsSpectator)
		{
			continue;
		}
		
		Level.Game.RestartPlayer(P);
	}
}

function bool RestartPlayer( pawn aPlayer )
{
    local bool bResult;
	if(R_RunePlayer(aPlayer) != None)
	{
		R_RunePlayer(aPlayer).DiscardInventory();
	}
	DiscardInventory(aPlayer);
	aPlayer.GotoState('PlayerWalking');

	bResult = Super.RestartPlayer(aPlayer);

    if(!bResult)
    {
        return false;
    }

    // Override with game stats
    aPlayer.MaxHealth = DefaultPlayerMaxHealth;
    aPlayer.Health = DefaultPlayerHealth;
    aPlayer.MaxPower = DefaultPlayerMaxRunePower;
    aPlayer.RunePower = DefaultPlayerRunePower;

    return true;
}

function PlayerPawn GetPlayerPawnByID(int PlayerID)
{
	local PlayerPawn P;
	
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		if(P.PlayerReplicationInfo != None
		&& P.PlayerReplicationInfo.PlayerID == PlayerID)
		{
			return P;
		}
	}
	return None;
}

/**
*   TempBan
*   Temporarily ban a player for some duration.
*/
function TempBan(PlayerPawn P, float DurationSeconds, optional String ReasonString)
{
    local String PlayerIPString;
    local String PlayerIPStringIterator;
    local Pawn PawnIterator;
    local Pawn PendingDestroyPawns[64];
    local int i;

    if(DurationSeconds < 1.0)
    {
        return;
    }

    if(TempBanManager != None)
    {
        PlayerIPString = P.GetPlayerNetworkAddress();
        PlayerIPString = Left(PlayerIPString, InStr(PlayerIPString, ":"));
        TempBanManager.ApplyTempBan(PlayerIPString, DurationSeconds, ReasonString);

        i = 0;
        for(PawnIterator = Level.PawnList; PawnIterator != None; PawnIterator = PawnIterator.NextPawn)
        {
            if(PlayerPawn(PawnIterator) != None)
            {
                PlayerIPStringIterator = PlayerPawn(PawnIterator).GetPlayerNetworkAddress();
                PlayerIPStringIterator = Left(PlayerIPStringIterator, InStr(PlayerIPStringIterator, ":"));
                if(PlayerIPStringIterator == PlayerIPString)
                {
                    PendingDestroyPawns[i] = PawnIterator;
                    ++i;
                }
            }
        }

        for(i = 0; i < 64; ++i)
        {
            if(PendingDestroyPawns[i] != None)
            {
                PendingDestroyPawns[i].Destroy();
            }
        }
    }
}

/**
*   PreLogin (override)
*   Overridden to check for temporary bans on incoming connections.
*/
event PreLogin(
	String Options,
	String Address,
	out String Error,
	out String FailCode)
{
    local String PlayerIPString;
    local float RemainingTempBanDurationSeconds;
    local String BanReasonString;

    // Check for temp ban
    if(TempBanManager != None)
    {
        PlayerIPString = Address;
        PlayerIPString = Left(PlayerIPString, InStr(PlayerIPString, ":"));
        if(TempBanManager.CheckTempBan(PlayerIPString, RemainingTempBanDurationSeconds, BanReasonString))
        {
            Error = "You are temporarily banned.";

            if(BanReasonString != "")
            {
                Error = Error @ "Reason:" @ BanReasonString $ ".";
            }

            Error = Error @ int(RemainingTempBanDurationSeconds) @ "seconds remaining";

            return;
        }
    }

	Super.PreLogin(Options, Address, Error, FailCode);
}

/**
*   Login (override)
*   Overridden to force all incoming players to spawn with a common class.
*   Individual class data is extracted and applied to R_RunePlayer.
*/
event PlayerPawn Login(
	String Portal,
	String Options,
	out String Error,
	Class<PlayerPawn> SpawnClass)
{
	local Class<PlayerPawn> IncomingClass;
	local PlayerPawn P;
	
	IncomingClass = SpawnClass;
	
	SpawnClass = RunePlayerClass;

	P = Super.Login(
		Portal,
		Options,
		Error,
		SpawnClass);
	
	if(Class<RunePlayer>(IncomingClass) != None
	&& Class<R_RunePlayer>(IncomingClass) == None)
	{
		UtilitiesClass.Static.RModLog("Incoming player subclass: " $ IncomingClass);
		if(R_RunePlayer(P) != None)
		{
			R_RunePlayer(P).ApplyRunePlayerSubClass(Class<RunePlayer>(IncomingClass));
		}
	}
	else if(Class<Spectator>(IncomingClass) != None)
	{
		// Destroy PRI for messaging spectators (webadmin spectator)
		if(Class<MessagingSpectator>(IncomingClass) != None)
		{
			P.PlayerReplicationInfo.Destroy();
		}
		
		UtilitiesClass.Static.RModLog("Incoming spectator class: " $ IncomingClass);
		if(R_RunePlayer(P) != None)
		{
			R_RunePlayer(P).ApplyRunePlayerSubClass(Self.SpectatorMarkerClass);
		}
	}
	
	return P;
}

event PostLogin(PlayerPawn NewPlayer)
{
    local String IPString;

	Super.PostLogin(NewPlayer);

	// All players initially enter into player validation state
	if(R_RunePlayer(NewPlayer) != None)
	{
        R_RunePlayer(NewPlayer).GotoState('PlayerValidation');
	}

    // Save player IP to PRI
    if(NewPlayer != None && R_PlayerReplicationInfo(NewPlayer.PlayerReplicationInfo) != None)
    {
        IPString = NewPlayer.GetPlayerNetworkAddress();
        IPString = Left(IPString, InStr(IPString, ":"));
        R_PlayerReplicationInfo(NewPlayer.PlayerReplicationInfo).PlayerIP = IPString;
    }

    // Allow persistent score manager to match saved score data
    if(PersistentScoreManager != None)
    {
        PersistentScoreManager.ApplyPersistentScore(NewPlayer);
    }
}

function ReportValidationSucceeded(PlayerPawn P)
{
    local String PlayerLogString;

    PlayerLogString = UtilitiesClass.Static.GetPlayerIdentityLogString(P);
    UtilitiesClass.Static.RModLog("Player validation succeeded for" @ PlayerLogString);

    if(R_RunePlayer(P) != None)
    {
        if(R_RunePlayer(P).RunePlayerSubClass == SpectatorMarkerClass)
        {
            MakePlayerSpectate(R_RunePlayer(P));
        }
        else
        {
            RestartPlayer(P);
        }
    }
}

function ReportValidationFailed(PlayerPawn P, String ReasonString)
{
    local String PlayerLogString;

    PlayerLogString = UtilitiesClass.Static.GetPlayerIdentityLogString(P);
    UtilitiesClass.Static.RModLog("Player validation failed for" @ PlayerLogString @ "Reason:" @ ReasonString);

    TempBan(P, 300.0);
}

event Logout(Pawn P)
{
	// Do not logout the dummy pawns used for copying
	if(class'RMod.R_RunePlayer'.Static.CheckForDummyTag(P))
	{
		return;
	}

    // Update persistent score info when player leaves
    if(PersistentScoreManager != None)
    {
        PersistentScoreManager.SavePersistentScore(P);
    }
	
	Super.Logout(P);
}

event bool IsRelevant(Actor A)
{
	local Vector Loc;
	local Rotator Rot;
	
    // This check is only true at the start of every level, so this is the best
    // place to do startup item removal
    if(bMarkSpawnedActorsAsNativeToLevel)
    {
        if(bRemoveNativeWeapons && Weapon(A) != None)   { return false; }
        if(bRemoveNativeShields && Shield(A) != None)   { return false; }
        if(bRemoveNativeRunes && Runes(A) != None)      { return false; }
        if(bRemoveNativeFoods && Food(A) != None)       { return false; }
    }

    if(ActorSubstitutionClass != None)
    {
        A = ActorSubstitutionClass.Static.PerformActorSubstitution(Self, A);
    }

	if(!Super.IsRelevant(A))
	{
		return false;
	}
	
	// Mark for native level
	if(bMarkSpawnedActorsAsNativeToLevel)
	{
		MarkActorAsNativeToLevel(A);
	}
	else
	{
		MarkActorAsNotNativeToLevel(A);
	}
	
	return true;
}

/**
*   AddDefaultInventory (override)
*   Overridden to account for spawning substituted classes as defaults.
*/
function AddDefaultInventory(Pawn PlayerPawn)
{
    local Weapon newWeapon;
    local Shield newShield;
    local Class<Weapon> SpawnWeaponClass;
    local Class<Shield> SpawnShieldClass;

    PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ * PlayerJumpZScaling();

    if(PlayerPawn.IsA('Spectator'))
    {
        return;
    }

    // If loadouts are enabled, then grant inventory based on loadout
    if(bLoadoutsEnabled)
    {
        AddDefaultInventory_LoadoutEnabled(PlayerPawn);
        return;
    }

    // Spawn default weapon.
    if (PlayerPawn.Weapon == None)
    {
        if((DefaultWeapon != None && PlayerPawn.FindInventoryType(DefaultWeapon)==None)     // Default weapon exists that player doesn't yet have
        ||  BaseMutator.MutatedDefaultWeapon() != None)                                       // Mutators dictating a default weapon
        {
            SpawnWeaponClass = BaseMutator.MutatedDefaultWeapon();

            if(ActorSubstitutionClass != None)
            {
                SpawnWeaponClass = Class<Weapon>(ActorSubstitutionClass.Static.GetActorSubstitutionClass(SpawnWeaponClass));
            }

            newWeapon = Spawn(SpawnWeaponClass,,,PlayerPawn.Location);
            if(newWeapon != None)
            {
                newWeapon.bTossedOut = true;
                newWeapon.Instigator = PlayerPawn;
                newWeapon.BecomeItem();
                PlayerPawn.AddInventory(newWeapon);
                PlayerPawn.AcquireInventory(newWeapon);
                PlayerPawn.Weapon = newWeapon;
                newWeapon.GotoState('Active');
            }
        }
    }

    // Spawn default shield
    if (PlayerPawn.Shield == None)
    {
        if((DefaultShield!=None && PlayerPawn.FindInventoryType(DefaultShield)==None)
        ||  BaseMutator.MutatedDefaultShield()!=None)
        {
            SpawnShieldClass = BaseMutator.MutatedDefaultShield();

            if(ActorSubstitutionClass != None)
            {
                SpawnShieldClass = Class<Shield>(ActorSubstitutionClass.Static.GetActorSubstitutionClass(SpawnShieldClass));
            }

            newShield = Spawn(SpawnShieldClass,,,PlayerPawn.Location);
            if(newShield != None)
            {
                newShield.bTossedOut = true;
                newShield.Instigator = PlayerPawn;
                newShield.BecomeItem();
                PlayerPawn.AddInventory(newShield);
                PlayerPawn.AcquireInventory(newShield);
                PlayerPawn.Shield = newShield;
                newShield.GotoState('Active');
            }
        }
    }

    BaseMutator.ModifyPlayer(PlayerPawn);
}

function AddDefaultInventory_LoadoutEnabled(Pawn PlayerPawn)
{
    local R_RunePlayer RP;
    local R_LoadoutReplicationInfo LRI;
    local Class<Inventory> LoadoutInventoryClasses[16];
    local int i;
    local Class<Inventory> LoadoutInventoryClassCurrent, LoadoutInventoryClassTemp;
    local Inventory InventoryCurrent;

    RP = R_RunePlayer(PlayerPawn);
    if(RP != None)
    {
        LRI = RP.LoadoutReplicationInfo;
        if(LRI != None)
        {
            LoadoutInventoryClasses[0] = LRI.TertiaryInventoryClass;
            LoadoutInventoryClasses[1] = LRI.SecondaryInventoryClass;
            LoadoutInventoryClasses[2] = LRI.PrimaryInventoryClass;
        }
    }

    // If there's a shield in the array, swap it so that it's the last item granted
    for(i = 15; i >= 0; --i)
    {
        if(Class<Shield>(LoadoutInventoryClasses[i]) != None)
        {
            LoadoutInventoryClassTemp = LoadoutInventoryClasses[15];
            LoadoutInventoryClasses[15] = LoadoutInventoryClasses[i];
            LoadoutInventoryClasses[i] = LoadoutInventoryClassTemp;
        }
    }

    // Clear out any remaining shields from the array, since players can only hold one
    for(i = i; i >= 0; --i)
    {
        if(Class<Shield>(LoadoutInventoryClasses[i]) != None)
        {
            LoadoutInventoryClasses[i] = None;
        }
    }

    // Grant all inventories
    for(i = 0; i < 16; ++i)
    {
        LoadoutInventoryClassCurrent = LoadoutInventoryClasses[i];
        if(LoadoutInventoryClassCurrent != None && PlayerPawn.FindInventoryType(LoadoutInventoryClassCurrent) == None)
        {
            if(ActorSubstitutionClass != None)
            {
                LoadoutInventoryClassCurrent = Class<Inventory>(ActorSubstitutionClass.Static.GetActorSubstitutionClass(LoadoutInventoryClassCurrent));
            }

            InventoryCurrent = Spawn(LoadoutInventoryClassCurrent,,, PlayerPawn.Location);
            InventoryCurrent.Instigator = PlayerPawn;
            InventoryCurrent.BecomeItem();
            PlayerPawn.AddInventory(InventoryCurrent);
            PlayerPawn.AcquireInventory(InventoryCurrent);
            if(Weapon(InventoryCurrent) != None)
            {
                PlayerPawn.Weapon = Weapon(InventoryCurrent);
            }
            else if(Shield(InventoryCurrent) != None)
            {
                // If equipping a shield, may need to stow whatever is in hands
                if(RP != None && RP.Weapon != None && RP.Weapon.A_Defend == 'None')
                {
                    RP.InstantStow();
                }
                PlayerPawn.Shield = Shield(InventoryCurrent);
            }
            InventoryCurrent.GotoState('Active');
        }
    }
}

/**
*   CheckIsGameDamageEnabled
*   Called by R_RunePlayer.JointDamaged to allow game modes to enable and
*   disable global invulnerability as desired.
*/
function bool CheckIsGameDamageEnabled()
{
    return true;
}

/**
*   CheckIsScoringEnabled
*   Called by R_GameInfo.ScoreKill to allow game modes to enable and
*   disable score tracking as desired.
*/
function bool CheckIsScoringEnabled()
{
    return true;
}

function bool ChangeTeam(Pawn Other, int N)
{
	if(Other.PlayerReplicationInfo == None
	|| Other.PlayerReplicationInfo.bIsSpectator
	|| Other.GetStateName() == 'PlayerSpectating')
	{
		return false;
	}
	
	Other.PlayerReplicationInfo.Team = N;
	if (LocalLog != None)
		LocalLog.LogTeamChange(Other);
	if (WorldLog != None)
		WorldLog.LogTeamChange(Other);
	return true;
}

function ScoreKill(Pawn Killer, Pawn Other)
{
    if(!CheckIsScoringEnabled())
    {
        return;
    }

    if (Other==None)
    {
        log("Warning: ScoreKill (OTHER==NONE): Killer="$Killer@"Other="$Other);
        return;
    }

    Other.DieCount++;
    if (Other.bIsPlayer && Other.PlayerReplicationInfo != None)
	{
        Other.PlayerReplicationInfo.Deaths +=1;
	}

    if( (Killer == Other) || (Killer == None) )
    {
        if (Other.PlayerReplicationInfo != None)
		{
            Other.PlayerReplicationInfo.Score -= 1;
		}
	}
    else if ( Killer != None )
    {
		if(bTeamGame && Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team)
		{
			Killer.PlayerReplicationInfo.Score -= 1;
		}
		else
		{
			Killer.killCount++;
			if ( Killer.PlayerReplicationInfo != None )
			{
				Killer.PlayerReplicationInfo.Score += 1;
			}
		}
	}
    BaseMutator.ScoreKill(Killer, Other);
}

function MakePlayerSpectate(R_RunePlayer P)
{
	// This is not the same as a player being in 'PlayerSpectating' state.
	// When this function is called, the player is considered a non-active player
	P.GoToState('PlayerSpectating');
	P.PlayerReplicationInfo.Team = 255;
	P.PlayerReplicationInfo.bIsSpectator = true;
}

function RequestSpectate(R_RunePlayer P)
{
	MakePlayerSpectate(P);
}

function bool SetEndCams(string Reason)
{
	local pawn aPawn;

	for ( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
		if ( aPawn.bIsPlayer )
		{
			if(!(aPawn.GetStateName() == 'PlayerSpectating'
			|| (aPawn.PlayerReplicationInfo != None && aPawn.PlayerReplicationInfo.bIsSpectator)))
			{
				aPawn.GotoState('GameEnded');
			}
			aPawn.ClientGameEnded();
		}	

	return true;
}

/**
*   CheckAllowRestart
*   Allows game modes to allow or deny player restarts.
*   Note that this works independently from RunePlayer.bCanRestart.
*   So, both this function AND bCanRestart must be true
*/
function bool CheckAllowRestart(PlayerPawn P)
{
    return true;
}

defaultproperties
{
    RunePlayerClass=Class'RMod.R_RunePlayer'
    SpectatorMarkerClass=Class'RMod.R_ASpectatorMarker'
    PlayerReplicationInfoClass=Class'RMod.R_PlayerReplicationInfo'
    UtilitiesClass=Class'RMod.R_AUtilities'
    ActorSubstitutionClass=Class'RMod.R_AActorSubstitution'
    ColorsClass=Class'RMod.R_AColors'
    GameOptionsClass=Class'RMod.R_GameOptions'
    LoadoutOptionReplicationInfoClass=Class'RMod.R_LoadoutOptionReplicationInfo'
    bMarkSpawnedActorsAsNativeToLevel=True
    ScoreBoardType=Class'RMod.R_Scoreboard'
    HUDType=Class'RMod.R_RunePlayerHUD'
    HUDTypeSpectator=Class'RMod.R_RunePlayerHUDSpectator'
    GameReplicationInfoClass=Class'RMod.R_GameReplicationInfo'
    TempBanManagerClass=Class'RMod.R_TempBanManager'
    PersistentScoreManagerClass=Class'RMod.R_PersistentScoreManager'
    bEnablePersistentScoreTracking=true
    bAllowSpectatorBroadcastMessage=false
    AutoAim=0.0
    DefaultPlayerHealth=100
    DefaultPlayerMaxHealth=100
    DefaultPlayerRunePower=0
    DefaultPlayerMaxRunePower=100
    bLoadoutsEnabled=False
    bRemoveNativeWeapons=False
    bRemoveNativeShields=False
    bRemoveNativeRunes=False
    bRemoveNativeFoods=False
}
