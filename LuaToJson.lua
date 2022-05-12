package.path = package.path .. ";./EncounterZoneList/?.lua"
package.path = package.path .. ";./Dependances/JsonLua/json.lua"

app = {}

function app:isDemoBuild()
  return false
end

require("Math")
local encounterZone = require("EncounterList")
json = require("json")

-- Fonction pour ecrire dans un fichier
function write(text, path,mode)
  mode = mode or "w"

  local file, errorString = io.open( path, mode )

  if not file then
      -- Error occurred; output the cause
      print( "File error: " .. errorString )
  else
      -- Write data to file
      file:write(text)
      -- Close the file handle
      io.close( file )
  end

  file = nil
end

luaTable =  encounterZone:get()
jsonTable = json.encode(luaTable)

--Enregistrer la liste dans un fichier json
write(jsonTable,"G:/Projets/Git/Outils/CoromonUnpacker/EncounterZoneList/EncounterList.json")