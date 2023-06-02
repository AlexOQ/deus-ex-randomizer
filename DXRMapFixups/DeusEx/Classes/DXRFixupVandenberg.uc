class DXRFixupVandenberg extends DXRFixup;

var bool M14GaryNotDone;

function PreFirstEntryMapFixes()
{
    local ElevatorMover e;
    local Button1 b;
    local ComputerSecurity comp;
    local KarkianBaby kb;
    local DataLinkTrigger dlt;
    local FlagTrigger ft;
    local HowardStrong hs;
    local #var(DeusExPrefix)Mover door;
    local DXREnemies dxre;
    local #var(prefix)TracerTong tt;
    local SequenceTrigger st;
    local #var(prefix)ShopLight sl;

    switch(dxr.localURL)
    {
    case "12_VANDENBERG_CMD":
        // add goals and keypad code
        Player().StartDataLinkTransmission("DL_no_carla");
        foreach AllActors(class'#var(prefix)TracerTong', tt) {
            RemoveFears(tt);// he looks pretty sick
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(-2467,866,-2000),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(-2689,4765,-2143),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(-163,7797,-2143),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(2512,6140,-2162),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(2267,643,-2000),rotm(0,0,0),'Wandering');

        sl = #var(prefix)ShopLight(_AddActor(self, class'#var(prefix)ShopLight', vectm(1.125000, 938.399963, -1025), rotm(0, 16384, 0)));
        sl.bInvincible = true;
        sl.bCanBeBase = true;
        break;

#ifdef vanillamaps
    case "12_VANDENBERG_TUNNELS":
        foreach AllActors(class'ElevatorMover', e, 'Security_door3') {
            e.BumpType = BT_PlayerBump;
            e.BumpEvent = 'SC_Door3_opened';
        }
        AddSwitch( vectm(-396.634888, 2295, -2542.310547), rotm(0, -16384, 0), 'SC_Door3_opened').bCollideWorld = false;
        foreach AllActors(class'Button1', b) {
            if( b.Event == 'Top' || b.Event == 'middle' || b.Event == 'Bottom' ) {
                AddDelay(b, 5);
            }
        }
        break;

    case "14_VANDENBERG_SUB":
        AddSwitch( vectm(3790.639893, -488.639587, -369.964142), rotm(0, 32768, 0), 'Elevator1');
        AddSwitch( vectm(3799.953613, -446.640015, -1689.817993), rotm(0, 16384, 0), 'Elevator1');

        foreach AllActors(class'KarkianBaby',kb) {
            if(kb.BindName == "tankkarkian"){
                kb.BindName = "TankKharkian";
            }
        }
        break;

    case "14_OCEANLAB_LAB":
        if(!#defined(vmd))// button to open the door heading towards the ladder in the water
            AddSwitch( vectm(3077.360107, 497.609467, -1738.858521), rotm(0, 0, 0), 'Access');
        foreach AllActors(class'ComputerSecurity', comp) {
            if( comp.UserList[0].userName == "Kraken" && comp.UserList[0].Password == "Oceanguard" ) {
                comp.UserList[0].userName = "Oceanguard";
                comp.UserList[0].Password = "Kraken";
            }
        }

        Spawn(class'PlaceholderItem',,, vectm(37.5,531.4,-1569)); //Secretary desk
        Spawn(class'PlaceholderItem',,, vectm(2722,226.5,-1481)); //Greasel Lab desk
        Spawn(class'PlaceholderItem',,, vectm(4097.8,395.4,-1533)); //Desk with zappy electricity near construction zone
        Spawn(class'PlaceholderItem',,, vectm(4636.1,1579.3,-1741)); //Electrical box in construction zone
        Spawn(class'PlaceholderItem',,, vectm(5359.5,3122.3,-1761)); //Construction vehicle tread
        Spawn(class'PlaceholderItem',,, vectm(3114.3,3711.2,-2549)); //Storage room in crew capsule

        Spawn(class'PlaceholderContainer',,, vectm(-71,775,-1599)); //Secretary desk corner
        Spawn(class'PlaceholderContainer',,, vectm(1740,156,-1599)); //Open storage room
        Spawn(class'PlaceholderContainer',,, vectm(2999,482,-1503)); //Greasel lab
        Spawn(class'PlaceholderContainer',,, vectm(1780,3725,-2483)); //Crew module bed
        Spawn(class'PlaceholderContainer',,, vectm(1733,3848,-4223)); //Corner in hall to UC

        break;
    case "14_OCEANLAB_UC":
        //Make the datalink immediately trigger when you download the schematics, regardless of where the computer is
        foreach AllActors(class'FlagTrigger',ft){
            if (ft.name=='FlagTrigger0'){
                ft.bTrigger = True;
                ft.event = 'schematic2';
            }
        }
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.name=='DataLinkTrigger2'){
                dlt.Tag = 'schematic2';
            }
        }

        //This door can get stuck if a spiderbot gets jammed into the little bot-bay
        foreach AllActors(class'#var(DeusExPrefix)Mover', door, 'Releasebots') {
            door.MoverEncroachType=ME_IgnoreWhenEncroach;
        }

        Spawn(class'PlaceholderItem',,, vectm(1020.93,8203.4,-2864)); //Over security computer
        Spawn(class'PlaceholderItem',,, vectm(348.9,8484.63,-2913)); //Turret room
        Spawn(class'PlaceholderItem',,, vectm(1280.84,8534.17,-2913)); //Turret room
        Spawn(class'PlaceholderItem',,, vectm(1892,8754.5,-2901)); //Turret room, opposite from bait computer
        break;

    case "14_Oceanlab_silo":
        if(!dxr.flags.IsReducedRando()) {
            foreach AllActors(class'HowardStrong', hs) {
                hs.ChangeAlly('', 1, true);
                hs.ChangeAlly('mj12', 1, true);
                hs.ChangeAlly('spider', 1, true);
                RemoveFears(hs);
                hs.MinHealth = 0;
                hs.BaseAccuracy *= 0.1;
                GiveItem(hs, class'#var(prefix)BallisticArmor');
                if(!dxr.flags.IsReducedRando()) {
                    dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
                    if(dxre != None) {
                        dxre.GiveRandomWeapon(hs, false, 2);
                        dxre.GiveRandomMeleeWeapon(hs);
                    }
                    hs.FamiliarName = "Howard Stronger";
                    hs.UnfamiliarName = "Howard Stronger";
                }
                if(!#defined(vmd)) {// vmd allows AI to equip armor, so maybe he doesn't need the health boost?
                    SetPawnHealth(hs, 200);
                }
            }
        }

        //The door closing behind you when the ambush starts sucks if you came in via the silo.
        //Just make it not close.
        foreach AllActors(class'SequenceTrigger', st, 'doorclose') {
            if (st.Event=='blast_door4' && st.Tag=='doorclose'){
                st.Event = '';
                st.Tag = 'doorclosejk';
                break;
            }
        }

        class'PlaceholderEnemy'.static.Create(self,vectm(-264,-6991,-553),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(-312,-6886,327),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(270,-6601,1500),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(-1257,-3472,1468),rotm(0,0,0),'Wandering');
        class'PlaceholderEnemy'.static.Create(self,vectm(1021,-3323,1476),rotm(0,0,0),'Wandering');

        break;
    case "12_VANDENBERG_COMPUTER":
        Spawn(class'PlaceholderItem',,, vectm(579,2884,-1629)); //Table near entrance
        Spawn(class'PlaceholderItem',,, vectm(1057,2685.25,-1637)); //Table overlooking computer room
        Spawn(class'PlaceholderItem',,, vectm(1970,2883.43,-1941)); //In first floor computer room
        break;

    case "12_VANDENBERG_GAS":
        class'PlaceholderEnemy'.static.Create(self,vectm(635,488,-930),rotm(0,0,0),'Wandering');

        break;
#endif
    }
}

function PostFirstEntryMapFixes()
{
    local #var(prefix)CrateUnbreakableLarge c;
    local Actor a;

    switch(dxr.localURL) {
#ifndef revision
    case "12_VANDENBERG_CMD":
        foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16, vectm(570.835083, 1934.114014, -1646.114746)) {
            info("removing " $ c $ " dist: " $ VSize(c.Location - vectm(570.835083, 1934.114014, -1646.114746)) );
            c.Destroy();
        }
        break;

    case "14_OCEANLAB_LAB":
        // ensure rebreather before greasel lab, in case the storage closet key is in the flooded area
        a = _AddActor(Self, class'#var(prefix)Rebreather', vectm(1569, 24, -1628), rotm(0,0,0));
        a.SetPhysics(PHYS_None);
        l("PostFirstEntryMapFixes spawned "$ActorToString(a));
        break;
#endif
    }
}

function AnyEntryMapFixes()
{
    local MIB mib;
    local NanoKey key;
    local #var(prefix)HowardStrong hs;

    if(dxr.flagbase.GetBool('schematic_downloaded') && !dxr.flagbase.GetBool('DL_downloaded_Played')) {
        dxr.flagbase.SetBool('DL_downloaded_Played', true);
    }

    switch(dxr.localURL)
    {
    case "12_Vandenberg_gas":
        foreach AllActors(class'MIB', mib, 'mib_garage') {
            key = NanoKey(mib.FindInventoryType(class'NanoKey'));
            l(mib$" has key "$key$", "$key.KeyID$", "$key.Description);
            if(key == None) continue;
            if(key.KeyID != '') continue;
            l("fixing "$key$" to garage_entrance");
            key.KeyID = 'garage_entrance';
            key.Description = "Garage Door";
            key.Timer();// make sure to fix the ItemName in vanilla
        }
        break;

    case "14_VANDENBERG_SUB":
        FixSavageSkillPointsDupe();
        break;

    case "14_OCEANLAB_SILO":
        foreach AllActors(class'#var(prefix)HowardStrong', hs) {
            hs.ChangeAlly('', 1, true);
            hs.ChangeAlly('mj12', 1, true);
            hs.ChangeAlly('spider', 1, true);
            RemoveFears(hs);
            hs.MinHealth = 0;
        }
        Player().StartDataLinkTransmission("DL_FrontGate");
        break;
    }
}

function FixSavageSkillPointsDupe()
{
    local Conversation c;
    local ConEventAddSkillPoints sk;
    local ConEvent e, prev, next;

    c = GetConversation('GaryWaitingForSchematics');
    if(c==None) return;
    for(e = c.eventList; e != None; e=next) {
        next = e.nextEvent;// keep this when we delete e
        sk = ConEventAddSkillPoints(e);
        if(sk != None) {
            FixConversationDeleteEvent(sk, prev);
        }
        else {
            prev = e;
        }
    }

    if(!dxr.flagbase.GetBool('M14GaryDone')) {
        M14GaryNotDone = true;
        SetTimer(1, true);
    }
}

function TimerMapFixes()
{
    if(M14GaryNotDone && dxr.flagbase.GetBool('M14GaryDone')) {
        M14GaryNotDone = false;
        player().SkillPointsAdd(500);
    }
}
