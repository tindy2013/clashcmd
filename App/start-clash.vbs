path = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
profile = path + "\..\Profile"
CreateObject("WScript.Shell").Run Chr(34) + path + "\clash-win64.exe" + Chr(34) + " -d " + Chr(34) + profile + Chr(34),0
