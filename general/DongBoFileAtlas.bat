@echo off
setlocal enabledelayedexpansion

echo Dang quet TOAN BO cac thu muc con de xu ly Spine...
echo --------------------------------------------------

:: 1. Duyet qua TOAN BO thu muc con (dung /r de quet de quy)
for /r /d %%D in (*) do (
    set "folder=%%D"
    
    :: Di vao thu muc con
    pushd "%%D"

    :: 2. Tim file .skel de lay ten lam chuan
    set "BaseName="
    for %%s in (*.skel) do (
        if not defined BaseName set "BaseName=%%~ns"
    )

    if defined BaseName (
        echo.
        echo [THU MUC] Dang xu ly: "!folder!"
        echo    [INFO] Da chon ten chuan: !BaseName!

        :: 3. Tao script VBS tam thoi (dat trong thu muc temp cua he thong)
        set "vbsfile=%temp%\fix_spine_!random!.vbs"
        (
            echo Set fso = CreateObject("Scripting.FileSystemObject"^)
            echo Set regEx = New RegExp
            echo regEx.Global = True
            echo Function CleanAtlas(content^)
            echo     Dim s: s = content
            echo     s = Replace(s, "\r\n", vbCrLf^)
            echo     s = Replace(s, """", ""^)
            echo     s = Replace(s, "[", ""^)
            echo     s = Replace(s, "]", ""^)
            echo     Dim pos: pos = InStr(s, ".png"^)
            echo     If pos ^> 0 Then
            echo         Dim startLine: startLine = InStrRev(s, vbCrLf, pos^)
            echo         If startLine ^> 0 Then s = Mid(s, startLine + 2^)
            echo     End If
            echo     Dim lastIdx: lastIdx = InStrRev(s, "index: -1"^)
            echo     If lastIdx ^> 0 Then s = Left(s, lastIdx + 9^)
            echo     Set reg = New RegExp
            echo     reg.Pattern = "^\s*.*\.png"
            echo     reg.Multiline = True
            echo     s = reg.Replace(s, "!BaseName!.png"^)
            echo     CleanAtlas = s
            echo End Function
            echo Set file = fso.OpenTextFile(WScript.Arguments(0^), 1^)
            echo content = file.ReadAll: file.Close
            echo Set outfile = fso.CreateTextFile(WScript.Arguments(1^), True^)
            echo outfile.Write CleanAtlas(content^): outfile.Close
        ) > "!vbsfile!"

        :: 4. Quet va xu ly file .json (Atlas)
        for %%f in (*.json) do (
            findstr /m ".png" "%%f" >nul
            if !errorlevel! == 0 (
                echo    [OK] Dang lam sach: %%f -^> !BaseName!.atlas
                cscript //nologo "!vbsfile!" "%%f" "!BaseName!.atlas"
                del "%%f"
            ) else (
                echo    [XOA] File JSON rac: %%f
                del "%%f"
            )
        )

        :: 5. Dong bo file .png neu co
        for %%p in (*.png) do (
            set "imgName=%%~np"
            if /i "!imgName!" neq "!BaseName!" (
                echo    [OK] Dong bo anh: %%p -^> !BaseName!.png
                ren "%%p" "!BaseName!.png"
            )
        )
        
        :: Xoa file VBS tam
        if exist "!vbsfile!" del "!vbsfile!"
        echo    [HOAN THANH] Da xong !BaseName!
    )
    
    :: Thoat khoi thu muc con
    popd
)

echo.
echo --------------------------------------------------
echo [TAT CA DA HOAN THANH]
pause