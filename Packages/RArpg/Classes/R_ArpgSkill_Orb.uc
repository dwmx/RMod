class R_ArpgSkill_Orb extends R_ArpgSkill;

var private Class<Actor> OrbActorClass;

auto state Idle
{
    function ActivateSkill()
    {
        local R_ArpgPawn OwnerPawn;
        local Vector LookDirection;

        OwnerPawn = GetArpgPawnOwner();
        if(OwnerPawn == None)
        {
            return;
        }

        LookDirection = OwnerPawn.GetLookDirection();
        OwnerPawn.Spawn(OrbActorClass, OwnerPawn,, OwnerPawn.Location, Rotator(LookDirection));
        GotoState('Cooldown');
    }
}

defaultproperties
{
    OrbActorClass=Class'Spells.SkullFrost'
    CooldownDurationSeconds=1.0
}