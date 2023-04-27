tell application "Music"
	try
		tell artwork 1 of current track
			if format is JPEG picture then
				set imgFormat to ".jpg"
			else
				set imgFormat to ".png"
			end if
		end tell
		set rawData to (get raw data of artwork 1 of current track)
	on error errStr number errorNumber
		# set theERR to "Sketchybar: Unable to retrieve track information."
		# display alert theERR message errStr & "
		# 		(Error Number:" & errorNumber & ")"
		# return
        return "ERROR: getting track"
	end try
end tell

set coverPath to ("/tmp/cover" & imgFormat) as text

try
	tell me to set fileRef to (open for access coverPath with write permission)
	write rawData to fileRef starting at 0
	tell me to close access fileRef
on error m number n
	log n
	log m
	try
		tell me to close access fileRef
	end try
end try

