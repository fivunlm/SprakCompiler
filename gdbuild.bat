
@echo off

tools\PCYACC.EXE -v Grupo05.y

if %ERRORLEVEL% == 0 (

gcc -fpermissive -Wwrite-strings -g GRUPO05.C -lstdc++ -o out/Grupo05.exe

)

if %ERRORLEVEL% == 0 (

copy test\pruebagral.txt out\

cd out\

gdb Grupo05.exe

cd ..
)

