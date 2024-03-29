// Author        : NikC-
// Home Repo     : https://github.com/InsultingPros/KFHardPatF
// License       : https://www.gnu.org/licenses/gpl-3.0.en.html
class HardPatController extends BossZombieController;

var NavigationPoint MidGoals[2];
var byte ReachOffset;
var Actor OldPathsCheck[3];

final function Debugf(string S)
{
    Level.GetLocalPlayerController().ClientMessage(S);
    Log(S);
}

final function FindPathAround()
{
    local Actor Res;
    local NavigationPoint N;
    local NavigationPoint OldPts[12];
    local byte i;
    local bool bResult;

    if (Enemy == none || VSizeSquared(Enemy.Location - Pawn.Location) < 360000)
        return; // No can do this.

    // Attempt to find an alternative path to enemy.
    /* This works by:
        - finding shortest path to enemy
        - block middle path point
        - if the path is still about same to enemy, try block the new path and repeat up to 6 times.
    */
    for (i = 0; i < ArrayCount(OldPts); ++i)
    {
        Res = FindPathToward(Enemy);
        if (Res == none)
            break;
        if (i > 0 && CompareOldPaths())
        {
            bResult = true;
            break;
        }
        N = GetMidPoint();
        if (N == none)
            break;
        N.bBlocked = true;
        OldPts[i] = N;
        if (i == 0)
            SetOldPaths();
    }

    // Unblock temp blocked paths.
    for (i = 0; i < ArrayCount(OldPts); ++i)
        if (OldPts[i] != none)
            OldPts[i].bBlocked = false;

    if (!bResult)
        return;

    // Fetch results and switch state.
    GetMidGoals();
    if (ReachOffset < 2)
        GoToState('PatFindWay');
}

final function NavigationPoint GetMidPoint()
{
    local byte n;

    for (n = 0; n < ArrayCount(RouteCache); ++n)
        if (RouteCache[n] == none)
            break;

    if(n == 0)
        return none;

    return NavigationPoint(RouteCache[(n - 1) * 0.5]);
}

final function bool CompareOldPaths()
{
    local byte n, i;

    for (i = 0; i < 6; ++i)
    {
        if (RouteCache[i] == none)
            break;
        for (n = 0; n < ArrayCount(OldPathsCheck); ++n)
            if (RouteCache[i] == OldPathsCheck[n])
                return false;
    }
    return true;
}

final function SetOldPaths()
{
    local byte n;

    for (n = 0; n < ArrayCount(OldPathsCheck); ++n)
        OldPathsCheck[n] = RouteCache[n + 1];
    if (RouteCache[1] == none)
        OldPathsCheck[0] = RouteCache[0];
}

final function GetMidGoals()
{
    local byte n;

    for (n = 0; n < ArrayCount(RouteCache); ++n)
        if (RouteCache[n] == none)
            break;

    if (n == 0)
    {
        ReachOffset = 2;
        return;
    }
    --n;
    MidGoals[0] = NavigationPoint(RouteCache[n * 0.5]);
    MidGoals[1] = NavigationPoint(RouteCache[n]);
    if (MidGoals[0] == MidGoals[1])
        ReachOffset = 1;
    else
        ReachOffset = 0;
}

// WTF! mod stuff
// overridden to actually get the freakin' pat to the players quickly
//...unlike what the state I'm overridding accomplished (nothing)
state InitialHunting
{
    // based off of MonsterController
    // overridden to always have an enemy right off the bat
    // and (via the original PickDestination() in MonsterController) start moving towards them now

    function PickDestination()
    {
        local Controller C;

        for (C = Level.ControllerList; C != none; C = C.NextController)
        {
            if (C.bIsPlayer && C.Pawn != none && C.Pawn.Health > 0)
            {
                Enemy = C.Pawn;
                break;
            }
        }

        super.PickDestination();
    }
}

state PatFindWay
{
Ignores Timer,SeePlayer,HearNoise,DamageAttitudeTo,EnemyChanged,Startle,Tick;

    final function PickDestination()
    {
        if (ReachOffset >= 2)
        {
            GotoState('ZombieHunt');
            return;
        }
        if (ActorReachable(MidGoals[ReachOffset]))
        {
            MoveTarget = MidGoals[ReachOffset];
            ++ReachOffset;
        }
        else
        {
            MoveTarget = FindPathToward(MidGoals[ReachOffset]);
            if (MoveTarget == none)
                ++ReachOffset;
        }
    }
    function BreakUpDoor(KFDoorMover Other, bool bTryDistanceAttack)
    {
        global.BreakUpDoor(Other, bTryDistanceAttack);
        Pawn.GoToState('');
    }

Begin:
    PickDestination();
    if (MoveTarget == none)
        Sleep(0.5f);
    else
        MoveToward(MoveTarget, MoveTarget,, false);
    GoTo'Begin';
}

defaultproperties{}