@echo off
set xv_path=F:\\yingjian\\xilinx\\Vivado\\2016.2\\bin
call %xv_path%/xelab  -wto 01d27565e07e4ea688649f850d4efd06 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot myKeyboardSim_behav xil_defaultlib.myKeyboardSim xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
