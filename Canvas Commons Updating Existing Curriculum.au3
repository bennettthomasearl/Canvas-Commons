#cs ----------------------------------------------------------------
Name ..........: Canvas Commons Updating Existing Curriculum.au3
Description ...: Updating existing curriculum in Canvas Commons
AutoIt Version : 3.3.14.5
Author(s) .....: Thomas E. Bennett, Anthony R. Perez
Date ..........: Fri April 2, 2021 11:08:03 CST

When running this macro; make a batch file (.bat or .cmd) with these properties:
"C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "{Path to Script}\Canvas Commons Updating Existing Curriculum.au3" "email or username" "password" "WebDriver path" ".csv path" "local username"

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
#include <Date.au3>

Local $sDesiredCapabilities, $sSession, $sPath, $sFile, $sLine, $sCSV, $sFilename, $sArrayNumber, $i, $sSearchTag, $sData, $sDate, $sTime

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

	$sDate = _NowDate()
	$sTime = _NowTime()

	; Dashboard page, this is needed for the loop to continue correctly.
	_WD_Navigate($sSession, "https://cevmultimedia.instructure.com/courses")
	_WD_LoadWait($sSession, 6000)

	; Read the .csv file
	Local $sLine = FileReadLine($sFile)
	If @error = -1 Then ExitLoop

	; Split this string by the ;
	$sCSV = StringSplit($sLine, ';', 1)

	$i = $sCSV[0]
	;MsgBox($MB_SYSTEMMODAL, "Value of $i", $i)
	;Exit

	; Further split the string by (
	$sFilename = StringSplit ($sCSV[1], '(', 1)

	; Get the last array number
	$sArrayNumber = UBound($sFilename)-1

	; Remove ) from the string and use the last array number to ouput the curriculum id number
	$sFilename = StringReplace ($sFilename[$sArrayNumber], ')', "")

	;MsgBox($MB_SYSTEMMODAL, "Click an Existing Course", "//span[contains(text(),'"& $sCSV[1] &"')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'"& $sCSV[1] &"')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'"& $sCSV[1] &"')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Settings", "//a[@class='settings']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='settings']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='settings']")
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

	;MsgBox($MB_SYSTEMMODAL, "Click All content radio button", "//input[@name='selective_import']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@name='selective_import']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@name='selective_import']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Overwrite assessment content with matching IDs", "//input[@id='overwriteAssessmentContent']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='overwriteAssessmentContent']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='overwriteAssessmentContent']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Import button", "//input[@id='migrationFileUpload']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='submitMigration']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='submitMigration']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	; Taught how to do the below code:
	; https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version-01162021/page/48/#comments

	;MsgBox($MB_SYSTEMMODAL, "Wait for 'Completed' to appear", "//li[1]//div[4]//span[1][contains(text(),'Completed')]")
	;The line directly below isn't ideal; but it works. It looks at the topmost (first) row as this row will be doing the processing.
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//li[1]//div[4]//span[1][contains(text(),'Completed')]", Default, 30*60*1000)
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

	;MsgBox($MB_SYSTEMMODAL, "Enter the iframe and verifying the status of 'Is this an update to a previously shared resource?'", "//*[name()='svg' and @name='IconX']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//iframe[@id='tool_content']")
	; !!! -- ENTERING IFRAME; VERY IMPORTANT -- !!!
	_WD_FrameEnter($sSession, $sElement)
	; SVGs are part of a different namespace than regular XML; so below is needed to find SVGs.
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//*[name()='svg' and @name='IconCheck']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//*[name()='svg' and @name='IconCheck']")
	If @error = $_WD_ERROR_Success Then
		MsgBox($MB_SYSTEMMODAL, "This was a previously shared resource and it needs to be updated. ", "You need to code this condition in. Halting.")
		Exit
	EndIf

	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//*[name()='svg' and @name='IconX']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//*[name()='svg' and @name='IconX']")
	If @error = $_WD_ERROR_Success Then
		_WD_ElementAction($sSession, $sElement, 'click')
		_WD_LoadWait($sSession, 2000)

		While @error = $_WD_ERROR_Success
			;MsgBox($MB_SYSTEMMODAL, @error,"Loop Start")
			_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@class='LoadMore-button-btn Button Button--link']")
			$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@class='LoadMore-button-btn Button Button--link']")
			_WD_ElementAction($sSession, $sElement, 'click')
			If @error = $_WD_ERROR_Success Then
				_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'"& $sCSV[1] &"')]")
				$sElement2 = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'"& $sCSV[1] &"')]")
				_WD_ElementAction($sSession, $sElement2, 'click')
				If @error = $_WD_ERROR_Success Then
					SetError($_WD_ERROR_NoMatch)
					;MsgBox($MB_SYSTEMMODAL, @error,"Exiting Loop")
				EndIf
				If @error = $_WD_ERROR_NoMatch Then
					SetError($_WD_ERROR_Success)
					;MsgBox($MB_SYSTEMMODAL, @error,"Again")
					$i = $i + 1
					If $i = 30 Then ; Refresh the page and search again
						$i = 0
						Send("{F5}")
						_WD_LoadWait($sSession, 2000)
						$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//iframe[@id='tool_content']")
						; !!! -- ENTERING IFRAME; VERY IMPORTANT -- !!!
						_WD_FrameEnter($sSession, $sElement)
						_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//*[name()='svg' and @name='IconX']")
						$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//*[name()='svg' and @name='IconX']")
						_WD_ElementAction($sSession, $sElement, 'click')
						_WD_LoadWait($sSession, 2000)
					EndIf
				EndIf
			EndIf
		WEnd
	EndIf

	;MsgBox($MB_SYSTEMMODAL, "Enter the description information", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//textarea[@id='versionNotes']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//textarea[@id='versionNotes']")
	_WD_ElementAction($sSession, $sElement, 'value', "Curriculum Updates. Updated curriculum sent to Canvas on: " & $sDate & " at " & $sTime & " CST")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click 'Update'", "//button[@class='form-submit-button Button Button--primary-large']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//button[@class='form-submit-button Button Button--primary-large']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	_WD_FrameLeave($sSession)
WEnd

_WD_DeleteSession($sSession)
_WD_Shutdown()
Exit