# The goal is to override a function called createEncounterZone
# in the lua decompiled to be able to extract
# the json needed for the Coromon Location app

findFunction = False

with open("G:/Projets/Git/Outils/CoromonUnpacker/EncounterZoneList/EncounterListTmp.lua","r") as f: #location of the decompiled EncounterList file
    contents = f.readlines()

out_file = []
for line in contents:
    out_file.append(line)
    if "local function createEncounterZone" in line:  #we're looking for the function
        findFunction = True
    if line == "end\n" and findFunction:    #and we're adding the same function just after it with out code
        out_file.append("function createEncounterZone(number,table)\n")
        out_file.append("  return {step=number,\n")
        out_file.append("    encounter=table}\n")
        out_file.append("end\n")

with open("G:/Projets/Git/Outils/CoromonUnpacker/EncounterZoneList/EncounterList.lua","w") as f: #and we're creating a new lua file we can execute after
    f.writelines(out_file)