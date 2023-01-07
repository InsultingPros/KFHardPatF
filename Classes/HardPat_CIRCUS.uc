// Circus variant
// Author        : NikC-
// Home Repo     : https://github.com/InsultingPros/KFHardPatF
// License       : https://www.gnu.org/licenses/gpl-3.0.en.html
class HardPat_CIRCUS extends HardPat;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax

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
    // same as default pat
    // defSkins(0)=
    // defSkins(1)=

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