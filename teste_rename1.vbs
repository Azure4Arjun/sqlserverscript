Option Explicit

Dim objFSO, objFolder, objFile, strNewName, strOldName
Dim strPath, strName, strDate

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder("D:\scripts\rename_files")
For Each objFile In objFolder.Files
  ' Check if file name ends with ".txt".
  If (Right(LCase(objFile.Name), 4) = ".abf") Then
    ' Rename the file.
    strOldName = objFile.Path
    strPath = objFile.ParentFolder
    strName = objFile.Name
    strDate = replace(date, "/", "")
    ' Change name by changing extension to ".bak"
    strName = Left(strName, Len(strName) - 4) & "_" & strDate & ".abf"
    strNewName = strPath & "\" & strName
    ' Rename the file.
    Wscript.Echo strOldName & " : " & strNewName
    objFSO.MoveFile strOldName, strNewName
  End If
Next

'Set objFSO =  Nothing
'Set objFolder =  =  Nothing
'Set objFile =  =  Nothing 
'Set strNewName  =  Nothing
'Set strOldName =  =  Nothing
