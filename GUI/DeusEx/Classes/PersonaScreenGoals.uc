class DXRPersonaScreenGoals injects PersonaScreenGoals;

var PersonaActionButtonWindow btnBingo, btnGoalHints, btnEntranceLocs, btnEntranceSpoilers, btnGoalSpoilers, btnGoalLocs;
//var PersonaCheckBoxWindow  chkShowSpoilers;
var string goalRandoWikiUrl;
var string InfoWindowHeader, InfoWindowText;
var string EntSpoilerWindowHeader, EntSpoilerWindowText;
var string GoalSpoilerWindowHeader, GoalSpoilerWindowText;
var String DisplaySpoilers;
var String GoalLocations;
var bool bDisplaySpoilers;

function CreateControls()
{
    local DXRando dxr;

    Super.CreateControls();

    //Get rid of the "Confirm Note Deletion" checkbox
    //It's free real estate!
    //Instead, use the state from MenuChoice_ConfirmNoteDelete instead
    chkConfirmNoteDeletion.Hide();
    bConfirmNoteDeletes = bool(player.ConsoleCommand("get MenuChoice_ConfirmNoteDelete confirm_delete"));

    btnBingo = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnBingo.SetButtonText("|&Bingo");
    btnBingo.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 13, 179);
    btnBingo.SetSensitivity(true);

    foreach player.AllActors(class'DXRando',dxr){
        if (dxr.flags.settings.goals > 0) {
            btnGoalHints = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
            btnGoalHints.SetButtonText("|&Goal Randomization Wiki");
            btnGoalHints.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 65, 179);
            btnGoalHints.SetSensitivity(true);

            //CreateShowSpoilersCheckbox();
            if (dxr.flags.settings.spoilers==1){
                CreateShowSpoilersButton(); //A button makes a confirmation window easier
            }

            //Goals is set in Revision, but not supported there
#ifndef revision
            CreateGoalLocationsButton();
#endif
        }

        if (dxr.flags.IsEntranceRando()){
            btnEntranceLocs = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
            btnEntranceLocs.SetButtonText("Entrances");
            btnEntranceLocs.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 220, 411);
            btnEntranceLocs.SetSensitivity(true);

            if (dxr.flags.settings.spoilers==1){
                btnEntranceSpoilers = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
                btnEntranceSpoilers.SetButtonText("Entrance Spoilers");
                btnEntranceSpoilers.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 300, 411);
                btnEntranceSpoilers.SetSensitivity(true);
            }
        }
        break;
    }
}

/*
function CreateShowSpoilersCheckbox()
{
	chkShowSpoilers = PersonaCheckBoxWindow(winClient.NewChild(Class'PersonaCheckBoxWindow'));

	bDisplaySpoilers = False;

	chkShowSpoilers.SetText(DisplaySpoilers);
	chkShowSpoilers.SetToggle(bDisplaySpoilers);
	chkShowSpoilers.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 300, 180);
}
*/

function CreateShowSpoilersButton()
{
	bDisplaySpoilers = False;

    btnGoalSpoilers = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnGoalSpoilers.SetButtonText(DisplaySpoilers);
    btnGoalSpoilers.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 290, 179);
    btnGoalSpoilers.SetSensitivity(true);

}

//Maybe this should be shifted left when not in entrance rando mode?
function CreateGoalLocationsButton()
{
    btnGoalLocs = PersonaActionButtonWindow(winClient.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnGoalLocs.SetButtonText(GoalLocations);
    btnGoalLocs.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 450, 411);
    btnGoalLocs.SetSensitivity(true);

}

function PopulateGoals()
{
    Super.PopulateGoals();

    if (bDisplaySpoilers){
        PopulateSpoilers();
    }
}

function PopulateSpoilers()
{
    local DXRMissions missions;
    local PersonaHeaderTextWindow spoilerHeader;
    local PersonaGoalItemWindow spoilerWindow;
    local int i;
    local string spoilName,spoilLoc;

    foreach player.AllActors(class'DXRMissions',missions){
        // Create Goals Header
	    spoilerHeader = PersonaHeaderTextWindow(winGoals.NewChild(Class'PersonaHeaderTextWindow'));
	    spoilerHeader.SetTextAlignments(HALIGN_Left, VALIGN_Center);
	    spoilerHeader.SetText("Spoilers");
        if (missions.num_goals==0){
            spoilerWindow = PersonaGoalItemWindow(winGoals.NewChild(Class'PersonaGoalItemWindow'));
			spoilerWindow.SetGoalProperties(True, False, "No possible goals in this map");
            break;
        }
        for(i=0;i<missions.num_goals;i++){
            spoilName = missions.GetSpoiler(i).goalName;
            spoilLoc = missions.GetSpoiler(i).goalLocation;
            spoilLoc = Caps(Left(spoilLoc,1))$Mid(spoilLoc,1);

            spoilerWindow = PersonaGoalItemWindow(winGoals.NewChild(Class'PersonaGoalItemWindow'));
			spoilerWindow.SetGoalProperties(True, False, spoilName $": "$spoilLoc);
        }

        break;
    }
}

/*
event bool ToggleChanged(Window button, bool bNewToggle)
{
    Super.ToggleChanged(button,bNewToggle);

    if (button == chkShowSpoilers)
	{
        //root.MessageBox(GoalSpoilerWindowHeader,GoalSpoilerWindowText,0,False,Self);
		bDisplaySpoilers = bNewToggle;
		PopulateGoals();
	}

	return True;
}
*/

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    local MenuUIMessageBoxWindow msgBox;
    local string action;

    msgBox = MenuUIMessageBoxWindow(msgBoxWindow);
    if (msgBox.winText.GetText()==InfoWindowText){
        if (buttonNumber==0){
            action="wiki";
        }
    } else if (msgBox.winText.GetText()==EntSpoilerWindowText){
        if (buttonNumber==0){
            action="entspoilers";
            class'DXRStats'.static.AddCheatOffense(player);
        }
    } else if (msgBox.winText.GetText()==GoalSpoilerWindowText){
        action="goalspoilers";
        bDisplaySpoilers=(buttonNumber==0);
        if(bDisplaySpoilers)
            class'DXRStats'.static.AddCheatOffense(player);
    }

    if (action=="wiki"){
        player.ConsoleCommand("start "$goalRandoWikiUrl);
        // Destroy the msgbox!
	    root.PopWindow();
        return true;
    } else if (action=="entspoilers"){
        // Destroy the msgbox!
	    root.PopWindow();
        generateEntranceNote(True);
        return true;
    } else if (action=="goalspoilers"){
        // Destroy the msgbox!
	    root.PopWindow();
        PopulateGoals();
        return true;

    }

    return Super.BoxOptionSelected(msgBoxWindow,buttonNumber);
}

function Teleporter findOtherTeleporter(Teleporter nearThis){
    local Teleporter thing,nearestThing;

    foreach player.AllActors(class'Teleporter',thing) {
        if (thing==nearThis){
            continue;
        } else if (nearestThing==None){
            nearestThing = thing;
        } else {
            if ((VSize(nearThis.Location-thing.Location)) < (VSize(nearThis.Location-nearestThing.Location))){
                nearestThing = thing;
            }
        }
    }
    return nearestThing;
}


function generateEntranceNote(bool bSpoil)
{
#ifdef vanilla
	local DeusExNote newNote;
	local PersonaNotesEditWindow newNoteWindow;
    local String entranceList,source,dest;
    local DeusExLevelInfo dxLevel;
    local DXREntranceRando entRando;
    local int i;
    local bool found;

    if (bSpoil){
        entranceList="Entrance Rando Spoilers: ";
    } else {
        entranceList="Randomized Entrances: ";
    }

    foreach player.AllActors(class'DeusExLevelInfo',dxLevel){
        entranceList = entranceList $ dxLevel.MissionLocation $ " (Mission "$dxLevel.missionNumber$")";
        break;
    }

    entranceList = entranceList $ "|n--------------------------------------------------------";

    foreach player.AllActors(class'DXREntranceRando',entRando){
        entRando.LoadConns();
        player.ClientMessage("Found "$entRando.numConns$" connections in EntranceRando");
        for (i=0;i<entRando.numConns;i++){
            found=False;
            if (entRando.GetConnection(i).a.mapname==entRando.dxr.localURL){
                source = class'DXRMapInfo'.static.GetTeleporterName(entRando.dxr.localURL,entRando.GetConnection(i).a.inTag);
                dest = class'DXRMapInfo'.static.GetTeleporterName(entRando.GetConnection(i).b.mapname,entRando.GetConnection(i).b.inTag);
                found=True;
            }else if (entRando.GetConnection(i).b.mapname==entRando.dxr.localURL){
                source = class'DXRMapInfo'.static.GetTeleporterName(entRando.dxr.localURL,entRando.GetConnection(i).b.inTag);
                dest = class'DXRMapInfo'.static.GetTeleporterName(entRando.GetConnection(i).a.mapname,entRando.GetConnection(i).a.inTag);
                found=True;
            }

            if(found){
                entranceList=entranceList$"|n"$source$" -> ";
                if (bSpoil){
                    entranceList=entranceList$dest;
                }
            }
        }
        break;
    }

	// Create a new note and then a window to display it in
	newNote = player.AddNote(entranceList, True);

	newNoteWindow = CreateNoteEditWindow(newNote);
	newNoteWindow.Lower();
	SetFocusWindow(newNoteWindow);
#endif
}

function generateGoalLocationNote()
{
    local DeusExNote newNote;
    local PersonaNotesEditWindow newNoteWindow;
    local DeusExLevelInfo dxLevel;
    local String goalLocationList;
    local DXRMissions missions;

    foreach player.AllActors(class'DeusExLevelInfo',dxLevel){
        goalLocationList = dxLevel.MissionLocation $ " (Mission "$dxLevel.missionNumber$") Possible Goal Locations:|n|n";
        break;
    }

    //Actually get the list of goals and locations
    foreach player.AllActors(class'DXRMissions',missions){
        goalLocationList = goalLocationList $ missions.generateGoalLocationList();
        break;
    }

    // Create a new note and then a window to display it in
	newNote = player.AddNote(goalLocationList, True);

	newNoteWindow = CreateNoteEditWindow(newNote);
	newNoteWindow.Lower();
	SetFocusWindow(newNoteWindow);
}

function bool ButtonActivated( Window buttonPressed )
{
    if(buttonPressed == btnBingo) {
        SaveSettings();
        root.InvokeUIScreen(class'PersonaScreenBingo');
        return true;
    } else if(buttonPressed == btnGoalHints) {
        SaveSettings();
        root.MessageBox(InfoWindowHeader,InfoWindowText,0,False,Self);
        return true;
    } else if (buttonPressed == btnEntranceLocs) {
        generateEntranceNote(False);
        return true;
    } else if (buttonPressed == btnEntranceSpoilers) {
        root.MessageBox(EntSpoilerWindowHeader,EntSpoilerWindowText,0,False,Self);
        return true;
    } else if (buttonPressed == btnGoalSpoilers) {
        root.MessageBox(GoalSpoilerWindowHeader,GoalSpoilerWindowText,0,False,Self);
        return true;
    } else if (buttonPressed == btnGoalLocs) {
        generateGoalLocationNote();
        return true;
    }
    return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
     InfoWindowHeader="Open Wiki?"
     InfoWindowText="Would you like to open the DXRando Goal Randomization wiki page in your web browser?"
     EntSpoilerWindowHeader="Spoilers?"
     EntSpoilerWindowText="Are you sure you want to see spoilers for the entrance randomization? This will impact your score! Click Entrances instead if you don't want to hurt your score."
     GoalSpoilerWindowHeader="Spoilers?"
     GoalSpoilerWindowText="Do you want to see spoilers for the goal randomization? This will impact your score! Click Goal Locations instead if you don't want to hurt your score."
     goalRandoWikiUrl="https://github.com/Die4Ever/deus-ex-randomizer/wiki/Goal-Randomization"
     DisplaySpoilers="Show Spoilers"
     GoalLocations="Goal Locations"
}
