@echo off
echo Instalando uv (necessario para o Godot AI)...
powershell -NoProfile -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
echo.
echo Pronto. Pode fechar esta janela.
pause
