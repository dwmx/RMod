class RKSHUD extends HUD;

struct FRKSHUDLocalizedMessage
{
    var class<LocalMessage> MessageClass;
    var int Switch;
    var PlayerReplicationInfo PRI1;
    var PlayerReplicationInfo PRI2;
    var Object OptionalObject;
    var float EndOfLife;
    var float LifeTime;
    var String StringMessage;
    var Color DrawColor1;
    var Color DrawColor2;
    var Sound MessageSound;
};

var FRKSHUDLocalizedMessage HUDLocalizedMessage;

simulated function PopulateHUDLocalizedMessage(
    out FRKSHUDLocalizedMessage OutHUDLocalizedMessage,
    class<LocalMessage> MessageClass,
    optional int Switch,
    optional PlayerReplicationInfo PRI1,
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject,
    optional string CriticalString)
{
    local class<RKSMessage> RKSMessageClass;

    OutHUDLocalizedMessage.MessageClass = MessageClass;
    OutHUDLocalizedMessage.Switch = Switch;
    OutHUDLocalizedMessage.PRI1 = PRI1;
    OutHUDLocalizedMessage.PRI2 = PRI2;
    OutHUDLocalizedMessage.OptionalObject = OptionalObject;
    OutHUDLocalizedMessage.StringMessage = CriticalString;
    OutHUDLocalizedMessage.LifeTime = MessageClass.Static.GetLifeTime(CriticalString);
    OutHUDLocalizedMessage.EndOfLife = OutHUDLocalizedMessage.LifeTime + Level.TimeSeconds;

    RKSMessageClass = class<RKSMessage>(MessageClass);
    if(RKSMessageClass != None)
    {
        OutHUDLocalizedMessage.DrawColor1 = RKSMessageClass.Static.GetDrawColor1(Switch, PRI1, PRI2, OptionalObject);
        OutHUDLocalizedMessage.DrawColor2 = RKSMessageClass.Static.GetDrawColor2(Switch, PRI1, PRI2, OptionalObject);
        OutHUDLocalizedMessage.MessageSound = RKSMessageClass.Static.GetMessageSound(Switch, PRI1, PRI2, OptionalObject);
    }
    else
    {
        OutHUDLocalizedMessage.DrawColor1 = MessageClass.Static.GetColor(Switch, PRI1, PRI2);
    }

    // TODO: Move this to some kind of queue.pop mechanism, for now just play it right when message is received
    if(OutHUDLocalizedMessage.MessageSound != None)
    {
        PlayMessageSound(OutHUDLocalizedMessage.MessageSound);
    }
}

simulated function LocalizedMessage(
    class<LocalMessage> MessageClass,
    optional int Switch,
    optional PlayerReplicationInfo PRI1,
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject,
    optional string CriticalString)
{
    if(CriticalString == "")
    {
        CriticalString = MessageClass.Static.GetString(Switch, PRI1, PRI2, OptionalObject);
    }

    PopulateHUDLocalizedMessage(HUDLocalizedMessage, MessageClass, Switch, PRI1, PRI2, OptionalObject, CriticalString);
}

simulated function PlayMessageSound(Sound MessageSound)
{
    local PlayerPawn PP;

    Log("My owner is" @ Owner);
    PP = PlayerPawn(Owner);
    if(PP != None)
    {
        Log("Playing sound" @ MessageSound);
        PP.PlaySound(MessageSound, SLOT_Interface, 1.4);
    }
}

simulated event DrawMessages(Canvas C)
{
    C.SetPos(C.ClipX * 0.5, C.ClipY * 0.5);
    C.DrawColor = HUDLocalizedMessage.DrawColor1;
    C.Font = C.BigFont;
    C.DrawText(HUDLocalizedMessage.StringMessage);
}

simulated event PostRender(Canvas C)
{
    DrawMessages(C);
}

defaultproperties
{}