class DXRMissionsM15 extends DXRMissions;


function int InitGoals(int mission, string map)
{
    local int goal, loc, loc2;

    AddGoalLocation("15_AREA51_BUNKER", "Jock", START_LOCATION | VANILLA_START, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
    AddGoalLocation("15_AREA51_BUNKER", "Bunker", START_LOCATION, vect(-1778.574707, 1741.028320, -213.732849), rot(0, -12416, 0));
    AddGoalLocation("15_AREA51_BUNKER", "Behind the Van", START_LOCATION, vect(-493.825836, 3099.697510, -512.897827), rot(0, 0, 0));

    goal = AddGoal("15_AREA51_BUNKER", "Walton Simons", NORMAL_GOAL, 'WaltonSimons0', PHYS_Falling);
    AddGoalActor(goal, 1, 'Trigger0', PHYS_None); //Triggers WaltonTalks
    AddGoalActor(goal, 2, 'OrdersTrigger1', PHYS_None); //WaltonTalks -> Conversation triggers WaltonAttacks
    AddGoalActor(goal, 3, 'AllianceTrigger0', PHYS_None); //WaltonAttacks

    loc = AddGoalLocation("15_AREA51_BUNKER", "Command 24", NORMAL_GOAL | VANILLA_GOAL, vect(1125.623779,3076.459961,-462.398041), rot(0, -33064, 0));
    AddActorLocation(loc, 1, vect(471.648193, 2674.075439, -487.900055), rot(0,0,0));
    loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Supply Shed", NORMAL_GOAL, vect(-1563,3579,-198), rot(0, 0, 0));
    AddActorLocation(loc, 1, vect(-1358,2887,-160), rot(0,0,0));
    loc = AddGoalLocation("15_AREA51_BUNKER", "Behind Tower", NORMAL_GOAL, vect(-1136,-137,-181), rot(0, 0, 0));
    AddActorLocation(loc, 1, vect(-1344,740,-160), rot(0,0,0));
    loc = AddGoalLocation("15_AREA51_BUNKER", "Hangar", NORMAL_GOAL, vect(1182,-1140,-478), rot(0, -33064, 0));
    AddActorLocation(loc, 1, vect(781,-235,-487), rot(0,0,0));
    loc = AddGoalLocation("15_AREA51_BUNKER", "Bunker Entrance", NORMAL_GOAL, vect(3680,1875,-848), rot(0, -18224, 0));
    AddActorLocation(loc, 1, vect(3470,1212,-800), rot(0,0,0));
    loc = AddGoalLocation("15_AREA51_ENTRANCE", "Sector 3 Access", NORMAL_GOAL, vect(-456,124,-16), rot(0, 0, 0));
    AddActorLocation(loc, 1, vect(-20,80,-180), rot(0,0,0));
    loc = AddGoalLocation("15_AREA51_FINAL", "Heliowalton", NORMAL_GOAL, vect(-4400,750,-1475), rot(0, 0, 0));
    AddActorLocation(loc, 1, vect(-3720,730,-1105), rot(0,0,0));
    loc = AddGoalLocation("15_AREA51_FINAL", "Reactor Lab", NORMAL_GOAL, vect(-3960,-3266,-1552), rot(0, 0, 0));
    AddActorLocation(loc, 1, vect(-3455,-3261,-1560), rot(0,0,0));

    AddGoal("15_AREA51_BUNKER", "Area 51 Blast Door Computer", GOAL_TYPE1, 'ComputerSecurity0', PHYS_None);
    AddGoalLocation("15_AREA51_BUNKER", "the tower", GOAL_TYPE1 | VANILLA_GOAL, vect(-1248.804321,137.393707,442.793121), rot(0, 0, 0));
    AddGoalLocation("15_AREA51_BUNKER", "Command 24", GOAL_TYPE1, vect(1125.200562,2887.646484,-432.319794), rot(0, 0, 0));
    AddGoalLocation("15_AREA51_BUNKER", "the hangar", GOAL_TYPE1, vect(1062.942261,-2496.865723,-443.252533), rot(0, 16384, 0));
    AddGoalLocation("15_AREA51_BUNKER", "the supply shed", GOAL_TYPE1, vect(-1527.608521,3280.824219,-158.588562), rot(0, -16384, 0));

    return 151;
}

function PreFirstEntryMapFixes()
{
    local Trigger t;

    if ( dxr.localURL == "15_AREA51_BUNKER" ) {
        foreach AllActors(class'Trigger',t){
            if (t.Name=='Trigger1' || t.Name=='Trigger2'){
                t.Destroy(); //Just rely on one trigger for Walton
            }
        }
    }
}

function CreateGoal(out Goal g, GoalLocation Loc)
{
    local #var(prefix)ScriptedPawn sp;
    local OrdersTrigger ot;
    local #var(prefix)AllianceTrigger at;
    local Trigger t;
    local FlagBase f;

    f = dxr.flagbase;

    switch(g.name) {
    case "Walton Simons": //Much the same as above, but he could be dead already
        if (f.GetBool('WaltonSimons_Dead')){
            l("Walton Simons dead, not spawning");
            return;
        }

        sp = #var(prefix)ScriptedPawn(Spawnm(class'#var(prefix)WaltonSimons',, 'DXRMissions', Loc.positions[0].pos));
        ot = OrdersTrigger(Spawnm(class'OrdersTrigger',,'WaltonTalks',Loc.positions[0].pos));
        at = #var(prefix)AllianceTrigger(Spawnm(class'#var(prefix)AllianceTrigger',,'WaltonAttacks',Loc.positions[0].pos));
        t = Trigger(Spawnm(class'Trigger',,,Loc.positions[1].pos));
        g.actors[0].a = sp;
        g.actors[1].a = ot;
        g.actors[2].a = at;
        g.actors[3].a = t;

        sp.BarkBindName = "WaltonSimons";
        sp.Tag='WaltonSimons';
        sp.SetOrders('WaitingFor');
        sp.bInvincible=False;

        sp.SetAlliance('mj12');

        GiveItem(sp,class'WeaponPlasmaRifle',100);
        GiveItem(sp,class'WeaponNanoSword');
        GiveItem(sp,class'WeaponLAM',3); //A bomb!

        sp.ConBindEvents();

        ot.Event='WaltonSimons';
        ot.Orders='RunningTo';
        ot.SetCollision(False,False,False);

        at.Event='WaltonSimons';
        at.Alliances[0].AllianceLevel=-1;
        at.Alliances[0].AllianceName='Player';
        at.Alliances[0].bPermanent=True;
        at.SetCollision(False,False,False);

        t.Event='WaltonTalks';
        t.SetCollisionSize(1024,300);

        break;
    }
}

function AfterMoveGoalToLocation(Goal g, GoalLocation Loc)
{
    local #var(prefix)DataCube dc1;
    local #var(prefix)InformationDevices dc2;
    local string dctext;

    if (g.name=="Area 51 Blast Door Computer" && Loc.name != "the tower") {
        foreach AllActors(class'#var(prefix)DataCube',dc1){
            if(dc1.TextTag!='15_Datacube07') continue;

            dctext = "Yusef:|n|nThey've jammed all communications, even narrow band microcasts, so this is the only way I could pass a message to you.  ";
            dctext = dctext $ "I don't know who these guys are -- they're not ours, not any of ours I've ever seen at least -- but they're slaughtering us.  ";
            dctext = dctext $ "I managed to hack the first layer of the Dreamland systems, but the best I could do was lock the bunker doors and reroute control to the security console in "$Loc.name$".  ";
            dctext = dctext $ "Should take them awhile to figure that one out, and the moment they do I'll nail the first bastard that sticks his head out of the hole.  If something happens to me, the login is ";
            dctext = dctext $ "\"a51\" and the password is \"xx15yz\".|n|n";
            dctext = dctext $ "BTW, be careful -- a squad made it out before I managed to lock the doors: they headed for the warehouse and then I lost contact with them.|n|n--Hawkins";

            dc2 = SpawnDatacube(dc1.Location, dc1.Rotation, dctext);
            if( dc2 != None ){
                l("DXRMissions spawned "$ dc2 @ dctext @ dc2.Location);
                dc1.Destroy();
            }
            else warning("failed to spawn tower datacube at "$dc1.Location);
        }
    }
}
