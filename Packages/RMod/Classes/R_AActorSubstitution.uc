//==============================================================================
//  R_AActorSubstitution
//  Abstract class meant to provide static functions for swapping out specified
//  actors with other actors.
//  R_GameInfo uses this in IsRelevant to swap out normal Rune weapon classes
//  with the RMod weapon classes.
//  To implement custom substitutions per game type, extend this class and
//  override GetActorSubstitutionClass, then update
//  R_GameInfo.ActorSubstitutionClass.
//==============================================================================
class R_AActorSubstitution extends Object abstract;

var Class<R_AUtilities> UtilitiesClass;

/**
*   GetActorSubstitutionClass
*   Maps input classes to the class they should be substituted with.
*/
static function Class<Actor> GetActorSubstitutionClass(Class<Actor> InClass)
{
    switch(InClass)
    {
        // Swords
        case Class'RuneI.VikingShortSword':     return Class'RMod.R_Weapon_VikingShortSword';
        case Class'RuneI.RomanSword':           return Class'RMod.R_Weapon_RomanSword';
        case Class'RuneI.VikingBroadSword':     return Class'RMod.R_Weapon_VikingBroadSword';
        case Class'RuneI.DwarfWorkSword':       return Class'RMod.R_Weapon_DwarfWorkSword';
        case Class'RuneI.DwarfBattleSword':     return Class'RMod.R_Weapon_DwarfBattleSword';

        // Axes
        case Class'RuneI.HandAxe':              return Class'RMod.R_Weapon_HandAxe';
        case Class'RuneI.GoblinAxe':            return Class'RMod.R_Weapon_GoblinAxe';
        case Class'RuneI.VikingAxe':            return Class'RMod.R_Weapon_VikingAxe';
        case Class'RuneI.SigurdAxe':            return Class'RMod.R_Weapon_SigurdAxe';
        case Class'RuneI.DwarfBattleAxe':       return Class'RMod.R_Weapon_DwarfBattleAxe';

        // Hammers
        case Class'RuneI.RustyMace':            return Class'RMod.R_Weapon_RustyMace';
        case Class'RuneI.BoneClub':             return Class'RMod.R_Weapon_BoneClub';
        case Class'RuneI.TrialPitMace':         return Class'RMod.R_Weapon_TrialPitMace';
        case Class'RuneI.DwarfWorkHammer':      return Class'RMod.R_Weapon_DwarfWorkHammer';
        case Class'RuneI.DwarfBattleHammer':    return Class'RMod.R_Weapon_DwarfBattleHammer';

        // Shields
        case Class'RuneI.GoblinShield':         return Class'RMod.R_Shield_GoblinShield';
        case Class'RuneI.VikingShield':         return Class'RMod.R_Shield_VikingShield';
        case Class'RuneI.VikingShield2':        return Class'RMod.R_Shield_VikingShield';
        case Class'RuneI.VikingShieldCross':    return Class'RMod.R_Shield_VikingShield';
        case Class'RuneI.DarkShield':           return Class'RMod.R_Shield_DarkShield';
        case Class'RuneI.DwarfWoodShield':      return Class'RMod.R_Shield_DwarfWoodShield';
        case Class'RuneI.DwarfBattleShield':    return Class'RMod.R_Shield_DwarfBattleShield';
        
        // Ropes
        case Class'RuneI.ClimbableChain':       return Class'RMod.R_ClimbableChain';
        case Class'RuneI.ClimbableVine':        return Class'RMod.R_ClimbableVine';
        case Class'RuneI.Rope':                 return Class'RMod.R_ClimbableChain';

        // Tarp
        case Class'RuneI.Tarp':                 return Class'RMod.R_Tarp';
    }

    return InClass;
}

/**
*   PerformActorSubstitution
*   Called by R_GameInfo.IsRelevant in order to substitute actors at spawn time.
*/
static function Actor PerformActorSubstitution(Actor WorldContextActor, Actor InActor)
{
    local String LogMessage;
    local Class<Actor> SubstitutionClass;
    local Actor TempActor;

    if(WorldContextActor == None || InActor == None)
    {
        return InActor;
    }

    // If no substitution, return input
    SubstitutionClass = GetActorSubstitutionClass(InActor.Class);
    if(SubstitutionClass == InActor.Class)
    {
        return InActor;
    }

    // Log
    LogMessage = "Substituting" @ SubstitutionClass @ "in place of" @ InActor.Class;
    if(Default.UtilitiesClass != None)
    {
        Default.UtilitiesClass.Static.RModLog(LogMessage);
    }
    else
    {
        Log(LogMessage);
    }

    // Replace
    TempActor = WorldContextActor.Spawn(SubstitutionClass,,,InActor.Location, InActor.Rotation);
    if(TempActor == None)
    {
        LogMessage = "Substitution failed for" @ SubstitutionClass;
        if(Default.UtilitiesClass != None)
        {
            Default.UtilitiesClass.Static.RModLog(LogMessage);
        }
        else
        {
            Log(LogMessage);
        }
        return InActor;
    }

    // Notify the new actor of the substitution so that it can replace important properties
    if(R_AWeapon(TempActor) != None)
    {
        R_AWeapon(TempActor).NotifySubstitutedForInstance(InActor);
    }
    else if(R_AShield(TempActor) != None)
    {
        R_AShield(TempActor).NotifySubstitutedForInstance(InActor);
    }
    else if(R_Tarp(TempActor) != None)
    {
        R_Tarp(TempActor).NotifySubstitutedForInstance(InActor);
    }

    InActor.Destroy();
    InActor = TempActor;
    return InActor;
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
}