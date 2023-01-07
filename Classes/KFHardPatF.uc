class KFHardPatF extends Mutator
    config(KFHardPatF);

const VERSION="3.6.0";
var() config bool bUseCustomMC;
var() config byte EventNum;

var transient bool bBroadcast;
var string strSeasonalPat;

struct sSeasonalVariants
{
    var byte idx;
    var class<HardPat> variant;
};
var public array<sSeasonalVariants> SeasonalVariants;

var KFGameType KFGT;

event PreBeginPlay()
{
    // so what I was thinking when I didn't put super code?
    super.PreBeginPlay();

    KFGT = KFGameType(Level.Game);
    if (KFGT == none)
    {
        log("Hard Patriarch: KFGameType not found! Mutator is destroyed!");
        Destroy();
        return;
    }

    // SaveConfig();
}

function MatchStarting()
{
    SetTimer(1.0, false);
}

function Timer()
{
    // waaaaait, why do i even check this?
    if (bUseCustomMC && AllowMonsterCollectionSwap())
    {
        KFGT.MonsterCollection = class'HPMonstersCollection';
        log("Hard Patriarch: HPMonstersCollection is loaded!");
    }

    // move the code outa here, so later we can add
    // more variants without copy-paste hell
    strSeasonalPat = getPatClassName();
    log("Hard Patriarch: " $ strSeasonalPat $ " is selected!");

    KFGT.EndGameBossClass = strSeasonalPat;

    if (KFGT.MonsterCollection != none)
        KFGT.MonsterCollection.default.EndGameBossClass = strSeasonalPat;

    if (!bBroadcast)
        return;

    BroadcastText("%rHard Pat Mutator%w:");
    BroadcastText("%b" $ strSeasonalPat $ " %wis activated!");
    bBroadcast = false;

    SetTimer(0.0, false);
    // Destroy();
}

public function string getPatClassName()
{
    local int i;

    for (i = 0; i < SeasonalVariants.length; i++)
    {
        if (SeasonalVariants[i].idx == EventNum)
            return string(SeasonalVariants[i].variant);
    }

    // if nothing found, return the standard pat
    return string(SeasonalVariants[0].variant);
}

public function bool AllowMonsterCollectionSwap()
{
    local byte i;
    local bool bResult;

    for (i = 0; i < 4; i++)
    {
        log(">>>>>>>> INDEX IS: " $ i);
        if (KFGT.MonsterCollection == kfgt.SpecialEventMonsterCollections[i])
        {
            log("TRUE!!!!!!!!!!!!!!!!!!!!!!!");
            bResult = true;
            break;
        }
    }

    return bResult;
}

//=========================================================================
function bool CheckAdmin(PlayerController Sender)
{
    if ( (Sender.PlayerReplicationInfo != none && Sender.PlayerReplicationInfo.bAdmin)
        || Level.NetMode == NM_Standalone || Level.NetMode == NM_ListenServer)
        return true;

    return false;
}

function Mutate(string input, PlayerController Sender)
{
    local int i;
    local array<string> wordsArray;
    local string command, mod;
    local array<string> modArray;

    // DONT break the chain!!!
    super.Mutate(input, Sender);

    // ignore empty cmds and dont go further
    // P.S. let's ignore the fact that I was
    // using custom command instead of native
    split(input, " ", wordsArray);
    if (wordsArray.Length == 0)
        return;

    // do stuff with our cmd
    command = wordsArray[0];
    if (wordsArray.Length > 1)
        mod = wordsArray[1];
    else
        mod = "";

    while (i + 1 < wordsArray.Length || i < 10)
    {
        if (i + 1 < wordsArray.Length)
            modArray[i] = wordsArray[i+1];
        else
            modArray[i] = "";
        i ++;
    }

    if (command ~= "PAT")
    {
        // allow only admins
        if (!CheckAdmin(Sender))
        {
            SendMessage(Sender, "%wKFHardPatF requires %rADMIN %wprivileges!");
            return;
        }

        if (mod ~= "HELP" || mod ~= "HLP" || mod ~= "HALP")
        {
            // Helper class. Allows to type 'mutate help <cmd>' and get detailed description
            class'Helper'.static.TellAbout(modArray[1], Sender, self);
            return;
        }

        else if (mod ~= "STANDARD" || mod ~= "0" || mod ~= "")
        {
            EventNum = 0;
            ActivateTimer();
            return;
        }

        else if (mod ~= "XMAS" || mod ~= "1")
        {
            EventNum = 1;
            ActivateTimer();
            return;
        }

        else if (mod ~= "CIRCUS" || mod ~= "2")
        {
            EventNum = 2;
            ActivateTimer();
            return;
        }

        else if (mod ~= "HALLOWEEN" || mod ~= "3")
        {
            EventNum = 3;
            ActivateTimer();
            return;
        }

        else if (mod ~= "STATUS")
        {
            BroadcastText("%rHard Pat Mutator %wversion %y" $ VERSION);
            BroadcastText("%wCurrently active: - %b" $KFGameType(Level.Game).MonsterCollection.default.EndGameBossClass$ " %w(%gEventNum = " $EventNum$ "%w).");
            return;
        }

        else if (mod ~= "SAVE")
        {
            SaveConfig();
            SendMessage(Sender, "%wConfig file is %rsaved%w!");
            return;
        }
    }
}

function ActivateTimer()
{
    bBroadcast = true;
    SetTimer(1.0, false);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    super.FillPlayInfo(PlayInfo);

    PlayInfo.AddSetting("Hard Pat", "bUseCustomMC", "Use Custom MonsterCollection", 0, 0, "Check");
    PlayInfo.AddSetting("Hard Pat", "EventNum", "Select Season", 0, 1, "Select", "0;Standard;1;Xmas;2;Circus;3;Halloween",,,true);
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
            return super.GetDescriptionText(Property);
    }
}

//============================== BROADCASTING ==============================
// SendMessage(target, message). Nagi <3 dkanus <3
function SendMessage(PlayerController pc, coerce string message)
{
    if (pc == none || message == "")
        return;

    // keep WebAdmin clean and shiny
    if (pc.playerReplicationInfo.PlayerName ~= "WebAdmin"
        && pc.PlayerReplicationInfo.PlayerID == 0)
        message = class'Helper'.static.StripFormattedString(message);
    else
        message = class'Helper'.static.ParseFormattedLine(message);

    // funny that message Type was `AdminPlus` and no one reported this
    pc.teamMessage(none, message, 'Hard Pat');
}

// BroadcastText("something",true/false)
function BroadcastText(string message)
{
    local Controller c;

    for (c = level.controllerList; c != none; c = c.nextController)
    {
        if (!C.bIsPlayer)
            continue;
        SendMessage(PlayerController(c), message);
    }
}

defaultproperties
{
    GroupName="KF-BossMut"
    FriendlyName="Extended and fixed Hard Patriarch."
    Description="Make the Patriarch harder than ever."

    // better do this than call the function manually...
    bAddToServerPackages=true

    // now this matches kfgametype enumeration
    SeasonalVariants(0)=(idx=0,variant=class'HardPat')
    SeasonalVariants(1)=(idx=1,variant=class'HardPat_CIRCUS')
    SeasonalVariants(2)=(idx=2,variant=class'HardPat_HALLOWEEN')
    SeasonalVariants(3)=(idx=3,variant=class'HardPat_XMAS')

    bUseCustomMC=true
    EventNum=0
}