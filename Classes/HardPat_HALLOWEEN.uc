//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HardPat_HALLOWEEN extends HardPat;


#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax


defaultproperties
{
    defSkins(0)=Shader'KF_Specimens_Trip_T.patriarch_invisible_gun'
    defSkins(1)=Shader'KF_Specimens_Trip_HALLOWEEN_T.Patriarch.Patriarch_Halloween_Invisible'

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