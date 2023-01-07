//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HardPat_CIRCUS extends HardPat;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

simulated function CloakBoss()
{
    local Controller C;
    local int Index;

    if (bSpotted)
    {
        Visibility = 120;

        if (Level.NetMode == NM_DedicatedServer)
            return;

        Skins[0] = Finalblend'KFX.StalkerGlow';
        Skins[1] = Finalblend'KFX.StalkerGlow';
        Skins[2] = Finalblend'KFX.StalkerGlow';
        bUnlit = true;

        return;
    }

    Visibility = 1;
    bCloaked = true;

    if (Level.NetMode != NM_Client)
    {
        for (C = Level.ControllerList; C != none; C = C.NextController)
        {
            if (C.bIsPlayer && C.Enemy == self)
            {
                C.Enemy = none; // Make bots lose sight with me.
            }
        }
    }

    if (Level.NetMode == NM_DedicatedServer)
        return;

    Skins[1] = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';
    Skins[0] = Shader'KF_Specimens_Trip_T.patriarch_invisible';

    // Invisible - no shadow
    if (PlayerShadow != none)
        PlayerShadow.bShadowActive = false;

    // Remove/disallow projectors on invisible people
    Projectors.Remove(0, Projectors.Length);
    bAcceptsProjectors = false;
    SetOverlayMaterial(FinalBlend'KF_Specimens_Trip_T.patriarch_fizzle_FB', 1.0, true);

    // Randomly send out a message about Patriarch going invisible(10% chance)
    if (FRand() < 0.10)
    {
        // Pick a random Player to say the message
        Index = Rand(Level.Game.NumPlayers);

        for (C = Level.ControllerList; C != none; C = C.NextController)
        {
            if (PlayerController(C) != none)
            {
                if (Index == 0)
                {
                    PlayerController(C).Speech('AUTO', 8, "");
                    break;
                }

                Index--;
            }
        }
    }
}

// should be derived and used.
static simulated function PreCacheMaterials(LevelInfo myLevel)
{
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.Patriarch_Circus.Patriarch_Circus_CMB');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gatling_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.gatling_D');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.PatGungoInvisible_cmb');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible_gun');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_fizzle_FB');
}

defaultproperties
{
    sndSaveMe=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_SaveMe'
    sndKnockDown=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_KnockedDown'
    sndEntrance=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Entrance'
    sndVictory=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Victory'
    sndMGPreFire=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_WarnGun'
    sndMisslePreFire=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_WarnRocket'
    sndTauntNinja=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_TauntNinja'
    sndTauntLumberJack=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_TauntLumberJack'
    sndTauntRadial=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_TauntRadial'

    RocketFireSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_FireRocket'
    MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_HitPlayer_Impale'
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_HitPlayer_Fist'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Jump'
    DetachedArmClass=class'KFChar.SeveredArmPatriarch_CIRCUS'
    DetachedLegClass=class'KFChar.SeveredLegPatriarch_CIRCUS'
    DetachedHeadClass=class'KFChar.SeveredHeadPatriarch_CIRCUS'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_Death'
    MenuName="Hard Ringmaster"
    AmbientSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Patriarch.Kev_IdleLoop'
    Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.Patriarch_Circus'
    Skins(0)=Combiner'KF_Specimens_Trip_CIRCUS_T.Patriarch_Circus.Patriarch_Circus_CMB'
    Skins(1)=Combiner'KF_Specimens_Trip_T.gatling_cmb'
}