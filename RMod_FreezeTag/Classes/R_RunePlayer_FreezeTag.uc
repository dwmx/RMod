class R_RunePlayer_FreezeTag extends R_RunePlayer;

var Class<R_AFreezeTagStatics> FreezeTagStaticsClass;

var R_IceStatueProxy IceStatueProxy;
var bool bInFrozenState;

var float FrozenMaxHealth;
var float FrozenHealth;
var float FrozenSavedAnimRate;
var float FrozenSavedAnimProxyAnimRate;

// See the note above DamageBodyPart
var R_RunePlayer FrozenInstigator;

replication
{
    reliable if(Role == ROLE_Authority)
        bInFrozenState;

    reliable if(Role == ROLE_Authority)
        ClientThaw;
}

// Note:
// For whatever, totally bizarre reason, it appears that when an instigator is set in calls to Died(), or if Instigator is set
// right before a call to Died, then this player will become desynced on SOME of the clients, SOMETIMES.
// For this reason, we bypass the usage of Instigator and use the FrozenInstigator for Freezing / Thawing players, which gets sent
// to the appropriate functions in game info.
function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
{
    local int PassThrough;
    local int SeverDamage;
    local int BluntDamage;
    local bool bAlreadyDead;
    local int AppliedDamage;
    local Debris Gib;
    local float scale;
    local int i, NumChunks;
    local vector AdjMomentum;

    //---------------------------------------------------
    // RunePlayer.DamageBodyPart
    if(bBloodLust)
    {
        Damage /= 2;
        Strength -= Damage;
        if(Strength > 0)
            return(true);  // Damage to Ragnar takes away his bloodlust (but doesn't damage him)
        else
            Damage = -Strength * 2;
        
        // Force the strength to atrophy by removing the last strength point
        Strength = 1;
        StrengthDecay(999.0); // force the strength to atrophy

        // Then, this passes through and the remainder damage is applied to Ragnar
    }

    //---------------------------------------------------
    // Pawn.DamageBodyPart
    if(!class'GameInfo'.Default.bVeryLowGore)
    {
        if (CurrentSkin != 0)
            SpecialPainSkin(BodyPart);
        else
            PainSkin(BodyPart);
    }

    GetDamageValues(Damage, DamageType, BluntDamage, SeverDamage);
    Level.Game.ReduceDamage(BluntDamage, SeverDamage, DamageType, self, EventInstigator);
    PassThrough = LimbPassThrough(BodyPart, BluntDamage, SeverDamage);

    // Give instigator strength boost if deserving
    if(EventInstigator!=None && EventInstigator.IsA('PlayerPawn') && Health>0 &&
        (DamageType=='blunt' || DamageType=='sever' || DamageType=='bluntsever') &&
        EventInstigator.Weapon!=None && !EventInstigator.Weapon.bPoweredUp &&
        (PassThrough>0) )
    { // Boost the player's strength/bloodlust for successful conventional attacks
        EventInstigator.BoostStrength(0.2 * Damage);
    }

    if (BodyPart != BODYPART_BODY)
    {
        if (BodyPartSeverable(BodyPart) && (BodyPartHealth[BodyPart] > 0))
        {
            BodyPartHealth[BodyPart] -= SeverDamage;
    
            if(BodyPartHealth[BodyPart] <= 0)
            {   // Body Part was killed
                if (BodyPartCritical(BodyPart))
                {
                    PassThrough = Max(Health, Damage);
                    DamageType = 'decapitated';
                }

                // Sever the limb
                if(!class'GameInfo'.Default.bLowGore)
                {
                    BodyPartVisibility(BodyPart, false);
                    BodyPartCollision(BodyPart, false);
                    LimbSevered(BodyPart, Momentum);
                }
            }
        }
    }

    if (DamageType=='sever' || DamageType=='bluntsever')
    {   // spawn chunks
        NumChunks = (Damage / 15) + 1;
        NumChunks = NumChunks * Level.Game.DebrisPercentage;
        for(i = 0; i < NumChunks; i++)
        {
            Gib = spawn(GibClass,,, HitLocation + VRand() * 2,);
            if (Gib != None)
            {
                Gib.SetSize(RandRange(0.1, 0.4));
                Gib.SetMomentum((-0.08 * Momentum));
            }
        }
    }
    else if (DamageType == 'crushed')
    {   // Force the gib when crushed
        PassThrough = Default.Health*3;
        bGibbable = true;
    }

    // Apply damage to body
    if (PassThrough != 0)
    {
        bAlreadyDead = (Health <= 0);

//		AppliedDamage = Level.Game.ReduceDamage(PassThrough, DamageType, self, EventInstigator);
        AppliedDamage = PassThrough;

        Health -= AppliedDamage;

        // [RMod]
        if(Health < 1)
        {
            Health = 1;
            FrozenInstigator = R_RunePlayer(EventInstigator);
            Suicide();
        }
        // Regular Rune
        else if (Health > 0)
        {
            // Apply momentum
            // NOTE:  This code is duplicated in Shield.Active and Shield.Idle states
            AdjMomentum = momentum / Mass;
            if(Mass < VSize(AdjMomentum) && Velocity.Z <= 0)
            {           
                AdjMomentum.Z += (VSize(AdjMomentum) - Mass) * 0.5;
            }
            AddVelocity(AdjMomentum);
//			if (Velocity.Z == 0)
//				AddVelocity(momentum / Mass);

            if(CanGotoPainState())
            { // Only goto the painstate if the pawn allows it 
                PlayTakeHitSound(AppliedDamage, DamageType, 1);

                if(PassThrough > 5) // DAMAGE_EPSILON = 5
                { // Only go to the painstate if the damage is over a given level
                    if (GetStateName() != 'Pain' && GetStateName() != 'pain')
                    {
                        NextStateAfterPain = GetStateName();

                        // Play pain anim
                        PlayTakeHit(0.1, AppliedDamage, HitLocation, DamageType, Momentum, BodyPart);
                        GotoState('Pain');
                    }
                    return(false);
                }
            }
        }
        else if (bAlreadyDead)
        {   // Twitch corpse or Gib
            if(Health < -Default.Health && bGibbable && !bHidden)
            { // Gib if beaten down far enough
                SpawnBodyGibs(Momentum);
                PlayDyingSound('gibbed');
                if (bIsPlayer)
                    bHidden=true;
                else
                    Destroy();
            }
        }
        else
        { // Kill the creature
            AddVelocity(momentum * 2 / Mass);
            if(Health < -Default.Health && bGibbable)
            { // Gib if beaten down far enough
                Died(EventInstigator, 'gibbed', HitLocation);
//				if (bIsPlayer)	// moved to died
//					bHidden=true;
//				else
//					Destroy();
            }
            else
            {
                // Apply momentum
                Died(EventInstigator, DamageType, HitLocation);
            }
        }
        MakeNoise(1.0);
    }

    return(false);
}

// Tick is simulated here so that all clients can simulate the speed up and slow down of animation rate when frozen
simulated event Tick(float DeltaSeconds)
{
    if(Role >= ROLE_AutonomousProxy)
    {
        Super.Tick(DeltaSeconds);
    }

    TickFrozenState(DeltaSeconds);
}

simulated function TickFrozenState(float DeltaSeconds)
{
    local float NewAnimRate;
    local float NewAnimProxyAnimRate;

    if(bInFrozenState)
    {
        NewAnimRate = 0.0;
        if(AnimProxy != None)
        {
            NewAnimProxyAnimRate = 0.0;
        }
    }
    else
    {
        NewAnimRate = AnimRate;
        if(AnimProxy != None)
        {
            NewAnimProxyAnimRate = AnimProxy.AnimRate;
        }
    }

    if(AnimRate != NewAnimRate)
    {
        AnimRate = NewAnimRate;
    }

    if(AnimProxy != None && AnimProxy.AnimRate != NewAnimProxyAnimRate)
    {
        AnimProxy.AnimRate = NewAnimProxyAnimRate;
    }
}

function Thaw()
{
    if(GetStateName() == 'Frozen')
    {
        if(Role == ROLE_Authority)
        {
            ClientThaw();
            PerformThaw();
            Health = Maxhealth;
        }
        else if(Role == ROLE_AutonomousProxy)
        {
            PerformThaw();
        }
    }
}

function ClientThaw()
{
    PerformThaw();
}

function PerformThaw()
{
    GotoState('PlayerWalking');
}

function KilledBy(Pawn EventInstigator)
{
    Died(EventInstigator, 'suicided', Location );
}

/**
*   GetCurrentDiedBehaviorAsByte
*   Get the death behavior value from the current freeze tag game info.
*   This allows the game to change when players should become frozen or when
*   they should just die.
*/
function byte GetCurrentDiedBehaviorAsByte()
{
    local byte DiedBehaviorByte;
    local R_GameInfo_ArenaFreezeTag RGIArena;
    local R_GameInfo_TDMFreezeTag RGITDM;

    DiedBehaviorByte = FreezeTagStaticsClass.Static.GetDeathBehaviorAsByte_DieOnDeath();

    RGIArena = R_GameInfo_ArenaFreezeTag(Level.Game);
    RGITDM = R_GameInfo_TDMFreezeTag(Level.Game);

    if(RGIArena != None)
    {
        DiedBehaviorByte = RGIArena.GetCurrentDiedBehaviorAsByte(Self);
    }
    else if(RGITDM != None)
    {
        DiedBehaviorByte = RGITDM.GetCurrentDiedBehaviorAsByte(Self);
    }

    return DiedBehaviorByte;
}

/**
*   Died (override)
*   Overridden to allow the current game mode to tell this player to freeze
*   instead of dying.
*/
function Died(Pawn Killer, Name DamageType, Vector HitLocation)
{
    local byte DiedBehaviorByte;
    local R_GameInfo_ArenaFreezeTag GI;

    if(Role == ROLE_Authority)
    {
        DiedBehaviorByte = GetCurrentDiedBehaviorAsByte();

        if(DiedBehaviorByte == FreezeTagStaticsClass.Static.GetDeathBehaviorAsByte_DieOnDeath())
        {
            Super.Died(Killer, DamageType, HitLocation);
        }
        else if(DiedBehaviorByte == FreezeTagStaticsClass.Static.GetDeathBehaviorAsByte_FreezeOnDeath())
        {
            Health = 1;
            Instigator = Killer;
            GotoState('Frozen');
        }
    }
}

function bool ReceiveIceStatueProxyJointDamaged(int Damage, Pawn EventInstigator, Vector HitLoc, Vector Momentum, Name DamageType, int Joint)
{
    return true;
}

function NotifyEjectedFromArena()
{
    local Vector HitLocation;

    HitLocation.X = 0.0;
    HitLocation.Y = 0.0;
    HitLocation.Z = 0.0;
    Super.Died(Instigator, 'None', HitLocation);
}

state Frozen extends PlayerWalking
{
    ignores
        PowerupFire,
        PowerupBlaze,
        PowerupStone,
        PowerupIce,
        PowerupFriend,
        SetOnFire,
        WeaponActivate,
        SwipeEffectStart,
        Fire,
        AltFire,
        Use,
        Throw,
        Powerup,
        Taunt,
        Jump,
        SwitchWeapon,
        PlayWaiting,
        PlayMoving;

    event BeginState()
    {
        local R_PlayerReplicationInfo_FreezeTag RPRIFT;

        Super.BeginState();

        FrozenHealth = FrozenMaxHealth;
        FrozenSavedAnimRate = AnimRate;
        if(AnimProxy != None)
        {
            FrozenSavedAnimProxyAnimRate = AnimProxy.AnimRate;
        }
        bInFrozenState = true;

        if(Weapon != None)
        {
            if(Weapon.bPoweredUp)
            {
                Weapon.PowerupEnd();
            }
            Weapon.FinishAttack();
        }

        //ApplyStatueFeatures();
        bSweepable = false;

        PlaySound(Sound'WeaponsSnd.Powerups.atfreezeice01', SLOT_Interface, 0.75);

        if(Role == ROLE_Authority)
        {
            SpawnIceStatueProxy();
            if(R_GameInfo_ArenaFreezeTag(Level.Game) != None)
            {
                NotifyGameInfoOfFrozen();
                FrozenInstigator = None;
            }

            RPRIFT = R_PlayerReplicationInfo_FreezeTag(PlayerReplicationInfo);
            if(RPRIFT != None)
            {
                RPRIFT.bIsFrozen = true;
            }
        }
    }

    function SpawnIceStatueProxy()
    {
        DestroyIceStatueProxy();
        IceStatueProxy = Spawn(Class'RMod_FreezeTag.R_IceStatueProxy', Self);
    }

    event EndState()
    {
        local R_PlayerReplicationInfo_FreezeTag RPRIFT;

        Super.EndState();

        AnimRate = FrozenSavedAnimRate;
        if(AnimProxy != None)
        {
            AnimProxy.AnimRate = FrozenSavedAnimProxyAnimRate;
        }
        bInFrozenState = false;
        bSweepable = true;
        DestroyIceStatueProxy();
        RemoveStatueFeatures();

        PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain, 0.35);
        SpawnDebris();

        if(Role == ROLE_Authority)
        {
            if(R_GameInfo_ArenaFreezeTag(Level.Game) != None)
            {
                NotifyGameInfoOfThawed();
                FrozenInstigator = None;
            }

            RPRIFT = R_PlayerReplicationInfo_FreezeTag(PlayerReplicationInfo);
            if(RPRIFT != None)
            {
                RPRIFT.bIsFrozen = false;
            }
        }
    }

    /**
    *   NotifyGameInfoOfFrozen
    *   Notify the owning game mode that this player was frozen.
    *   Since there is no base freeze tag game mode, all different freeze tag
    *   modes need their own explicit call.
    */
    function NotifyGameInfoOfFrozen()
    {
        local R_GameInfo_ArenaFreezeTag RGIArena;
        local R_GameInfo_TDMFreezeTag RGITDM;

        RGIArena = R_GameInfo_ArenaFreezeTag(Level.Game);
        if(RGIArena != None)
        {
            RGIArena.NotifyFrozen(Self, FrozenInstigator);
            return;
        }

        RGITDM = R_GameInfo_TDMFreezeTag(Level.Game);
        if(RGITDM != None)
        {
            RGITDM.NotifyFrozen(Self, FrozenInstigator);
            return;
        }
    }

    /**
    *   NotifyGameInfoOfThawed
    *   Notify the owning game mode that this player was thawed.
    *   Since there is no base freeze tag game mode, all different freeze tag
    *   modes need their own explicit call.
    */
    function NotifyGameInfoOfThawed()
    {
        local R_GameInfo_ArenaFreezeTag RGIArena;
        local R_GameInfo_TDMFreezeTag RGITDM;

        RGIArena = R_GameInfo_ArenaFreezeTag(Level.Game);
        if(RGIArena != None)
        {
            RGIArena.NotifyThawed(Self, FrozenInstigator);
            return;
        }

        RGITDM = R_GameInfo_TDMFreezeTag(Level.Game);
        if(RGITDM != None)
        {
            RGITDM.NotifyThawed(Self, FrozenInstigator);
            return;
        }
    }

    function DestroyIceStatueProxy()
    {
        if(IceStatueProxy != None)
        {
            IceStatueProxy.Destroy();
        }
    }

    function ApplyStatueFeatures()
    {
        local Inventory I;
        ApplyStatueFeaturesToActor(Self);
        I = Inventory;
        while(I != None)
        {
            ApplyStatueFeaturesToActor(I);
            I = I.Inventory;
        }
    }

    function ApplyStatueFeaturesToActor(Actor A)
    {
        local int i;
        for(i = 0; i < 16; ++i)
        {
            A.SkelGroupSkins[i] = Texture'statues.ice1';
        }
    }

    function RemoveStatueFeatures()
    {
        local Inventory I;
        RemoveStatueFeaturesFromActor(Self);
        I = Inventory;
        while(I != None)
        {
            RemoveStatueFeaturesFromActor(I);
            I = I.Inventory;
        }
    }

    function RemoveStatueFeaturesFromActor(Actor A)
    {
        local int i;
        for(i = 0; i < 16; ++i)
        {
            A.SkelGroupSkins[i] = A.Default.SkelGroupSkins[i];
        }
        A.SetDefaultPolyGroups();
    }

    function PlayerMove(float DeltaSeconds)
    {
        aForward = 0.0;
        aStrafe = 0.0;
        aUp = 0.0;
        bDuck = 0;
        DodgeDir = DODGE_None;

        Super.PlayerMove(DeltaSeconds);
    }

    function bool ReceiveIceStatueProxyJointDamaged(int Damage, Pawn EventInstigator, Vector HitLoc, Vector Momentum, Name DamageType, int Joint)
    {
        FrozenInstigator = R_RunePlayer(EventInstigator);
        // If struck by a teammate, then thaw
        if(EventInstigator != None && EventInstigator.PlayerReplicationInfo != None && EventInstigator.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
        {
            SpawnDebris(,2);
            //PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain, 0.35);
            FrozenHealth = Clamp(FrozenHealth - Damage, 0.0, FrozenMaxHealth);
            if(FrozenHealth == 0.0)
            {
                Thaw();
            }
        }
    }

    function bool JointDamaged(int Damage, Pawn EventInstigator, Vector HitLoc, Vector Momentum, Name DamageType, int Joint)
    {
        return true;
    }

    function SpawnDebris(optional vector Momentum, optional int NumChunks)
    {
        local debris d;
        local vector loc;
        local float scale;
        local int i;

        // Find appropriate size of chunks
        if(NumChunks == 0)
        {
            NumChunks = Clamp(Mass/10, 2, 15);
        }
        
        scale = (CollisionRadius*CollisionRadius*CollisionHeight) / (NumChunks*500);
        scale = scale ** 0.3333333;

        // Spawn debris
        for (i=0; i<NumChunks; i++)
        {
            loc = Location;
            loc.X += (FRand()*2-1)*CollisionRadius;
            loc.Y += (FRand()*2-1)*CollisionRadius;
            loc.Z += (FRand()*2-1)*CollisionHeight;
            d = Spawn(class'debrisice',,,loc);
            if (d != None)
            {
                d.SetSize(scale);
                d.SetMomentum(Momentum);
            }
        }
    }
}

defaultproperties
{
    FreezeTagStaticsClass=Class'RMod_FreezeTag.R_AFreezeTagStatics'
    MaxHealth=200
    Health=200
    bInFrozenState=false
    FrozenMaxHealth=100
    FrozenHealth=100
    FrozenSavedAnimRate=1.0
    FrozenSavedAnimProxyAnimRate=1.0
}