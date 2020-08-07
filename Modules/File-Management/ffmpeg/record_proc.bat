@echo off
::Hier wird  versucht das Mikrofon mit aufzuzeichnen


IF "%CAPTURE_MICRO%" EQU "yes" (
	
	echo starting recording microphone instance

	start /BELOWNORMAL /MIN ffmpeg -loglevel %LOGLEVEL% -y ^
		-f dshow -i audio="%MICROPHONE%" ^
		-acodec pcm_s16le ^
		"%PATHPREFIX%%DATESTR%_mikrofon.wav"
)

echo Die FFmpeg Prozesse mit mit "Q" auf der Tastatur zu beenden

::Nimmt den Bildschirm auf
IF "%CAPTURE_AUDIO%" EQU "yes" (

	echo starting recording with audio to %VIDEOFILE%
	start /WAIT /BELOWNORMAL /MIN ffmpeg -loglevel %LOGLEVEL% -y -framerate %FRAMERATE% ^
		-f dshow -i video="screen-capture-recorder":audio="virtual-audio-capturer" ^
		-r %FRAMERATE% -vcodec libx264 -qp 0 -preset ultrafast -acodec pcm_s16le ^
		"%VIDEOFILE%"
		
	echo Compressing Video to %PATHPREFIX%%DATESTR%_bildschirm_audio.mp4
	
	start /B /LOW /MIN ffmpeg -i "%VIDEOFILE%"  ^
		-vcodec libx264 -acodec libvo_aacenc -r %FRAMERATE% -qp %QUALITY_PROFILE% ^
		-pix_fmt yuv420p ^
		"%PATHPREFIX%%DATESTR%_bildschirm_audio.mp4"

) ELSE (
	
	echo starting recording without audio to %VIDEOFILE%
	start /WAIT /BELOWNORMAL /MIN ffmpeg -loglevel %LOGLEVEL% -y -framerate %FRAMERATE% ^
		-f dshow -i video="screen-capture-recorder" ^
		-r %FRAMERATE% -vcodec libx264 -qp 0 -preset ultrafast ^
		"%VIDEOFILE%"
		
	echo Compressing Video to %PATHPREFIX%%DATESTR%_bildschirm_noaudio.mp4
	
	start /B /LOW /MIN ffmpeg -i "%VIDEOFILE%"  ^
		-vcodec libx264 -r %FRAMERATE% -qp %QUALITY_PROFILE% ^
		-pix_fmt yuv420p ^
		"%PATHPREFIX%%DATESTR%_bildschirm_noaudio.mp4"
)


exit