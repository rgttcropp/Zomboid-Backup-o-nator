@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
:: Date and time
for /f "tokens=*" %%a in ('powershell -Command "(Get-Date).ToString('dd-MM-yyyy__HH-mm')"') do set "date_time=%%a"

cls

:: Check if the script is run with administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This program must be run as an administrator.
    echo To do this, right-click on the script and choose "Run as administrator".
    pause
    exit /b
)

cls

echo.
echo Cropp Rgtt
echo  ____    _  _  _      ____ 
echo (  _ \  / )/ )( \ ___(__  )
echo  ) _ ( / / ) \/ ((___)/ _/ 
echo (____/(_/  \____/    (____)
echo.
echo ==============================
echo    Zomboid Backup-o-nator
echo ==============================
echo.
echo This program allows you to backup Project Zomboid saves.
echo.
echo Press any key to start...
pause > nul

:: Set backup source folder with no extra quotes. (Sandbox, Apocalypse ...)
set "SRC_BASE=C:\Users\%USERNAME%\Zomboid\Saves\Sandbox"
:: Backups folder will be created, change the destination folder
set "DEST_BASE=C:\Users\%USERNAME%\Zomboid\Saves"
if not exist "!DEST_BASE!\Backups" (
    mkdir "!DEST_BASE!\Backups"
)

:START
set count=1
cls
echo ====================
echo     SAVE LIST
echo ====================
echo.
echo Choose the save to backup or type "0" to exit:
for /d %%F in (%SRC_BASE%\*) do (
    echo !count! - %%~nxF
    set "folder[!count!]=%%F"
    set /a count+=1
)
echo.
echo 0 - Exit
echo.
set /p choice=Enter the number you want to backup: 

:: If the user types 0
if "%choice%"=="0" (
    echo Exiting the program...
    exit /b
)

:: Check if the choice is valid
if defined folder[%choice%] (

    :: Extract the name of the selected folder
    for %%F in (!folder[%choice%]!) do (
        set "folder_name=%%~nxF"
    )
    echo.
    echo You selected the folder: !folder_name!
    timeout /t 2 /nobreak > nul

    :: Create the backup folder with the date and time
    set "backup_folder=%DEST_BASE%\Backups\Backup-%date_time%\!folder_name!"

    :: Perform the backup
    cls
    echo.
    echo Performing the backup...
    echo.
    robocopy "!folder[%choice%]!" "!backup_folder!" /E /COPYALL /ZB /R:3 /W:5 >> temp_log.txt 2>&1
    type temp_log.txt
    cls

    :: Check if robocopy was successful
    if %errorlevel% leq 3 (
        cls
        echo Backup of folder !folder_name! was successful!
		:: del log file
        del temp_log.txt
    ) else (
        cls
        echo.
        echo ERROR
        echo An error occurred during backup. >> temp_log.txt
        echo Please check if the destination folder is accessible and if there is enough space. >> temp_log.txt
        echo Make sure no other programs are using the files. >> temp_log.txt
        echo Error details: >> temp_log.txt
        echo ================================ >> temp_log.txt
        echo Error code: %errorlevel% >> temp_log.txt
        echo ================================ >> temp_log.txt
        echo. >> temp_log.txt
        echo.
        echo Something went wrong during the backup. Please check the log file!
        echo Ensure that the destination folder is accessible and there is enough space.
        echo.
      
        :: Move the log file to the backup destination
        set "log_file=%DEST_BASE%\Backup\Backup-%date_time%\Backup-log-%date_time%.txt"
        move /Y temp_log.txt "!log_file!"

        echo The log file has been moved to: !log_file!
        pause
        exit /b
    )
) else (
    cls
    echo Invalid folder number. Please try again and choose a valid number.
    pause
    goto START
)

echo Press any key to go back to the start and make another backup...
pause > nul
goto START
