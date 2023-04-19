class DXRFixupParis extends DXRFixup;

function PreFirstEntryMapFixes()
{
    local GuntherHermann g;
    local DeusExMover m;
    local Trigger t;
    local Dispatcher d;
    local ScriptedPawn sp;
    local Conversation c;
    local #var(prefix)DataLinkTrigger dlt;
    local #var(prefix)JaimeReyes j;

    // shut up, Tong!
    foreach AllActors(class'#var(prefix)DataLinkTrigger', dlt) {
        switch(dlt.dataLinkTag) {
        case 'DL_paris_10_shaft':
        case 'DL_paris_10_radiation':
        case 'DL_paris_10_catacombs':
        case 'DL_tunnels_oldplace':
        case 'DL_tunnels_oldplace2':
        case 'DL_tunnels_oldplace3':
        case 'DL_metroentrance':
        case 'DL_club_entry':
        case 'DL_apartments':
        case 'DL_hotel':
        case 'DL_bakery':
        case 'DL_entered_graveyard':
            dlt.Event='';
            dlt.Destroy();
        }
    }

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        FixConversationAddNote(GetConversation('MeetAimee'), "Stupid, stupid, stupid password.");
        break;

#ifdef vanillamaps
    case "10_PARIS_CATACOMBS_TUNNELS":
        foreach AllActors(class'Trigger', t)
            if( t.Event == 'MJ12CommandoSpecial' )
                t.Touch(player());// make this guy patrol instead of t-pose

        AddSwitch( vect(897.238892, -120.852928, -9.965580), rot(0,0,0), 'catacombs_blastdoor02' );
        AddSwitch( vect(-2190.893799, 1203.199097, -6.663990), rot(0,0,0), 'catacombs_blastdoorB' );
        break;

    case "10_PARIS_CHATEAU":
        foreach AllActors(class'DeusExMover', m, 'everettsignal')
            m.Tag = 'everettsignaldoor';
        d = Spawn(class'Dispatcher',, 'everettsignal', vect(176.275253, 4298.747559, -148.500031) );
        d.OutEvents[0] = 'everettsignaldoor';
        AddSwitch( vect(-769.359985, -4417.855469, -96.485504), rot(0, 32768, 0), 'everettsignaldoor' );

        //speed up the secret door...
        foreach AllActors(class'Dispatcher', d, 'cellar_doordispatcher') {
            d.OutDelays[1] = 0;
            d.OutDelays[2] = 0;
            d.OutDelays[3] = 0;
            d.OutEvents[2] = '';
            d.OutEvents[3] = '';
        }
        foreach AllActors(class'DeusExMover', m, 'secret_candle') {
            m.MoveTime = 0.5;
        }
        foreach AllActors(class'DeusExMover', m, 'cellar_door') {
            m.MoveTime = 1;
        }
        break;
    case "10_PARIS_METRO":
        //If neither flag is set, JC never talked to Jaime, so he just didn't bother
        if (!dxr.flagbase.GetBool('JaimeRecruited') && !dxr.flagbase.GetBool('JaimeLeftBehind')){
            //Need to pretend he *was* recruited, so that he doesn't spawn
            dxr.flagbase.SetBool('JaimeRecruited',True);
        }
        // fix the night manager sometimes trying to talk to you while you're flying away https://www.youtube.com/watch?v=PeLbKPSHSOU&t=6332s
        c = GetConversation('MeetNightManager');
        if(c!=None) {
            c.bInvokeBump = false;
            c.bInvokeSight = false;
            c.bInvokeRadius = false;
        }
        foreach AllActors(class'#var(prefix)JaimeReyes', j) {
            RemoveFears(j);
        }
        break;
#endif

    case "10_PARIS_CLUB":
        foreach AllActors(class'ScriptedPawn',sp){
            if (sp.BindName=="LDDPAchille" || sp.BindName=="Camille"){
                sp.bImportant=True;
            }
        }

    case "11_PARIS_CATHEDRAL":
        foreach AllActors(class'GuntherHermann', g) {
            g.ChangeAlly('mj12', 1, true);
        }
        break;
    }
}

function PostFirstEntryMapFixes()
{
}

function AnyEntryMapFixes()
{
    local DXRNPCs npcs;
    local DXREnemies dxre;
    local ScriptedPawn sp;
    local Merchant m;
    local TobyAtanwe toby;

    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS":
        // spawn Le Merchant with a hazmat suit because there's no guarantee of one before the highly radioactive area
        // we need to do this in AnyEntry because we need to recreate the conversation objects since they're transient
        npcs = DXRNPCs(dxr.FindModule(class'DXRNPCs'));
        if(npcs != None) {
            sp = npcs.CreateForcedMerchant("Le Merchant", 'lemerchant', vect(-3209.483154, 5190.826172,1199.610352), rot(0, -10000, 0), class'#var(prefix)HazMatSuit');
            m = Merchant(sp);
            if (m!=None){  // CreateForcedMerchant returns None if he already existed, but we still need to call it to recreate the conversation since those are transient
                m.MakeFrench();
            }
        }
        // give him weapons to defend himself
        dxre = DXREnemies(dxr.FindModule(class'DXREnemies'));
        if(dxre != None && sp != None) {
            sp.bKeepWeaponDrawn = true;
            GiveItem(sp, class'#var(prefix)WineBottle');
            dxre.RandomizeSP(sp, 100);
            RemoveFears(sp);
            sp.ChangeAlly('Player', 0.0, false);
            sp.MaxProvocations = 0;
            sp.AgitationSustainTime = 3600;
            sp.AgitationDecayRate = 0;
        }
        break;
    case "10_PARIS_CATACOMBS_TUNNELS":
        SetTimer(1.0, True); //To update the Nicolette goal description
        break;
    case "10_PARIS_CLUB":
        FixConversationAddNote(GetConversation('MeetCassandra'),"with a keypad back where the offices are");
        break;
    case "10_PARIS_CHATEAU":
        FixConversationAddNote(GetConversation('NicoletteInStudy'),"I used to use that computer whenever I was at home");
        break;
    case "11_PARIS_EVERETT":
        foreach AllActors(class'TobyAtanwe', toby) {
            toby.bInvincible = false;
        }
        break;
    }
}

function TimerMapFixes()
{
    switch(dxr.localURL)
    {
    case "10_PARIS_CATACOMBS_TUNNELS":
        UpdateGoalWithRandoInfo('FindNicolette');
        break;
    }
}
