//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HardPat_HALLOWEEN extends HardPat;


#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax

simulated function CloakBoss()
{
    local Controller C;
    local int Index;

    // No cloaking if zapped
    if (bZapped)
    {
        return;
    }

    if ( bSpotted )
    {
        Visibility = 120;

        if ( Level.NetMode==NM_DedicatedServer )
        {
            return;
        }

        Skins[0] = Finalblend'KFX.StalkerGlow';
        Skins[1] = Finalblend'KFX.StalkerGlow';
        Skins[2] = Finalblend'KFX.StalkerGlow';
        bUnlit = true;

        return;
    }

    Visibility = 1;
    bCloaked = true;

    if ( Level.NetMode!=NM_Client )
    {
        for ( C=Level.ControllerList; C!=none; C=C.NextController )
        {
            if ( C.bIsPlayer && C.Enemy==self )
            {
                C.Enemy = none; // Make bots lose sight with me.
            }
        }
    }

    if( Level.NetMode==NM_DedicatedServer )
    {
        return;
    }

    Skins[1] = Shader'KF_Specimens_Trip_HALLOWEEN_T.Patriarch.Patriarch_Halloween_Invisible';
    Skins[0] = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';

    // Invisible - no shadow
    if(PlayerShadow != none)
    {
        PlayerShadow.bShadowActive = false;
    }

    // Remove/disallow projectors on invisible people
    Projectors.Remove(0, Projectors.Length);
    bAcceptsProjectors = false;
    SetOverlayMaterial(FinalBlend'KF_Specimens_Trip_T.patriarch_fizzle_FB', 1.0, true);

    // Randomly send out a message about Patriarch going invisible(10% chance)
    if ( FRand() < 0.10 )
    {
        // Pick a random Player to say the message
        Index = Rand(Level.Game.NumPlayers);

        for ( C = Level.ControllerList; C != none; C = C.NextController )
        {
            if ( PlayerController(C) != none )
            {
                if ( Index == 0 )
                {
                    PlayerController(C).Speech('AUTO', 8, "");
                    break;
                }

                Index--;
            }
        }
    }
}

defaultproperties
{
    sndSaveMe=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_SaveMe'
    sndKnockDown=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_KnockedDown'
    sndEntrance=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Entrance'
    sndVictory=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Victory'
    sndMGPreFire=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_WarnGun'
    sndMisslePreFire=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_WarnRocket'
    sndTauntNinja=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_TauntNinja'
    sndTauntLumberJack=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_TauntLumberJack'
    sndTauntRadial=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_TauntRadial'

    RocketFireSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_FireRocket'
    MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_HitPlayer_Impale'
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_HitPlayer_Fist'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Jump'
    DetachedArmClass=class'KFChar.SeveredArmPatriarch_HALLOWEEN'
    DetachedLegClass=class'KFChar.SeveredLegPatriarch_HALLOWEEN'
    DetachedHeadClass=class'KFChar.SeveredHeadPatriarch_HALLOWEEN'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Death'
    MenuName="Hard Sheriff"
    AmbientSound=Sound'KF_BasePatriarch_HALLOWEEN.Kev_IdleLoop'
    Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.Patriarch_Halloween'
    Skins(1)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.Patriarch.Patriarch_RedneckZombie_CMB'
}