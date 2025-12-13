//==============================================================================
//  R_ActorSubstitutionSpawnNotify
//  This is spawned by R_GameInfo and acts as a server-only SpawnNotify
//  Performs all actor substitution after the game has begun play
//  During game initialization, R_GameInfo.IsRelevant does the substitution
//==============================================================================
class R_ActorSubstitutionSpawnNotify extends SpawnNotify;

event Actor SpawnNotification(Actor A)
{
    local Class<R_AActorSubstitution> ActorSubstitutionClass;
    local R_GameInfo GI;

    if(Role == ROLE_Authority && A != None)
    {
        GI = R_GameInfo(Level.Game);
        if(GI != None)
        {
            ActorSubstitutionClass = GI.ActorSubstitutionClass;
            if(ActorSubstitutionClass != None)
            {
                return ActorSubstitutionClass.Static.PerformActorSubstitution(Self, A);
            }
        }
    }

    return A;
}

defaultproperties
{
    RemoteRole=ROLE_None
}