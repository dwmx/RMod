class R_WeaponSwipe extends Actor;

const STATE_IDLE        = 0;
const STATE_SWINGING    = 1;
const STATE_THROW       = 2;
var private int WeaponSwipeState;
var private Actor WeaponSwipeAffector;   // The weapon holder or thrower

replication
{
    reliable if(Role == ROLE_Authority)
        WeaponSwipeState;
}

/////////////////////////////////////////////////////////////////////////////////
//  SafeGetOwnerAsWeapon
//  Return the owner of this effect as a Weapon. Destroy this effect if the
//  Owner is invalid.
simulated function Weapon SafeGetOwnerAsWeapon()
{
    if(Weapon(Self.Owner) == None)
        Self.Destroy();
    return Weapon(Self.Owner);
}

/////////////////////////////////////////////////////////////////////////////////
//  ClientUpdateState
//  Called when Client has received a state update from server and needs to
//  follow.
simulated function ClientUpdateState()
{
    switch(Self.WeaponSwipeState)
    {
    case STATE_IDLE:
        Self.GotoState('Idle');
        break;
    case STATE_SWINGING:
        Self.GotoState('Swinging');
        break;
    case STATE_THROW:
        Self.GotoState('Throw');
        break;
    }
}

/////////////////////////////////////////////////////////////////////////////////
//  ClientSwipeEffects
simulated function ClientEnableSwipeEffect()
{
    local class<WeaponSwipe> SwipeClass;
    local Weapon W;
    W = Self.SafeGetOwnerAsWeapon();
    if(W == None)
        return;

    if(R_RunePlayer(Self.WeaponSwipeAffector) != None)
        SwipeClass = class'RuneI.WeaponSwipeBlue';
    else
        SwipeClass = W.SwipeClass;

    if(SwipeClass == None)
        return;
    if(W.Swipe != None)
        Self.ClientDisableSwipeEffect();

    W.Swipe = Self.Spawn(SwipeClass, W,, W.Location);
    if(W.Swipe == None)
        return;

    if(R_RunePlayer(Self.WeaponSwipeAffector) != None)
    {
        W.Swipe.ParticleTexture[0] =
            R_RunePlayer(Self.WeaponSwipeAffector).GetWeaponSwipeTexture();
        W.Swipe.SwipeSpeed =
            R_RunePlayer(Self.WeaponSwipeAffector).GetWeaponSwipeSpeed();
    }
    W.Swipe.BaseJointIndex = W.SweepJoint1;
    W.Swipe.OffsetJointIndex = W.SweepJoint2;
    W.Swipe.SystemLifeSpan = -1.0;
    W.Swipe.SetBase(W);
    W.AttachActorToJoint(W.Swipe, 0);
}

simulated function ClientDisableSwipeEffect()
{
    local Weapon W;
    W = Self.SafeGetOwnerAsWeapon();
    if(W == None)
        return;
    if(W.Swipe == None)
        return;

    W.Swipe.SystemLifeSpan = 3.0;
    W.Swipe.SetBase(None);
    W.Swipe = None;
    W.DetachActorFromJoint(0);
}

/////////////////////////////////////////////////////////////////////////////////
auto state Idle
{
    simulated event BeginState()
    {
        Self.WeaponSwipeState = STATE_IDLE;
    }

    simulated event Tick(float DeltaTime)
    {
        local Weapon W;

        // Server Tick
        if(Self.Role == ROLE_Authority)
        {
            W = Self.SafeGetOwnerAsWeapon();
            if(W == None)
                return;
            if(W.GetStateName() == 'Swinging')
            {
                Self.GotoState('Swinging');
                return;
            }
            else if(W.GetStateName() == 'Throw')
            {
                Self.GotoState('Throw');
                return;
            }
        }
        // Client Tick
        else
        {
            if(Self.WeaponSwipeState != STATE_IDLE)
                Self.ClientUpdateState();
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////
state Swinging
{
    simulated event BeginState()
    {
        local Weapon W;

        Self.WeaponSwipeState = STATE_SWINGING;

        // Client BeginState
        if(Self.Role < ROLE_Authority)
        {
            W = Self.SafeGetOwnerAsWeapon();
            if(W == None)
                return;
            Self.WeaponSwipeAffector = W.Owner;
            Self.ClientEnableSwipeEffect();
        }
    }

    simulated event EndState()
    {
        local Weapon W;

        // Client EndState
        if(Self.Role < ROLE_Authority)
        {
            W = Self.SafeGetOwnerAsWeapon();
            if(W == None)
                return;
            Self.WeaponSwipeAffector = None;
            Self.ClientDisableSwipeEffect();
        }
    }

    simulated event Tick(float DeltaTime)
    {
        local Weapon W;
        W = Self.SafeGetOwnerAsWeapon();
        if(W == None)
            return;

        // Server tick
        if(Self.Role == ROLE_Authority)
        {
            if(W.GetStateName() != 'Swinging')
            {
                GotoState('Idle');
                return;
            }
        }
        // Client tick
        else
        {
            if(Self.WeaponSwipeState != STATE_SWINGING)
                Self.ClientUpdateState();
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////
state Throw
{
    simulated event BeginState()
    {
        local Weapon W;

        Self.WeaponSwipeState = STATE_SWINGING;

        // Client BeginState
        if(Self.Role < ROLE_Authority)
        {
            W = Self.SafeGetOwnerAsWeapon();
            if(W == None)
                return;
            Self.WeaponSwipeAffector = W.Instigator;
            Self.ClientEnableSwipeEffect();
        }
    }

    simulated event EndState()
    {
        local Weapon W;

        // Client EndState
        if(Self.Role < ROLE_Authority)
        {
            W = Self.SafeGetOwnerAsWeapon();
            if(W == None)
                return;
            Self.WeaponSwipeAffector = None;
            Self.ClientDisableSwipeEffect();
        }
    }

    simulated event Tick(float DeltaTime)
    {
        local Weapon W;
        W = Self.SafeGetOwnerAsWeapon();
        if(W == None)
            return;

        // Server tick
        if(Self.Role == ROLE_Authority)
        {
            if(W.GetStateName() != 'Throw')
            {
                GotoState('Idle');
                return;
            }
        }
        // Client tick
        else
        {
            if(Self.WeaponSwipeState != STATE_SWINGING)
                Self.ClientUpdateState();
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////

defaultproperties
{
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
	 DrawType=DT_None
}