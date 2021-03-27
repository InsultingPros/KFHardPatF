Class HardPat extends ZombieBoss
  config(KFHardPatF);

var transient bool bInitialized;

var KFGameType KFGT;

struct FCombatState
{
	var() config bool bMovCG,bRunCG,bPauseCG,bMisIgnoreRange,bAltRoute;
	var() config int NumMis[2],NumCG[2];
	var() config float MisRepTime;
};

var() config FCombatState PatStates[4];
var() config int PatHealth;

var transient float GiveUpTime;
var byte MissilesLeft;
var bool bValidBoss,bMovingChaingunAttack;
var(Sounds) sound SaveMeSound;

replication
{
	reliable if( ROLE==ROLE_AUTHORITY )
		bMovingChaingunAttack;
}

simulated function PostBeginPlay()
{
  Health = PatHealth;
  HealthMax = PatHealth;

  KFGT = KFGameType(Level.Game);

	Super.PostBeginPlay();
}

function bool MakeGrandEntry()
{
	bValidBoss = true;
	return Super.MakeGrandEntry();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
  if( bValidBoss )
		Super.Died(Killer,damageType,HitLocation);

	else Super(KFMonster).Died(Killer,damageType,HitLocation);
}

simulated function Tick(float DeltaTime)
{
  if(Level.NetMode == NM_DedicatedServer)
  {
    if(KFGT.IsInState('MatchOver') && !bInitialized)
    {
      BroadcastText("%wThe %b" $MenuName$ "%w health is %r" $Health$ " %w/ %r" $int(HealthMax)$ " %w(" $Health/HealthMax*100$ "%).");
      Log("Hard Patriarch: SQUAD WIPED OUT! The " $MenuName$ " health is " $Health$ " / " $int(HealthMax)$ " (" $Health/HealthMax*100$ "%).");
      bInitialized = true;
    }

    else if(bInitialized && !KFGT.IsInState('MatchOver'))
    {
      bInitialized = false;
    }
  }

  Super.Tick(DeltaTime);
}

simulated function bool HitCanInterruptAction()
{
	return (!bWaitForAnim && !bShotAnim);
}

function DoorAttack(Actor A)
{
	if ( !bShotAnim && A!=None )
	{
		Controller.Target = A;
		bShotAnim = true;
		Acceleration = vect(0,0,0);
		HandleWaitForAnim('MeleeImpale');
		SetAnimAction('MeleeImpale');
	}
}

function RangedAttack(Actor A)
{
	local float D;
	local bool bOnlyE;
	local bool bDesireChainGun;

	// Randomly make him want to chaingun more
	if( Controller.LineOfSightTo(A) && FRand() < 0.15 && LastChainGunTime<Level.TimeSeconds )
	{
		bDesireChainGun = true;
	}

	if ( bShotAnim )
	{
		if( !IsAnimating(ExpectingChannel) )
			bShotAnim = false;
		return;
	}
	D = VSize(A.Location-Location);
	bOnlyE = (Pawn(A)!=None && OnlyEnemyAround(Pawn(A)));
	if ( IsCloseEnuf(A) )
	{
		bShotAnim = true;
		if( Health>1500 && Pawn(A)!=None && FRand() < 0.5 )
		{
			SetAnimAction('MeleeImpale');
		}
		else
		{
			SetAnimAction('MeleeClaw');
			//PlaySound(sound'Claw2s', SLOT_None); KFTODO: Replace this
		}
	}
	else if( Level.TimeSeconds>LastSneakedTime )
	{
		if( Rand(3)==0 )
		{
			// Wait another 20-40 to try this again
			LastSneakedTime = Level.TimeSeconds+20.f+FRand()*20;
			Return;
		}
		SetAnimAction('transition');
		GoToState('SneakAround');
	}
	else if( bChargingPlayer && (bOnlyE || D<200) )
		Return;
	else if( !bDesireChainGun && !bChargingPlayer && (D<300 || (D<700 && bOnlyE)) &&
        (Level.TimeSeconds - LastChargeTime > (5.0 + 5.0 * FRand())) )  // Don't charge again for a few seconds
	{
		SetAnimAction('transition');
		GoToState('Charging');
	}
	else if( LastMissileTime<Level.TimeSeconds && (PatStates[SyringeCount].bMisIgnoreRange || D>500) )
	{
		if( !Controller.LineOfSightTo(A) || FRand() > 0.75 )
		{
			LastMissileTime = Level.TimeSeconds+FRand() * 5;
			Return;
		}

		LastMissileTime = Level.TimeSeconds + 10 + FRand() * 15;

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('PreFireMissile');

		HandleWaitForAnim('PreFireMissile');

		GoToState('FireMissile');
	}
	else if ( !bWaitForAnim && !bShotAnim && LastChainGunTime<Level.TimeSeconds )
	{
		if ( !Controller.LineOfSightTo(A) || FRand()> 0.85 )
		{
			LastChainGunTime = Level.TimeSeconds+FRand()*4;
			Return;
		}

		LastChainGunTime = Level.TimeSeconds + 5 + FRand() * 10;

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('PreFireMG');

		HandleWaitForAnim('PreFireMG');
		MGFireCounter = PatStates[SyringeCount].NumCG[0] + Rand(PatStates[SyringeCount].NumCG[1]);

		GoToState('FireChaingun');
	}
}

simulated function bool AnimNeedsWait(name TestAnim)
{
	if( TestAnim == 'FireMG' )
		return !bMovingChaingunAttack;
	return Super.AnimNeedsWait(TestAnim);
}

simulated function int DoAnimAction( name AnimName )
{
	if( AnimName=='FireMG' && bMovingChaingunAttack )
	{
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone, True);
		PlayAnim('FireMG',, 0.f, 1);
		return 1;
	}
	else if( AnimName=='FireEndMG' )
	{
		//SetBoneDirection(FireRootBone,rot(0,0,0),,0,0);
		AnimBlendParams(1, 0);
	}
	return Super.DoAnimAction( AnimName );
}

simulated function AnimEnd(int Channel)
{
	local name  Sequence;
	local float Frame, Rate;

	if( Level.NetMode==NM_Client && bMinigunning )
	{
		GetAnimParams( Channel, Sequence, Frame, Rate );

		if( Sequence != 'PreFireMG' && Sequence != 'FireMG' )
		{
			//SetBoneDirection(FireRootBone,rot(0,0,0),,0,0);
			Super(KFMonster).AnimEnd(Channel);
			return;
		}

		if( bMovingChaingunAttack )
			DoAnimAction('FireMG');
		else
		{
			PlayAnim('FireMG');
			bWaitForAnim = true;
			bShotAnim = true;
			IdleTime = Level.TimeSeconds;
		}
	}
	else
	{
		//SetBoneDirection(FireRootBone,rot(0,0,0),,0,0);
		Super(KFMonster).AnimEnd(Channel);
	}
}

// Fix: Don't spawn needle before last stage.
simulated function NotifySyringeA()
{
	if( Level.NetMode!=NM_Client )
	{
		if( SyringeCount<3 )
			SyringeCount++;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();
	}
	if( Level.NetMode!=NM_DedicatedServer )
		DropNeedle();
}

simulated function NotifySyringeC()
{
	if( Level.NetMode!=NM_DedicatedServer )
	{
		CurrentNeedle = Spawn(Class'BossHPNeedle');
		CurrentNeedle.Velocity = vect(-45,300,-90) >> Rotation;
		DropNeedle();
	}
}

simulated function ZombieCrispUp() // Don't become crispy.
{
	bAshen = true;
	bCrispified = true;
	SetBurningBehavior();
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( ZombieBoss(InstigatedBy)==None ) // ignore damage from other patriarch and own rockets
		Super.TakeDamage(Damage,InstigatedBy,Hitlocation,Momentum,damageType,HitIndex);
}

state KnockDown
{
	Ignores RangedAttack,TakeDamage;

Begin:
	if ( Health > 0 )
	{
		Sleep(GetAnimDuration('KnockDown'));
		CloakBoss();
		PlaySound(SaveMeSound, SLOT_Misc, 2.0,,500.0);

		if ( KFGT.FinalSquadNum == SyringeCount )
		{
		  KFGT.AddBossBuddySquad();
		}

		GotoState('Escaping');
	}
	else
	{
	   GotoState('');
	}
}

state FireChaingun
{
	function BeginState()
	{
		Super.BeginState();
		bMovingChaingunAttack = PatStates[SyringeCount].bMovCG;
		bChargingPlayer = (PatStates[SyringeCount].bRunCG && Rand(2)==0);
		bCanStrafe = true;
	}
	function EndState()
	{
		bChargingPlayer = false;
		Super.EndState();
		bMovingChaingunAttack = false;
		bCanStrafe = false;
	}
	function Tick( float Delta )
	{
		Super(KFMonster).Tick(Delta);
		if( bChargingPlayer )
			GroundSpeed = OriginalGroundSpeed * 2.3;
		else GroundSpeed = OriginalGroundSpeed * 1.15;
	}
	function AnimEnd( int Channel )
	{
		if( MGFireCounter <= 0 )
		{
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}
		else if( bMovingChaingunAttack )
		{
			if( bFireAtWill && Channel!=1 )
				return;
			if( Controller.Target!=None )
				Controller.Focus = Controller.Target;
			bShotAnim = false;
			bFireAtWill = True;
			SetAnimAction('FireMG');
		}
		else
		{
			if ( Controller.Enemy != none )
			{
				if ( Controller.LineOfSightTo(Controller.Enemy) && FastTrace(GetBoneCoords('tip').Origin,Controller.Enemy.Location))
				{
					MGLostSightTimeout = 0.0;
					Controller.Focus = Controller.Enemy;
					Controller.FocalPoint = Controller.Enemy.Location;
				}
				else
				{
					MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
					Controller.Focus = None;
				}
				Controller.Target = Controller.Enemy;
			}
			else
			{
				MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
				Controller.Focus = None;
			}

			if( !bFireAtWill )
			{
				MGFireDuration = Level.TimeSeconds + (0.75 + FRand() * 0.5);
			}
			else if ( FRand() < 0.03 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
			{
				// Randomly send out a message about Patriarch shooting chain gun(3% chance)
				PlayerController(Controller.Enemy.Controller).Speech('AUTO', 9, "");
			}

			bFireAtWill = True;
			bShotAnim = true;
			Acceleration = vect(0,0,0);

			SetAnimAction('FireMG');
			bWaitForAnim = true;
		}
	}
	function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
	{
		local float EnemyDistSq, DamagerDistSq;

		global.TakeDamage(Damage,instigatedBy,hitlocation,Momentum,damageType);
		if( bMovingChaingunAttack || Health<=0 )
			return;

		// if someone close up is shooting us, just charge them
		if( InstigatedBy != none )
		{
			DamagerDistSq = VSizeSquared(Location - InstigatedBy.Location);

			if( (ChargeDamage > 200 && DamagerDistSq < (500 * 500)) || DamagerDistSq < (100 * 100) )
			{
				SetAnimAction('transition');
				GoToState('Charging');
				return;
			}
		}

		if( Controller.Enemy != none && InstigatedBy != none && InstigatedBy != Controller.Enemy )
		{
			EnemyDistSq = VSizeSquared(Location - Controller.Enemy.Location);
			DamagerDistSq = VSizeSquared(Location - InstigatedBy.Location);
		}

		if( InstigatedBy != none && (DamagerDistSq < EnemyDistSq || Controller.Enemy == none) )
		{
			MonsterController(Controller).ChangeEnemy(InstigatedBy,Controller.CanSee(InstigatedBy));
			Controller.Target = InstigatedBy;
			Controller.Focus = InstigatedBy;

			if( DamagerDistSq < (500 * 500) )
			{
				SetAnimAction('transition');
				GoToState('Charging');
			}
		}
	}

Begin:
	While( True )
	{
		if( !bMovingChaingunAttack )
			Acceleration = vect(0,0,0);

		if( MGLostSightTimeout > 0 && Level.TimeSeconds > MGLostSightTimeout )
		{
			Acceleration = vect(0,0,0);
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}

		if( MGFireCounter <= 0 )
		{
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}

		// Give some randomness to the patriarch's firing (constantly fire after first stage passed)
		if( Level.TimeSeconds > MGFireDuration && PatStates[SyringeCount].bPauseCG )
		{
			if( AmbientSound != MiniGunSpinSound )
			{
				SoundVolume=185;
				SoundRadius=200;
				AmbientSound = MiniGunSpinSound;
			}
			Sleep(0.5 + FRand() * 0.75);
			MGFireDuration = Level.TimeSeconds + (0.75 + FRand() * 0.5);
		}
		else
		{
			if( bFireAtWill )
    				FireMGShot();
			Sleep(0.05);
		}
	}
}

state Healing
{
Ignores TakeDamage;
}

state FireMissile
{
	function RangedAttack(Actor A)
	{
		if( MissilesLeft>1 )
		{
			Controller.Target = A;
			Controller.Focus = A;
		}
	}
	function BeginState()
	{
		MissilesLeft = PatStates[SyringeCount].NumMis[0];
		if( PatStates[SyringeCount].NumMis[1]>0 )
			MissilesLeft += Rand(PatStates[SyringeCount].NumMis[1]+1);
		MissilesLeft = Max(MissilesLeft,1);
		Acceleration = vect(0,0,0);
	}

	function AnimEnd( int Channel )
	{
		local vector Start;
		local Rotator R;

		Start = GetBoneCoords('tip').Origin;
		if( Controller.Target == None )
			Controller.Target = Controller.Enemy;

		if ( !SavedFireProperties.bInitialized )
		{
      // fixed 'MyAmmo not found'
			SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
			SavedFireProperties.ProjectileClass = Class'BossLAWProjX';
			SavedFireProperties.WarnTargetPct = 0.15;
			SavedFireProperties.MaxRange = 10000;
			SavedFireProperties.bTossed = False;
			SavedFireProperties.bLeadTarget = True;
			SavedFireProperties.bInitialized = true;
		}
		SavedFireProperties.bInstantHit = (SyringeCount<1);
		SavedFireProperties.bTrySplash = (SyringeCount>=2);

		R = AdjustAim(SavedFireProperties,Start,100);
		PlaySound(RocketFireSound,SLOT_Interact,2.0,,TransientSoundRadius,,false);
		Spawn(Class'BossLAWProjX',,,Start,R);

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('FireEndMissile');
		HandleWaitForAnim('FireEndMissile');

		// Randomly send out a message about Patriarch shooting a rocket(5% chance)
		if ( FRand() < 0.05 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
		{
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 10, "");
		}

		if( --MissilesLeft==0 )
			GoToState('');
		else GoToState(,'SecondMissile');
	}
Begin:
	while ( true )
	{
		Acceleration = vect(0,0,0);
		Sleep(0.1);
	}
SecondMissile:
	Acceleration = vect(0,0,0);
	Sleep(PatStates[SyringeCount].MisRepTime);
	AnimEnd(0);
}

State Escaping // Added god-mode.
{
Ignores TakeDamage,RangedAttack;

	function BeginState()
	{
		GiveUpTime = Level.TimeSeconds+20.f+FRand()*20.f;
		Super.BeginState();
		bBlockActors = false; // Run through players.
		bIgnoreEncroachers = true; // Allow run past cade if needed.
    MotionDetectorThreat=0; // dont blow up pipes while escaping...
	}
	function EndState()
	{
		Super.EndState();
		bIgnoreEncroachers = false;
		if( Health>0 )
			bBlockActors = true;
    MotionDetectorThreat = default.MotionDetectorThreat;
	}
	function Tick( float Delta )
	{
		if( Level.TimeSeconds>GiveUpTime )
		{
			BeginHealing();
			return;
		}
		if( !bChargingPlayer )
		{
			bChargingPlayer = true;
        	if( Level.NetMode!=NM_DedicatedServer )
        		PostNetReceive();
    	}
		GroundSpeed = OriginalGroundSpeed * 2.5;
		Global.Tick(Delta);
	}

Begin:
	While( true )
	{
		Sleep(0.5);
		if( !bCloaked && !bShotAnim )
			CloakBoss();
		
		if( !Controller.IsInState('SyrRetreat') && !Controller.IsInState('WaitForAnim'))
			Controller.GoToState('SyrRetreat');
	}
}

State SneakAround
{
	function BeginState()
	{
		super.BeginState();
		SneakStartTime = Level.TimeSeconds+10.f+FRand()*15.f;
	}
	function EndState()
	{
		super.EndState();
		LastSneakedTime = Level.TimeSeconds+20.f+FRand()*30.f;
		if( Controller!=None && Controller.IsInState('PatFindWay') )
			Controller.GoToState('ZombieHunt');
	}
	function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
	{
		global.TakeDamage(Damage,instigatedBy,hitlocation,Momentum,damageType);
		if( Health<=0 )
			return;

		// if someone close up is shooting us, just charge them
		if( InstigatedBy!=none && VSizeSquared(Location - InstigatedBy.Location)<62500 )
			GoToState('Charging');
	}

Begin:
	CloakBoss();
	if( PatStates[SyringeCount].bAltRoute && Rand(5)<=3 )
		HardPatController(Controller).FindPathAround();
	While( true )
	{
		Sleep(0.5);

		if( !bCloaked && !bShotAnim )
			CloakBoss();
		if( !Controller.IsInState('PatFindWay') )
		{
			if( Level.TimeSeconds>SneakStartTime )
				GoToState('');
			if( !Controller.IsInState('WaitForAnim') && !Controller.IsInState('ZombieHunt') )
				Controller.GoToState('ZombieHunt');
		}
		else SneakStartTime = Level.TimeSeconds+30.f;
	}
}

//============================== BROADCASTING ==============================
function BroadcastText(string message)
{
	local Controller c;
  local PlayerController pc;

	for(c = level.controllerList; c != none; c = c.nextController)
	{
		if(!C.bIsPlayer)
      continue;
    pc = PlayerController(c);

    if(pc.playerReplicationInfo.PlayerName ~= "WebAdmin" && pc.PlayerReplicationInfo.PlayerID == 0)
      message = class'Helper'.static.StripFormattedString(message);
    else
      message = class'Helper'.static.ParseFormattedLine(message);

    pc.teamMessage(none, message, 'Hard Pat');
	}
}

defaultproperties
{
   MenuName="Hard Pat"
   ControllerClass=Class'KFHardPatF.HardPatController'

   PatStates(0)=(bMovCG=False,bRunCG=False,bPauseCG=True,bMisIgnoreRange=False,bAltRoute=False,NumMis[0]=1,NumMis[1]=0,NumCG[0]=35,NumCG[1]=5,MisRepTime=1.000000)
   PatStates(1)=(bMovCG=False,bRunCG=False,bPauseCG=False,bMisIgnoreRange=False,bAltRoute=False,NumMis[0]=2,NumMis[1]=0,NumCG[0]=45,NumCG[1]=10,MisRepTime=0.800000)
   PatStates(2)=(bMovCG=True,bRunCG=False,bPauseCG=False,bMisIgnoreRange=True,bAltRoute=True,NumMis[0]=3,NumMis[1]=0,NumCG[0]=55,NumCG[1]=15,MisRepTime=0.700000)
   PatStates(3)=(bMovCG=True,bRunCG=True,bPauseCG=False,bMisIgnoreRange=True,bAltRoute=True,NumMis[0]=4,NumMis[1]=0,NumCG[0]=65,NumCG[1]=15,MisRepTime=0.500000)

   PatHealth=4000

   ClawMeleeDamageRange=75 //85
   ImpaleMeleeDamageRange=85 //45

   ZappedDamageMod=1.00
	 ZapResistanceScale=2.0
   ZappedSpeedMod=0.8

   bCanDistanceAttackDoors=False

   LODBias=4.000000

   Skins(0)=Combiner'KF_Specimens_Trip_T.gatling_cmb'
   Skins(1)=Combiner'KF_Specimens_Trip_T.patriarch_cmb'

   SaveMeSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_SaveMe'
   RocketFireSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_FireRocket'
   MiniGunFireSound=Sound'KF_BasePatriarch.Attack.Kev_MG_GunfireLoop'
   MiniGunSpinSound=Sound'KF_BasePatriarch.Attack.Kev_MG_TurbineFireLoop'

   MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_HitPlayer_Impale'
   MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Talk'

   MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_HitPlayer_Fist'
   JumpSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Jump'
   DetachedArmClass=Class'KFChar.SeveredArmPatriarch'
   DetachedLegClass=Class'KFChar.SeveredLegPatriarch'
   DetachedHeadClass=Class'KFChar.SeveredHeadPatriarch'
   DetachedSpecialArmClass=Class'KFChar.SeveredRocketArmPatriarch'
   HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Pain'
   DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Death'
   AmbientSound=Sound'KF_BasePatriarch.Idle.Kev_IdleLoop'
   Mesh=SkeletalMesh'KF_Freaks_Trip.Patriarch_Freak'
}