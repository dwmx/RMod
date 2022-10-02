class R_LoadoutWindow extends UWindowFramedWindow;

var float TimeStampSeconds;
var float DeferredTimeSeconds;
var bool bDeferred;

event Created()
{
    Super.Created();

    bSizable = false;
    bAlwaysOnTop = true;
    bLeaveOnScreen = true;
    SetAcceptsFocus();
}

event SetDimensions()
{
    SetSize(ParentWindow.WinWidth * 0.666, ParentWindow.WinWidth * 0.666);
    WinLeft = ParentWindow.WinWidth * 0.5 - WinWidth * 0.5;
    WinTop = ParentWindow.WinHeight * 0.5 - WinHeight * 0.5;
}

event ResolutionChanged(float Width, float Height)
{
    SetDimensions();
}

function ShowWindowDeferred(float TimeSeconds)
{
    DeferredTimeSeconds = TimeSeconds;
    TimeStampSeconds = Root.GetPlayerOwner().Level.TimeSeconds;
    bDeferred = true;
}

event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);

    if(bDeferred && (Root.GetPlayerOwner().Level.TimeSeconds - TimeStampSeconds >= DeferredTimeSeconds))
    {
        bDeferred = false;
        ShowWindow();
    }
}

defaultproperties
{
    ClientClass=Class'RMod.R_LoadoutDialog'
    WindowTitle="Loadout"
    bAcceptsHotKeys=True
    bDeferred=False
}