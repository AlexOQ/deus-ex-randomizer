class DXRFixupM15 extends DXRFixup;

var int storedReactorCount;// Area 51 goal

function CheckConfig()
{
    local int i;

#ifdef vanillamaps
    add_datacubes[i].map = "15_AREA51_BUNKER";
    add_datacubes[i].text = "Security Personnel:|nDue to the the threat of a mass civilian raid of Area 51, we have updated the ventilation security system.|n|nUser: SECURITY |nPassword: NarutoRun |n|nBe on the lookout for civilians running with their arms swept behind their backs...";
    i++;

    add_datacubes[i].map = "15_AREA51_BUNKER";
    add_datacubes[i].text = "Security Personnel:|nFor increased ventilation system security, we have replaced the elevator button with a keypad.  The code is 17092019.  Do not share the code with anyone and destroy this datacube after reading.";
    i++;
#endif

    add_datacubes[i].map = "15_AREA51_ENTRANCE";
    add_datacubes[i].text =
        "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
        $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
        $ "  The code is 6786.  I love you."
        $ "|n|nJustin";
    i++;

    add_datacubes[i].map = "15_AREA51_ENTRANCE";
    add_datacubes[i].text =
        "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
        $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
        $ "  The code is 3901.  I love you."
        $ "|n|nJohn";
    i++;

    add_datacubes[i].map = "15_AREA51_ENTRANCE";
    add_datacubes[i].text =
        "Julia, I must see you -- we have to talk, about us, about this project.  I'm not sure what we're doing here anymore and Page has made... strange requests of the interface team."
        $ "  I would leave, but not without you.  You mean too much to me.  After the duty shift changes, come to my chamber -- it's the only place we can talk in private."
        $ "  The code is 4322.  I love you."
        $ "|n|nJim";
    i++;

    add_datacubes[i].map = "15_AREA51_PAGE";
    add_datacubes[i].text =
        "The security guys found my last datacube so they changed the UC Control Rooms code to 1234. I don't know what they're so worried about, no one could make it this far into Area 51. What's the worst that could happen?";
    i++;

    add_datacubes[i].map = "15_AREA51_PAGE";
    add_datacubes[i].text =
        "The security guys found my last datacube so they changed the Aquinas Router code to 6188. I don't know what they're so worried about, no one could make it this far into Area 51. What's the worst that could happen?";
    i++;

    Super.CheckConfig();
}

function PreFirstEntryMapFixes()
{
    local DeusExMover d;
    local ComputerSecurity c;
    local Keypad k;
    local Switch1 s;
    local Switch2 s2;
    local SequenceTrigger st;
    local SpecialEvent se;
    local DataLinkTrigger dlt;
    local ComputerPersonal comp_per;

#ifdef vanillamaps
    switch(dxr.localURL)
    {
    case "15_AREA51_BUNKER":
        // doors_lower is for backtracking
        AddSwitch( vect(4309.076660, -1230.640503, -7522.298340), rot(0, 16384, 0), 'doors_lower');
        player().DeleteAllGoals();

        //Change vent entry security computer password so it isn't pre-known
        foreach AllActors(class'ComputerSecurity',c){
            if (c.UserList[0].UserName=="SECURITY" && c.UserList[0].Password=="SECURITY"){
                c.UserList[0].Password="NarutoRun"; //They can't stop all of us
            }
        }

        //Move the vent entrance elevator to the bottom to make it slightly less convenient
        foreach AllActors(class'SequenceTrigger',st){
            if (st.Tag=='elevator_mtunnel_down'){
                st.Trigger(Self,player());
            }
        }

        //This door can get stuck if a spiderbot gets jammed into the little bot-bay
        foreach AllActors(class'DeusExMover',d){
            if (d.Tag=='bot_door'){
                d.MoverEncroachType=ME_IgnoreWhenEncroach;
            }
        }

        //Swap the button at the top of the elevator to a keypad to make this path a bit more annoying
        foreach AllActors(class'Switch2',s2){
            if (s2.Event=='elevator_mtunnel_up'){
                k = Spawn(class'Keypad2',,,s2.Location,s2.Rotation);
                k.validCode="17092019"; //September 17th, 2019 - First day of "Storm Area 51"
                k.bToggleLock=False;
                k.Event='elevator_mtunnel_up';
                s2.event='';
                s2.Destroy();
                break;
            }
        }

        //Lock the fan entrance top door
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_Bunker_Fan'){ break;}
        }
        d = DeusExMover(findNearestToActor(class'DeusExMover',dlt));
        d.bLocked=True;
        d.bBreakable=True;
        d.FragmentClass=Class'DeusEx.MetalFragment';
        d.ExplodeSound1=Sound'DeusExSounds.Generic.MediumExplosion1';
        d.ExplodeSound2=Sound'DeusExSounds.Generic.MediumExplosion2';
        d.minDamageThreshold=25;
        d.doorStrength = 0.20; //It's just grating on top of the vent, so it's not that strong

        Spawn(class'PlaceholderItem',,, vectm(-1469.9,3238.7,-213)); //Storage building
        Spawn(class'PlaceholderItem',,, vectm(-1565.4,3384.8,-213)); //Back of Storage building
        Spawn(class'PlaceholderItem',,, vectm(-1160.9,256.3,-501)); //Tower basement
        Spawn(class'PlaceholderItem',,, vectm(1481,3192.7,-468)); //Command building bed
        Spawn(class'PlaceholderItem',,, vectm(923.008606,2962.796387,-482.689789)); //Command building locker
        Spawn(class'PlaceholderItem',,, vectm(1106.5,-2860.4,-165)); //Hangar building roof
        Spawn(class'PlaceholderItem',,, vectm(1104.7,-2925.7,-325)); //Hangar building next to guy who gives up
        Spawn(class'PlaceholderItem',,, vectm(520.26,-1482.3,-453)); //Boxes in Hangar
        Spawn(class'PlaceholderItem',,, vectm(1017.5,-1842.1,-453)); //Boxes in Hangar near enemies

        class'PlaceholderEnemy'.static.Create(self,vectm(-2237,3225,-192), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(4234,3569,-736), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(3744,-1030,-7481), 0);

        break;

    case "15_AREA51_FINAL":
        // Generator_overload is the cover over the beat the game button used in speedruns
        foreach AllActors(class'DeusExMover', d, 'Generator_overload') {
            d.move(vectm(0, 0, -1));
        }
        AddSwitch( vect(-5112.805176, -2495.639893, -1364), rot(0, 16384, 0), 'blastdoor_final');// just in case the dialog fails
        AddSwitch( vect(-5112.805176, -2530.276123, -1364), rot(0, -16384, 0), 'blastdoor_final');// for backtracking
        AddSwitch( vect(-3745, -1114, -1950), rot(0,0,0), 'Page_Blastdoors' );

        foreach AllActors(class'DeusExMover', d, 'doors_lower') {
            d.bLocked = false;
            d.bHighlight = true;
            d.bFrobbable = true;
        }

        //Generator Failsafe buttons should spit out some sort of message if the coolant isn't cut
        //start_buzz1 and start_buzz2 are the tags that get hit when the coolant isn't cut
        se = Spawn(class'SpecialEvent',,'start_buzz1');
        se.Message = "Coolant levels normal - Failsafe cannot be disabled";
        se = Spawn(class'SpecialEvent',,'start_buzz2');
        se.Message = "Coolant levels normal - Failsafe cannot be disabled";

        //Increase the radius of the datalink that opens the sector 4 blast doors
        foreach AllActors(class'DataLinkTrigger',dlt){
            if (dlt.datalinkTag=='DL_Helios_Door2'){
                dlt.SetCollisionSize(900,dlt.CollisionHeight);
            }
        }

        Spawn(class'PlaceholderItem',,, vectm(-4185.2,-207.35,-1386)); //Helios storage room
        Spawn(class'PlaceholderItem',,, vectm(-4346.5,-1404.5,-2020)); //Storage room near sector 4 door
        Spawn(class'PlaceholderItem',,, vectm(-5828.7,-412.6,-1514)); //Storage room on stairs to sector 4
        Spawn(class'PlaceholderItem',,, vectm(-4984.8,-3713.8,-1354)); //On top of control panels near cooling pool near entrance
        Spawn(class'PlaceholderItem',,, vectm(-5242.45,-2675.55,-1364)); //Boxes right near Tong at entrance
        Spawn(class'PlaceholderItem',,, vectm(-3110.8,-4931.9,-1555)); //Reactor control room

        Spawn(class'PlaceholderContainer',,, vectm(-4100,2345,-384)); //Arms under Helios
        Spawn(class'PlaceholderContainer',,, vectm(-3892,2397,1147)); //Arms under Helios
        Spawn(class'PlaceholderContainer',,, vectm(-4253.9,771.4,-1564)); //Under staircase near Helios
        Spawn(class'PlaceholderContainer',,, vectm(-3040,-4960,-1607)); //Reactor control room

        class'PlaceholderEnemy'.static.Create(self,vectm(-5113,-989,-1995), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(-5899,-1112,-1323), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(-4795,-1596,-1357), 0);

        break;

    case "15_AREA51_ENTRANCE":
        foreach AllActors(class'DeusExMover', d, 'DeusExMover') {
            if( d.Name == 'DeusExMover20' ) d.Tag = 'final_door';
        }
        AddSwitch( vect(-867.193420, 244.553101, 17.622702), rot(0, 32768, 0), 'final_door');

        foreach AllActors(class'DeusExMover', d, 'doors_lower') {
            d.bLocked = false;
            d.bHighlight = true;
            d.bFrobbable = true;
        }

        //Change break room security computer password so it isn't pre-known
        //This code isn't written anywhere, so you shouldn't have knowledge of it
        foreach AllActors(class'ComputerSecurity',c){
            if (c.UserList[0].UserName=="SECURITY" && c.UserList[0].Password=="SECURITY"){
                c.UserList[0].Password="TinFoilHat";
            }
        }

        Spawn(class'PlaceholderItem',,, vectm(1542.28,-2080,-349)); //Near karkians under Everett
        Spawn(class'PlaceholderItem',,, vectm(3310.14,-2512.35,10.3)); //Boxes right at entrance
        Spawn(class'PlaceholderItem',,, vectm(4022.8,-710.4,-149)); //Boxes near barracks
        Spawn(class'PlaceholderItem',,, vectm(4811,63.7,-173)); //Barracks table
        Spawn(class'PlaceholderItem',,, vectm(3262.9,1492.9,-149)); //Boxes out front of rec room
        Spawn(class'PlaceholderItem',,, vectm(3163.7,2306.2,-169)); //Rec Room ping pong table
        Spawn(class'PlaceholderItem',,, vectm(-404.7,1624.6,-349)); //Near corpse under cherry picker
        Spawn(class'PlaceholderItem',,, vectm(18.6,1220.4,-149)); //Boxes near cherry picker
        Spawn(class'PlaceholderItem',,, vectm(-1712.9,191.25,26)); //In front of ambush elevator

        class'PlaceholderEnemy'.static.Create(self,vectm(4623,210,-176), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(3314,2196,-176), 0);
        class'PlaceholderEnemy'.static.Create(self,vectm(-190,-694,-180), 0);

        break;

    case "15_AREA51_PAGE":
        foreach AllActors(class'ComputerSecurity', c) {
            if( c.UserList[0].userName != "graytest" || c.UserList[0].Password != "Lab12" ) continue;
            c.UserList[0].userName = "Lab 12";
            c.UserList[0].Password = "graytest";
        }
        foreach AllActors(class'Keypad', k) {
            if( k.validCode == "9248" )
                k.validCode = "2242";
        }
        foreach AllActors(class'Switch1',s){
            if (s.Name == 'Switch21'){
                s.Event = 'door_page_overlook';
            }
        }

        // fix the Helios ending skip
        foreach AllActors(class'ComputerPersonal', comp_per) {
            if(comp_per.Name == 'ComputerPersonal0') {
                comp_per.Tag = 'router_computer';
                class'DXRTriggerEnable'.static.Create(comp_per, 'router_door', 'router_computer');
                break;
            }
        }
        break;
    }
#endif
}

function AnyEntryMapFixes()
{
    local Gray g;
    local ElectricityEmitter ee;
    local #var(DeusExPrefix)Mover d;

    switch(dxr.localURL)
    {
    case "15_AREA51_FINAL":
#ifdef vanillamaps
        foreach AllActors(class'Gray', g) {
            if( g.Tag == 'reactorgray1' ) g.BindName = "ReactorGray1";
            else if( g.Tag == 'reactorgray2' ) g.BindName = "ReactorGray2";
        }
#endif
        break;

    case "15_AREA51_PAGE":
        // get the password from Helios sooner
        FixConversationAddNote(GetConversation('DL_Final_Helios06'), "Use the login");
        // timer to count the blue fusion reactors
        SetTimer(1, True);

        foreach AllActors(class'ElectricityEmitter', ee, 'emitter_relay_room') {
            if(ee.DamageAmount >= 30) {// these are OP
                ee.DamageAmount /= 2;
                ee.damageTime *= 2.0;
                ee.randomAngle /= 2.0;
            }
        }

        if((!#defined(revision)) && (!#defined(gmdx))) {// cover the button better
            foreach AllActors(class'#var(DeusExPrefix)Mover', d, 'Page_button') {
                d.SetLocation(d.Location-vectm(0,0,2)); // original Z was -5134
            }
        }
        break;
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "15_AREA51_PAGE":
        Area51_CountBlueFusion();
        break;
    }
}

function Area51_CountBlueFusion()
{
    local int newCount;

    newCount = 4;

    if (dxr.flagbase.GetBool('Node1_Frobbed'))
        newCount--;
    if (dxr.flagbase.GetBool('Node2_Frobbed'))
        newCount--;
    if (dxr.flagbase.GetBool('Node3_Frobbed'))
        newCount--;
    if (dxr.flagbase.GetBool('Node4_Frobbed'))
        newCount--;

    if (newCount!=storedReactorCount){
        // A fusion reactor has been shut down!
        storedReactorCount = newCount;

        switch(newCount){
            case 0:
                player().ClientMessage("All Blue Fusion reactors shut down!");
                SetTimer(0, False);  // Disable the timer now that all fusion reactors are shut down
                break;
            case 1:
                player().ClientMessage("1 Blue Fusion reactor remaining");
                break;
            case 4:
                // don't alert the player at the start of the level
                break;
            default:
                player().ClientMessage(newCount$" Blue Fusion reactors remaining");
                break;
        }

        UpdateReactorGoal(newCount);
    }
}

function UpdateReactorGoal(int count)
{
    local string goalText;
    local DeusExGoal goal;
    local int bracketPos;
    goal = player().FindGoal('OverloadForceField');

    if (goal!=None){
        goalText = goal.text;
        bracketPos = InStr(goalText,"[");

        if (bracketPos>0){ //If the extra text is already there, strip it.
            goalText = Mid(goalText,0,bracketPos-1);
        }

        goalText = goalText$" ["$count$" remaining]";

        goal.SetText(goalText);
    }
}
