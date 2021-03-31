#cs ----------------------------------------------------------------
Name ..........: Canvas Commons
Description ...: Import thin common cartridge (thin cc) files into Canvas Commons
AutoIt Version : 3.3.14.5
Author(s) .....: Thomas E. Bennett, Anthony R. Perez
Date ..........: Tue Mar 9 9:05:52 CST 2021

When running this macro; make a batch file (.bat or .cmd) with these properties:
"C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "{Path to Script}\Canvas Commons.au3" "email or username" "password" "WebDriver path" ".csv path" "local username"

Recommended Reading / Requirements
https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version-01162021/#comments
https://www.autoitscript.com/wiki/WebDriver
https://www.autoitscript.com/wiki/WebDriver#Installation
https://www.autoitscript.com/wiki/Adding_UDFs_to_AutoIt_and_SciTE
https://www.autoitscript.com/autoit3/docs/intro/running.htm#CommandLine
wd_core.au3
wd_helper.au3

From wd_core.au3
Global Const $_WD_LOCATOR_ByCSSSelector = "css selector"
Global Const $_WD_LOCATOR_ByXPath = "xpath"
Global Const $_WD_LOCATOR_ByLinkText = "link text"
Global Const $_WD_LOCATOR_ByPartialLinkText = "partial link text"
Global Const $_WD_LOCATOR_ByTagName = "tag name"
#ce ----------------------------------------------------------------

#include "wd_core.au3"
#include "wd_helper.au3"
#include <MsgBoxConstants.au3>

Local $sDesiredCapabilities, $sSession, $sPath, $sFile, $sLine, $sCSV, $sFilename, $sArrayNumber, $i, $sSearchTag, $sData

; Update these values to match your environment.
$sPath = $CmdLine[3]
$sFile = FileOpen($CmdLine[4], 0)

Func SetupChrome()
_WD_Option('Driver', $sPath)
_WD_Option('Port', 9515)
;_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\chrome.log"')

$sDesiredCapabilities = '{"capabilities": {"alwaysMatch": {"unhandledPromptBehavior": "ignore", ' & _
    '"goog:chromeOptions": {"w3c": true, "excludeSwitches": ["enable-automation"], "useAutomationExtension": false, ' & _
    '"prefs": {"credentials_enable_service": false},' & _
    '"args": ["start-maximized"] }}}}'
EndFunc

SetupChrome()
_WD_Startup()
$sSession = _WD_CreateSession($sDesiredCapabilities)

; Canvas Login page
_WD_Navigate($sSession, "https://cevmultimedia.instructure.com/login/canvas")
_WD_LoadWait($sSession, 2000)

; Email or Username field
_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='pseudonym_session_unique_id']")
$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='pseudonym_session_unique_id']")
; Email or Username passed by command line parameters
_WD_ElementAction($sSession, $sElement, 'value', $CmdLine[1])

; Password field
_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='pseudonym_session_password']")
$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='pseudonym_session_password']")
; Password passed by command line parameters
_WD_ElementAction($sSession, $sElement, 'value', $CmdLine[2])

; Log in button
_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//button[contains(text(),'Log In')]")
$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[contains(text(),'Log In')]")
; Click the Log in button
_WD_ElementAction($sSession, $sElement, 'click')

While 1
	; Read the .csv file
	Local $sLine = FileReadLine($sFile)
	If @error = -1 Then ExitLoop

	; Split this string by the ;
	$sCSV = StringSplit($sLine, ';', 1)

	$i = $sCSV[0]-1

	; Further split the string by (
	$sFilename = StringSplit ($sCSV[1], '(', 1)

	; Get the last array number
	$sArrayNumber = UBound($sFilename)-1

	; Remove ) from the string and use the last array number to ouput the curriculum id number
	$sFilename = StringReplace ($sFilename[$sArrayNumber], ')', "")

	;MsgBox($MB_SYSTEMMODAL, "Click Start a New Course", "//button[@id='start_new_course']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@id='start_new_course']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@id='start_new_course']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Change the Course Name", "//input[@id='course_name'] Value: " & $sCSV[1] & "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='course_name']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='course_name']")
	_WD_ElementAction($sSession, $sElement, 'value', $sCSV[1])
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Create Course button", "//span[contains(text(),'Create course')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Create course')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Create course')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Settings", "//a[@class='settings']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='settings']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='settings']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Change the Course Code", "//input[@id='course_course_code'] Value: (" & $sFilename & ")")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='course_course_code']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='course_course_code']")
	_WD_ElementAction($sSession, $sElement, 'clear')
	_WD_LoadWait($sSession, 2000)
	_WD_ElementAction($sSession, $sElement, 'value', "(" & $sFilename & ")")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Update Course Details", "//button[contains(text(),'Update Course Details')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//button[contains(text(),'Update Course Details')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[contains(text(),'Update Course Details')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Import Course Content", "//a[@class='Button Button--link Button--link--has-divider Button--course-settings import_content']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='Button Button--link Button--link--has-divider Button--course-settings import_content']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='Button Button--link Button--link--has-divider Button--course-settings import_content']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Select the correct Content Type", "//select[@id='chooseMigrationConverter']//option[contains(text(),'Common Cartridge 1.x Package')]")
	_WD_ElementOptionSelect ($sSession, $_WD_LOCATOR_ByXPath, "//select[@id='chooseMigrationConverter']//option[contains(text(),'Common Cartridge 1.x Package')]")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Choose File", "I know it's ghetto; but it works. :P")
	Send("{TAB}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	Send("{SPACE}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)

	; Upload .imscc file
	; Wait for the file upload window to appear
	WinWaitActive ("[CLASS:#32770]", "Open")
	; Set the input focus on the 'File name:' textbox
	ControlFocus("Open","","Edit1")
	; Type in the file path of the needed file
	ControlSetText("Open","","Edit1","C:\Users\" & $CmdLine[5] & "\Downloads\icevcourse_" & $sFilename & "_canvas.imscc")
	; Click the 'Open' button
	ControlClick("Open","","Button1")
	; End of Upload .imscc file

	_WD_LoadWait($sSession, 4000)

	;MsgBox($MB_SYSTEMMODAL, "Click All content radio button", "//div[contains(@class,'controls selectContent')]//div[1]//label[1]//input[1]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//div[contains(@class,'controls selectContent')]//div[1]//label[1]//input[1]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//div[contains(@class,'controls selectContent')]//div[1]//label[1]//input[1]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Import button", "//input[@id='migrationFileUpload']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='submitMigration']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='submitMigration']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	; Taught how to do the below code:
	; https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version-01162021/page/48/#comments

	;MsgBox($MB_SYSTEMMODAL, "Wait for 'Completed' to appear", "//span[contains(text(),'Completed')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Completed')]", Default, 30*60*1000)
	;MsgBox($MB_SYSTEMMODAL, "Click Settings", "//a[@class='settings']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='settings']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='settings']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

 	;MsgBox($MB_SYSTEMMODAL, "Click Share to Commons", "//a[@class='Button Button--link Button--link--has-divider Button--course-settings course-settings-sub-navigation-lti']")
 	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='Button Button--link Button--link--has-divider Button--course-settings course-settings-sub-navigation-lti']']")
 	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='Button Button--link Button--link--has-divider Button--course-settings course-settings-sub-navigation-lti']")
 	_WD_ElementAction($sSession, $sElement, 'click')
 	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Enter the iframe and check Public (any Canvas Commons user)", "")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//iframe[@id='tool_content']")
	; !!! -- ENTERING IFRAME; VERY IMPORTANT -- !!!
	_WD_FrameEnter($sSession, $sElement)
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Public (any Canvas Commons user)')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Public (any Canvas Commons user)')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Enter the description information", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//textarea[@id='description']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//textarea[@id='description']")
	_WD_ElementAction($sSession, $sElement, 'value', 'For integration information please visit: https://www.icevonline.com/resources/product-guides/icev-and-canvas. If this is a certification; the final certification exam must be completed in icevonline.com.')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Enter the search tags", "CEV Multimedia")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='tags']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='tags']")
	_WD_ElementAction($sSession, $sElement, 'value', 'CEV Multimedia')
	Send("{ENTER}")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Enter the search tags", "iCEV")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='tags']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='tags']")
	_WD_ElementAction($sSession, $sElement, 'value', 'iCEV')
	Send("{ENTER}")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Enter the search tags", "")
	Do
		_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='tags']")
		$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='tags']")
		ClipPut ($sCSV[$i])
		Send("^v")
		Send("{ENTER}")
		_WD_LoadWait($sSession, 2000)
		Sleep(2000)
		$i = $i - 1
	Until $i = 0
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Select the From: grade level", "//span[contains(text(),'From:')]//following::select//option[contains(text(),'9th grade')]")
	_WD_ElementOptionSelect ($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'From:')]//following::select//option[contains(text(),'9th grade')]")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Select the To: grade level", "//span[contains(text(),'To:')]//following::select//option[contains(text(),'12th grade')]")
	_WD_ElementOptionSelect ($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'To:')]//following::select//option[contains(text(),'12th grade')]")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click 'Click to Change'", "//button[@class='ImagePicker-button Button Button--default']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@class='ImagePicker-button Button Button--default']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click 'browse'", "//span[@class='Link FilePicker-browse']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[@class='Link FilePicker-browse']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	WinWaitActive ("[CLASS:#32770]", "Open")
	; This method sets input focus to 'File name' text box.
	ControlFocus("Open","","Edit1")
	; This method input file path of a control.
	ControlSetText("Open","","Edit1","C:\Users\" & $CmdLine[5] & "\Downloads\icev_logo.png")
	; This method click on 'Open' button of file uploader.
	ControlClick("Open","","Button1")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click 'Save'", "//button[@class='Button Button--primary']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@class='Button Button--primary']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click 'Share'", "//button[@class='form-submit-button Button Button--primary-large']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@class='form-submit-button Button Button--primary-large']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	_WD_FrameLeave($sSession)

WEnd

_WD_DeleteSession($sSession)
_WD_Shutdown()
Exit