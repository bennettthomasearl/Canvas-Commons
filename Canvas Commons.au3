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

Local $sDesiredCapabilities, $sSession, $sPath, $sFile, $sLine, $sCSV, $sFilename, $sArrayNumber

; Update these values to match your environment.
$sPath = $CmdLine[3]
$sFile = FileOpen($CmdLine[4], 0)

Func SetupChrome()
_WD_Option('Driver', $sPath)
_WD_Option('Port', 9515)
_WD_Option('DriverParams', '--verbose --log-path="' & @ScriptDir & '\chrome.log"')

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

	; Further split the string by (
	$sFilename = StringSplit ($sCSV[1], '(', 1)

	; Get the last array number
	$sArrayNumber = UBound($sFilename)-1

	; Remove ) from the string and use the last array number to ouput the curriculum id number
	$sFilename = StringReplace ($sFilename[$sArrayNumber], ')', "")

	;MsgBox($MB_SYSTEMMODAL, "Go to Resources", "//a[contains(text(),'Resources')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'Resources')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'Resources')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Dropdown button", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//div[contains(@class,'action-links-wrapper action-links-wrapper-regular')]//div[contains(@class,'action-links-unfold')]", 1000)
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//div[contains(@class,'action-links-wrapper action-links-wrapper-regular')]//div[contains(@class,'action-links-unfold')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Import button", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@id='import-collection-btn']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@id='import-collection-btn']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the correct Import from:* option", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//div[@id='edit-adapter-common-cartridge-imscc-wrapper']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//div[@id='edit-adapter-common-cartridge-imscc-wrapper']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Change the Collection Title", "_WD_ElementAction($sSession, $sElement, 'value'," & $sCSV[1] & ")")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='edit-destination-new-collection-title']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='edit-destination-new-collection-title']")
	_WD_ElementAction($sSession, $sElement, 'value', $sCSV[1])
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Next button", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-collection-import-form']//input[@id='edit-submit']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-collection-import-form']//input[@id='edit-submit']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Attach File button", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[@id='upload-btn']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[@id='upload-btn']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	; Upload .imscc file
	; Wait for the file upload window to appear
	WinWaitActive ("[CLASS:#32770]", "Open")
	; Set the input focus on the 'File name:' textbox
	ControlFocus("Open","","Edit1")
	; Type in the file path of the needed file
	ControlSetText("Open","","Edit1","C:\Users\" & $CmdLine[5] & "\Downloads\icevcourse_" & $sFilename & "_v1.2.imscc")
	; Click the 'Open' button
	ControlClick("Open","","Button1")
	; End of Upload .imscc file

	_WD_LoadWait($sSession, 4000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Next button", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-collection-import-form']//input[@id='edit-submit']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-collection-import-form']//input[@id='edit-submit']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;Give Schoology time to process the file before continuing.

	;Twenty (20) minute wait
	;_WD_LoadWait($sSession, 1200000)

	;Ten (10) minute wait
	_WD_LoadWait($sSession, 600000)

	;Five (5) minute wait
	;_WD_LoadWait($sSession, 300000)

	;Thirty (30) second wait
	;_WD_LoadWait($sSession, 30000)

	;MsgBox($MB_SYSTEMMODAL, "Go into the Resource that was just uploaded", "//a[contains(text(),'" & $sCSV[1] & "')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'" & $sCSV[1] & "')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'" & $sCSV[1] & "')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 4000)

	; This is needed to force all of the folders to show on this page, sends browser to the end / bottom of the page.
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{END}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{END}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Add Resources button", "//span[contains(text(),'Add Resources')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Add Resources')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Add Resources')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Add Folder button", "//a[contains(text(),'Add Folder')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'Add Folder')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'Add Folder')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Name the folder", $sCSV[1])
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='edit-title']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@id='edit-title']")
	_WD_ElementAction($sSession, $sElement, 'value', $sCSV[1])
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Provide a description", "")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//iframe[@id='edit-description_ifr']")
	_WD_FrameEnter($sSession, $sElement)
		_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//body[@id='tinymce']")
		$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//body[@id='tinymce']")
	_WD_ElementAction($sSession, $sElement, 'value', "For integration information please visit: https://www.icevonline.com/resources/product-guides/iCEV-and-Schoology. The final certification exam must be taken at iCEVonline.com; the final exam cannot be integrated through an external tool." & $sCSV[2] & "")
	_WD_FrameLeave($sSession)
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Create button", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-collection-add-folder-form']//input[@id='edit-submit']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-collection-add-folder-form']//input[@id='edit-submit']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 10000)

	; This is needed to force all of the folders to show on this page, sends browser to the end / bottom of the page.
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{PGDN}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{END}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)
	WinActivate ("Schoology - Google Chrome")
	Send("{END}")
	_WD_LoadWait($sSession, 2000)
	Sleep(2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Select All checkbox", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@class='form-checkbox select-all-checkbox']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//input[@class='form-checkbox select-all-checkbox']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the created folder (uncheck)", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//table[@id='collection-view-contents']//child::a[@class='item-title active sLibraryAjaxedLinks-processed sExtlink-processed'][contains(text(),'" & $sCSV[1] & "')]//parent::td//parent::tr//child::td[@class='collection-item-checkbox sLibrary-processed']//input[@class='form-checkbox']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//table[@id='collection-view-contents']//child::a[@class='item-title active sLibraryAjaxedLinks-processed sExtlink-processed'][contains(text(),'" & $sCSV[1] & "')]//parent::td//parent::tr//child::td[@class='collection-item-checkbox sLibrary-processed']//input[@class='form-checkbox']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click the Edit button", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Edit')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//span[contains(text(),'Edit')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Move to", "")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'Move to')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[contains(text(),'Move to')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Select the correct folder", "//select[@id='edit-folder-select']//option[contains(text(), '" & $sCSV[1] & "')]")
	_WD_ElementOptionSelect ($sSession, $_WD_LOCATOR_ByXPath, "//select[@id='edit-folder-select']//option[contains(text(), '" & $sCSV[1] & "')]")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Move to", "//form[@id='s-library-bulk-move-form']//input[@id='edit-submit']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-bulk-move-form']//input[@id='edit-submit']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-bulk-move-form']//input[@id='edit-submit']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Share in Pulic Resources", "//a[@class='action-publish-template sExtlink-processed popups-processed']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='action-publish-template sExtlink-processed popups-processed']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//a[@class='action-publish-template sExtlink-processed popups-processed']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Provide Public Info", "//textarea[@id='edit-description']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//iframe[@id='edit-description_ifr']")
	_WD_FrameEnter($sSession, $sElement)
		_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//body[@id='tinymce']")
		$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//body[@id='tinymce']")
	_WD_ElementAction($sSession, $sElement, 'value', "For integration information please visit: https://www.icevonline.com/resources/product-guides/iCEV-and-Schoology. The final certification exam must be taken at iCEVonline.com; the final exam cannot be integrated through an external tool." & $sCSV[2] & "")
	_WD_FrameLeave($sSession)
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Select the correct Resource Type", "//select[@id='edit-use-category']//option[contains(text(),'Curriculum')]")
	_WD_ElementOptionSelect ($sSession, $_WD_LOCATOR_ByXPath, "//select[@id='edit-use-category']//option[contains(text(),'Curriculum')]")
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Subject Technology and Engineering", "//div[@id='taxonomy-chooser']//span[contains(text(),'Technology and Engineering')]")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//div[@id='taxonomy-chooser']//span[contains(text(),'Technology and Engineering')]")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//div[@id='taxonomy-chooser']//span[contains(text(),'Technology and Engineering')]")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 2000)

	;MsgBox($MB_SYSTEMMODAL, "Click Make Public", "//form[@id='s-library-template-publish-form']//input[@id='edit-submit']")
	_WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-template-publish-form']//input[@id='edit-submit']")
	$sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, "//form[@id='s-library-template-publish-form']//input[@id='edit-submit']")
	_WD_ElementAction($sSession, $sElement, 'click')
	_WD_LoadWait($sSession, 300000)

WEnd

_WD_DeleteSession($sSession)
_WD_Shutdown()
Exit