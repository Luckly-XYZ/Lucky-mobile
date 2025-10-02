@echo off
chcp 65001 > nul

setlocal
REM 操作说明：因不能查看设备应用数据库  故 通过adb连接设备 导出 指定包名 数据库
adb exec-out "run-as com.xy.mobile cat /data/data/com.xy.mobile/databases/im_db.db" > im_db.db
endlocal