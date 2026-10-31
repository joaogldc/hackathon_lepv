@echo off
cd /d "%~dp0"
(
echo USERPROFILE=%USERPROFILE%
where uvx
"%USERPROFILE%\.local\bin\uvx.exe" --version
) > verificar_uv.log 2>&1
