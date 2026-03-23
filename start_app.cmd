@echo off
echo Starting CoM-PAS AIBuddy Backend...
start "AIBuddy Backend" cmd /k "python backend\run.py"

echo Starting CoM-PAS AIBuddy Mobile App...
echo Using Flutter at: C:\src\flutter\bin\flutter.bat

cd mobile_app
"C:\src\flutter\bin\flutter.bat" run -d chrome
pause
