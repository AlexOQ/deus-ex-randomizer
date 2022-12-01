class BingoTile extends ButtonWindow;

var int progress, max;

event DrawWindow(GC gc)
{
    local color c;
    local int progHeight;

    c.R = 255;
    c.G = 255;
    c.B = 255;
    SetTextColors(c, c, c, c, c, c);

    c.R = 5;
    c.G = 5;
    c.B = 5;
    gc.SetTileColor(c);
    gc.SetStyle(DSTY_Normal);
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');

    c.R = 30;
    c.G = 100;
    c.B = 30;
    gc.SetStyle(DSTY_Normal);
    gc.SetTileColor(c);
    progHeight = height * (float(progress)/float(max));
    gc.DrawPattern(0, height-progHeight, width, progHeight, 0, 0, Texture'Solid');

    Super.DrawWindow(gc);
}

simulated function SetProgress(int tprogress, int tmax)
{
    progress = tprogress;
    max = tmax;
}

//Bingo tiles don't need to handle any key presses
event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	return false;
}
