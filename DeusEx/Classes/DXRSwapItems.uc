class DXRSwapItems extends DXRActorsBase;

function FirstEntry()
{
    Super.FirstEntry();

    if( dxr.localURL == "INTRO" || dxr.localURL == "ENDGAME1" || dxr.localURL == "ENDGAME2" || dxr.localURL == "ENDGAME3" || dxr.localURL == "ENDGAME4" || dxr.localURL == "00_TRAINING" )
    { // extra randomization in the intro for the lolz, ENDGAME4 doesn't have a DeusExLevelInfo object though, so it doesn't get randomized :(
        RandomizeIntro();
        return;
    }

    SwapAll('Inventory');
    SwapAll('Containers');
}

function RandomizeIntro()
{
    local Tree t;
    local DeusExMover m;
    local BreakableGlass g;

    SetSeed("RandomizeIntro");
    
    foreach AllActors(class'Tree', t)
    { // exclude 80% of trees from the SwapAll by temporarily hiding them
        if( rng(100) < 80 ) t.bHidden = true;
    }
    foreach AllActors(class'DeusExMover', m)
    {
        m.bHidden = true;
    }
    foreach AllActors(class'BreakableGlass', g)
    {
        g.bHidden = true;
    }
    SwapAll('Actor');
    foreach AllActors(class'Tree', t)
    {
        t.bHidden = false;
    }
    foreach AllActors(class'DeusExMover', m)
    {
        m.bHidden = false;
    }
    foreach AllActors(class'BreakableGlass', g)
    {
        g.bHidden = false;
    }
}
