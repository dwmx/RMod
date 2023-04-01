//==============================================================================
//  R_AGameOptionsChecker
//  Provides a simple static interface for actors to check game options
//==============================================================================
class R_AGameOptionsChecker extends Object abstract;

/**
*   GetGameOptionsFromWorldContextObject
*   Get the R_GameOptions instance from the R_GameInfo that the provided Actor
*   is active within
*
*   For internal use
*/
static function R_GameOptions GetGameOptionsFromWorldContextActor(Actor WorldContextActor)
{
    local R_GameInfo RGI;
    local R_GameOptions RGO;
    
    if(WorldContextActor == None || WorldContextActor.Role != ROLE_Authority || WorldContextActor.Level.Game == None)
    {
        return None;
    }
    
    RGI = R_GameInfo(WorldContextActor.Level.Game);
    if(RGI != None)
    {
        RGO = RGI.GameOptions;
        if(RGO != None)
        {
            return RGO;
        }
    }
    
    return None;
}

//==============================================================================
//  Begin Game Options
//==============================================================================
static function bool GetGameOption_ShieldHitStun(Actor WorldContextActor)
{
    local R_GameOptions RGO;
    RGO = GetGameOptionsFromWorldContextActor(WorldContextActor);
    if(RGO != None)
    {
        return RGO.bOptionShieldHitStun;
    }
    return false;
}

static function bool GetGameOption_ShieldDamageBoostsStrength(Actor WorldContextActor)
{
    local R_GameOptions RGO;
    RGO = GetGameOptionsFromWorldContextActor(WorldContextActor);
    if(RGO != None)
    {
        return RGO.bOptionShieldDamageBoostsStrength;
    }
    return false;
}

static function bool GetGameOption_ManualBloodlust(Actor WorldContextActor)
{
    local R_GameOptions RGO;
    RGO = GetGameOptionsFromWorldContextActor(WorldContextActor);
    if(RGO != None)
    {
        return RGO.bOptionManualBloodlust;
    }
    return false;
}

static function bool GetGameOption_WeaponTierBlockable(Actor WorldContextActor, int WeaponTier)
{
    local R_GameOptions RGO;
    
    if(WeaponTier <= 0 || WeaponTier > 5)
    {
        // Invalid weapon tier
        return false;
    }
    
    RGO = GetGameOptionsFromWorldContextActor(WorldContextActor);
    if(RGO != None)
    {
        switch(WeaponTier)
        {
            case 1: return RGO.bOptionWeaponThrowBlockTier1;
            case 2: return RGO.bOptionWeaponThrowBlockTier2;
            case 3: return RGO.bOptionWeaponThrowBlockTier3;
            case 4: return RGO.bOptionWeaponThrowBlockTier4;
            case 5: return RGO.bOptionWeaponThrowBlockTier5;
        }
    }
    return false;
}
//==============================================================================
//  End Game Options
//==============================================================================