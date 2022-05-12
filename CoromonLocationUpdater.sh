#!/bin/bash
corona_archiver=".\Dependances\CoronaArchiver\corona-archiver.exe"                       #Location of your corona archiver executable to unpacked *.car packages
unLuac=".\Dependances\UnLuac\unluac.jar"                                                 #Location of your unluac jar for decompiling *.lu files
resourceCar="F:\Programmes\SteamGames\steamapps\common\Coromon\Resources\resource.car"   #Location of the resource.car archive in the Coromon Games
coromonUnpacker='./'                                                                     #Root of the Coromon Unpacker Tools
coromonLocationData='G:\Projets\Git\Coromon-Location\data\'
logFile="./CoromonUnpacker.log"
pwd=$(pwd -W)

# function to clear from temporary needed directories
clear_directories(){
    d1=$coromonUnpacker'PackageUnpacked\'
    d2=$coromonUnpacker'EncounterZoneList\'

    if test -d "$d1" ; then
        rm -rd $coromonUnpacker'PackageUnpacked\'
        echo "Removing $pwd/PackageUnpacked/ directory" >> "$logFile"
    fi

    if test -d "$d2" ; then
        rm -rd $coromonUnpacker'EncounterZoneList\'
        echo "Removing $pwd/EncounterZoneList/ directory" >> "$logFile"
    fi
}

#Begin of the operation by testing if Coromon game is installed or not at the specified location
if test -f "$resourceCar"; then
    clear_directories
    if test -e "$logFile" ; then
        touch "$logFile"
    fi

    mkdir $coromonUnpacker'PackageUnpacked\'
    echo "Creating $pwd/PackageUnpacked/ directory" > "$logFile"

    mkdir $coromonUnpacker'EncounterZoneList\'
    echo "Creating $pwd/EncounterZoneList/ directory" >> "$logFile"


    #Decompressing the Coromon game Resource.car
    {
        echo "Unpacking coromon Resource.car" >> "$logFile"
        $corona_archiver -u $resourceCar $coromonUnpacker'PackageUnpacked\'
    } || {
        echo "[E] Error when trying to unpack the Resource.car." >> "$logFile"
        clear_directories
        exit 1
    }


    #We need the math library for executing the EncounterZone lua
    {
        cp $coromonUnpacker'PackageUnpacked\classes.libraries.math.lu' $coromonUnpacker'EncounterZoneList\'                             #we're extracting the math library
        echo "Math librairy binary copied to be decompiled." >> "$logFile"
        java -jar $unLuac $coromonUnpacker'EncounterZoneList\classes.libraries.math.lu' > $coromonUnpacker'EncounterZoneList\Math.lua'  #and we decompiled it
        echo "Math library decompiled" >> "$logFile"
    } || {
        echo "[E] Error when copying or decompiling the Math library " >> "$logFile"
        clear_directories
        exit 1
    }

    {
        cp 'G:\Projets\Git\Outils\CoromonUnpacker\PackageUnpacked\classes.lists.EncounterZoneList.lu' 'G:\Projets\Git\Outils\CoromonUnpacker\EncounterZoneList\' #we're do the same with
        echo "EncounterZoneList binary copied to be decompiled." >> "$logFile"
        java -jar $unLuac  $coromonUnpacker'EncounterZoneList\classes.lists.EncounterZoneList.lu' >  $coromonUnpacker'EncounterZoneList\EncounterListTmp.lua'   #the EncounterList lua
        echo "EncounterZoneList binary decompiled" >> "$logFile"
    } || {
        echo "[E] Error when copying or decompiling the EncounterZoneList" >> "$logFile"
        clear_directories
        exit 1
    }


    #we're overriting the "createEncounterZone" function
    {
        python $coromonUnpacker'OverrideCreateEncounterZone.py'
        echo "'createEncounterZone' overridden. EncounterList.lua created" >> "$logFile"
    } || {
        echo "[E] Error when exexuting the python script $coromonUnpacker'OverrideCreateEncounterZone.py'" >> "$logFile"
        clear_directories
        exit 1
    }

    #And we're executing the convertion into a JSON file
    {
        lua $coromonUnpacker'LuaToJson.lua'
        echo "Lua executed. JSON created with the complete encounter table." >> "$logFile"

        cp $coromonUnpacker'EncounterZoneList\EncounterList.json' $coromonLocationData
        echo "JSON copied to the target location : $coromonLocationData" >> "$logFile"
    } || {
        echo "[E] Error when executing the lua to create the JSON : $coromonUnpacker'LuaToJson.lua''" >> "$logFile"
        clear_directories
        exit 1
    }

    clear_directories
else
    echo "You haven't any Coromon Games at the location $resourceCar
Be sure to have the game installed and modify the CoromonLocationUpdater.sh file accordingly." > "$logFile"
fi

