class RKSMutator extends Mutator;

var RKSList ListRoot;

var config int KillStreakCountKillingSpree;
var config int KillStreakCountRampage;
var config int KillStreakCountDominating;
var config int KillStreakCountUnstoppable;
var config int KillStreakCountGodlike;

event BeginPlay()
{
    Super.BeginPlay();

    Class'RKSStatics'.Static.RKSLog("RuneKillStreaks mutator spawned");

    ListRoot = new(None) Class'RKSList';
    ListRoot.AssociatedPawn = None;
    ListRoot.AssociatedPlayerState = None;
}

function RKSList FindOrAppendPawn(Pawn P)
{
    local RKSList ListNode;

    ListNode = ListRoot.Find(P);
    if(ListNode == None)
    {
        ListRoot.Append(P);
    }

    ListNode = ListRoot.Find(P);
    if(ListNode != None)
    {
        if(ListNode.AssociatedPlayerState != None)
        {
            ListNode.AssociatedPlayerState.MutatorOwner = Self;
        }
        return ListNode;
    }

    Class'RKSStatics'.Static.Warn("FindOrAppendPawn failed");
    return None;
}

function ModifyPlayer(Pawn Other)
{
    FindOrAppendPawn(Other);
}

function ScoreKill(Pawn Killer, Pawn Other)
{
    local RKSList ListNode;

    Super.ScoreKill(Killer, Other);

    // Score kill
    ListNode = FindOrAppendPawn(Killer);
    if(ListNode != None && ListNode.AssociatedPlayerState != None)
    {
        ListNode.AssociatedPlayerState.NotifyScoredKill(Killer, Other);
    }

    // Score death
    ListNode = FindOrAppendPawn(Other);
    if(ListNode != None && ListNode.AssociatedPlayerState != None)
    {
        ListNode.AssociatedPlayerState.NotifyScoredDeath(Killer, Other);
    }
}

//  BroadcastLocalizedRKSMessage
//  Send an RKSMessage to all clients
//  (play this sound on all clients)
function BroadcastLocalizedRKSMessage(
    class<RKSMessage> MessageClass,
    int Switch,
    optional PlayerReplicationInfo PRI1,
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject)
{
    local RKSList ListNode;
    local RKSClientChannel ClientChannel;

    for(ListNode = ListRoot; ListNode != None; ListNode = ListNode.Next)
    {
        ClientChannel = ListNode.AssociatedClientChannel;
        if(ClientChannel != None)
        {
            ClientChannel.ClientReceiveLocalizedMessage(MessageClass, Switch, PRI1, PRI2, OptionalObject);
        }
    }
}

//  SendClientLocalizedRKSMessage
//  Send an RKSMessage to only the client associated with the player state
//  (play this sound on only the owner client)
function SendClientLocalizedRKSMessage(
    RKSPlayerState CallingPlayerState,
    class<RKSMessage> MessageClass,
    int Switch,
    optional PlayerReplicationInfo PRI1,
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject)
{
    local RKSList ListNode;
    local RKSClientChannel ClientChannel;

    ListNode = ListRoot;
    while(ListNode != None && ListNode.AssociatedPlayerState != CallingPlayerState)
    {
        ListNode = ListNode.Next;
    }

    if(ListNode.AssociatedPlayerState != CallingPlayerState)
    {
        return;
    }

    ClientChannel = ListNode.AssociatedClientChannel;
    if(ClientChannel != None)
    {
        ClientChannel.ClientReceiveLocalizedMessage(MessageClass, Switch, PRI1, PRI2, OptionalObject);
    }
}

defaultproperties
{
    KillStreakCountKillingSpree=5
    KillStreakCountRampage=10
    KillStreakCountDominating=15
    KillStreakCountUnstoppable=20
    KillStreakCountGodlike=25
}