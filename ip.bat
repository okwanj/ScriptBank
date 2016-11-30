@echo off    
rem //设置变量     
set NAME="本地连接"    
rem //以下属性值可以根据需要更改    
set ADDR=192.168.200.82    
set MASK=255.255.252.0    
set GATEWAY=192.168.207.254
set DNS1=192.168.207.254
set DNS2=8.8.8.8    
rem //以上属性依次为IP地址、子网掩码、网关、首选DNS、备用DNS    
    
echo 当前可用操作有：    
echo 1 设置为静态IP    
echo 2 设置为动态IP    
echo 3 退出    
echo 请选择后回车：    
set /p operate=    
if %operate%==1 goto 1    
if %operate%==2 goto 2    
if %operate%==3 goto 3    
    
:1    
echo 正在设置静态IP，请稍等...    
rem //可以根据你的需要更改     
echo IP地址 = %ADDR%    
echo 掩码 = %MASK%    
echo 网关 = %GATEWAY%    
netsh interface ipv4 set address name=%NAME% source=static addr=%ADDR% mask=%MASK% gateway=%GATEWAY% gwmetric=0 >nul     
echo 首选DNS = %DNS1%     
netsh interface ipv4 set dns name=%NAME% source=static addr=%DNS1% register=PRIMARY >nul     
echo 备用DNS = %DNS2%     
netsh interface ipv4 add dns name=%NAME% addr=%DNS2% index=2 >nul     
echo 静态IP已设置！    
pause    
goto 3    
    
:2    
echo 正在设置动态IP，请稍等...    
echo 正在从DHCP自动获取IP地址...    
netsh interface ip set address "本地连接" dhcp    
echo 正在从DHCP自动获取DNS地址...    
netsh interface ip set dns "本地连接" dhcp     
echo 动态IP已设置！    
pause    
goto 3    
    
:3    
exit   