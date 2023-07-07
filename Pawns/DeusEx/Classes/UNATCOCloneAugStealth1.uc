//=============================================================================
// UNATCOCloneAugStealth1.
//=============================================================================
class UNATCOCloneAugStealth1 extends UNATCOClone2;

var bool nametag;

function BeginPlay()
{
	Super.BeginPlay();

    //Random chance of switching body texture and switching to UNATCOCloneAugStealth1NametagCarcass
    if (Rand(100) < 5){
        nametag=True;
        GiveNametag();
    }

    SetTimer(2.0,True);
}

function Carcass SpawnCarcass()
{
    ResetSkinStyle();
    if (bStunned)
        return Super.SpawnCarcass();

    Explode();
    return None;
}

function GiveNametag()
{
    MultiSkins[2]=Texture'UNATCOCloneAugStealth1BodyNametag';
    CarcassType=Class'UNATCOCloneAugStealth1NametagCarcass';
}

function ResetSkinStyle()
{
    Super.ResetSkinStyle();
    if (nametag){
        GiveNametag();
    }
}

function Explode(optional vector HitLocation) // argument for compatibility with Revision and VMD
{
    local SphereEffect sphere;
    local ScorchMark s;
    local ExplosionLight light;
    local int i;
    local float explosionDamage;
    local float explosionRadius;

#ifdef revision
    Super.Explode();
    return;
#elseif vmd
    Super.Explode();
    return;
#endif

    explosionDamage = 100;
    explosionRadius = 256;

    // alert NPCs that I'm exploding
    AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
    PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

    // draw a pretty explosion
    light = Spawn(class'ExplosionLight',,, Location);
    if (light != None)
        light.size = 4;

    Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
    Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

    sphere = Spawn(class'SphereEffect',,, Location);
    if (sphere != None)
        sphere.size = explosionRadius / 32.0;

    // spawn a mark
    s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
    if (s != None)
    {
        s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
        s.ReattachDecal();
    }

    // spawn some rocks and flesh fragments
    for (i=0; i<explosionDamage/6; i++)
    {
        if (FRand() < 0.3)
            spawn(class'Rockchip',,,Location);
        else
            spawn(class'FleshFragment',,,Location);
    }

    HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}

function EnableCloak(bool bEnable)  // beware! called from C++
{
	if (!bHasCloak || (CloakEMPTimer > 0) || (Health <= 0) || bOnFire)
		bEnable = false;

	if (bEnable && !bCloakOn)
	{
		SetSkinStyle(STY_Translucent, Texture'WhiteStatic', -0.4); //-0.4 seems to actually be pretty stealthy
		KillShadow();
		bCloakOn = bEnable;
	}
	else if (!bEnable && bCloakOn)
	{
		ResetSkinStyle();
		CreateShadow();
		bCloakOn = bEnable;
	}
}

function bool ShouldBeCloaked()
{
    switch(GetStateName()){
        case 'Seeking':
        case 'Alerting':
        case 'Attacking':
        case 'Fleeing':
            return True;
            break;
        default:
            return False;
            break;
    }
    return False;
}

function Timer()
{
    local bool cloak;
    //Kludge to force our own cloak logic while keeping the performance (I guess) of the native C++ code

    cloak=ShouldBeCloaked();

    bHasCloak=cloak;
    EnableCloak(cloak);  //Needed to disable cloak again afterwards
}

defaultproperties
{
    bHasCloak=False
    CloakThreshold=9999;

    CarcassType=Class'DeusEx.UNATCOCloneAugStealth1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'UNATCOCloneAugStealth1Head'
    MultiSkins(1)=Texture'UNATCOCloneAugStealth1Legs'
    MultiSkins(2)=Texture'UNATCOCloneAugStealth1Body'
    MultiSkins(3)=Texture'UNATCOCloneAugStealth1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'UNATCOCloneAugStealth1Helmet'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="Augmented UNATCO Troop"
    UnfamiliarName="Augmented UNATCO Troop"
}