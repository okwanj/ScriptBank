@echo off    
rem //���ñ���     
set NAME="��������"    
rem //��������ֵ���Ը�����Ҫ����    
set ADDR=192.168.200.82    
set MASK=255.255.252.0    
set GATEWAY=192.168.207.254
set DNS1=192.168.207.254
set DNS2=8.8.8.8    
rem //������������ΪIP��ַ���������롢���ء���ѡDNS������DNS    
    
echo ��ǰ���ò����У�    
echo 1 ����Ϊ��̬IP    
echo 2 ����Ϊ��̬IP    
echo 3 �˳�    
echo ��ѡ���س���    
set /p operate=    
if %operate%==1 goto 1    
if %operate%==2 goto 2    
if %operate%==3 goto 3    
    
:1    
echo �������þ�̬IP�����Ե�...    
rem //���Ը��������Ҫ����     
echo IP��ַ = %ADDR%    
echo ���� = %MASK%    
echo ���� = %GATEWAY%    
netsh interface ipv4 set address name=%NAME% source=static addr=%ADDR% mask=%MASK% gateway=%GATEWAY% gwmetric=0 >nul     
echo ��ѡDNS = %DNS1%     
netsh interface ipv4 set dns name=%NAME% source=static addr=%DNS1% register=PRIMARY >nul     
echo ����DNS = %DNS2%     
netsh interface ipv4 add dns name=%NAME% addr=%DNS2% index=2 >nul     
echo ��̬IP�����ã�    
pause    
goto 3    
    
:2    
echo �������ö�̬IP�����Ե�...    
echo ���ڴ�DHCP�Զ���ȡIP��ַ...    
netsh interface ip set address "��������" dhcp    
echo ���ڴ�DHCP�Զ���ȡDNS��ַ...    
netsh interface ip set dns "��������" dhcp     
echo ��̬IP�����ã�    
pause    
goto 3    
    
:3    
exit   