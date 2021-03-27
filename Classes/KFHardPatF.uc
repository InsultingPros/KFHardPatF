Class KFHardPatF extends Mutator
  config(KFHardPatF);

var() config bool bUseCustomMC;
var() config byte EventNum;

var transient bool bBroadcast;
var string strSeasonalPat;

var KFGameType KFGT;
var KFHardPatF Mut;

function PreBeginPlay()
{
  KFGT = KFGameType(Level.Game);
  if (KFGT == none)
  {
    log("Hard Patriarch: KFGameType not found! Mutator is destroyed!");
    Destroy();
    return;
  }

  Mut = self;
  AddToPackageMap();
  //SaveConfig();
}

function MatchStarting()
{
	SetTimer(1.0, false);
}

function Timer()
{
  if (bUseCustomMC && KFGT.MonsterCollection == class'KFGameType'.default.MonsterCollection)
  {
    KFGT.MonsterCollection = class'HPMonstersCollection';
    log("Hard Patriarch: HPMonstersCollection is loaded!");
  }

  switch (EventNum)
	{
		case 1:
      strSeasonalPat = "KFHardPatF.HardPat_XMAS";
			break;
    case 2:
      strSeasonalPat = "KFHardPatF.HardPat_CIRCUS";
			break;
    case 3:
      strSeasonalPat = "KFHardPatF.HardPat_HALLOWEEN";
			break;
		default:
      strSeasonalPat = "KFHardPatF.HardPat";
	}
  log("Hard Patriarch: " $strSeasonalPat$ " is selected!");

	KFGT.EndGameBossClass = strSeasonalPat;

	if( KFGT.MonsterCollection != None )
		KFGT.MonsterCollection.Default.EndGameBossClass = strSeasonalPat;

  if(!bBroadcast)
    return;

  BroadcastText("%rHard Pat Mutator%w:");
  BroadcastText("%b" $strSeasonalPat$ " %wis activated!");
  bBroadcast = false;

  SetTimer(0.0, false);
	//Destroy();
}

//=========================================================================
// split our mutate cmd so we can use fancy ON / OFF switches
function array<string> SplitString(string inputString, string div)
{
	local array<string> parts;
	local bool bEOL;
	local string tempChar;
	local int preCount, curCount, partCount, strLength;
  
  inputString = Caps(inputString);
	strLength = Len(inputString);
	if(strLength == 0)
		return parts;
	bEOL = false;
	preCount = 0;
	curCount = 0;
	partCount = 0;

	while(!bEOL)
	{
		tempChar = Mid(inputString, curCount, 1);
		if(tempChar != div)
			curCount ++;
		else
		{
			if(curCount == preCount)
			{
				curCount ++;
				preCount ++;
			}

			else
			{
				parts[partCount] = Mid(inputString, preCount, curCount - preCount);
				partCount ++;
				preCount = curCount + 1;
				curCount = preCount;
			}
		}

		if(curCount == strLength)
		{
			if(preCount != strLength)
				parts[partCount] = Mid(inputString, preCount, curCount);
			bEOL = true;
		}
	}

	return parts;
}

function bool CheckAdmin(PlayerController Sender)
{
	if ( (Sender.PlayerReplicationInfo != none && Sender.PlayerReplicationInfo.bAdmin) || Level.NetMode == NM_Standalone || Level.NetMode == NM_ListenServer )
		return true;

	return false;
}

function Mutate(string MutateString, PlayerController Sender)
{
  local int i;
	local array<String> wordsArray;
	local String command, mod;
	local array<String> modArray;

  // ignore empty cmds and dont go further
	wordsArray = SplitString(MutateString, " ");
	if(wordsArray.Length == 0)
		return;

	// do stuff with our cmd
	command = wordsArray[0];
	if(wordsArray.Length > 1)
		mod = wordsArray[1];
	else
		mod = "";

	i = 0;
	while(i + 1 < wordsArray.Length || i < 10)
	{
		if(i + 1 < wordsArray.Length)
			modArray[i] = wordsArray[i+1];
		else
			modArray[i] = "";
		i ++;
	}

  // allow only admins and filter 'PAT' keyword
  if(command != "PAT")
  {
    Super.Mutate(MutateString, Sender);
    return;
  }

  if(!CheckAdmin(Sender))
  {
    SendMessage(Sender, "%wRequires %rADMIN %wprivileges!");
    return;
  }

  if(mod ~= "HELP" || mod ~= "HLP" || mod ~= "HALP")
  {
    // Helper class. Allows to type 'mutate help <cmd>' and get detailed description
    class'Helper'.static.TellAbout(modArray[1], Sender, self);
  }

  else if(mod ~= "STANDARD" || mod ~= "0" || mod ~= "")
  {
    EventNum = 0;
    ActivateTimer();
    return;
  }

  else if(mod ~= "XMAS" || mod ~= "1")
  {
    EventNum = 1;
    ActivateTimer();
    return;
  }

  else if(mod ~= "CIRCUS" || mod ~= "2")
  {
    EventNum = 2;
    ActivateTimer();
    return;
  }

  else if(mod ~= "HALLOWEEN" || mod ~= "3")
  {
    EventNum = 3;
    ActivateTimer();
    return;
  }

  else if(mod ~= "STATUS")
  {
    BroadcastText("%rHard Pat Mutator%w:");
    BroadcastText("%wCurrently active: - %b" $KFGameType(Level.Game).MonsterCollection.Default.EndGameBossClass$ " %w(%gEventNum = " $EventNum$ "%w).");
  }

  else if(mod ~= "SAVE")
  {
    SaveConfig();
    SendMessage(Sender, "%rConfig is saved!");
  }
  
  Super.Mutate(MutateString, Sender);
}

function ActivateTimer()
{
  bBroadcast = true;
  SetTimer(1.0, false);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("Hard Pat", "bUseCustomMC", "Use Custom MonsterCollection", 0, 0, "Check");
	PlayInfo.AddSetting("Hard Pat", "EventNum", "Select Season", 0, 1, "Select", "0;Standard;1;Xmas;2;Circus;3;Halloween",,,True);
}

static event string GetDescriptionText(string Property)
{
	switch (Property)
  {
		case "bUseCustomMC":
			return "Chech this to enable custom MonsterCollection and avoid broken servers with invisible pats, when you switch from to other votings.";
		case "EventNum":
			return "Available types - Standard, Xmas, Circus, Halloween.";
		default:
			return Super.GetDescriptionText(Property);
	}
}

//============================== BROADCASTING ==============================
// SendMessage(target, message). Nagi <3 dkanus <3
function SendMessage(PlayerController pc, coerce string message)
{
	if(pc == none || message == "")
		return;

	// keep WebAdmin clean and shiny
	if(pc.playerReplicationInfo.PlayerName ~= "WebAdmin" && pc.PlayerReplicationInfo.PlayerID == 0)
    message = class'Helper'.static.StripFormattedString(message);
  else
    message = class'Helper'.static.ParseFormattedLine(message);

	pc.teamMessage(none, message, 'AdminPlus');
}

// BroadcastText("something",true/false)
function BroadcastText(string message)
{
  local Controller c;

	for(c = level.controllerList; c != none; c = c.nextController)
	{
		if(!C.bIsPlayer)
      continue;
    SendMessage(PlayerController(c), message);
	}
}

defaultproperties
{
   GroupName="KF-BossMut"
   FriendlyName="Extended and fixed Hard Patriarch."
   Description="Make the Patriarch harder than ever."

   bUseCustomMC=true
   EventNum=0
}