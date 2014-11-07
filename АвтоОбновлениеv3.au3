#include <GUIConstants.au3>
#include <Date.au3>
#include <ButtonConstants.au3>
#include <DateTimeConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#NoTrayIcon
$NumParams = $CmdLine[0]


Global $InputLogin
Global $InputPassword
Global $Auth = False
Global $MultiUse = False
Global $UseAuth
Global $User
Global $Password
Global $UseBackup
Global $PathBackup
Global $FormatPathBackup
Global $IgnoreResult
Global $UseLogs = True
Global $PathLogs
Global $FormatPathLogs
Global $OneLog
Global $ShowLogs
Global $UseRIB
Global $UseFileUp
Global $FileUpPath
Global $UseBlockUsers
Global $UseBreak
Global $PathBaseFiles
Global $Path1CEXE
Global $TimeWait
Global $DefaultTimeWait
Global $FileCfg
Global $UseLoadCf
Global $A_Clear[1]
;~ прочитаем стандартные настройки через INI файл
If $NumParams = 1 Then

	$Param = $CmdLine[1]
	If StringInStr($Param,'File=') > 0 OR StringInStr($Param,'Srvr=') > 0 Then
		$ConnectStr = $Param
	Else
		$MultiFile = $CmdLine[1]
		$MultiUse = True
	EndIf
	$IniFileName = "UpdateScript.ini"
ElseIf $NumParams = 2 Then
	$MultiFile = $CmdLine[1]
	$MultiUse = True
	$IniFileName = $CmdLine[2]
	$UpdateScript = FileExists($IniFileName)
If Not $UpdateScript Then
	MsgBox(0,'Ошибка','Не найден файл настроек!')
	Exit
EndIf
Else
	$IniFileName = "UpdateScript.ini"
EndIf


$UpdateScript = FileExists($IniFileName)
Opt("GUIOnEventMode", 1)
If Not $UpdateScript Then
;~ 		Настройка 1С
		$UseAuth = True
		WriteLog ($IniFileName, "[1C]")
		WriteLog ($IniFileName,';Использование авторитизации для избежания "Свечения" паролей')
		WriteLog ($IniFileName,';Если не исполозовать по будет подставлять указанные ниже параменры')
		WriteLog ($IniFileName, "Использовать авторитизацию=Да")
		$User = "Администратор"
		WriteLog ($IniFileName,';Пользователь для подстановки по умолчанию')
		WriteLog ($IniFileName, "Пользователь="&$User)
		$Password = ''
		WriteLog ($IniFileName,';Пароль для подстановки по умолчанию')
		WriteLog ($IniFileName, "Пароль=")
;~ 		Настройка бекапа
		WriteLog ($IniFileName, "[Backup]")
		$UseBackup = True
		WriteLog ($IniFileName,';Использование системы создания Backup')
		WriteLog ($IniFileName,';Если не указано использование Backup, тогда по умолчанию используется')
		WriteLog ($IniFileName, "Делать Backup=Да")
		$PathBackup = ''
		WriteLog ($IniFileName,';Путь к папке с бекапами')
		WriteLog ($IniFileName, "Путь к бекапам=")
		$FormatPathBackup = '@BASENAME@\@DATE@\@FILENAME@.DT'
		WriteLog ($IniFileName,";Создание формата файла Backup'a")
		WriteLog ($IniFileName,";Можно использовать задавая следующие параметры:")
		WriteLog ($IniFileName,";@DATE@ - дата бекапа подставить в формате ГГГГММДД_ЧЧ_ММ")
		WriteLog ($IniFileName,";@BASENAME@ - имя Базы для которой создаектся бекап, возмется из переданного параметра или из списка")
		WriteLog ($IniFileName,";@FILENAME@ - произвольное имя(без расширения)")
		WriteLog ($IniFileName, "Формат файла Backup'a="& $FormatPathBackup)
		$IgnoreResult =  False
		WriteLog ($IniFileName,";Игнорирование результата Backup'a")
		WriteLog ($IniFileName,"Игнорировать результат Backup'a =Нет")
;~ 		Настройка запуска внешней обработки
		WriteLog ($IniFileName, "[ExecuteEpf]")
		$UseRunEpf = False
		WriteLog ($IniFileName,';Использование системы запуска внешней обработки')
		WriteLog ($IniFileName,';Если не указано использование запуска обработки, тогда по умолчанию не используется')
		WriteLog ($IniFileName, "Запустить обработку = Нет")
		$PathForEpf = ''
		WriteLog ($IniFileName,';Путь к конечному файлу с внешней обработкой')
		WriteLog ($IniFileName, "Путь к внешней обработке=")

		$UseRunEpfAfterUpdate = False
		WriteLog ($IniFileName,';Использование системы запуска внешней обработки')
		WriteLog ($IniFileName,';Если не указано использование запуска обработки, тогда по умолчанию не используется')
		WriteLog ($IniFileName, "Запустить обработку после обновления = Нет")
		$PathForEpfAfterUpdate = ''
		WriteLog ($IniFileName,';Путь к конечному файлу с внешней обработкой')
		WriteLog ($IniFileName, "Путь к внешней обработке после обновления=")

;~ 		Настройка пакетного запуска конфигуратора
		WriteLog ($IniFileName, "[ExecuteConfig]")
		$UseRunConfig = False
		WriteLog ($IniFileName,';Использование системы пакетного запуска конфигуратора')
		WriteLog ($IniFileName,';Если не указано использование запуска конфигуратора тогда по умолчанию не используется')
		WriteLog ($IniFileName, "Запустить конфигуратор до обновления = Нет")
		$ParamForConfig = ''
		WriteLog ($IniFileName,';Набор параметров запуска конфигуратора')
		WriteLog ($IniFileName, "Параметры запуска до=")

		$UseRunConfigAfterUpdate = False
	    WriteLog ($IniFileName,';Использование системы пакетного запуска конфигуратора')
		WriteLog ($IniFileName,';Если не указано использование запуска конфигуратора тогда по умолчанию не используется')
		WriteLog ($IniFileName, "Запустить конфигуратор после обновления = Нет")
		$ParamForConfigAfterUpdate = ''
		WriteLog ($IniFileName,';Набор параметров запуска конфигуратора')
		WriteLog ($IniFileName, "Параметры запуска после=")

;~ 		Настройка логов
		WriteLog ($IniFileName, "[Logs]")
		$UseLogs =  True
		WriteLog($IniFileName, ";Признак ведения логов")
		WriteLog($IniFileName, "Вести логи=Да")
		$PathLogs = ''
		WriteLog($IniFileName, ";Путь к папке с логами")
		WriteLog($IniFileName, "Путь к логам")
		$FormatPathLogs = '@BASENAME@\@DATE@\@FILENAME@.txt'
		WriteLog ($IniFileName,";Создание формата файла лога Backup'a")
		WriteLog ($IniFileName,";Можно использовать задавая следующие параметры:")
		WriteLog ($IniFileName,";@DATE@ - дата бекапа подставить в формате ГГГГММДД_ЧЧ_ММ")
		WriteLog ($IniFileName,";@BASENAME@ - имя Базы для которой создаектся лог, возмется из переданного параметра или из списка")
		WriteLog ($IniFileName,";@FILENAME@ - произвольное имя(без расширения)")
		WriteLog ($IniFileName,"Формат файла логов="&$FormatPathLogs)
		WriteLog ($IniFileName,";Создание одного лога Backup'a")
		WriteLog ($IniFileName,";При использовании обновления через список баз")
		WriteLog ($IniFileName,";Данный параметр определяет наличие общего лога")
		WriteLog ($IniFileName,";При обнолении через параметр (1 база) ")
		WriteLog ($IniFileName,";Данный параметр определяет отсутствие индивидуального лога")
		$OneLog = False
		WriteLog($IniFileName,"Один общий лог=Нет")
		$ShowLogs = False
		WriteLog ($IniFileName,";Показ пога по завершении работы")
		WriteLog($IniFileName,"Показать лог=Нет")
;~ 		Найстрока обновления
		WriteLog ($IniFileName, "[Update]")
		$UseRIB = True
		WriteLog($IniFileName, ";Использование обновления для РИБ'ов")
		WriteLog($IniFileName, ";ОСТРОЖНО: НЕ УНИВЕРСАЛЬНЫЙ МЕХАНИЗМ")
		WriteLog($IniFileName, ";В данном случае будет передан параметр при запуске 1С:Предприятие 'ЗагрузитьОбновление' после создания бекапа ")
		WriteLog($IniFileName, ";В после обновления Иб будет передан параметр при запуске 1С:Предприятие 'ЗагрузитьВыгрузить' ")
		WriteLog($IniFileName, "Использовать РИБ=Да")
		$UseParamLoadUpdate = False
		WriteLog($IniFileName, "Использовать параметр ЗагрузитьОбновление = НЕТ")

		$UseParamLoadUpload = False
		WriteLog($IniFileName, "Использовать параметр ЗагрузитьВыгрузить = НЕТ")



		$UseFileUp = False
		WriteLog($IniFileName, ";Использовать обновление из файла")
		WriteLog($IniFileName, "Использовать обновление из файла=Нет")
		$FileUpPath = ''
		WriteLog($IniFileName, ";Путь к файлу обновления конфигурации, если она находится на поддержке")
		WriteLog($IniFileName, ";Если путь не задан, а стоит признак обноления из файла")
		WriteLog($IniFileName, ";Будет открыт диалог выбора файла")
		WriteLog($IniFileName, "Путь к файлу обновления=")
		WriteLog($IniFileName, "Использовать загрузку cf= Нет")
		WriteLog($IniFileName, "Путь к файлу конфигурации=")

;~ 		Настройка отключения пользователей
		$UseBlockUsers = True
		WriteLog($IniFileName, "[BlockUsers]")
		WriteLog($IniFileName, ";ОСТРОЖНО: НЕ УНИВЕРСАЛЬНЫЙ МЕХАНИЗМ")
		WriteLog($IniFileName, ";В данном случае будет передан параметр при запуске 1С:Предприятие 'БлокироватьПользователей' ")
		WriteLog($IniFileName, ";В конце работы скрипта будет передан параметр при запуске 1С:Предприятие 'СнятьБлокировкуПользователей' ")
		WriteLog($IniFileName, "Использовать отключение пользователей = Да")
;~ 		Настройка Updater'а
		WriteLog ($IniFileName, "[Default]")
		WriteLog ($IniFileName, ";Настройки скрипта обновления баз данных")
		$UseBreak = False
		WriteLog ($IniFileName, ";Справшивать остановку после каждого действия")
		WriteLog ($IniFileName, ";Дабы дать возможность отключения скрипта до окончания")
		WriteLog($IniFileName, "Справшивать остановку после каждого действия=Нет")
		$PathBaseFiles = ''
		WriteLog ($IniFileName, ";Путь к файлу со списком баз (необазательный)")
		WriteLog($IniFileName, "Путь к файлу со списком баз="&$PathBaseFiles)
		WriteLog ($IniFileName,";Формат ОДНОЙ строки списка баз ")
		WriteLog ($IniFileName,";А так же параметры на прием скриптом ")
		WriteLog ($IniFileName,";Где параметры:")
		WriteLog ($IniFileName,";Для файлового варианта: ")
		WriteLog ($IniFileName,";@BASENAME@ - имя Базы для которой создается ")
		WriteLog ($IniFileName,";@BASEPATH@ - Строка соединения с базой данных (функция в 1С: ПолучитьСтрокуСоединения()) без кавычек в середине строки")
		WriteLog ($IniFileName,";Формат: @BASENAME@|@BASEPATH@ ")
		WriteLog ($IniFileName,";Для серверного варианта: ")
		WriteLog ($IniFileName,";Формат: @ConnectString@ - Строка соединения с базой данных (функция в 1С: ПолучитьСтрокуСоединения()) без кавычек в середине строки")
		$Path1CEXE = 'C:\Program Files\1cv81\bin\1cv8.exe'
		WriteLog ($IniFileName,";Путь к исполняемому файлу 1С (1cv8.exe)")
		WriteLog ($IniFileName,";Если путь не задан, будет открыт диалог выбора файла")
		WriteLog ($IniFileName,"Путь к файлу пусковому файлу 1С="&$Path1CEXE)
 		$TimeWait = 120
		WriteLog ($IniFileName,";Время ожидания выполнения действий 1С")
		WriteLog ($IniFileName,";По умолчанию 2 часа после этого скрипт переходит к следующему дейтсвию")
		WriteLog ($IniFileName,";Указывается в минутах")
		WriteLog ($IniFileName,"Пауза="&$TimeWait)
	Else
;~ 		Настройка 1С
		$UseAuth = IniRead($IniFileName, "1C", "Использовать авторитизацию", "Истина")
		$UseAuth = StringToBool ($UseAuth,True)
		$User = IniRead($IniFileName, "1C", "Пользователь", "Администратор")
		$Password = IniRead($IniFileName, "1C", "Пароль", "")

;~ 		Настройка бекапа
		$UseBackup = IniRead($IniFileName, "Backup", "Делать Backup", "Истина")
		$UseBackup = StringToBool ($UseBackup,True)
		$PathBackup = IniRead($IniFileName, "Backup", "Путь к бекапам", "")
		$FormatPathBackup = IniRead($IniFileName, "Backup", "Формат файла Backup'a", '@BASENAME@\@DATE@\@FILENAME@.DT')
		$IgnoreResult = IniRead($IniFileName, "Backup", "Игнорировать результат Backup'a", "НЕТ")
		$IgnoreResult = StringToBool ($IgnoreResult,False)

;~ 		Настройка запуска внешней обработки
		$UseRunEpf = IniRead($IniFileName, "ExecuteEpf", "Запустить обработку", "Ложь")
		$UseRunEpf = StringToBool ($UseRunEpf,False)
		$PathForEpf = IniRead($IniFileName, "ExecuteEpf", "Путь к внешней обработке", "")

		$UseRunEpfAfterUpdate = IniRead($IniFileName, "ExecuteEpf", "Запустить обработку после обновления", "Ложь")
		$UseRunEpfAfterUpdate = StringToBool ($UseRunEpfAfterUpdate,False)
		$PathForEpfAfterUpdate = IniRead($IniFileName, "ExecuteEpf", "Путь к внешней обработке после обновления", "")

;~ 		Настройка пакетного запуска конфигуратора
		$UseRunConfig = IniRead($IniFileName, "ExecuteConfig", "Запустить конфигуратор до обновления", "Ложь")
		$UseRunConfig = StringToBool ($UseRunConfig,False)
		$ParamForConfig = IniRead($IniFileName, "ExecuteConfig", "Параметры запуска до", "")

		$UseRunConfigAfterUpdate = IniRead($IniFileName, "ExecuteConfig", "Запустить конфигуратор после обновления", "Ложь")
		$UseRunConfigAfterUpdate = StringToBool ($UseRunConfigAfterUpdate,False)
	    $ParamForConfigAfterUpdate = IniRead($IniFileName, "ExecuteConfig", "Параметры запуска после", "")

;~ 		Настройка логов
		$UseLogs = IniRead($IniFileName, "Logs", "Вести логи", "Истина")
		$UseLogs = StringToBool ($UseLogs,True)
		$PathLogs = IniRead($IniFileName, "Logs", "Путь к логам", "")
		$FormatPathLogs = IniRead($IniFileName, "Logs", "Формат файла логов", "@BASENAME@\@DATE@\@FILENAME@.txt")

		$OneLog = IniRead($IniFileName, "Logs", "Один общий лог", "НЕТ")
		$OneLog = StringToBool ($OneLog,False)
		$ShowLogs = IniRead($IniFileName, "Logs", "Показать лог", "Ложь")
		$ShowLogs = StringToBool ($ShowLogs,False)

;~ 		Найстрока обновления
		$UseRIB = IniRead($IniFileName, "Update", "Использовать РИБ", "ДА")
		$UseRIB = StringToBool ($UseRIB,True)
		$UseParamLoadUpdate = IniRead($IniFileName, "Update", "Использовать параметр ЗагрузитьОбновление", "НЕТ")
		$UseParamLoadUpdate = StringToBool ($UseParamLoadUpdate,False)
		$UseParamLoadUpload = IniRead($IniFileName, "Update", "Использовать параметр ЗагрузитьВыгрузить", "НЕТ")
		$UseParamLoadUpload = StringToBool ($UseParamLoadUpload,False)

		$UseFileUp = IniRead($IniFileName, "Update", "Использовать обновление из файла", "НЕТ")
		$UseFileUp = StringToBool ($UseFileUp,True)
		$FileUpPath = IniRead($IniFileName, "Update", "Путь к файлу обновления", "")

;~ 		Настройка отключения пользователей
		$UseBlockUsers = IniRead($IniFileName, "BlockUsers", "Использовать отключение пользователей", "ДА")
		$UseBlockUsers = StringToBool ($UseBlockUsers,True)

;~ 		Настройка Updater'а
		$UseBreak = IniRead($IniFileName, "Default", "Справшивать остановку после каждого действия", "Ложь")
		$UseBreak = StringToBool ($UseBreak,False)
		$Path1CEXE = IniRead($IniFileName, "Default", "Путь к файлу пусковому файлу 1С", "C:\Program Files\1cv81\bin\1cv8.exe")
		$PathBaseFiles = IniRead($IniFileName, "Default", "Путь к файлу со списком баз",'')
		$TimeWait = IniRead($IniFileName, "Default", "Пауза",120)
		$TimeWait = Number($TimeWait)
		If $TimeWait = 0 Then
			$TimeWait = 120
		EndIf
		$UseLoadCf = IniRead($IniFileName, "Update", "Использовать загрузку cf",'Нет')
		$UseLoadCf = StringToBool ($UseLoadCf,False)
		$FileCfg = IniRead($IniFileName, "Update", "Путь к файлу конфигурации", "")
EndIf

If NOT FileExists($Path1CEXE) then
	$msg = MsgBox(20, "Не обнаружен файл запуска 1С", "Вы хотите выбрать данный файл? Если нет, то скрипт закончит работу ", 50)
		if $msg = 7 Then
			Exit
		EndIf
EndIf

While 1
	If FileExists($Path1CEXE) then ExitLoop
	$Path1CEXE = FileOpenDialog("Выберите файл запуска программы 1С ", @ProgramFilesDir & "", "Программы (*.exe)", 1 )
WEnd

If $UseFileUp AND NOT FileExists($FileUpPath) then
	$msg = MsgBox(20, "Не обнаружен файл бля обновления конфигурации 1С", "Вы хотите выбрать данный файл обновления? Если нет, то скрипт закончит работу ", 50)
		if $msg = 7 Then
			Exit
		EndIf
EndIf
if $UseFileUp Then
	While 1
		If FileExists($FileUpPath) then ExitLoop
		$FileUpPath = FileOpenDialog("Выберите файл обновления ", @WorkingDir & "", "Конфигрурации 1С (*.cf)|Обновления конфигурации 1С (*.cfu)|Все доступные (*.cfu;*.cf)", 1 )
	WEnd
EndIf
If $PathBaseFiles <>'' AND NOT FileExists($PathBaseFiles) then
	MsgBox(0,'Ошибка',"Не указано неодно действие в скрипте")
	Exit
Else
	$multiUse= True
	$MultiFile = $PathBaseFiles
EndIf


If $UseAuth Then

	Opt("GUIOnEventMode", 1)  ; Change to OnEvent mode
	$mainwindow = GUICreate("Аторитизация скрипта", 242, 120)
	GUISetOnEvent($GUI_EVENT_CLOSE, "OKButton")
	GUICtrlCreateLabel("Для выполнения скрипта необходимо ввести:", 5, 10)
	$okbutton = GUICtrlCreateButton("Запустить скрипт", 60, 85, 120)
	GUICtrlSetOnEvent($okbutton, "OKButton")
	GUISetState(@SW_SHOW)
	GUICtrlCreateLabel("Пользователь 1С:", 5, 37)
	GUICtrlCreateLabel("Пароль 1С:", 5, 62)
	$InputLogin =GUICtrlCreateInput ("Администратор", 110,  35, 120, 20)
	$InputPassword =GUICtrlCreateInput ("", 110,  60, 120, 20,0x0020)

	;~ ждем ввода логина и пароля
	While 1
	  Sleep(1000)  ; Idle around
		If $Auth Then
		   GUIDelete()
		 ExitLoop
		EndIf

	WEnd

EndIf

#Region ### START Koda GUI section ### Form=
$MainForm = GUICreate("Обновление конфигураций 1С", 781, 350, 211, 145)
GUISetOnEvent($GUI_EVENT_CLOSE, "MainFormClose")
$Run = GUICtrlCreateTabItem("Выполнение скрипта")
GUICtrlSetState(-1, $GUI_HIDE)
$ProgressWait = GUICtrlCreateProgress(8, 30, 25, 313, $PBS_VERTICAL)
;~ $ProgressWait = GUICtrlCreateProgress(8, 30, 25, 313, BitOR($PBS_SMOOTH,$PBS_VERTICAL))
$lblProtocol = GUICtrlCreateLabel("Протокол:", 42, 84, 97, 28)
GUICtrlSetFont(-1, 16, 400, 0, "Garamond")
$lstLogList = GUICtrlCreateListView("Дата|База|Действие|Результат", 41, 117, 735, 227, BitOR($LVS_REPORT,$LVS_SINGLESEL,$LVS_SHOWSELALWAYS,$LVS_SORTDESCENDING,$LVS_AUTOARRANGE,$WS_HSCROLL))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 130)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 250)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 200)
$txtCommentRun = GUICtrlCreateInput("Ожидание запуска", 40, 30, 737, 21, BitOR($ES_CENTER,$ES_AUTOHSCROLL,$ES_READONLY))
$ProgressStatus = GUICtrlCreateProgress(40, 60, 737, 17)
$txtBaseNameLog = GUICtrlCreateInput("Ожидание запуска", 8, 4, 769, 21, BitOR($ES_CENTER,$ES_AUTOHSCROLL,$ES_READONLY))
#EndRegion ### END Koda GUI section ###

GUISetState(@SW_SHOW)


Func MainFormClose ()
	Exit
EndFunc

GUICtrlSetData ($ProgressWait,0)
_ArrayAdd($A_Clear,'')
FOR $element IN $A_Clear
	GUICtrlDelete($element)
NEXT

if $multiUse Then



	$MultiLogFileName = String (@YEAR)& String (@MON)&String (@MDAY) &'_'&String (@HOUR)&'_'& String (@MIN)&'\MultiLog.txt'


	$MultiLogFile = GetLogFile ($MultiLogFileName)
	$file = FileOpen($MultiFile, 0)

	; Check if file opened for reading OK
	If $file = -1 Then
		MsgBox(0, "Error", "Не могу открыть указанный файл для работы с мульти-обновлением.")
		Exit
	EndIf

	; Read in lines of text until the EOF is reached
	While 1
		$line = FileReadLine($file)
		If @error = -1 Then
			ExitLoop
		EndIf
			$tline =''
;~ 			MsgBox(0, "Line read:", $line)
			$tline =''&$line
;~ 			MsgBox(0, "$tline read:", $tline)
;~ 			$array = StringSplit($tline, @TAB)
;~ 			If not @error Then
			$ConnectStr = $line
;~ 				MsgBox(0, "$PrgExe:", $PrgExe)
;~  			MsgBox(0, "$ConnectStr:", $ConnectStr)

				$BaseName = GetBaseName($ConnectStr)
				$Connect =GetConnectStr($ConnectStr)
				$prefics = GetPrefics($ConnectStr)
;~ 				MsgBox(0, "$Connect:", $Connect)
;~  				MsgBox(0, "$BaseName:", $BaseName)
;~ 				Exit
				If $UseBackUp Then
					$BackupName = GetBackupName ($BaseName,$FormatPathBackup,$Connect)
				Else
					$BackupName = ""
				EndIf

				if $UseLogs Then
					$LogFileName = GetLogFileName($FormatPathLogs,$BaseName,$Connect)
					$LogFile = GetLogFile($LogFileName)
				Else
					$LogFileName = ""
					$LogFile = ''
				EndIf
 				DoUp ($Path1CEXE,$BaseName,$Connect,$prefics,$BackupName,$LogFile)
				AddLogToMultiLog($MultiLogFile,$LogFileName,$BaseName,$Connect,$prefics,$BackupName)
;~ 		   EndIf
	Wend

	FileClose($MultiLogFile)

	MsgBox(0, "Обновление конфигураии", "Обновление прошло успешно")
	Sleep(60)
	If $ShowLogs Then ShellExecute($MultiLogFileName)
	Exit
Else
	$BaseName = GetBaseName($ConnectStr)
	$Connect =GetConnectStr($ConnectStr)
	$prefics = GetPrefics($ConnectStr)
	If $UseBackUp Then
		$BackupName = GetBackupName ($BaseName,$FormatPathBackup,$Connect)
	Else
		$BackupName = ""
	EndIf
	if $UseLogs Then
		$LogFileName = GetLogFileName($FormatPathLogs,$BaseName,$Connect)
		$LogFile = GetLogFile($LogFileName)
	Else
		$LogFileName = ""
		$LogFile = ''
	EndIf
	$Result = DoUp ($Path1CEXE,$BaseName,$Connect,$prefics,$BackupName,$LogFile)
	If $Result Then
	$TextR = "Обновление прошло успешно"
	Else
	$TextR = "Обновление прошло c ошибками"
	EndIf
	MsgBox(0, "Обновление конфигураии",$TextR )
	If $ShowLogs Then ShellExecute($LogFileName)
	Exit
EndIf

Func UpdateForm ($Base,$Action,$Percent)

	GUICtrlSetData($txtBaseNameLog,$Base)
	GUICtrlSetData($txtCommentRun,$Action)
	GUICtrlSetData($ProgressStatus,$Percent)
;~ 	GUICtrlSetData($ProgressWait,100-$Percent)
	$ListItem = GUICtrlCreateListViewItem(_Now()&'|'&$Base&'|'&$Action,$lstLogList)
	_ArrayAdd($A_Clear,$ListItem)
	Return $ListItem
EndFunc

Func ReplaceStringFormat ($Rtext,$BaseName,$Connect)


	$RDATE = '@DATE@'
	$ZNDATE = String (@YEAR)& String (@MON)&String (@MDAY) &'_'&String (@HOUR)&'_'& String (@MIN)
	$RBASENAME = '@BASENAME@'
	$ZNBASENAME  = $BaseName
	$RBASEPATH = '@BASEPATH@'
	$ZNBASEPATH = $Connect
	$RFILENAME = '@FILENAME@'
	$ZNFILENAME = $BaseName &'_'&$ZNDATE
	$Rtext = StringReplace ($Rtext,$RDATE,$ZNDATE)
	$Rtext = StringReplace ($Rtext,$RBASENAME,$ZNBASENAME)
	$Rtext = StringReplace ($Rtext,$RBASEPATH,$ZNBASEPATH)

	$Rtext = StringReplace ($Rtext,$RFILENAME,$ZNFILENAME)
;~ 	MsgBox(0, "ОШИБКА", $Rtext)

	return $Rtext


EndFunc


Func StringToBool ($Text,$DefaultName)
    $bool = $DefaultName
	if StringUpper ($Text) = "ЛОЖЬ" Then
		$bool = False
	ElseIf StringUpper ($Text) = "ИСТИНА" Then
		$bool = True
	ElseIf StringUpper ($Text) = "ДА" Then
		$bool = True
	ElseIf StringUpper ($Text) = "НЕТ" Then
		$bool = False
	ElseIf StringUpper ($Text) = "1" Then
		$bool = True
	ElseIf StringUpper ($Text) = "0" Then
		$bool = False
	ElseIf StringUpper ($Text) = "TRUE" Then
		$bool = True
	ElseIf StringUpper ($Text) = "FALSE" Then
		$bool = False
	EndIf
	Return $bool
EndFunc

Func GetLogFileName($Rtext,$BaseName,$Connect)
    $logname = ReplaceStringFormat ($Rtext,$BaseName,$Connect)

	Return $logname

EndFunc
Func AddLogToMultiLog($MultiLogFile,$LogFileName,$BaseName,$Connect,$prefics,$BackupName)
	If $OneLog then

		if $prefics = 'F' Then
		 $preficsr = 'файловая база'
		Else
		 $preficsr = 'клиент-серверная база'
		EndIf
		WriteMultiLog ($MultiLogFile,'---------------------------------------------')
		WriteMultiLog ($MultiLogFile,'Дата обновления:           '&@TAB&_Now())
		WriteMultiLog ($MultiLogFile,'Обновление базы:           '&@TAB&$BaseName)
		WriteMultiLog ($MultiLogFile,'Строка соединения:         '&@TAB&$Connect)
		WriteMultiLog ($MultiLogFile,'Режим базы:                '&@TAB&$preficsr)
		WriteMultiLog ($MultiLogFile,'Имя файла архивной копии:  '&@TAB&$BackupName)
		WriteMultiLog ($MultiLogFile,'Имя файла логов:           '&@TAB&$LogFileName)
		WriteMultiLog ($MultiLogFile,'ЛОГ:')
		$logfileadd = FileOpen($LogFileName, 0)
		While 1
			$logline = FileReadLine($logfileadd)
			If @error = -1 Then ExitLoop
			WriteLog ($MultiLogFile,$logline)

		Wend
		WriteLog ($MultiLogFile,'---------------------------------------------')
		FileClose($logfileadd)
	EndIf
EndFunc
Func UpdateResult($item,$txtResult)
	GUICtrlSetData ($item,'|||'&$txtResult)
EndFunc
Func DoUp ($PrgExe,$BaseName,$Connect,$prefics,$BackupName,$LogFile)
	$Con = True

	DeleteLogS ($BaseName)
	WriteLog ($LogFile,"Начало обновления "& _Now())
	$Item = UpdateForm ($BaseName,"Начало обновления",0)
	UpdateResult ($Item,'Выполнено')

;~ 	ProgressOn("Выполнение обновления ИБ: "&$BaseName, "", "0 процентов",200,200,16)
;~ 	ProgressSet(5, "5 процентов","Установка блокировки пользователей")


	$Con = BlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
		WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

		FileClose($LogFile)
;~ 		ProgressOff()
		Return $Con
	EndIf
	UpdateResult ($Item,'Выполнено')
	AksForStop($LogFile)

;~ 	ProgressSet(10, "10 процентов","Идет создание бекапа")

	$Con = BkCopy($PrgExe,$BaseName,$Connect,$prefics,$BackupName,$LogFile)
	If Not $Con then
		WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

		FileClose($LogFile)
;~ 		ProgressOff()
		Return $Con
	EndIf
	AksForStop($LogFile)


;~ ProgressSet(20, "20 процентов","Получаем новую конфигурацию")
	$Con = RunEpf ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
		WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

		FileClose($LogFile)
		Return $Con
	EndIf
	AksForStop($LogFile)

    $Con = RunConfig ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
		WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

		FileClose($LogFile)
		Return $Con
	EndIf
	AksForStop($LogFile)


;~ 	ProgressSet(20, "20 процентов","Получаем новую конфигурацию")
	$Con =ReadMessager ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
		WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

		FileClose($LogFile)
		Return $Con
	EndIf


	AksForStop($LogFile)

;~ 	ProgressSet(50, "50 процентов","Идет обновление ИБ")
	$Con = Update ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
			WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

			FileClose($LogFile)
;~ 			ProgressOff()
		Return $Con
	EndIf
	AksForStop($LogFile)

;~ 	ProgressSet(80 , "80 процентов", "Обмениваемся с центром")
	$Con =ReadWriteMessager ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
			WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

			FileClose($LogFile)
;~ 			ProgressOff()
			Return $Con
	EndIf
	;~ ProgressSet(20, "20 процентов","Получаем новую конфигурацию")
	$Con = RunEpfAfterUpdate ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
		WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

		FileClose($LogFile)
		Return $Con
	EndIf

   AksForStop($LogFile)

  		

    $Con = RunConfigAfterUpdate ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
	If Not $Con then
		WriteLog ($LogFile,"ПРЕРВАНО ---- КРИТИЧЕСКАЯ ОШИБКА ("& _Now()&')')

		FileClose($LogFile)
		Return $Con
  	EndIf

	AksForStop($LogFile)
   
;~ 	ProgressSet(100 , "Закончено", "Обновление завершено")
	sleep(1000)
;~ 	ProgressOff()


	FileClose($LogFile)


EndFunc

Func SpecialEvents()

EndFunc

Func ReadMessager ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
	$result = True
	If $UseRIB Then
		 If $UseParamLoadUpdate then
		   $Item = UpdateForm ($BaseName,"Чтение новой конфигурации",50)
		   $PID = Run ($PrgExe &' ENTERPRISE /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /C ЗагрузитьОбновление /DisableStartupMessages /UCКодРазрешения',"", @SW_HIDE)
		   $result =WaitSleep($PID)
		   If $Result Then
			   WriteLog ($LogFile,"Чтение новой конфигурации ---- УСПЕШНО ("& _Now()&')')
			   UpdateResult($item,'УСПЕШНО')
		   Else
			   WriteLog ($LogFile,"Чтение новой конфигурации ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
			   UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
		   EndIf
		 Else
			   WriteLog ($LogFile,"Чтение новой конфигурации ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
			   UpdateResult($item,'НЕ ИСПОЛЬЗУЕТСЯ')
		 EndIf
	ElseIf $UseFileUp Then
		$Item = UpdateForm ($BaseName,"Чтение новой конфигурации",50)
		$PID = Run ($PrgExe &' DESIGNER /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /UCКодРазрешения /UpdateCfg "'&$FileUpPath&'" /DumpResult "'&$BaseName&'update.rst"',"", @SW_HIDE)
		$result =WaitSleep($PID)
		If $Result Then
;~ 			WriteLog ($LogFile,"Чтение новой конфигурации ---- УСПЕШНО ("& _Now()&')')
			If NOT $IgnoreResult Then
				$UpdateResult = CheckResult($BaseName&"update.rst")
				If $UpdateResult Then
					WriteLog ($LogFile,"Чтение новой конфигурации---- УСПЕШНО ("& _Now()&')')
					UpdateResult($item,'УСПЕШНО')
				Else
					WriteLog ($LogFile,"Чтение новой конфигурации ---- ОШИБКА ("& _Now()&')')
					UpdateResult($item,'ОШИБКА')
					AksForStop($LogFile)
					$Con = UnBlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)

					Return False
				EndIf
			EndIf
			If $IgnoreResult Then
				UpdateResult($item,'УСПЕШНО')
				If $UpdateResult Then
				$tx = "УСПЕШНО"
				Else
				$tx = "ОШИБКА"
				EndIf
				WriteLog ($LogFile,"Чтение новой конфигурации ---- ИГНОРИРОВАНИЕ ("&$tx&") ("& _Now()&')')
			EndIf
		Else
			WriteLog ($LogFile,"Чтение новой конфигурации ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
			UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
		EndIf
	ElseIf $UseLoadCf Then
		$Item = UpdateForm ($BaseName,"Чтение новой конфигурации",50)
		$PID = Run ($PrgExe &' DESIGNER /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /UCКодРазрешения /LoadCfg "'&$FileCfg&'" /DumpResult "'&$BaseName&'update.rst"',"", @SW_HIDE)
		$result =WaitSleep($PID)
		If $Result Then
;~ 			WriteLog ($LogFile,"Чтение новой конфигурации ---- УСПЕШНО ("& _Now()&')')
			If NOT $IgnoreResult Then
				$UpdateResult = CheckResult($BaseName&"update.rst")
				If $UpdateResult Then
					WriteLog ($LogFile,"Чтение новой конфигурации---- УСПЕШНО ("& _Now()&')')
					UpdateResult($item,'УСПЕШНО')
				Else
					WriteLog ($LogFile,"Чтение новой конфигурации ---- ОШИБКА ("& _Now()&')')
					UpdateResult($item,'ОШИБКА')
					AksForStop($LogFile)
					$Con = UnBlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)

					Return False
				EndIf
			EndIf
			If $IgnoreResult Then
				UpdateResult($item,'УСПЕШНО')
				If $UpdateResult Then
				$tx = "УСПЕШНО"
				Else
				$tx = "ОШИБКА"
				EndIf
				WriteLog ($LogFile,"Чтение новой конфигурации ---- ИГНОРИРОВАНИЕ ("&$tx&") ("& _Now()&')')
			EndIf
		Else
			WriteLog ($LogFile,"Чтение новой конфигурации ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
			UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
		EndIf
	Else
		WriteLog ($LogFile,"Чтение новой конфигурации ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')

	EndIf

	Return $result
EndFunc

Func ReadWriteMessager ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
   $result = True
  if $UseRIB then
	  If $UseParamLoadUpload then

		  $Item = UpdateForm ($BaseName,"Обмен с центром",80)
		  $PID = Run ($PrgExe &' ENTERPRISE /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /C ЗагрузитьВыгрузить /DisableStartupMessages /UCКодРазрешения',"", @SW_HIDE)
		  $result =WaitSleep($PID)
		  If $Result Then
			  WriteLog ($LogFile,"Обмен с центром (Загрузка/выгрузка) ---- УСПЕШНО ("& _Now()&')')
			  UpdateResult($item,'УСПЕШНО')
		  Else
			  WriteLog ($LogFile,"Обмен с центром (Загрузка/выгрузка) ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
			  UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
		   EndIf
	  Else
			WriteLog ($LogFile,"Обмен с центром (Загрузка/выгрузка)  ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
			UpdateResult($item,'НЕ ИСПОЛЬЗУЕТСЯ')
	  EndIf

   Else
	WriteLog ($LogFile,"Обмен с центром ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')

  EndIf
  Return $result
EndFunc

Func BlockUsers ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
$result = True
  If $UseBlockUsers Then
	$Item = UpdateForm ($BaseName,"Установка блокировки пользователей",10)
	$PID = Run ($PrgExe &' ENTERPRISE /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /CЗавершитьРаботуПользователей /DisableStartupMessages /UCКодРазрешения',"", @SW_HIDE)
	$result =WaitSleep($PID)
	If $Result Then
		WriteLog ($LogFile,"Блокировка пользователей ---- УСПЕШНО ("& _Now()&')')
		UpdateResult($item,'УСПЕШНО')
	Else
		WriteLog ($LogFile,"Блокировка пользователей ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
	EndIf
  Else
	WriteLog ($LogFile,"Блокировка пользователей ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
  EndIf
  Return $result

EndFunc

Func RunEpf ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
  $result = True
  If $UseRunEpf Then
	$Item = UpdateForm ($BaseName,"Запуск обработки",10)
	$PID = Run ($PrgExe &' ENTERPRISE /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /Execute"'&$PathForEpf&'"  /DisableStartupMessages /UCКодРазрешения',"", @SW_HIDE)
	$result =WaitSleep($PID)
	If $Result Then
		WriteLog ($LogFile,"Запуск обработки завершен ---- УСПЕШНО ("& _Now()&')')
		UpdateResult($item,'УСПЕШНО')
	Else
		WriteLog ($LogFile,"Запуск обработки завершен ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
	EndIf
  Else
	WriteLog ($LogFile,"Запуск обработки завершен ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
  EndIf
  Return $result

EndFunc

Func RunEpfAfterUpdate ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
  $result = True
  If $UseRunEpfAfterUpdate Then
	$Item = UpdateForm ($BaseName,"Запуск обработки",10)
	$PID = Run ($PrgExe &' ENTERPRISE /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /Execute"'&$PathForEpfAfterUpdate&'"  /DisableStartupMessages /UCКодРазрешения',"", @SW_HIDE)
	$result =WaitSleep($PID)
	If $Result Then
		WriteLog ($LogFile,"Запуск обработки завершен ---- УСПЕШНО ("& _Now()&')')
		UpdateResult($item,'УСПЕШНО')
	Else
		WriteLog ($LogFile,"Запуск обработки завершен ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
	EndIf
  Else
	WriteLog ($LogFile,"Запуск обработки завершен ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
  EndIf
  Return $result

EndFunc

Func UnBlockUsers ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
 $result = True
 If $UseBlockUsers Then
	$Item = UpdateForm ($BaseName,"Снятие блокировки пользователей",99)
	$PID = Run ($PrgExe &' ENTERPRISE /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /CРазрешитьРаботуПользователей /DisableStartupMessages /UCКодРазрешения',"", @SW_HIDE)
    $result =WaitSleep($PID)
  If $Result Then
		WriteLog ($LogFile,"Снятие блокировки пользователей ---- УСПЕШНО ("& _Now()&')')
		UpdateResult($item,'УСПЕШНО')
	Else
		WriteLog ($LogFile,"Снятие блокировки пользователей ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
	EndIf
  Else
	WriteLog ($LogFile,"Снятие блокировки пользователей ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
  EndIf
  Return $result
EndFunc


Func RunConfig ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
  
  $result = True
  If $UseRunConfig then
	$Item = UpdateForm ($BaseName,"Запуск конфигуратора в пакетном режиме (до обновления)",20)
	$PID = Run ($PrgExe &' DESIGNER /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /UCКодРазрешения "'&$ParamForConfig&'" /DumpResult "'&$BaseName&'backup.rst"',"", @SW_HIDE)

	$result = WaitSleep($PID)
	IF $result Then

		If NOT $IgnoreResult Then
			$RunResult = CheckResult($BaseName&"backup.rst")
			If $RunResult Then
				WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (до обновления) ---- УСПЕШНО ("& _Now()&')')
				UpdateResult($item,'УСПЕШНО')
			Else
				WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (до обновления) ---- ОШИБКА ("& _Now()&')')
				UpdateResult($item,'ОШИБКА')
				AksForStop($LogFile)
				$Con = UnBlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
				Return False
			EndIf
		EndIf
		If $IgnoreResult Then
			UpdateResult($item,'УСПЕШНО')
			If $RunResult Then
			$tx = "УСПЕШНО"
			Else
			$tx = "ОШИБКА"
			EndIf
			WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (до обновления) ---- ИГНОРИРОВАНИЕ ("&$tx&") ("& _Now()&')')
		EndIf
	Else
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
		WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (до обновления)  ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
	EndIf
  Else

	WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (до обновления) ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
  EndIf
  Return $result
EndFunc

Func RunConfigAfterUpdate ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
  
  $result = True
  If $UseRunConfigAfterUpdate then
	$Item = UpdateForm ($BaseName,"Запуск конфигуратора в пакетном режиме (после обновления)",95)
	$PID = Run ($PrgExe &' DESIGNER /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /UCКодРазрешения "'&$ParamForConfigAfterUpdate&'" /DumpResult "'&$BaseName&'backup.rst"',"", @SW_HIDE)

	$result = WaitSleep($PID)
	IF $result Then

		If NOT $IgnoreResult Then
			$RunResult = CheckResult($BaseName&"backup.rst")
			If $RunResult Then
				WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (после обновления) ---- УСПЕШНО ("& _Now()&')')
				$Con = UnBlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
				UpdateResult($item,'УСПЕШНО')
			Else
				WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (после обновления) ---- ОШИБКА ("& _Now()&')')
				UpdateResult($item,'ОШИБКА')
				AksForStop($LogFile)
				$Con = UnBlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
				Return False
			EndIf
		EndIf
		If $IgnoreResult Then
			UpdateResult($item,'УСПЕШНО')
			If $RunResult Then
			$tx = "УСПЕШНО"
			Else
			$tx = "ОШИБКА"
			EndIf
			WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (после обновления) ---- ИГНОРИРОВАНИЕ ("&$tx&") ("& _Now()&')')
		EndIf
	Else
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
		WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (после обновления)  ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
	EndIf
  Else
	WriteLog ($LogFile,"Запуск конфигуратора в пакетном режиме (до обновления) ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
  EndIf
  Return $result
EndFunc



Func Update ($PrgExe,$BaseName,$ConnectStr,$prefics,$LogFile)
  $result = True
  if $UseRIB or $UseFileUp Or $UseLoadCf then
		$Item = UpdateForm ($BaseName,"Обновление конфигурации",50)
		$PID = Run ($PrgExe &' DESIGNER /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /UCКодРазрешения /UpdateDBCfg /DumpResult "'&$BaseName&'update.rst"',"", @SW_HIDE)
		$result =WaitSleep($PID)
	IF $result Then

		If NOT $IgnoreResult Then
			$UpdateResult = CheckResult($BaseName&"update.rst")
			If $UpdateResult Then
				WriteLog ($LogFile,"Обновление конфигурации ---- УСПЕШНО ("& _Now()&')')
				UpdateResult($item,'УСПЕШНО')

				Else
				WriteLog ($LogFile,"Обновление конфигурации ---- ОШИБКА ("& _Now()&')')
				UpdateResult($item,'ОШИБКА')
				AksForStop($LogFile)


				Return False
			EndIf
			$Con = UnBlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
		EndIf
		If $IgnoreResult Then
			UpdateResult($item,'УСПЕШНО')
			If $UpdateResult Then
			$tx = "УСПЕШНО"
			Else
			$tx = "ОШИБКА"
			EndIf
			WriteLog ($LogFile,"Обновление конфигурации ---- ИГНОРИРОВАНИЕ ("&$tx&") ("& _Now()&')')
		EndIf
	Else
		WriteLog ($LogFile,"Обновление конфигурации  ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
	EndIf

 Else
	WriteLog ($LogFile,"Обновление конфигурации ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
 EndIf

 Return $result
 EndFunc

Func BkCopy($PrgExe,$BaseName,$ConnectStr,$prefics,$BkName,$LogFile)
  $result = True
  If $UseBackUp then
	$Item = UpdateForm ($BaseName,"Создание архивной копии",20)
	$PID = Run ($PrgExe &' DESIGNER /'&$prefics&'"'&$ConnectStr&'" /N'&$User&' /P'&$Password&' /UCКодРазрешения /DumpIB "'&$BkName&'" /DumpResult "'&$BaseName&'backup.rst"',"", @SW_HIDE)

	$result = WaitSleep($PID)
	IF $result Then

		If NOT $IgnoreResult Then
			$BackupResult = CheckResult($BaseName&"backup.rst")
			If $BackupResult Then
				WriteLog ($LogFile,"Создание архивной копии ---- УСПЕШНО ("& _Now()&')')
				UpdateResult($item,'УСПЕШНО')
			Else
				WriteLog ($LogFile,"Создание архивной копии ---- ОШИБКА ("& _Now()&')')
				UpdateResult($item,'ОШИБКА')
				AksForStop($LogFile)
				$Con = UnBlockUsers ($PrgExe,$BaseName,$Connect,$prefics,$LogFile)
				Return False
			EndIf
		EndIf
		If $IgnoreResult Then
			UpdateResult($item,'УСПЕШНО')
			If $BackupResult Then
			$tx = "УСПЕШНО"
			Else
			$tx = "ОШИБКА"
			EndIf
			WriteLog ($LogFile,"Создание архивной копии ---- ИГНОРИРОВАНИЕ ("&$tx&") ("& _Now()&')')
		EndIf
	Else
		UpdateResult($item,'НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ')
		WriteLog ($LogFile,"Создание архивной копии  ---- НЕ ДОЖДАЛИСЬ ЗАВЕРШЕНИЯ ("& _Now()&')')
	EndIf
  Else

	WriteLog ($LogFile,"Создание архивной копии ---- НЕ ИСПОЛЬЗУЕТСЯ ("& _Now()&')')
  EndIf
  Return $result
EndFunc

Func WaitSleep($PID)

	;~ Add $TimeWait minutes to current time
	$sEndDate = _DateAdd( 'n',$TimeWait, _NowCalc())
	$result = False
	$Max = _DateDiff('s', _NowCalc(), $sEndDate)
	While 1
;~  		MsgBox(0,'',(1 - (_DateDiff('s', _NowCalc(), $sEndDate)/$Max))*100)
		GUICtrlSetData($ProgressWait,(_DateDiff('s', _NowCalc(), $sEndDate)/$Max)*100)
		If Not ProcessExists ($PID) Then
			$result = True
			ExitLoop
		EndIf
		Sleep(10)
		$Diff = _DateDiff('s', _NowCalc(), $sEndDate)
		If @Error Then
			$result = True
			ExitLoop
		EndIf
		If $Diff < 0 Then
			ProcessClose($PID)
			$result = False
			ExitLoop
		EndIf

	WEnd

	Return $result

EndFunc

Func CheckResult($FlName)


		$bool = False
			$line = FileReadLine($FlName,1)
				If @error = -1 Then
					$bool = False
				EndIf
				If $line = "1"Then
					$bool = False
				ElseIf $line = "0"Then
					$bool = True
				EndIf
		 Return $bool
EndFunc


Func WriteLog ($LogFile,$Text)

	; Check if file opened for writing OK
	If $UseLogs Then
		FileWriteLine($LogFile, $Text & @CRLF)
	EndIf


EndFunc

Func WriteMultiLog ($LogFile,$Text)

	; Check if file opened for writing OK
	If $OneLog Then
		FileWriteLine($LogFile, $Text & @CRLF)
	EndIf


EndFunc

Func AksForStop ($LogFile)
	If $UseBreak Then
		$msg = MsgBox(20, "Остановка обновления", "Вы хотите остановить обновление?", 5)
		if $msg = 6 Then
			WriteLog ($LogFile,"Скрипт обновления остановлен пользователем ")
			WriteLog ($LogFile,"Обновление может быть не выполнено до конца ")
			FileClose($LogFile)
			Exit
		EndIf
	EndIf
EndFunc
Func OKButton()
  ;Note: at this point @GUI_CTRLID would equal $okbutton,
  ;and @GUI_WINHANDLE would equal $mainwindow
  $Password = GUICtrlRead($InputPassword)
  $User =  GUICtrlRead($InputLogin)
;~   MsgBox(0, "GUI Event",'Пользователь: '&$User&' Пароль: '& $Password)
  $lenpass = StringLen($Password)
  $lenuser = StringLen($User)
  If $lenuser = 0 Then
	  MsgBox(64, "Ошибка", "Не заполнен пользователь")
	  $Auth = False
  ElseIf $lenpass = 0 Then
	  MsgBox(64, "Ошибка", "Не заполнен пароль")
	  $Auth = False
  Else
	$Auth = True
  EndIf

EndFunc

Func GetBaseName ($ConnectStr)
	If StringInStr($ConnectStr, "Srvr=") > 0 Then
		$result = StringInStr($ConnectStr, "Ref=")
		$BaseName = StringRight($ConnectStr, StringLen($ConnectStr)-$result-3)
		$BaseName = StringReplace($BaseName,";",'')
		$BaseName = StringReplace($BaseName,'"','')
		$BaseName = StringStripWS($BaseName,3)
		Return $BaseName
	Else
		$NumRazdelitel = StringInStr($ConnectStr, "|")
		If $NumRazdelitel > 0 Then
			$BaseName = StringLeft ($ConnectStr,$NumRazdelitel-1)
			$BaseName = StringReplace($BaseName,";",'')
			$BaseName = StringReplace($BaseName,'"','')
			$BaseName = StringStripWS($BaseName,3)
			Return $BaseName
		Else
			$BaseName = $ConnectStr
			$BaseName = StringReplace($BaseName,"/",'_')
			$BaseName = StringReplace($BaseName,"\",'_')
			$BaseName = StringReplace($BaseName,";",'')
			$BaseName = StringReplace($BaseName,'"','')
			$BaseName = StringStripWS($BaseName,3)
			Return $BaseName
		EndIf
	EndIf
EndFunc

Func GetConnectStr($ConnectStr)
	If StringInStr($ConnectStr, "Srvr=") > 0 Then
;~ 		Srvr="192.168.17.102";Ref="УПП_КА_Аренда";
		$ConnectStr = StringReplace($ConnectStr,";",'/',1)
		$ConnectStr = StringReplace($ConnectStr,";",'')
		$ConnectStr = StringReplace($ConnectStr,'"','')
		$ConnectStr = StringReplace($ConnectStr,"Srvr=",'')
		$ConnectStr = StringReplace($ConnectStr,"Ref=",'')
		Return $ConnectStr
	ElseIf StringInStr($ConnectStr, "File=") > 0 Then
		$ConnectStr = StringReplace($ConnectStr,'"','')
		$ConnectStr = StringReplace($ConnectStr,"File=",'')
		$ConnectStr = StringReplace($ConnectStr,";",'')
		$NumRazdelitel = StringInStr($ConnectStr, "|")
		If $NumRazdelitel > 0 Then
			$ConnectStr = StringRight ($ConnectStr,StringLen($ConnectStr)-$NumRazdelitel)
		EndIf
		Return $ConnectStr
	EndIf

EndFunc

Func GetPrefics($ConnectStr)
	If StringInStr($ConnectStr, "Srvr=") > 0 Then

		Return 'S'
	Else
		Return 'F'
	EndIf

EndFunc

Func GetBackupName ($BaseName,$Rtext,$Connect)
;~ анализируем строку соединения для того чтобы определить какая эта база
;~ 	MsgBox(0, "Error", "Невозможно открыть файл для редактирования."&$BaseName)
	$BN = ReplaceStringFormat ($Rtext,$BaseName,$Connect)
;~  	MsgBox(0, "Error", ""&$BN)
    $PathNum = StringInStr($BN, "\",0,-1)
;~ 	MsgBox(0, "$PathNum", ""&$PathNum)
	$Path = StringLeft( $BN, $PathNum )
;~ 		$NachPath = "\\192.168.17.125\d$\Хранилище 1C\Разработки 1C_8\УПП_Внедрение\Выгрузки\"
    DirCreate($PathBackup & $Path )
;~ 	MsgBox(0, "$Path", $PathBackup &$Path)
	$BkName  = $PathBackup & $BN

;~ 	ElseIf StringInStr($ConnectStr, "File=") > 0 Then
;~
;~ 		DirCreate($BaseName &'\'&String (@YEAR)& String (@MON)&String (@MDAY) &'_'&String (@HOUR)&'_'& String (@MIN)& '\')

;~ 		$BkName = $BaseName & $BN
;~
;~ EndIf

	Return $BkName
EndFunc

Func GetLogFile ($LogFileName)
	;Создание файла лога обновления
	$LogFile = FileOpen($LogFileName, 9)
	If $LogFile = -1 Then
		MsgBox(0, "Error", "Невозможно открыть файл для редактирования."&$LogFileName)
		Exit
	EndIf
	Return $LogFile

EndFunc

Func DeleteLogS($BaseName)
		;~ удаляем лог пред. закрузки
	If Not FileExists($BaseName&'backup.rst') Then

		FileDelete ( $BaseName&'backup.rst' )

	EndIf

	If Not FileExists($BaseName&'update.rst') Then

		FileDelete ( $BaseName&'update.rst' )

	EndIf
EndFunc
