class DXRReduceItems extends DXRActorsBase;

struct sReduceAmmo {
    var string type;
    var int percent;
};
struct sReduceItem {
    var string type;
    var int percent;
};
struct sSetMax {
    var string type;
    var int percent;
};
struct sMaxAmmo {
    var string type;
    var int percent;
};

var config int mission_scaling[16];
var config sReduceAmmo ammo_reductions[16];
var config sReduceItem reduce_items[16];
var config sSetMax max_copies[16];
var config sMaxAmmo max_ammo[16];

var config float min_rate_adjust, max_rate_adjust;

function CheckConfig()
{
    local int i;
    if( config_version < class'DXRFlags'.static.VersionToInt(1,5,6) ) {
        min_rate_adjust = default.min_rate_adjust;
        max_rate_adjust = default.max_rate_adjust;

        for(i=0; i < ArrayCount(mission_scaling); i++) {
            mission_scaling[i] = 100;
        }
        for(i=0; i < ArrayCount(ammo_reductions); i++) {
            ammo_reductions[i].type = "";
        }
        for(i=0; i < ArrayCount(reduce_items); i++) {
            reduce_items[i].type = "";
        }
        for(i=0; i < ArrayCount(max_copies); i++) {
            max_copies[i].type = "";
        }
        for(i=0; i < ArrayCount(max_ammo); i++) {
            max_ammo[i].type = "";
        }
    }
    Super.CheckConfig();
}

function PostFirstEntry()
{
    local int i, mission, scale;
    local class<Actor> c;
    Super.PostFirstEntry();

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];

    ReduceAmmo(class'Ammo', float(dxr.flags.ammo*scale)/100.0/100.0);

    ReduceSpawns(class'Multitool', dxr.flags.multitools*scale/100);
    ReduceSpawns(class'Lockpick', dxr.flags.lockpicks*scale/100);
    ReduceSpawns(class'BioelectricCell', dxr.flags.biocells*scale/100);
    ReduceSpawns(class'MedKit', dxr.flags.medkits*scale/100);

    for(i=0; i < ArrayCount(ammo_reductions); i++) {
        if( ammo_reductions[i].type == "" ) continue;
        c = GetClassFromString( ammo_reductions[i].type, class'Ammo' );
        ReduceAmmo(class<Ammo>(c), float(ammo_reductions[i].percent*scale)/100.0/100.0 );
    }
    for(i=0; i < ArrayCount(reduce_items); i++) {
        if( reduce_items[i].type == "" ) continue;
        c = GetClassFromString( reduce_items[i].type, class'Actor' );
        ReduceSpawns(c, reduce_items[i].percent*scale/100 );
    }
    SetAllMaxCopies(scale);
    SetTimer(1.0, true);
}

function Timer()
{
    local int mission, scale;
    Super.Timer();
    if( dxr == None ) return;

    mission = Clamp(dxr.dxInfo.missionNumber, 0, ArrayCount(mission_scaling)-1);
    scale = mission_scaling[mission];
    SetAllMaxCopies(scale);
}

function SetAllMaxCopies(int scale)
{
    local int i;
    local class<Actor> c;
    if( dxr == None ) return;
    SetMaxAmmo( class'Ammo', dxr.flags.ammo*scale/100 );

    SetMaxCopies(class'FireExtinguisher', 125);// just make sure to apply the enviro skill, HACK: 125% to counteract the normal 80%
    SetMaxCopies(class'Multitool', dxr.flags.multitools*scale/100 );
    SetMaxCopies(class'Lockpick', dxr.flags.lockpicks*scale/100 );
    SetMaxCopies(class'BioelectricCell', dxr.flags.biocells*scale/100 );
    SetMaxCopies(class'MedKit', dxr.flags.medkits*scale/100 );

    for(i=0; i < ArrayCount(max_copies); i++) {
        if( max_copies[i].type == "" ) continue;
        c = GetClassFromString( max_copies[i].type, class'DeusExPickup' );
        SetMaxCopies( class<DeusExPickup>(c), max_copies[i].percent*scale/100 );
    }
    for(i=0; i < ArrayCount(max_ammo); i++) {
        if( max_ammo[i].type == "" ) continue;
        c = GetClassFromString( max_ammo[i].type, class'Ammo' );
        SetMaxAmmo( class<Ammo>(c), max_ammo[i].percent*scale/100 );
    }
}

function ReduceAmmo(class<Ammo> type, float mult)
{
    local Weapon w;
    local Ammo a;
    local int i;
    local float tmult;

    l("ReduceAmmo "$mult);
    SetSeed( "ReduceAmmo" );

    foreach AllActors(class'Weapon', w)
    {
        if( w.AmmoName != type && ClassIsChildOf(w.AmmoName, type) == false ) continue;
        if( w.PickupAmmoCount > 0 ) {
            tmult = rngrangeseeded(mult, min_rate_adjust, max_rate_adjust, w.AmmoName);
            i = Clamp(float(w.PickupAmmoCount) * tmult, 1, 1000);
            l("reducing ammo in "$ActorToString(w)$" from "$w.PickupAmmoCount$" down to "$i$", tmult: "$tmult);
            w.PickupAmmoCount = i;
        }
    }

    foreach AllActors(class'Ammo', a)
    {
        if( ! a.IsA(type.name) ) continue;
        if( a.AmmoAmount > 0 && ( ! CarriedItem(a) ) ) {
            tmult = rngrangeseeded(mult, min_rate_adjust, max_rate_adjust, a.class.name);
            i = Clamp(float(a.AmmoAmount) * tmult, 1, 1000);
            l("reducing ammo in "$ActorToString(a)$" from "$a.AmmoAmount$" down to "$i$", tmult: "$tmult);
            a.AmmoAmount = i;
        }
    }

    ReduceSpawnsInContainers(type, mult*100.0 );
}

function ReduceSpawns(class<Actor> classname, float percent)
{
    local Actor a;
    local float tperc;

    SetSeed( "ReduceSpawns " $ classname );

    foreach AllActors(class'Actor', a)
    {
        //if( SkipActor(a, classname.name) ) continue;
        if( a == dxr.Player ) continue;
        if( a.Owner == dxr.Player ) continue;
        if( ! a.IsA(classname.name) ) continue;

        tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, a.class.name);
        if( !chance_single(tperc) )
        {
            l("destroying "$ActorToString(a)$", tperc: "$tperc);
            DestroyActor( a );
        }
    }

    ReduceSpawnsInContainers(classname, percent);
}

function ReduceSpawnsInContainers(class<Actor> classname, float percent)
{
    local Containers d;
    local float tperc;

    SetSeed( "ReduceSpawnsInContainers " $ classname.Name );

    foreach AllActors(class'Containers', d)
    {
        if( ClassIsChildOf( d.Content3, classname) ) {
            tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, d.Content3.name);
            if( !chance_single(tperc) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing content3 "$d.Content3$", tperc: "$tperc);
                d.Content3 = None;
            }
        }
        if( ClassIsChildOf( d.Content2, classname) ) {
            tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, d.Content2.name);
            if( !chance_single(tperc) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing content2 "$d.Content2$", tperc: "$tperc);
                d.Content2 = d.Content3;
            }
        }
        if( ClassIsChildOf( d.Contents, classname) ) {
            tperc = rngrangeseeded(percent, min_rate_adjust, max_rate_adjust, d.Contents.name);
            if( !chance_single(tperc) ) {
                l("ReduceSpawnsInContainers container "$ActorToString(d)$" removing contents "$d.Contents$", tperc: "$tperc);
                d.Contents = d.Content2;
            }
        }
    }
}

function SetMaxCopies(class<DeusExPickup> type, int percent)
{
    local DeusExPickup p;
    local int enviro_add;

    if( ClassIsChildOf(class'FireExtinguisher', type) )
        enviro_add = dxr.Player.SkillSystem.GetSkillLevel(class'SkillEnviro');

    foreach AllActors(class'DeusExPickup', p) {
        if( ! p.IsA(type.name) ) continue;
        p.maxCopies = float(p.default.maxCopies) * float(percent) / 100.0 * 0.8;
        if( FireExtinguisher(p) != None )
            p.maxCopies += enviro_add;

        if( p.NumCopies > p.maxCopies ) p.NumCopies = p.maxCopies;
    }
}

function SetMaxAmmo(class<Ammo> type, int percent)
{
    local Ammo a;
    local int demo_add;

    demo_add = dxr.Player.SkillSystem.GetSkillLevel(class'SkillDemolition');

    foreach AllActors(class'Ammo', a) {
        if( ! a.IsA(type.name) ) continue;
        a.MaxAmmo = float(a.default.MaxAmmo) * float(percent) / 100.0 * 0.8;
        if( AmmoEMPGrenade(a) != None || AmmoGasGrenade(a) != None || AmmoLAM(a) != None || AmmoNanoVirusGrenade(a) != None )
            a.MaxAmmo += demo_add;
        
        if( a.AmmoAmount > a.MaxAmmo ) a.AmmoAmount = a.MaxAmmo;
    }
}

defaultproperties
{
    bAlwaysTick=True
    min_rate_adjust=0.5
    max_rate_adjust=1.5
}
