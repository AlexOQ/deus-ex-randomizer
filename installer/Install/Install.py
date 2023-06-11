import os
from Install import *
from Install import _DetectFlavors
from Install import MapVariants

def DetectFlavors(exe:Path) -> list:
    assert exe.name.lower() == 'deusex.exe'
    system:Path = exe.parent
    assert system.name.lower() == 'system'
    return _DetectFlavors(system)


def Install(exe:Path, flavors:dict, speedupfix:bool) -> list:
    assert exe.name.lower() == 'deusex.exe'
    system:Path = exe.parent
    assert system.name.lower() == 'system'

    print('Installing flavors:', flavors, speedupfix)

    for(f, settings) in flavors.items():
        if 'Vanilla'==f:
            InstallVanilla(system, settings, speedupfix)
        if 'Vanilla? Madder.'==f:
            CreateModConfigs(system, settings, 'VMD', 'VMDSim')
        if 'GMDX v9'==f:
            InstallGMDX(system, settings, 'GMDXv9')
        if 'GMDX RSD'==f:
            InstallGMDX(system, settings, 'GMDXvRSD')
        if 'GMDX v10'==f:
            CreateModConfigs(system, settings, 'GMDX', 'GMDXv10')
        if 'Revision'==f:
            InstallRevision(system, settings)
        if 'HX'==f:
            InstallHX(system, settings)

    if speedupfix:
        EngineDllFix(system)
    return flavors


def InstallVanilla(system:Path, settings:dict, speedupfix:bool):
    gameroot = system.parent

    exe_source = GetSourcePath() / '3rdParty' / "KentieDeusExe.exe"
    exetype = settings['exetype']
    kentie = True
    if exetype == 'Launch':
        exe_source = GetSourcePath() / '3rdParty' / "Launch.exe"
        kentie = False
    exename = 'DXRando'
    # TODO: allow separate exe file for linux
    # maybe I can create the SteamPlay config file needed? I think it's a .desktop file
    if not IsWindows():
        exename = 'DeusEx'
    exedest:Path = system / (exename+'.exe')
    CopyTo(exe_source, exedest)

    intfile = GetSourcePath() / 'Configs' / 'DXRando.int'
    intdest = system / (exename+'.int')
    CopyTo(intfile, intdest)

    ini = GetSourcePath() / 'Configs' / "DXRandoDefault.ini"
    defini_dest = system / (exename+'Default.ini') # I don't think Kentie cares about this file, but Han's Launchbox does
    CopyTo(ini, defini_dest)

    # TODO: retain old resolution choices and stuff like that
    if kentie:
        configs_dest = Path.home() / 'Documents' / 'Deus Ex' / 'System'
    else:
        configs_dest = system
    DXRandoini = configs_dest / (exename+'.ini')
    DXRandoini.parent.mkdir(parents=True, exist_ok=True)
    CopyTo(ini, DXRandoini)

    changes = {}
    if not speedupfix:
        changes['DeusExe'] = {'FPSLimit': '120'}
        changes['D3D10Drv.D3D10RenderDevice'] = {'FPSLimit': '120', 'VSync': 'True'}

    if not IsWindows():
        changes['Engine.Engine'] = {'GameRenderDevice': 'D3DDrv.D3DRenderDevice'}
        changes['WinDrv.WindowsClient'] = {'StartupFullscreen': 'True'}

    if changes:
        b = defini_dest.read_bytes()
        b = Config.ModifyConfig(b, changes, additions={})
        defini_dest.write_bytes(b)

        b = DXRandoini.read_bytes()
        b = Config.ModifyConfig(b, changes, additions={})
        DXRandoini.write_bytes(b)

    dxrroot = gameroot / 'DXRando'
    (dxrroot / 'Maps').mkdir(exist_ok=True, parents=True)
    CopyPackageFiles('vanilla', gameroot, ['DeusEx.u'])
    CopyD3D10Renderer(system)

    if settings.get('mirrors'):
        MapVariants.InstallMirrors(dxrroot / 'Maps', settings.get('downloadcallback'), 'Vanilla')


def InstallGMDX(system:Path, settings:dict, exename:str):
    (changes, additions) = GetConfChanges('GMDX')
    # GMDX uses absolute path shortcuts with ini files in their arguments, so it's not as simple to copy their exe

    confpath = Path.home() / 'Documents' / 'Deus Ex' / exename / 'System' / 'gmdx.ini'
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        confpath.write_bytes(b)

    confpath = system / exename / 'System' / 'gmdx.ini'
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        confpath.write_bytes(b)

    CopyPackageFiles('GMDX', system.parent, ['GMDXRandomizer.u'])


def InstallRevision(system:Path, settings:dict):
    # Revision's exe is special and calls back to Steam which calls the regular Revision.exe file, so we pass in_place=True
    revsystem = system.parent / 'Revision' / 'System'
    CreateModConfigs(revsystem, settings, 'Rev', 'Revision', in_place=True)


def InstallHX(system:Path, settings:dict):
    CopyPackageFiles('HX', system.parent, ['HXRandomizer.u'])
    (changes, additions) = GetConfChanges('HX')
    ChangeModConfigs(system, settings, 'HX', 'HX', 'HX', changes, additions, True)
    int_source = GetPackagesPath('HX') / 'HXRandomizer.int'
    int_dest = system / 'HXRandomizer.int'
    CopyTo(int_source, int_dest)


def CreateModConfigs(system:Path, settings:dict, modname:str, exename:str, in_place:bool=False):
    exepath = system / (exename+'.exe')
    newexename = modname+'Randomizer'
    newexepath = system / (newexename+'.exe')
    modpath = system.parent / (modname+'Randomizer')
    mapspath = modpath / 'Maps'
    mapspath.mkdir(exist_ok=True)
    if not IsWindows():
        in_place = True
    if not in_place:
        CopyTo(exepath, newexepath)

    intfile = GetSourcePath() / 'Configs' / 'DXRando.int'
    intdest = system / (newexename+'.int')
    CopyTo(intfile, intdest)

    CopyPackageFiles(modname, system.parent, [modname+'Randomizer.u'])

    (changes, additions) = GetConfChanges(modname)
    ChangeModConfigs(system, settings, modname, exename, newexename, changes, additions, in_place)

    if settings.get('mirrors'):
        MapVariants.InstallMirrors(mapspath, settings.get('downloadcallback'), modname)


def ChangeModConfigs(system:Path, settings:dict, modname:str, exename:str, newexename:str, changes:dict, additions:dict, in_place:bool=False):
    # inis
    confpath = system / (exename + 'Default.ini')
    b = confpath.read_bytes()
    b = Config.ModifyConfig(b, changes, additions)
    outconf = system / (newexename + 'Default.ini')
    if in_place:
        outconf = confpath
    outconf.write_bytes(b)

    confpath = system / (exename + '.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        outconf = system / (newexename + '.ini')
        if in_place:
            outconf = confpath
        outconf.write_bytes(b)

    # User inis
    if in_place:
        return
    confpath = system / (exename + 'DefUser.ini')
    b = confpath.read_bytes()
    b = Config.ModifyConfig(b, changes, additions)
    outconf = system / (newexename + 'DefUser.ini')
    if in_place:
        outconf = confpath
    outconf.write_bytes(b)

    confpath = system / (exename + 'User.ini')
    if confpath.exists():
        b = confpath.read_bytes()
        b = Config.ModifyConfig(b, changes, additions)
        outconf = system / (newexename + 'User.ini')
        if in_place:
            outconf = confpath
        outconf.write_bytes(b)
