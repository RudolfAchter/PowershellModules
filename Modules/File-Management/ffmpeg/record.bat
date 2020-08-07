@echo off
:: Author: Rudolf Achter
:: Description: Nimmt den primären Bildschirm mit Screen Capture Recorder auf
:: Startet zwei Instanzen. Eine nimmt Bildschirm und Wiedergegebenen Sound auf
:: die zweite Instanz Nimmt das Mikrofon auf
:: Es wird kaum komprimiert, dass wir zumindest 10 Frames Full HD schaffen danach also das Video vernünftig packen

::Parameter
::Es können einer oder mehrere Parameter angegeben werden
::		audio			Bildschirm wird mit Ton aufgenommen
:: 		micro			Das Mikrofon wird mit aufgenommen
::		region			Zeig ein Fenster mit dem die aufzunehmende Region festgelegt werden kann
::		reset			Bietet die Möglichkeit alle Werte von Screen Capture Recorder zu setzen oder zu resetten

::Konfiguration

::So viele Frames per Second VERSUCHEN aufzuzeichnen
SET FRAMERATE=10
::Da hin willst du speichern
SET PATHPREFIX=C:\Users\darudi\Videos\Captures\record_
::So heisst dein Mikrofon
::Bekommst du so raus:
::ffmpeg -list_devices true -f dshow -i dummy 
SET MICROPHONE=Mikrofon (IDT High Definition Audio CODEC)
::So viel labert ffmpeg
SET LOGLEVEL=info
::Hier ist Screen Capture Recorder installiert
SET SCREEN_CAPTURE_RECORDER_PATH=C:\Program Files (x86)\Screen Capturer Recorder\

:: Quality Profile für Komprimierung mit libx264
SET QUALITY_PROFILE=30
::Konfiguration Ende

SET CAPTURE_MICRO=no
SET CAPTURE_AUDIO=no
SET ASK_REGION=no
SET ASK_RESET=no
::Der Zeit String ist ein Graus
::Wenn ich das mit %TIME% machen wuerde hätte ich ein Problem bei
::einstelliger Uhrzeit
::z.B. 0:05 oder 8:45 ab 10:01 passts erst

::For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set TIMESTR=%%a%%b)
SET TIMESTR=%time:~0,2%_%time:~3,2%_%time:~6,2%
SET DATESTR=%date:~6,4%-%date:~3,2%-%date:~0,2%_%TIMESTR%
SET VIDEOFILE=%PATHPREFIX%%DATESTR%_bildschirm_noaudio.mkv


FOR %%i in (%1 %2 %3 %4) do (

	IF "%%i" EQU "audio" (
		SET CAPTURE_AUDIO=yes
		SET VIDEOFILE=%PATHPREFIX%%DATESTR%_bildschirm_audio.mkv
	)
	
	IF "%%i" EQU "micro" (
		SET CAPTURE_MICRO=yes
	)
	
	IF "%%i" EQU "region" (
		SET ASK_REGION=yes
	)
	
	IF "%%i" EQU "reset" (
		SET ASK_RESET=yes
	)	
	
)

echo CAPTURE_AUDIO %CAPTURE_AUDIO%
echo CAPTURE_MICRO %CAPTURE_MICRO%
echo ASK_REGION %ASK_REGION%
echo ASK_RESET %ASK_RESET%
echo VIDEOFILE %VIDEOFILE%



IF "%ASK_RESET%" EQU "yes" (
	pushd "%SCREEN_CAPTURE_RECORDER_PATH%\configuration_setup_utility"
	call rudi_run_rb.bat setup_via_numbers.rb
	popd
)

::Fragt den User welcher Bildschirm Bereich aufgenommen werden soll
IF "%ASK_REGION%" EQU "yes" (
	pushd "%SCREEN_CAPTURE_RECORDER_PATH%\configuration_setup_utility"
	call rudi_run_rb.bat window_resize.rb
	popd
)

::Damit das alles Minimiert startet start ich das in einer neuen Batch

start /MIN /BELOWNORMAL record_proc.bat

