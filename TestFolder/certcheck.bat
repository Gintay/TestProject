@echo off
set logfile=certcheck.log
set CERT_VERISIGN_INT="Symantec Class 3 SHA256 Code Signing CA"
set SN_VERISIGN_INT=3d78d7f9764960b2617df4f01eca862a
set CERT_VERISIGN_ROOT="VeriSign Class 3 Public Primary Certification Authority - G5"
set SN_VERISIGN_ROOT=18dad19e267de8bb4a2158cdcc6b3b4a

echo Certificate chain validation [%DATE% %TIME%] > %logfile%
echo Checking certificate [%CERT_VERISIGN_INT%]...
certutil -verifystore CA %SN_VERISIGN_INT% >> %logfile%
if %ERRORLEVEL% equ 0 (
	echo ...found in local machine CA store
	goto :check_verisign_root
)
echo ...not found in local machine CA store
certutil -user -verifystore CA %SN_VERISIGN_INT% >> %logfile%
if %ERRORLEVEL% equ 0 (
	echo ...found in current user CA store
	goto :check_verisign_root
)
echo ...not found in current user CA store
echo Importing certificate [%CERT_VERISIGN_INT%] into "Intermediate Certification Authorities" current user store...
certutil -user -addstore CA %CERT_VERISIGN_INT%.cer >> %logfile%
if %ERRORLEVEL% neq 0 (
	echo ...certificate import failed
	goto end
)
echo ...successfully imported

:check_verisign_root
echo Checking certificate [%CERT_VERISIGN_ROOT%]...
certutil -verifystore AuthRoot %SN_VERISIGN_ROOT% >> %logfile%
if %ERRORLEVEL% equ 0 (
	echo ...found in local machine CA store
	goto :success
)
echo ...not found in local machine CA store
certutil -user -verifystore AuthRoot %SN_VERISIGN_ROOT% >> %logfile%
if %ERRORLEVEL% equ 0 (
	echo ...found in current user CA store
	goto :success
)
echo ...not found in current user CA store
echo Importing certificate [%CERT_VERISIGN_ROOT%] into "Third-Party Root Certification Authorities" current user store...
certutil -user -addstore AuthRoot %CERT_VERISIGN_ROOT%.cer  >> %logfile%
if %ERRORLEVEL% neq 0 (
	echo ...certificate import failed
	goto end
)
echo ...successfully imported

:success
echo All certificates successfully verified

:end