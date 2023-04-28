class RKSPlayerState extends Actor;

var RKSMutator MutatorOwner;

// Variables for kill streak messages (rampage, godlike, etc)
var int RunningKillStreakCount;

// Variables for consecutive kill messages (double kill, triple kill, etc)
var int ConsecutiveKillStreakCount;
var float MostRecentKillTimeStampSeconds;
var float KillStreakDurationThresholdSeconds;

var bool bPreviousKillBloodLustState;

//  NotifyScoredKill
//  Called when this player state's owning player scored a kill
//  Killer = Owner
function NotifyScoredKill(Pawn Killer, Pawn Other)
{
    local bool bCurrentKillBloodLustState;

    if(PlayerPawn(Killer) != None)
    {
        bCurrentKillBloodLustState = PlayerPawn(Killer).bBloodlust;
    }
    
    // First, check for consecutive kill streak messages (double kill, triple kill, etc)
    if(Level.TimeSeconds - MostRecentKillTimeStampSeconds <= KillStreakDurationThresholdSeconds)
    {
        ++ConsecutiveKillStreakCount;
        MessageForConsecutiveKillStreak(ConsecutiveKillStreakCount, Killer, Other);

        // Broadcast holy shit message if player gets bloodlust and a
        // triple kill or better at the same time
        if(ConsecutiveKillStreakCount >= 3 && bCurrentKillBloodLustState && !bPreviousKillBloodLustState)
        {
            //BroadcastHolyShit(Killer, Other);
        }
    }
    else
    {
        ConsecutiveKillStreakCount = 1;
    }

    MostRecentKillTimeStampSeconds = Level.TimeSeconds;

    if(PlayerPawn(Killer) != None)
    {
        bPreviousKillBloodLustState = bCurrentKillBloodLustState;
    }

    // Second, check for running kill streak messages (rampage, godlike, etc)
    ++RunningKillStreakCount;
    MessageForRunningKillStreak(RunningKillStreakCount, Killer, Other);
    
    // Third, if this was a headshot kill then send a headshot message
    if(PlayerPawn(Other) != None && PlayerPawn(Other).BodyPartHealth[Other.BODYPART_HEAD] <= 0)
    {
        MessageForHeadshot(Killer, Other);
    }
}

function MessageForConsecutiveKillStreak(int KillStreak, Pawn Killer, Pawn Other)
{
    local int MessageSwitch;
    local PlayerReplicationInfo PRI1;
    local PlayerReplicationInfo PRI2;

    MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_None();

    switch(KillStreak)
    {
    case 2: MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_DoubleKill();   break;
    case 3: MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_TripleKill();   break;
    case 4: MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_MultiKill();    break;
    case 5: MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_MegaKill();     break;
    case 6: MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_UltraKill();    break;
    case 7: MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_MonsterKill();  break;
    }

    if(MessageSwitch != class'RKSMessage_Announcement'.Static.GetSwitch_None())
    {
        if(Killer != None)
        {
            PRI1 = Killer.PlayerReplicationInfo;
        }
        if(Other != None)
        {
            PRI2 = Other.PlayerReplicationInfo;
        }

        if(MutatorOwner != None)
        {
            MutatorOwner.SendClientLocalizedRKSMessage(Self, class'RKSMessage_Announcement', MessageSwitch, PRI1, PRI2, Killer);
        }
    }
}

function MessageForRunningKillStreak(int KillStreak, Pawn Killer, Pawn Other)
{
    local int MessageSwitch;
    local PlayerReplicationInfo PRI1;
    local PlayerReplicationInfo PRI2;

    if(MutatorOwner == None)
    {
        return;
    }

    MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_None();

    if(KillStreak == MutatorOwner.KillStreakCountKillingSpree)
    {
        MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_KillingSpree();
    }
    else if(KillStreak == MutatorOwner.KillStreakCountRampage)
    {
        MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_Rampage();
    }
    else if(KillStreak == MutatorOwner.KillStreakCountDominating)
    {
        MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_Dominating();
    }
    else if(KillStreak == MutatorOwner.KillStreakCountUnstoppable)
    {
        MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_Unstoppable();
    }
    else if(KillStreak == MutatorOwner.KillStreakCountGodlike)
    {
        MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_Godlike();
    }

    if(MessageSwitch != class'RKSMessage_Announcement'.Static.GetSwitch_None())
    {
        if(MutatorOwner != None)
        {
            if(Killer != None)  { PRI1 = Killer.PlayerReplicationInfo; }
            if(Other != None)   { PRI2 = Other.PlayerReplicationInfo; }

            MutatorOwner.BroadcastLocalizedRKSMessage(class'RKSMessage_Announcement', MessageSwitch, PRI1, PRI2, Killer);
        }
    }
}

function MessageForHeadshot(Pawn Killer, Pawn Other)
{
    local int MessageSwitch;
    local PlayerReplicationInfo PRI1;
    local PlayerReplicationInfo PRI2;
    
    if(MutatorOwner == None)
    {
        return;
    }
    
    if(Killer != None)  { PRI1 = Killer.PlayerReplicationInfo; }
    if(Other != None)   { PRI2 = Other.PlayerReplicationInfo; }
    MessageSwitch = class'RKSMessage_Announcement'.Static.GetSwitch_Headshot();
    
    MutatorOwner.SendClientLocalizedRKSMessage(Self, class'RKSMessage_Announcement', MessageSwitch, PRI1, PRI2, Killer);
}

//  NotifyScoredDeath
//  Called when this player state's owning player scored a death
//  Other = Owner
function NotifyScoredDeath(Pawn Killer, Pawn Other)
{
    RunningKillStreakCount = 0;
    ConsecutiveKillStreakCount = 0;
}

defaultproperties
{
    RemoteRole=ROLE_None
    RunningKillStreakCount=0
    ConsecutiveKillStreakCount=0
    MostRecentKillTimeStampSeconds=0.0
    KillStreakDurationThresholdSeconds=5.0
    bPreviousKillBloodLustState=False
}