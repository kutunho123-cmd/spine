@echo off
chcp 65001 > nul
title Doi Tat Ca BIN thanh SKEL (Don Gian)

echo Bat dau tim va doi ten tat ca cac file *.bin thanh *.skel...
echo.

:: =======================================================
:: LỆNH THỰC THI (Lap qua tat ca cac file *.bin va doi ten)
:: REN "%%f" "%%~nf.skel"
:: %%f: Duong dan day du cua file goc
:: %%~nf: Ten file goc khong co duoi
:: =======================================================
FOR /R . %%f IN (*.bin) DO (
    REN "%%f" "%%~nf.skel"
)

echo.
echo =======================================================
echo Da hoan tat qua trinh doi ten!
echo =======================================================

pause