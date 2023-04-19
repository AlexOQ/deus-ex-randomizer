class DXRFixupM09 extends DXRFixup;

function CheckConfig()
{
    local int i;

    add_datacubes[i].map = "09_NYC_Dockyard";
    add_datacubes[i].text = "Jenny I've got your number|nI need to make you mine|nJenny don't change your number|n 8675309";// DXRPasswords doesn't recognize |n as a wordstop
    i++;

    Super.CheckConfig();
}

function PreFirstEntryMapFixes()
{
    local DeusExMover m;
    local ComputerSecurity cs;
    local Keypad2 k;
    local Button1 b;
    local WeaponGasGrenade gas;
    local Teleporter t;
    local BlockPlayer bp;
    local DynamicBlockPlayer dbp;
    local #var(prefix)OrdersTrigger ord;

    switch(dxr.localURL)
    {
#ifdef vanillamaps
    case "09_NYC_SHIP":
        foreach AllActors(class'DeusExMover', m, 'DeusExMover') {
            if( m.Name == 'DeusExMover7' ) m.Tag = 'shipbelowdecks_door';
        }
        AddSwitch( vect(2534.639893, 227.583054, 339.803802), rot(0,-32760,0), 'shipbelowdecks_door' );
        break;
#endif

    case "09_NYC_SHIPBELOW":
        // make the weld points highlightable
        foreach AllActors(class'DeusExMover', m, 'ShipBreech') {
            m.bHighlight = true;
            m.bLocked = true;
        }
        // remove the orders triggers that cause guys to attack when destroying weld points
        foreach AllActors(class'#var(prefix)OrdersTrigger', ord, 'wall1') {
            ord.Event = '';
            ord.Destroy();
        }
        foreach AllActors(class'#var(prefix)OrdersTrigger', ord, 'wall2') {
            ord.Event = '';
            ord.Destroy();
        }
        UpdateWeldPointGoal(5);

#ifdef vanillamaps
        Tag = 'FanToggle';
        foreach AllActors(class'ComputerSecurity',cs){
            if (cs.Name == 'ComputerSecurity4'){
                cs.specialOptions[0].Text = "Disable Ventilation Fan";
                cs.specialOptions[0].TriggerEvent='FanToggle';
                cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
            }
        }

        //Remove the stupid gas grenades that are past the level exit
        foreach AllActors(class'Teleporter',t){
            if (t.Tag=='ToAbove') break;
        }
        gas = WeaponGasGrenade(findNearestToActor(class'WeaponGasGrenade',t));
        if (gas!=None){
            gas.Destroy();
        }
        gas = WeaponGasGrenade(findNearestToActor(class'WeaponGasGrenade',t));
        if (gas!=None){
            gas.Destroy();
        }
#endif
        break;

    case "09_NYC_DOCKYARD":
        foreach AllActors(class'Button1',b){
            if (b.Tag=='Button1' && b.Event=='Lift' && b.Location.Z < 200){ //vanilla Z is 97 for the lower button, just giving some slop in case it was changed in another mod?
                k = Spawn(class'Keypad2',,,b.Location,b.Rotation);
                k.validCode="8675309"; //They really like Jenny in this place
                k.bToggleLock=False;
                k.Event='Lift';
                b.Event=''; //If you don't unset the event, it gets called when the button is destroyed...
                b.Destroy();
                break;
            }
        }
        // near the start of the map to jump over the wall, from (2536.565674, 1600.856323, 251.924713) to 3982.246826
        foreach RadiusActors(class'BlockPlayer', bp, 725, vect(3259, 1601, 252)) {
            bp.bBlockPlayers=false;
        }
        // 4030.847900 to 4078.623779
        foreach RadiusActors(class'BlockPlayer', bp, 25, vect(4055, 1602, 252)) {
            dbp = Spawn(class'DynamicBlockPlayer',,, bp.Location + vect(0,0,200));
            dbp.SetCollisionSize(bp.CollisionRadius, bp.CollisionHeight + 101);
        }
        break;

    case "09_NYC_SHIPFAN":
#ifdef vanillamaps
        Tag = 'FanToggle';
        foreach AllActors(class'ComputerSecurity',cs){
            if (cs.Name == 'ComputerSecurity6'){
                cs.specialOptions[0].Text = "Disable Ventilation Fan";
                cs.specialOptions[0].TriggerEvent='FanToggle';
                cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
            }
        }
#endif
        break;
    }
}

function PostFirstEntryMapFixes()
{
    local #var(prefix)CrateUnbreakableLarge c;

    switch(dxr.localURL) {
#ifndef revision
    case "09_NYC_DOCKYARD":
        // this crate can block the way out of the start through the vent
        foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 160, vect(2510.350342, 1377.569336, 103.858093)) {
            info("removing " $ c $ " dist: " $ VSize(c.Location - vect(2510.350342, 1377.569336, 103.858093)) );
            c.Destroy();
        }
        break;

    case "09_NYC_SHIPBELOW":
        // add a tnt crate on top of the pipe, visible from the ground floor
        _AddActor(Self, class'#var(prefix)CrateExplosiveSmall', vect(141.944641, -877.442627, -175.899567), rot(0,0,0));
        // remove big crates blocking the window to the pipe, 16 units == 1 foot
        foreach RadiusActors(class'#var(prefix)CrateUnbreakableLarge', c, 16*4, vect(-136.125000, -743.875000, -215.899323)) {
            c.Event = '';
            c.Destroy();
        }
        break;
#endif
    }
}

function AnyEntryMapFixes()
{
    local #var(Mover) m;

    switch(dxr.localURL)
    {
    case "09_NYC_SHIP":
#ifdef vanillamaps
        if(dxr.flagbase.GetBool('HelpSailor')) {
            foreach AllActors(class'#var(Mover)', m, 'FrontDoor') {
                m.bLocked = false;
            }
        }
#endif
        break;

    case "09_NYC_SHIPBELOW":
        SetTimer(1, True);
        break;
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "09_NYC_SHIPBELOW":
        NYC_09_CountWeldPoints();
        break;
    }
}

function UpdateWeldPointGoal(int count)
{
    local string goalText;
    local DeusExGoal goal;
    local int bracketPos;
    goal = player().FindGoal('ScuttleShip');

    if (goal!=None){
        goalText = goal.text;
        bracketPos = InStr(goalText,"(");

        if (bracketPos>0){ //If the extra text is already there, strip it.
            goalText = Mid(goalText,0,bracketPos-1);
        }

        goalText = goalText$" ("$count$" remaining)";

        goal.SetText(goalText);
    }
}

function NYC_09_CountWeldPoints()
{
    local int newWeldCount;
    local DeusExMover m;

    newWeldCount=0;

    //Search for the weld point movers
    foreach AllActors(class'DeusExMover',m, 'ShipBreech') {
        if (!m.bDestroyed){
            newWeldCount++;
        }
    }

    if (newWeldCount != storedWeldCount) {
        //A weld point has been destroyed!
        storedWeldCount = newWeldCount;

        switch(newWeldCount){
            case 0:
                player().ClientMessage("All weld points destroyed!");
                SetTimer(0, False);  //Disable the timer now that all weld points are gone
                break;
            case 1:
                player().ClientMessage("1 weld point remaining");
                break;
            default:
                player().ClientMessage(newWeldCount$" weld points remaining");
                break;
        }

        UpdateWeldPointGoal(newWeldCount);
    }
}


function Trigger(Actor Other, Pawn Instigator)
{
    if (Tag=='FanToggle'){
#ifdef vanillamaps
        ToggleFan();
#endif
    }
}

#ifdef vanillamaps
function ToggleFan()
{
    local Fan1 f;
    local ParticleGenerator pg;
    local ZoneInfo z;
    local AmbientSound as;
    local ComputerSecurity cs;
    local bool enable;
    local name compName;
    local DeusExMover dxm;

    //This function is now used in two maps
    switch(dxr.localURL)
    {
        case "09_NYC_SHIPBELOW":
            compName = 'ComputerSecurity4';
            break;
        case "09_NYC_SHIPFAN":
            compName = 'ComputerSecurity6';
            break;
        default:
            player().ClientMessage("Not in a map that understands how to toggle a fan!");
            return;
            break;
    }

    foreach AllActors(class'ComputerSecurity',cs){
        if (cs.Name == compName){
            //If you press disable, you want to disable...
            if (cs.SpecialOptions[0].Text == "Disable Ventilation Fan"){
                enable = False;
            } else {
                enable = True;
            }

            if (enable){
                cs.specialOptions[0].Text = "Disable Ventilation Fan";
                cs.specialOptions[0].TriggerText="Ventilation Fan Enabled"; //Unintuitive, but it prints the text before the trigger call
            } else {
                cs.specialOptions[0].Text = "Enable Ventilation Fan";
                cs.specialOptions[0].TriggerText="Ventilation Fan Disabled";
            }
            break;
        }
    }

    if (dxr.localURL=="09_NYC_SHIPBELOW"){
        //Fan1
        foreach AllActors(class'Fan1',f){
            if (f.Name == 'Fan1'){
                if (enable) {
                    f.RotationRate.Yaw = 50000;
                } else {
                    f.RotationRate.Yaw = 0;
                }
            }
        }

        //ParticleGenerator3
        foreach AllActors(class'ParticleGenerator',pg){
            if (pg.Name == 'ParticleGenerator3'){
                pg.bSpewing = enable;
                pg.bFrozen = !enable;
                pg.proxy.bHidden=!enable;
                break;
            }
        }

        //ZoneInfo0
        foreach AllActors(class'ZoneInfo',z){
            if (z.Name=='ZoneInfo0') {
                if (enable){
                    z.ZoneGravity.Z = 100;
                } else {
                    z.ZoneGravity.Z = -950;
                }
                break;
            }
        }

        //AmbientSound7
        //AmbientSound8
        foreach AllActors(class'AmbientSound',as){
            if (as.Name=='AmbientSound7'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.HumTurbine2", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound8'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.StrongWind", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            }
        }
    } else if (dxr.localURL=="09_NYC_SHIPFAN"){
        foreach AllActors(class'DeusExMover',dxm){
            if (dxm.Name == 'DeusExMover1'){
                if (enable) {
                    dxm.RotationRate.Yaw = -20000;
                } else {
                    dxm.RotationRate.Yaw = 0;
                }
            }
        }
        foreach AllActors(class'AmbientSound',as){
            if (as.Name=='AmbientSound6'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.FanLarge", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            } else if (as.Name=='AmbientSound0'){
                if (enable){
                    as.AmbientSound = Sound(DynamicLoadObject("Ambient.Ambient.MachinesLarge3", class'Sound'));
                } else {
                    as.AmbientSound = None;
                }
            }
        }
    }
}
#endif
