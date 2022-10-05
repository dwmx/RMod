class RKSHUD extends HUD;

var bool bLogDebugMessages;

struct FSavedCanvasState
{
    var byte Style;
    var float AlphaScale;
    var Color DrawColor;
    var Font Font;
    var float PosX, PosY;
};

struct FRKSHUDLocalizedMessage
{
    var class<LocalMessage> MessageClass;
    var int Switch;
    var PlayerReplicationInfo PRI1;
    var PlayerReplicationInfo PRI2;
    var Object OptionalObject;
    var float LifeTimeSeconds;
    var float LifeTimeSecondsMinimum;
    var float TimeStampSeconds;
    var String StringMessage;
    var Color DrawColor1;
    var Color DrawColor2;
    var Sound MessageSound;
    var bool bMessageIsLive;
};

const MAX_QUEUED_MESSAGES = 16;
struct FRKSHUDLocalizedMessageQueue
{
    var FRKSHUDLocalizedMessage QueuedMessages[16];
    var int QueueIndexFront;
    var int QueueIndexBack;
};
var FRKSHUDLocalizedMessageQueue MessageQueue;

simulated function DebugLog(string S)
{
    if(!bLogDebugMessages)
    {
        return;
    }

    class'RKSStatics'.Static.RKSLog("[RKSHUD Debug]:" @ S);
}

simulated function DebugWarn(string S)
{
    if(!bLogDebugMessages)
    {
        return;
    }

    class'RKSStatics'.Static.RKSWarn("[RKSHUD Debug]:" @ S);
}

//==============================================================================
//  Begin FSavedCanvasState Interface

simulated function SavedCanvasState_Save(
    Canvas C,
    out FSavedCanvasState OutSavedCanvasState)
{
    OutSavedCanvasState.Style = C.Style;
    OutSavedCanvasState.AlphaScale = C.AlphaScale;
    OutSavedCanvasState.DrawColor = C.DrawColor;
    OutSavedCanvasState.Font = C.Font;
    OutSavedCanvasState.PosX = C.CurX;
    OutSavedCanvasState.PosY = C.CurY;
}

simulated function SavedCanvasState_Restore(
    Canvas C,
    out FSavedCanvasState OutSavedCanvasState)
{
    C.Style = OutSavedCanvasState.Style;
    C.AlphaScale = OutSavedCanvasState.AlphaScale;
    C.DrawColor = OutSavedCanvasState.DrawColor;
    C.Font = OutSavedCanvasState.Font;
    C.CurX = OutSavedCanvasState.PosX;
    C.CurY = OutSavedCanvasState.PosY;
}

//  End FSavedCanvasState Interface
//==============================================================================

//==============================================================================
//  Begin FRKSHUDLocalizedMessage Interface

//  Message_Copy
//  Copy message structs
simulated function Message_Copy(
    out FRKSHUDLocalizedMessage OutSource,
    out FRKSHUDLocalizedMessage OutDestination)
{
    OutDestination.MessageClass = OutSource.MessageClass;
    OutDestination.Switch = OutSource.Switch;
    OutDestination.PRI1 = OutSource.PRI1;
    OutDestination.PRI2 = OutSource.PRI2;
    OutDestination.OptionalObject = OutSource.OptionalObject;
    OutDestination.LifeTimeSeconds = OutSource.LifeTimeSeconds;
    OutDestination.LifeTimeSecondsMinimum = OutSource.LifeTimeSecondsMinimum;
    OutDestination.TimeStampSeconds = OutSource.TimeStampSeconds;
    OutDestination.StringMessage = OutSource.StringMessage;
    OutDestination.DrawColor1 = OutSource.DrawColor1;
    OutDestination.DrawColor2 = OutSource.DrawColor2;
    OutDestination.MessageSound = OutSource.MessageSound;
}

//  Message_Populate
//  Fill out fields in HUD message from LocalizedMessage arguments
simulated function Message_Populate(
    out FRKSHUDLocalizedMessage OutMessage,
    class<LocalMessage> MessageClass,
    optional int Switch,
    optional PlayerReplicationInfo PRI1,
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject,
    optional string CriticalString)
{
    local class<RKSMessage> RKSMessageClass;

    OutMessage.MessageClass = MessageClass;
    OutMessage.Switch = Switch;
    OutMessage.PRI1 = PRI1;
    OutMessage.PRI2 = PRI2;
    OutMessage.OptionalObject = OptionalObject;
    OutMessage.StringMessage = CriticalString;

    RKSMessageClass = class<RKSMessage>(MessageClass);
    if(RKSMessageClass != None)
    {
        OutMessage.LifeTimeSeconds = RKSMessageClass.Static.GetLifeTimeSecondsMaximum(Switch, CriticalString);
        OutMessage.LifeTimeSecondsMinimum = RKSMessageClass.Static.GetLifeTimeSecondsMinimum(Switch, CriticalString);
        OutMessage.DrawColor1 = RKSMessageClass.Static.GetDrawColor1(Switch, PRI1, PRI2, OptionalObject);
        OutMessage.DrawColor2 = RKSMessageClass.Static.GetDrawColor2(Switch, PRI1, PRI2, OptionalObject);
        OutMessage.MessageSound = RKSMessageClass.Static.GetMessageSound(Switch, PRI1, PRI2, OptionalObject);
    }
    else
    {
        OutMessage.DrawColor1 = MessageClass.Static.GetColor(Switch, PRI1, PRI2);
        OutMessage.LifeTimeSeconds = MessageClass.Static.GetLifeTime(CriticalString);
        OutMessage.LifeTimeSecondsMinimum = OutMessage.LifeTimeSeconds;
    }
}

//  Message_BecomeLive
//  Called when this message has begun being displayed, not necessarily when it was received
//  Perform show-time initialization.
simulated function Message_BecomeLive(
    out FRKSHUDLocalizedMessage OutMessage)
{
    OutMessage.TimeStampSeconds = Level.TimeSeconds;
    OutMessage.bMessageIsLive = true;

    // Play message sound if there is one
    if(OutMessage.MessageSound != None)
    {
        PlayMessageSound(OutMessage.MessageSound);
    }
}

//  Message_BecomeDormant
//  Called when this message is no longer on display
simulated function Message_BecomeDormant(
    out FRKSHUDLocalizedMessage OutMessage)
{
    OutMessage.TimeStampSeconds = 0.0;
    OutMessage.bMessageIsLive = false;
}

//  Message_CheckHasBecomeLive
//  Returns true or false based on whether or not Message_BecomeLive has been
//  called for this message.
simulated function bool Message_CheckHasBecomeLive(
    out FRKSHUDLocalizedMessage OutMessage)
{
    return OutMessage.bMessageIsLive;
}

//  Message_CheckIsExpired
//  Returns true if this message has expired, false otherwise.
simulated function bool Message_CheckIsExpired(
    out FRKSHUDLocalizedMessage OutMessage)
{
    local float DeltaSeconds;

    DeltaSeconds = Level.TimeSeconds - OutMessage.TimeStampSeconds;
    if(DeltaSeconds >= OutMessage.LifeTimeSeconds)
    {
        return true;
    }
    return false;
}

//  Message_CheckCanBeOverwritten
//  Returns true if this message's minimum life time has been met.
simulated function bool Message_CheckCanBeOverwritten(
    out FRKSHUDLocalizedMessage OutMessage)
{
    local float DeltaSeconds;

    DeltaSeconds = Level.TimeSeconds - OutMessage.TimeStampSeconds;
    if(DeltaSeconds >= OutMessage.LifeTimeSecondsMinimum)
    {
        return true;
    }
    return false;
}

//  End FRKSHUDLocalizedMessage Interface
//==============================================================================

//==============================================================================
//  Begin FRKSHUDLocalizedMessageQueue Interface

//  MessageQueue_Init
//  Initializes the given message queue
simulated function MessageQueue_Init(
    out FRKSHUDLocalizedMessageQueue OutMessageQueue)
{
    OutMessageQueue.QueueIndexFront = 0;
    OutMessageQueue.QueueIndexBack = 0;
}

//  MessageQueue_Count
//  Returns number of messages alive in the queue
simulated function int MessageQueue_Count(
    out FRKSHUDLocalizedMessageQueue OutMessageQueue)
{
    local int QueueIndexFront;
    local int QueueIndexBack;

    QueueIndexFront = OutMessageQueue.QueueIndexFront;
    QueueIndexBack = OutMessageQueue.QueueIndexBack;
    if(QueueIndexBack < QueueIndexFront)
    {
        QueueIndexBack += MAX_QUEUED_MESSAGES;
    }

    return QueueIndexBack - QueueIndexFront;
}

//  MessageQueue_Peek
//  Populates OutMessage with the message at front of queue.
//  Return false if no messages in queue, true otherwise.
simulated function bool MessageQueue_Peek(
    out FRKSHUDLocalizedMessageQueue OutMessageQueue,
    out FRKSHUDLocalizedMessage OutMessage)
{
    if(MessageQueue_Count(OutMessageQueue) == 0)
    {
        return false;
    }

    Message_Copy(
        OutMessageQueue.QueuedMessages[OutMessageQueue.QueueIndexFront],
        OutMessage);
    
    return true;
}

//  MessageQueue_Push
//  Push new message into the queue.
//  Note that if the queue is full, the queue is unchanged and this
//  function returns false.
simulated function bool MessageQueue_Push(
    out FRKSHUDLocalizedMessageQueue OutMessageQueue,
    out FRKSHUDLocalizedMessage OutMessage)
{
    local int CurrentQueueIndexBack;
    local int NewQueueIndexBack;

    CurrentQueueIndexBack = OutMessageQueue.QueueIndexBack;
    NewQueueIndexBack = (CurrentQueueIndexBack + 1) % MAX_QUEUED_MESSAGES;

    if(NewQueueIndexBack == OutMessageQueue.QueueIndexFront)
    {
        return false;
    }

    Message_Copy(
        OutMessage,
        OutMessageQueue.QueuedMessages[CurrentQueueIndexBack]);
    OutMessageQueue.QueueIndexBack = NewQueueIndexBack;

    DebugLog("Pushed new message");

    return true;
}

//  MessageQueue_Pop
//  Remove message at front of queue
simulated function MessageQueue_Pop(
    out FRKSHUDLocalizedMessageQueue OutMessageQueue)
{
    if(OutMessageQueue.QueueIndexFront == OutMessageQueue.QueueIndexBack)
    {
        return;
    }

    OutMessageQueue.QueueIndexFront =
        (OutMessageQueue.QueueIndexFront + 1) % MAX_QUEUED_MESSAGES;
    
    DebugLog("Popped message");
}

//  MessageQueue_AutoUpdate
//  Perform self-updating logic on the queue.
//  Pops all expired messages until the queue is empty, or until a
//  non-expired message is at the front.
simulated function MessageQueue_AutoUpdate(
    out FRKSHUDLocalizedMessageQueue OutMessageQueue)
{
    while(MessageQueue_Count(OutMessageQueue) > 0)
    {
        // If the front message hasn't been activated yet, then activate it
        if(!Message_CheckHasBecomeLive(OutMessageQueue.QueuedMessages[OutMessageQueue.QueueIndexFront]))
        {
            Message_BecomeLive(OutMessageQueue.QueuedMessages[OutMessageQueue.QueueIndexFront]);
        }

        // Pop if the current message is expired, or if there are pending messages and the current can be overwritten
        if(Message_CheckIsExpired(OutMessageQueue.QueuedMessages[OutMessageQueue.QueueIndexFront])
        || (Message_CheckCanBeOverwritten(OutMessageQueue.QueuedMessages[OutMessageQueue.QueueIndexFront]) && MessageQueue_Count(OutMessageQueue) > 1))
        {
            Message_BecomeDormant(OutMessageQueue.QueuedMessages[OutMessageQueue.QueueIndexFront]);
            MessageQueue_Pop(OutMessageQueue);
        }
        // If the message isn't expired, break
        else
        {
            break;
        }
    }
}

//  End FRKSHUDLocalizedMessageQueue Interface
//==============================================================================

//  LocalizedMessage
//  Received localized message - push the message into queue
simulated function LocalizedMessage(
    class<LocalMessage> MessageClass,
    optional int Switch,
    optional PlayerReplicationInfo PRI1,
    optional PlayerReplicationInfo PRI2,
    optional Object OptionalObject,
    optional string CriticalString)
{
    local FRKSHUDLocalizedMessage NewMessage;

    if(CriticalString == "")
    {
        CriticalString = MessageClass.Static.GetString(Switch, PRI1, PRI2, OptionalObject);
    }

    Message_Populate(NewMessage, MessageClass, Switch, PRI1, PRI2, OptionalObject, CriticalString);
    if(!MessageQueue_Push(MessageQueue, NewMessage))
    {
        class'RKSStatics'.Static.Warn("Dropping message due to full queue - increase queue size");
    }
}

simulated function PlayMessageSound(Sound MessageSound)
{
    local PlayerPawn PP;

    PP = PlayerPawn(Owner);
    if(PP != None)
    {
        PP.PlaySound(MessageSound, SLOT_Interface, 1.0);
    }
}

simulated function DrawBackdrop(
    Canvas C,
    float CenterDrawX,
    float CenterDrawY,
    float DrawWidth,
    float DrawHeight,
    float Alpha)
{
    local FSavedCanvasState SavedC;
    local float DrawX, DrawY;
    local Texture DrawTexture;

    SavedCanvasState_Save(C, SavedC);

    Alpha = FClamp(Alpha, 0.0, 1.0);

    // Draw Backdrop
    C.Style = ERenderStyle.STY_AlphaBlend;
    C.AlphaScale = 0.5 * Alpha * Alpha;
    C.DrawColor.R = 0;
    C.DrawColor.G = 0;
    C.DrawColor.B = 0;
    DrawTexture = Texture'RuneI.sb_horizramp';

    // Backdrop right half
    DrawX = CenterDrawX;
    DrawY = CenterDrawY - (DrawHeight * 0.5);
    C.SetPos(DrawX, DrawY);
    C.DrawTile(DrawTexture, (DrawWidth * 0.5), DrawHeight, 0, 0, DrawTexture.USize, DrawTexture.VSize);

    // Backdrop left half
    DrawX = CenterDrawX - (DrawWidth * 0.5);
    DrawY = CenterDrawY - (DrawHeight * 0.5);
    C.SetPos(DrawX, DrawY);
    C.DrawTile(DrawTexture, (DrawWidth * 0.5), DrawHeight, 0, 0, -DrawTexture.USize, DrawTexture.VSize);

    // Borders
    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 255;

    // Top border right half
    DrawX = CenterDrawX;
    DrawY = CenterDrawY - (DrawHeight * 0.5);
    C.SetPos(DrawX, DrawY);
    C.DrawTile(DrawTexture, (DrawWidth * 0.5), 2, 0, 0, DrawTexture.USize, DrawTexture.VSize);

    // Top border left half
    DrawX = CenterDrawX - (DrawWidth * 0.5);
    DrawY = CenterDrawY - (DrawHeight * 0.5);
    C.SetPos(DrawX, DrawY);
    C.DrawTile(DrawTexture, (DrawWidth * 0.5), 2, 0, 0, -DrawTexture.USize, DrawTexture.VSize);

    // Bottom border right half
    DrawX = CenterDrawX;
    DrawY = CenterDrawY + (DrawHeight * 0.5);
    C.SetPos(DrawX, DrawY);
    C.DrawTile(DrawTexture, (DrawWidth * 0.5), 2, 0, 0, DrawTexture.USize, DrawTexture.VSize);

    // Bottom border left half
    DrawX = CenterDrawX - (DrawWidth * 0.5);
    DrawY = CenterDrawY + (DrawHeight * 0.5);
    C.SetPos(DrawX, DrawY);
    C.DrawTile(DrawTexture, (DrawWidth * 0.5), 2, 0, 0, -DrawTexture.USize, DrawTexture.VSize);

    SavedCanvasState_Restore(C, SavedC);
}

simulated function DrawMessageText(
    Canvas C,
    string DrawString,
    float CenterDrawX,
    float CenterDrawY,
    float Alpha)
{
    local FSavedCanvasState SavedC;
    local float MessageWidth, MessageHeight;
    local float DrawX, DrawY;

    SavedCanvasState_Save(C, SavedC);

    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 255;
    C.DrawColor = C.DrawColor * Alpha;
    C.Style = ERenderStyle.STY_Translucent;
    C.StrLen(DrawString, MessageWidth, MessageHeight);
    DrawX = CenterDrawX - (MessageWidth * 0.5);
    DrawY = CenterDrawY - (MessageHeight * 0.5);
    C.SetPos(DrawX, DrawY);
    C.DrawText(DrawString, false);

    SavedCanvasState_Restore(C, SavedC);
}

simulated event DrawMessages(Canvas C)
{
    local FSavedCanvasState SavedC;
    local FRKSHUDLocalizedMessage CurrentMessage;
    local float MessageWidth, MessageHeight;
    local string DrawString;
    local float DrawWidth, DrawHeight;
    local float DrawCenterX, DrawCenterY;
    local float Alpha;
    local float MessageDeltaSeconds;

    if(MessageQueue_Count(MessageQueue) == 0)
    {
        return;
    }
    MessageQueue_Peek(MessageQueue, CurrentMessage);

    SavedCanvasState_Save(C, SavedC);

    // Calc alpha
    MessageDeltaSeconds = Level.TimeSeconds - CurrentMessage.TimeStampSeconds;
    if(CurrentMessage.LifeTimeSeconds > 0.0)
    {
        Alpha = 1.0 - FClamp(MessageDeltaSeconds / CurrentMessage.LifeTimeSeconds, 0.0, 1.0);
    }
    else
    {
        Alpha = 1.0;
    }

    // Setup canvas
    C.Font = C.BigFont;
    DrawString = CurrentMessage.StringMessage;
    C.StrLen(DrawString, MessageWidth, MessageHeight);

    DrawCenterX = C.ClipX * 0.5;
    DrawCenterY = C.ClipY * 0.25;

    DrawWidth = FClamp(MessageWidth + 128.0, 128.0, 1024.0);
    DrawHeight = MessageHeight + 16.0;

    DrawMessageText(C, DrawString, DrawCenterX, DrawCenterY, Alpha);
    DrawBackdrop(C, DrawCenterX, DrawCenterY, DrawWidth, DrawHeight, Alpha);
    
    SavedCanvasState_Restore(C, SavedC);
}

simulated event PostRender(Canvas C)
{
    MessageQueue_AutoUpdate(MessageQueue);
    DrawMessages(C);
    Super.PostRender(C);
}

simulated event BeginPlay()
{
    Super.BeginPlay();
    DebugLog("Initializing RKS HUD");
    MessageQueue_Init(MessageQueue);
}

defaultproperties
{
    bLogDebugMessages=True
}