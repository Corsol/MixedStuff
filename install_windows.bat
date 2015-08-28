@echo off
REM # Quick install section
REM # This will automatically use the variables below to install the world databases without prompting then optimize them and exit
REM # To use: Set your environment variables below

REM # -- Change the values below to match your server --

Set svr=localhost
Set user=mangos
Set pass=mangos
Set port=3306
Set admin=root
Set adminpass=yourpassword
Set sd2Path=..\server\src\bindings\scripts\sql

REM # -- Don't change after this point --
Set wdb=mangos
Set cdb=characters
Set rdb=realmd
Set sdb=scriptdev2
REM Set ddb=dbc

Set yesno=y
Set yesnoDefault=y
Set dbpath=full_db
Set worldPath=World\Setup
Set worldUpdates=World\Updates
Set charPath=Character\Setup
Set realmPath=Realm\Setup
Set realmUpdates=Realm\Updates
REM Set dbcPath=DBC\Setup
Set updates_path=under_dev
Set mysql=Tools\

CLS
echo.
echo ((--- Mangos World Database Installer ---))

if not exist %mysql%\mysql.exe goto patherror:

echo. 
echo. 
echo MM   MM         MM   MM  MMMMM   MMMM   MMMMM
echo MM   MM         MM   MM MMM MMM MM  MM MMM MMM
echo MMM MMM         MMM  MM MMM MMM MM  MM MMM
echo MM M MM         MMMM MM MMM     MM  MM  MMM
echo MM M MM  MMMMM  MM MMMM MMM     MM  MM   MMM
echo MM M MM M   MMM MM  MMM MMMMMMM MM  MM    MMM
echo MM   MM     MMM MM   MM MM  MMM MM  MM     MMM
echo MM   MM MMMMMMM MM   MM MMM MMM MM  MM MMM MMM
echo MM   MM MM  MMM MM   MM  MMMMMM  MMMM   MMMMM
echo         MM  MMM https://getmangos.eu
echo         MMMMMM  https://getmangos.eu/wiki 
echo. 
echo Credits to: Factionwars, Nemok, BrainDedd, Antz and Corsol
echo ==========================================================
echo. 
color 
set /p svr=What is your MySQL host name? [localhost] : 
if "%svr%" == "" set svr=localhost
set /p port=What is your MySQL port? [3306] : 
if "%port%" == "" set port=3306
set /p user=What is your MySQL user name? [mangos] : 
if "%user%" == "" set user=mangos
set /p pass=What is your MySQL password? [mangos] : 
if "%pass%" == "" set pass=mangos
set /p admin=What is the name of a user that can create databases? [root] : 
if "%admin%" == "" set admin=root
set /p adminpass=What is the password of your user that can create databases? [root] : 
if "%adminpass%" == "" Set adminpass=root

echo.
set /p yesno=Is your first installation? (y\n, default: y) :
if "%yesno%" == "" set yesno=%yesnoDefault%
if "%yesno%" == "y" (
	goto dbCreation: 
) else (
	goto realm:
)
goto finish:


:dbCreation
	echo.
	echo Creating all databases from World\Setup\mangosdCreateDB.sql
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% < World\Setup\mangosdCreateDB.sql
	echo Done
	
:realm
echo.
echo This will wipe out your current Realm database and replace it. 
Set yesno=
Set /p yesno=Do you wish to continue? (y\n, default: y) :
if "%yesno%" == "" set yesno=%yesnoDefault%
if "%yesno%" == "y" (
	echo. 
	echo Importing Realm database from %realmPath%\realmdLoadDB.sql
	
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %rdb% < %realmPath%\realmdLoadDB.sql

	echo. 
	echo Importing dbdocs updates... 
	for %%s in (Realm\Updates\Rel20\*.sql) do ( 
		echo %%s
		%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %rdb% < %%s )

	echo.
	echo Importing Rel21 updates... 
	for %%s in (%realmUpdates%\Rel21\*.sql) do (
		echo %%s & %mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %rdb% < %%s )
		
	echo Done
) else (
	echo Realm installations has been skipped
)

:character
echo. 
echo This will wipe out your current Character database and replace it. 
Set yesno=
Set /p yesno=Do you wish to continue? (y\n, default: y) :
if "%yesno%" == "" set yesno=%yesnoDefault%
if "%yesno%" == "y" (
	echo.
	echo Importing Character database from: %charPath%\characterLoadDB.sql 
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %cdb% < %charPath%\characterLoadDB.sql
	
	echo Done
) else (
	echo Character installations has been skipped
)

:world
echo.
echo This will wipe out your current World database and replace it. 
Set yesno=
Set /p yesno=Do you wish to continue? (y\n, default: y) :
if "%yesno%" == "" set yesno=%yesnoDefault%
if "%yesno%" == "y" (
	echo.
	echo Importing World database... %worldPath%\mangosdLoadDB.sql 

	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %worldPath%\mangosdLoadDB.sql
	echo.
	for %%s in (%worldPath%\FullDB\*.sql) do (
		echo %%s 
		%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %%s )

	echo Importing Rel18 updates...
	for %%s in (%worldUpdates%\Rel18\*.sql)	do (
		echo %%s 
		%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %%s )

	echo.
	echo Importing Rel19 updates... 
	for %%s in (%worldUpdates%\Rel19\*.sql)	do (
		echo %%s 
		%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %%s )
	
	echo.
	echo Importing under_dev updates... 
	for %%s in (%updates_path%\*.sql) do (
		echo %%s 
		%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %%s )

	echo Done
) else (
	echo World installations has been skipped.
)


REM :dbc
REM echo 
REM Set yesno=
REM Set /p yesno=Do you want to install additional DBC-files tables? (y\n, default: y) :
REM if "%yesno%" == "" set yesno=%yesnoDefault%
REM if "%yesno%" == "y" (
REM 	echo 
REM 	echo Creating DBC database... %dbcPath%\dbcCreateDB.sql
REM 	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% < %dbcPath%\dbcCreateDB.sql
	
REM 	echo 
REM 	for %%s in ()%dbcPath%\DataFiles\*.sql)	do (
REM 		echo %%s 
REM			%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %ddb% < %%s )

REM 	echo Done
REM ) else (
REM 	echo DBC installations has been skipped
REM )

:sd2
echo. 
echo This will wipe out your current ScriptDev2 database and replace it. 
Set yesno=
Set /p yesno=Do you wish to continue? (y\n, default: y) :
if "%yesno%" == "" set yesno=%yesnoDefault%
if "%yesno%" == "y" (
	if not exist %sd2Path%\scriptdev2_create_database.sql goto sd2PathError:
	echo.
	echo Creating database from  %sd2Path%\scriptdev2_create_database.sql
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% < %sd2Path%\scriptdev2_create_database.sql
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %sdb% < %sd2Path%\scriptdev2_create_structure_mysql.sql

	echo.
	echo Importing ScriptDev2 database from  %sd2Path%\scriptdev2_script_full.sql
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %sdb% < %sd2Path%\scriptdev2_script_full.sql
	
	echo.
	echo Reset Mangos scriptName information from  %sd2Path%\mangos_scriptname_full.sql
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %sd2Path%\mangos_scriptname_clear.sql
	%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %sd2Path%\mangos_scriptname_full.sql

	echo.
	echo Importing updates... 
	for %%s in (%sd2Path%\updates\*.sql) do (
		echo %%s 
		%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %%s )

	echo.
	echo Importing extra creature scripts... 
	for %%s in (%sd2Path%\optional\*.sql) do (
		echo %%s 
		%mysql%mysql -q -s -h %svr% --user=%admin% --password=%adminpass% --port=%port% %wdb% < %%s )

	echo Done
) else (
	echo ScriptDev2 installations has been skipped
)
goto finish:

:sd2PathError
echo Cannot find the SQL script for ScriptDev2 at path %sd2Path%
echo ScriptDev2 installation aborted.
goto finish:

:patherror
echo Cannot find the mysql.exe into path  %mysql%
echo Installation aborted.

:finish
echo.
pause