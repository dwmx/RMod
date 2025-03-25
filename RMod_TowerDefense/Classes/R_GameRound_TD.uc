//==============================================================================
// R_GameRound_TD
// Represents all state of a round instance in the owning game info
// Spawned and managed by R_GameInfo_TD
//==============================================================================
class R_GameRound_TD extends Object;

var R_GameInfo_TD GameInfoOwner;

var float MobTimerSeconds;
var int NumMobsToSpawn;

function InitializeGameRound(R_GameInfo_TD NewGameInfoOwner)
{
    GameInfoOwner = NewGameInfoOwner;
    NumMobsToSpawn = 10;
}

function TickGameRound(float DeltaSeconds)
{
    local float MobSpawnTime;
    
    if(NumMobsToSpawn > 0)
    {
        MobSpawnTime = 1.0; // Every 1 seconds
    
        MobTimerSeconds += DeltaSeconds;
        
        // Spawn a mob every 5 seconds
        if(MobTimerSeconds > MobSpawnTime)
        {
            SpawnMob();
            MobTimerSeconds = MobTimerSeconds % MobSpawnTime;
        }
    }
}

function SpawnMob()
{
    local R_MobPathNode InitialMobPathNode;
    local R_Mob SpawnedMob;
    
    if(GameInfoOwner != None)
    {
        InitialMobPathNode = GameInfoOwner.InitialMobPathNode;
        if(InitialMobPathNode != None)
        {
            SpawnedMob = GameInfoOwner.Spawn(Class'R_Mob', /*Owner*/, /*Tag*/, InitialMobPathNode.Location, /*Rotation*/);
            if(SpawnedMob != None)
            {
                SpawnedMob.ApplyMobAppearance(Class'R_AMobAppearance_Dwarf_Black');
                SpawnedMob.TargetActor = InitialMobPathNode;
                
                NumMobsToSpawn--;
                return;
            }
        }
    }
    
    Log("SpawnMob Failed");
}

//Spawn(BuildableClass, RunePlayerTD, /*SpawnTag*/, BuildLocation, SpawnRotation);