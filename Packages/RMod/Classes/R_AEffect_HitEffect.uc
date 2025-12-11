//==============================================================================
//  R_AEffect_HitEffect
//  Base class for hit effects
//==============================================================================
class R_AEffect_HitEffect extends R_AEffect abstract;

var Class<Actor> HitEffectClass;
var Class<Actor> BloodLustDebrisClass;
var int BloodlustDebrisSpawnCount;

/**
*   PostNetBeginPlay (override)
*   This event is fired after initial actor replication has been completed
*/
simulated event PostNetBeginPlay()
{
    if(Role == ROLE_Authority && Level.NetMode == NM_DedicatedServer)
    {
        // Dedicated servers don't play any effects
        return;
    }
    
    SpawnHitEffect();
    
    // R_AWeapon sets itself as the owner of this effect when spawned
    // R_RunePlayer has bloodlust state replicated via bBloodlustReplicated
    // Use the two of these to play special client-side bloodlust effects
    if(Owner != None && R_RunePlayer(Owner.Owner) != None)
    {
        if(R_RunePlayer(Owner.Owner).bAuthoritativeBloodlust)
        {
            SpawnBloodlustHitEffect();
        }
    }
    
    Destroy();
}

/**
*   SpawnHitEffect
*   Spawns the normal hit effect
*/
simulated function SpawnHitEffect()
{
    local Actor SpawnedHitEffect;
    local int i;
    
    if(HitEffectClass != None)
    {
        SpawnedHitEffect = Spawn(HitEffectClass,,, Self.Location, Self.Rotation);
        if(SpawnedHitEffect != None)
        {
            // Disable replication if spawned on listen server
            SpawnedHitEffect.RemoteRole = ROLE_None;
        }
    }
    
}

/**
*   SpawnBloodlustHitEffect
*   Additional effects to spawn if the owner has bloodlust
*/
simulated function SpawnBloodlustHitEffect()
{
    local Actor SpawnedDebris;
    local int i;
    
    if(BloodLustDebrisClass != None)
    {
        for(i = 0; i < BloodlustDebrisSpawnCount; ++i)
        {
            SpawnedDebris = Spawn(BloodLustDebrisClass);
            if(SpawnedDebris != None)
            {
                SpawnedDebris.RemoteRole = ROLE_None;
            }
        }
    }
}

defaultproperties
{
    HitEffectClass=None
    BloodLustDebrisClass=None
    BloodlustDebrisSpawnCount=24
}