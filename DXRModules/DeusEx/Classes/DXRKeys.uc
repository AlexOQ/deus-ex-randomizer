class DXRKeys extends DXRActorsBase transient;

var config safe_rule keys_rules[64];

function CheckConfig()
{
    local int i;
    if( ConfigOlderThan(2,5,2,4) ) {
        for(i=0; i<ArrayCount(keys_rules); i++) {
            keys_rules[i].map = "";
        }
#ifdef revision
        revision_keys_rules();
#else
        vanilla_keys_rules();
#endif
    }
    for(i=0; i<ArrayCount(keys_rules); i++) {
        keys_rules[i].map = Caps(keys_rules[i].map);
    }
    Super.CheckConfig();
}

function vanilla_keys_rules()
{
    local int i;

    keys_rules[i].map = "01_NYC_UNATCOISLAND";
    keys_rules[i].item_name = 'UNhatchdoor';
    keys_rules[i].min_pos = vect(-999999, -999999, -999999);
    keys_rules[i].max_pos = vect(999999, 999999, 999999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "03_NYC_AIRFIELD";
    keys_rules[i].item_name = 'eastgate';
    keys_rules[i].min_pos = vect(1915, 2332, -999999);
    keys_rules[i].max_pos = vect(5579, 4031, 999999);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "03_NYC_AIRFIELD";
    keys_rules[i].item_name = 'eastgate';
    keys_rules[i].min_pos = vect(-999999, -999999, -999999);
    keys_rules[i].max_pos = vect(999999, 999999, 999999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "03_NYC_747";
    keys_rules[i].item_name = 'lebedevdoor';
    keys_rules[i].min_pos = vect(570, -312, 153);//ban the annoying spot behind the crates
    keys_rules[i].max_pos = vect(602, -280, 185);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "03_NYC_747";
    keys_rules[i].item_name = 'lebedevdoor';
    keys_rules[i].min_pos = vect(166, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    // in DXRFixup we spawn an extra one anyways
    keys_rules[i].map = "06_HONGKONG_WANCHAI_STREET";
    keys_rules[i].item_name = 'JocksKey';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "06_HONGKONG_STORAGE";
    keys_rules[i].item_name = 'NanoContainmentDoor';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "10_Paris_Chateau";
    keys_rules[i].item_name = 'duclare_chateau';
    keys_rules[i].min_pos = vect(-99999, -99999, -125);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "11_Paris_Cathedral";
    keys_rules[i].item_name = 'cath_maindoors';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "11_Paris_Cathedral";
    keys_rules[i].item_name = 'cathedralgatekey';
    keys_rules[i].min_pos = vect(-4907, 1802, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    //disallow this weird locked room under water
    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'control_room';
    keys_rules[i].min_pos = vect(-3521.955078, 3413.110352, -3246.771729);
    keys_rules[i].max_pos = vect(-2844.053467, 3756.776855, -3097.210205);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'maintenancekey';
    keys_rules[i].min_pos = vect(-3521.955078, 3413.110352, -3246.771729);
    keys_rules[i].max_pos = vect(-2844.053467, 3756.776855, -3097.210205);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'control_room';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'maintenancekey';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    //This key is added in DXRFixupVandenberg
    //Allow anywhere from the Hazard Lab to the front guardhouse
    keys_rules[i].map = "12_VANDENBERG_CMD";
    keys_rules[i].item_name = 'TimsClosetKey';
    keys_rules[i].min_pos = vect(-2398.429688,2211.012695,-99999);
    keys_rules[i].max_pos = vect(7217.410156,8535.856445,99999);
    keys_rules[i].allow = true;
    i++;


    //disallow the crew quarters
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'crewkey';
    keys_rules[i].min_pos = vect(-99999, 3034, -99999);
    keys_rules[i].max_pos = vect(3633, 99999, 99999);
    keys_rules[i].allow = false;
    i++;

    //disallow west (smaller X) of the flooded area
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'crewkey';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(-414.152771, 99999, 99999);
    keys_rules[i].allow = false;
    i++;

    //allow anything to the west (smaller X) of the crew quarters, except for the flooded area
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'crewkey';
    keys_rules[i].min_pos = vect(-414.152771, -99999, -99999);
    keys_rules[i].max_pos = vect(4856, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    //disallow flooded area
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'storage';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(-414.152771, 99999, 99999);
    keys_rules[i].allow = false;
    i++;

    //disallow flooded area
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'Glab';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(-414.152771, 99999, 99999);
    keys_rules[i].allow = false;
    i++;

    //disallow storage closet
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'storage';
    keys_rules[i].min_pos = vect(528.007446, -99999, -1653.906006);
    keys_rules[i].max_pos = vect(1047.852173, 436.867401, 99999);
    keys_rules[i].allow = false;
    i++;

    //disallow below storage
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'Glab';
    keys_rules[i].min_pos = vect(500, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, -1644.895142);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'storage';
    keys_rules[i].min_pos = vect(500, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, -1644.895142);
    keys_rules[i].allow = false;
    i++;

    //disallow east of greasel lab door
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'Glab';
    keys_rules[i].min_pos = vect(1879, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'storage';
    keys_rules[i].min_pos = vect(1879, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = false;
    i++;

    //allow before greasel lab
    keys_rules[i].map = "14_oceanlab_lab";
    keys_rules[i].item_name = 'storage';
    keys_rules[i].min_pos = vect(-414.152771, -99999, -99999);
    keys_rules[i].max_pos = vect(1888, 1930.014771, 99999);
    keys_rules[i].allow = true;
    i++;
    // X < -414.152771 == flooded area...
    // X > 528.007446, X < 1047.852173, Y < 436.867401, Z > -1653.906006 == storage closet
    // 1888.000000, 544.000000, -1536.000000 == glabs door, X > -414.152771 && X < 1888 && Y < 1930.014771 == before greasel labs
    // 4856.000000, 3515.999512, -1816.000000 == crew quarters door

    keys_rules[i].map = "15_area51_entrance";
    keys_rules[i].item_name = 'Factory';
    keys_rules[i].min_pos = vect(-816, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;
}

function revision_keys_rules()
{
    local int i;

    keys_rules[i].map = "01_NYC_UNATCOISLAND";
    keys_rules[i].item_name = 'UNhatchdoor';
    keys_rules[i].min_pos = vect(-999999, -999999, -999999);
    keys_rules[i].max_pos = vect(999999, 999999, 999999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "03_NYC_AIRFIELD";
    keys_rules[i].item_name = 'eastgate';
    keys_rules[i].min_pos = vect(1915, 2332, -999999);
    keys_rules[i].max_pos = vect(5579, 4031, 999999);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "03_NYC_AIRFIELD";
    keys_rules[i].item_name = 'eastgate';
    keys_rules[i].min_pos = vect(-999999, -999999, -999999);
    keys_rules[i].max_pos = vect(999999, 999999, 999999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "03_NYC_747";
    keys_rules[i].item_name = 'lebedevdoor';
    keys_rules[i].min_pos = vect(340, -312, 140);//ban the annoying spot behind the crates
    keys_rules[i].max_pos = vect(380, -280, 185);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "03_NYC_747";
    keys_rules[i].item_name = 'lebedevdoor';
    keys_rules[i].min_pos = vect(166, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    // in DXRFixup we spawn an extra one anyways
    keys_rules[i].map = "06_HONGKONG_WANCHAI_STREET";
    keys_rules[i].item_name = 'JocksKey';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "10_Paris_Chateau";
    keys_rules[i].item_name = 'duclare_chateau';
    keys_rules[i].min_pos = vect(-99999, -99999, -125);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "11_Paris_Cathedral";
    keys_rules[i].item_name = 'cath_maindoors';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "11_Paris_Cathedral";
    keys_rules[i].item_name = 'cathedralgatekey';
    keys_rules[i].min_pos = vect(-99999, -2664, -99999);
    keys_rules[i].max_pos = vect(-3614, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "11_Paris_Cathedral";
    keys_rules[i].item_name = 'cathedralgatekey';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = false;
    i++;

    //disallow this weird locked room under water
    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'control_room';
    keys_rules[i].min_pos = vect(-3521.955078, 3413.110352, -3246.771729);
    keys_rules[i].max_pos = vect(-2844.053467, 3756.776855, -3097.210205);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'maintenancekey';
    keys_rules[i].min_pos = vect(-3521.955078, 3413.110352, -3246.771729);
    keys_rules[i].max_pos = vect(-2844.053467, 3756.776855, -3097.210205);
    keys_rules[i].allow = false;
    i++;

    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'control_room';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "12_Vandenberg_Tunnels";
    keys_rules[i].item_name = 'maintenancekey';
    keys_rules[i].min_pos = vect(-99999, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "15_area51_entrance";
    keys_rules[i].item_name = 'Factory';
    keys_rules[i].min_pos = vect(-3000, -99999, -99999);
    keys_rules[i].max_pos = vect(99999, 99999, 99999);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "15_Area51_Page";
    keys_rules[i].item_name = 'exit_doors';
    keys_rules[i].min_pos = vect(-605.78,1140.87,212.5);
    keys_rules[i].max_pos = vect(2059.9,-1583.3,313);
    keys_rules[i].allow = true;
    i++;

    keys_rules[i].map = "15_Area51_Page";
    keys_rules[i].item_name = 'exit_doors';
    keys_rules[i].min_pos = vect(-192,-1810,202);
    keys_rules[i].max_pos = vect(-2392.5,22.78,350);
    keys_rules[i].allow = true;
    i++;
}

function FirstEntry()
{
    local int i;
    Super.FirstEntry();

    for(i=0; i<ArrayCount(keys_rules); i++) {
        // do these without writing them to the config
        keys_rules[i].min_pos *= coords_mult;
        keys_rules[i].max_pos *= coords_mult;
    }

    if( dxr.flags.settings.keysrando == 4 || dxr.flags.settings.keysrando == 2 ) // 1 is dumb aka anywhere, 3 is copies instead of smart positioning? 5 would be something more advanced?
        MoveNanoKeys4();
}

function RandoKey(#var(prefix)NanoKey k)
{
    local int oldseed;
    if( dxr.flags.settings.keysrando == 4 || dxr.flags.settings.keysrando == 2 ) {
        oldseed = SetSeed( "RandoKey " $ k.Name );
        _RandoKey(k, dxr.flags.settings.keys_containers > 0);
        dxr.SetSeed(oldseed);
    }
}

function MoveNanoKeys4()
{
    local #var(DeusExPrefix)Carcass carc;
    local #var(prefix)NanoKey k;

    SetSeed( "MoveNanoKeys4" );

#ifdef injections
    foreach AllActors(class'#var(DeusExPrefix)Carcass', carc) {
        carc.DropKeys();
    }
#endif

    foreach AllActors(class'#var(prefix)NanoKey', k )
    {
        if(!k.bHidden)
            GlowUp(k);
        if ( SkipActorBase(k) ) continue;
        _RandoKey(k, dxr.flags.settings.keys_containers > 0);
    }
}

function _RandoKey(#var(prefix)NanoKey k, bool containers)
{
    local Actor temp[1024];
    local Inventory a;
    local Containers c;
    local int num, slot, tries;

#ifndef injections
    k.ItemName = k.default.ItemName $ " (" $ k.Description $ ")";
    SetActorScale(k, 1.3);
#endif

    num=0;
    foreach AllActors(class'Inventory', a)
    {
        if( a == k ) continue;
        if( SkipActor(a) ) continue;
        if( KeyPositionGood(k, a.Location) == False ) continue;
#ifdef debug
        /*if(k.KeyID=='eastgate') {
            DebugMarkKeyPosition(a, k.KeyID);
            continue;
        }*/
#endif
        temp[num++] = a;
    }

    if(containers) {
        foreach AllActors(class'Containers', c)
        {
            if( SkipActor(c) ) continue;
            if( KeyPositionGood(k, c.Location) == False ) continue;
            if( HasBased(c) ) continue;
#ifdef debug
            /*if(k.KeyID=='eastgate') {
                DebugMarkKeyPosition(c, k.KeyID);
                continue;
            }*/
#endif
            temp[num++] = c;
        }
    }

    for(tries=0; tries<5; tries++) {
        slot=rng(num+1);// +1 for vanilla
        if(slot==0) {
            info("not swapping key "$k.KeyID$", num: "$num);
            break;
        }
        slot--;
        info("key "$k.KeyID$" got num: "$num$", slot: "$slot$", actor: "$temp[slot] $" ("$temp[slot].Location$")");
        // Swap argument A is more lenient with collision than argument B
        if( Swap(temp[slot], k) ) break;
    }
}

function bool KeyPositionGood(#var(prefix)NanoKey k, vector newpos)
{
    local #var(DeusExPrefix)Mover d;
    local float dist;
    local int i;

    i = GetSafeRule( keys_rules, k.KeyID, newpos);
    if( i != -1 ) return keys_rules[i].allow;

    dist = VSize( k.Location - newpos );
    if( dist > 5000 ) return False;

    foreach AllActors(class'#var(DeusExPrefix)Mover', d)
    {
        if( d.KeyIDNeeded == 'None' ) continue;
        else if( d.KeyIDNeeded != k.KeyID )
        {
            //if( PositionIsSafeLenient(k.Location, d, newpos) == False ) return False;
        }
        else if( PositionIsSafe(k.Location, d, newpos) == False ) return False;
    }
    //l("KeyPositionGood ("$ActorToString(k)$", "$newpos$") returning True with distance: "$dist);
    return True;
}

function RunTests()
{
    Super.RunTests();

    //1d tests
    testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(0.2,0,0)), true, "1d test" );

    testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(2,0,0)), true, "1d test" );
    testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(-2,0,0)), false, "1d test" );

    testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(0,0,0)), false, "1d test" );
    testbool( _PositionIsSafeOctant(vect(1,0,0), vect(0,0,0), vect(-0.001,0,0)), false, "1d test" );

    testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(0,0,0)), false, "1d test" );
    testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(-0.001,0,0)), false, "1d test" );

    testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(0.01,0,0)), true, "1d test" );
    testbool( _PositionIsSafeOctant(vect(0.1,0,0), vect(0,0,0), vect(0.011,0,0)), true, "1d test" );

    testbool( _PositionIsSafeOctant(vect(1,0,0), vect(4,0,0), vect(2,0,0)), true, "1d test" );
    testbool( _PositionIsSafeOctant(vect(-1,0,0), vect(4,0,0), vect(-2,0,0)), true, "1d test" );

    //2d tests
    testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(0,0,0)), true, "2d test" );
    testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(-90,0,0)), false, "2d test" );
    testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(0,-90,0)), false, "2d test" );
    testbool( _PositionIsSafeOctant(vect(-5,-5,0), vect(-10,-10,0), vect(-11,-11,0)), false, "2d test" );

    //3d tests
    testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(1,-3,1000)), true, "3d test" );
    testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(10.5,-0.8,100)), true, "3d test" );
    testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(10.5,-0.6,100)), true, "3d test" );
    testbool( _PositionIsSafeOctant(vect(1,-5,2), vect(0,0,0), vect(0.1,-0.1,10000)), true, "3d test" );

    //real numbers from 10_Paris_Chateau
    testbool( _PositionIsSafeOctant(vect(1299.113892,791.412354,435.917358), vect(1376.000000,1100.000000,-192.000000), vect(1254.237061,774.329773,422.100922)), true, "Chateau test");
    testbool( _PositionIsSafeOctant(vect(1299.113892,791.412354,435.917358), vect(1376.000000,1100.000000,-192.000000), vect(1297.832275,777.074097,436.520996)), true, "Chateau test");
    testbool( _PositionIsSafeOctant(vect(1299.113892,791.412354,435.917358), vect(1376.000000,1100.000000,-192.000000), vect(1442.119873,3275.193359,-526.853638)), false, "Chateau test");

    //real numbers from OceanLab
    testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(1590.162842,269.466125,-1578.974854)), false, "OceanLab test" );
    testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(-2588.39917,-5.10672,-1793.654907)), true, "OceanLab test" );
    testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(3037.546875,2127.136963,-1791.484619)), true, "OceanLab test" );
    testbool( _PositionIsSafeOctant(vect(3013.000732,2131.418213,-1792.079956), vect(4824,3528,-1752), vect(-2618.925049,-122.853104,-1833.302734)), true, "OceanLab test" );

    testbool( _PositionIsSafeOctant(vect(-2588.39917,-5.10672,-1794.256958), vect(1048,80,-1544), vect(785.475647,-79.326523,-1601.681763)), true, "OceanLab test" );
    testbool( _PositionIsSafeOctant(vect(1237.800659,112.333527,-1625.307007), vect(1880.000000,552.000000,-1544.000000), vect(-2620.478516,-19.642990,-1795.483643)), true, "OceanLab test" );
}

function ExtendedTests()
{
    local string oldurl;

    Super.ExtendedTests();

    oldurl = dxr.localURL;
    dxr.localURL = Caps("14_oceanlab_lab");

    TestKeyRules( 'Glab', false, vect(1964.752808, 3191.954834, -2537.410400), "crew area" );
    TestKeyRules( 'Glab', false, vect(-2535.691162, 234.638947, -1833.254883), "far flooded area" );
    TestKeyRules( 'Glab', false, vect(4225.205078, 407.563324, -1540.875000), "electricity room" );
    TestKeyRules( 'Glab', false, vect(1557.180542, 350.402100, -1809.903687), "below storage room" );
    TestKeyRules( 'Glab', true, vect(207.516022, 527.347168, -1575.402710), "gun turret room before storage" );
    TestKeyRules( 'Glab', true, vect(1237.800659, 112.333527, -1616.783936), "hallway before storage" );
    TestKeyRules( 'Glab', true, vect(1657.591064, -30.407259, -1630.926147), "unlocked storage room" );
    TestKeyRules( 'Glab', true, vect(785.475647, -79.326523, -1601.681763), "locked storage room" );

    TestKeyRules( 'storage', false, vect(1964.752808, 3191.954834, -2537.410400), "crew area" );
    TestKeyRules( 'storage', false, vect(-2535.691162, 234.638947, -1833.254883), "far flooded area" );
    TestKeyRules( 'storage', false, vect(4225.205078, 407.563324, -1540.875000), "electricity room" );
    TestKeyRules( 'storage', false, vect(1557.180542, 350.402100, -1809.903687), "below storage room" );
    TestKeyRules( 'storage', true, vect(207.516022, 527.347168, -1575.402710), "gun turret room before storage" );
    TestKeyRules( 'storage', true, vect(1237.800659, 112.333527, -1616.783936), "hallway before storage" );
    TestKeyRules( 'storage', true, vect(1657.591064, -30.407259, -1630.926147), "unlocked storage room" );
    TestKeyRules( 'storage', false, vect(785.475647, -79.326523, -1601.681763), "locked storage room" );

    dxr.localURL = oldurl;
}

function TestKeyRules(Name KeyID, bool allowed, vector loc, string description)
{
    local int i;
    description = "key: " $ KeyID $ ", expected allowed: "$allowed$", " $ description $ " ("$loc$")";
    i = GetSafeRule( keys_rules, KeyID, loc );
    if( allowed && i == -1 ) {
        test( true, "without key rule - " $ description );
        return;
    }
    test( i >= 0, "found key rule - " $ description );
    testbool( keys_rules[i].allow, allowed, description );
}
