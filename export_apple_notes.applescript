on esc(s)
	set t to s as text
	set AppleScript's text item delimiters to "\\"
	set parts to text items of t
	set AppleScript's text item delimiters to "\\\\"
	set t to parts as text
	set AppleScript's text item delimiters to tab
	set parts to text items of t
	set AppleScript's text item delimiters to "\\t"
	set t to parts as text
	set AppleScript's text item delimiters to return
	set parts to text items of t
	set AppleScript's text item delimiters to "\\n"
	set t to parts as text
	set AppleScript's text item delimiters to linefeed
	set parts to text items of t
	set AppleScript's text item delimiters to "\\n"
	set t to parts as text
	set AppleScript's text item delimiters to ""
	return t
end esc

set folderName to "Projet de vie (maisons de memoire)"
set outPath to "/private/tmp/apple_notes_project_export.tsv"
set rows to ""

tell application "/System/Applications/Notes.app"
	set targetFolder to first folder whose name is folderName
	set folderNotes to notes of targetFolder
	repeat with i from 1 to count of folderNotes
		set n to item i of folderNotes
		try
			set noteName to name of n
			set noteBody to body of n
			set createdAt to creation date of n
			set modifiedAt to modification date of n
			set rows to rows & i & tab & my esc(noteName) & tab & my esc(createdAt as text) & tab & my esc(modifiedAt as text) & tab & my esc(noteBody) & linefeed
		on error errMsg
			set rows to rows & i & tab & "[SKIPPED]" & tab & "" & tab & "" & tab & my esc(errMsg) & linefeed
		end try
	end repeat
end tell

set f to open for access POSIX file outPath with write permission
set eof of f to 0
write rows to f as «class utf8»
close access f
return outPath
