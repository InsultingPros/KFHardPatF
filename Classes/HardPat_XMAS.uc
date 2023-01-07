//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HardPat_XMAS extends HardPat;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_XMAS_T.utx

// should be derived and used.
static simulated function PreCacheMaterials(LevelInfo myLevel)
{
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.gatling_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gatling_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.gatling_D');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.PatGungoInvisible_cmb');

    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_Santa_cmb');
    myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa_env_cmb');
    myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.patriarch_Santa_Diff');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible_gun');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_fizzle_FB');
    // myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.Patriarch_Gore_Limbs_Diff');
    // myLevel.AddPrecacheMaterial(Texture'kf_fx_trip_t.Gore.Patriarch_Gore_Limbs_Spec');
}

defaultproperties
{
    defSkins(0)=Shader'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_santa_invisible_shdr'
    defSkins(1)=Shader'KF_Specimens_Trip_T.patriarch_invisible_gun'

    sndSaveMe=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_SaveMe'
    sndKnockDown=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_KnockedDown'
    sndEntrance=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Entrance'
    sndVictory=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Victory'
    sndMGPreFire=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_WarnGun'
    sndMisslePreFire=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_WarnRocket'
    // yeah TWI didn't add these sounds...
    // sndTauntNinja=
    // sndTauntLumberJack=
    // sndTauntRadial=

    RocketFireSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_FireRocket'
    MiniGunFireSound=Sound'KF_BasePatriarch_xmas.Attack.Kev_MG_GunfireLoop'
    MiniGunSpinSound=Sound'KF_BasePatriarch_xmas.Attack.Kev_MG_TurbineFireLoop'
    MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_HitPlayer_Impale'
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_HitPlayer_Fist'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Jump'
    DetachedArmClass=class'KFChar.SeveredArmPatriarch_XMas'
    DetachedLegClass=class'KFChar.SeveredLegPatriarch_XMas'
    DetachedHeadClass=class'KFChar.SeveredHeadPatriarch_XMas'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Death'
    MenuName="Hard Santa"
    AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_IdleLoop'
    Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.SantaClause_Patriarch'
    Skins(0)=Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_Santa_cmb'
    Skins(1)=Combiner'KF_Specimens_Trip_XMAS_T.gatling_cmb'
}