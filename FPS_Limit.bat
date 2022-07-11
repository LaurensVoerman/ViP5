@cd /D "%~dp0"
@SET "UE_5=C:\Program Files\Epic Games\UE_5.0\Engine\Binaries\Win64\UnrealEditor.exe"
@FOR /F "usebackq tokens=1,2* " %%i in (`reg QUERY "HKLM\SOFTWARE\EpicGames\Unreal Engine\5.0" /v "InstalledDirectory" 2^> NUL`) do @(
@if %%i==InstalledDirectory @if %%j==REG_SZ set "UE_5=%%k\Engine\Binaries\Win64\UnrealEditor.exe"
)
@if not exist "%UE_5%" @(
@echo UnrealEditor not found; "%UE_5%"
@GOTO :EOF
)
@echo UnrealEditor found:  "%UE_5%"
rem fake builddata
for %%i in (Content\VirtualRealityBP\Maps\*.umap) do (
  	if not exist Content\VirtualRealityBP\Maps\%%~ni_BuiltData.uasset (
  		fsutil file createnew Content\VirtualRealityBP\Maps\%%~ni_BuiltData.uasset 0
  	)
)

for %%i in (*.uproject) do (
start "UE4" /b "%UE_5%" "%~dp0%%i" -ExecCmds="t.MaxFPS 30"
rem start "UE4" /b "argprint.exe" "%~dp0%%i" -ExecCmds="t.MaxFPS 30"
GOTO :EOF
)
