class R_RunePlayerHUD_TD extends R_RunePlayerHUD;

struct FGameAnnouncementMessageTD
{
	var String MessageString;
	var float TimeStampSeconds;
};
var FGameAnnouncementMessageTD GameAnnouncementMessageTD;

simulated function LocalizedMessage(
	Class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional String CriticalString )
{
	if(Class<R_Message_GameAnnouncement_TD>(Message) != None)
	{
		GameAnnouncementMessageTD.MessageString = Class'RMod_TowerDefense.R_Message_GameAnnouncement_TD'.Static.GetStringFromSwitch(Switch);
		GameAnnouncementMessageTD.TimeStampSeconds = Level.TimeSeconds;
	}
	else
	{
		Super.LocalizedMessage(Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString);
	}
}

simulated function PostRender(Canvas C)
{
	local Pawn LocalPawnOwner;
	local R_PlayerReplicationInfo_TD PRI;
	local int GoldAmount;
	local String DrawString;
	local float StrW, StrH;

	Super.PostRender(C);

	GoldAmount = 0;

	LocalPawnOwner = Pawn(Owner);
	if(LocalPawnOwner != None)
	{
		PRI = R_PlayerReplicationInfo_TD(LocalPawnOwner.PlayerReplicationInfo);
		if(PRI != None)
		{
			GoldAmount = PRI.GetGold();
		}
	}

	DrawString = "Gold:" @ GoldAmount;
	C.Font = C.LargeFont;
	C.StrLen(DrawString, StrW, StrH);

	C.SetPos(C.ClipX - StrW, StrH);
	C.SetColor(255.0, 255.0, 1.0);
	C.DrawText(DrawString);

	DrawGameAnnouncementMessagesTD(C);
}

simulated function DrawGameAnnouncementMessagesTD(Canvas C)
{
	local float StrW, StrH;

	C.Reset();
	C.Font = C.LargeFont;
	C.StrLen(GameAnnouncementMessageTD.MessageString, StrW, StrH);
	C.SetPos(C.ClipX * 0.5 - StrW * 0.5, 10.0);
	C.SetColor(255.0, 255.0, 255.0);
	C.DrawText(GameAnnouncementMessageTD.MessageString);
}