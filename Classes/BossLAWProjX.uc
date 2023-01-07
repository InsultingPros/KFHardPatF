// Modified pat rocket
// Author        : NikC-
// Home Repo     : https://github.com/InsultingPros/KFHardPatF
// License       : https://www.gnu.org/licenses/gpl-3.0.en.html
class BossLAWProjX extends BossLAWProj;

#exec obj load file="KF_LAWSnd.uax"
#exec obj load file="KillingFloorStatics.usx"

static function PreloadAssets();
static function bool UnloadAssets()
{
    return true;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    // Don't let it hit this player, or blow up on another player
    if (Other == none || Other == Instigator || Other.Base == Instigator
        || KFBulletWhipAttachment(Other) != none
        || ExtendedZCollision(Other)!=none || Monster(Other) != none)
        return;

    Explode(HitLocation, Normal(HitLocation - Other.Location));
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex);

simulated function HitWall(vector HitNormal, actor Wall)
{
    super(Projectile).HitWall(HitNormal, Wall);
}

defaultproperties
{
	ExplosionSound=SoundGroup'KF_LAWSnd.Rocket_Explode'
	StaticMesh=StaticMesh'KillingFloorStatics.LAWRocket'
	AmbientSound=Sound'KF_LAWSnd.Rocket_Propel'
}