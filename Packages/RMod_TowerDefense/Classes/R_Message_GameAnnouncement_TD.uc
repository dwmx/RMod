class R_Message_GameAnnouncement_TD extends LocalMessage;

const UtilityLibrary = Class'RBase.R_AUtilityLibrary';

const SwitchCompressionHighBits = 8;

static function int MakeSwitch(Name MessageName, optional int Payload)
{
	local int MessageCode;
	local int Result;

	if(MessageName == 'WaveAnnouncement')
	{
		MessageCode = 1;
	}

	// Compress payload and message code into switch
	Result = UtilityLibrary.Static.CompressTwoInts(SwitchCompressionHighBits, Payload, MessageCode);
	return Result;
}

static function String GetStringFromSwitch(int Switch)
{
	local int MessageCode;
	local int Payload;
	local String Result;

	// Decompress message code and payload
	UtilityLibrary.Static.DecompressTwoInts(Switch, SwitchCompressionHighBits, Payload, MessageCode);

	if(MessageCode == 1)
	{
		return "Wave" @ Payload;
	}

	return Result;
}

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return "";
}