class R_Scoreboard_ArenaFreezeTag extends R_Scoreboard_Arena;

// Using the normal RMod Arena scoreboard, replacing Deaths and Damage Dealt with
// Freezes and Thaws scoring

function int GetValueForDeathsField(PlayerReplicationInfo PRI)
{
    if(R_PlayerReplicationInfo_ArenaFreezeTag(PRI) != None)
    {
        return int(R_PlayerReplicationInfo_ArenaFreezeTag(PRI).PlayerFreezes);
    }
    else
    {
        return Super.GetValueForDeathsField(PRI);
    }
}

function int GetValueForDamageDealtField(PlayerReplicationInfo PRI)
{
	if(R_PlayerReplicationInfo_ArenaFreezeTag(PRI) != None)
    {
        return int(R_PlayerReplicationInfo_ArenaFreezeTag(PRI).PlayerThaws);
    }
    else
    {
        return Super.GetValueForDamageDealtField(PRI);
    }
}

defaultproperties
{
    DeathsText="Freezes"
    DamageDealtText="Thaws"
}