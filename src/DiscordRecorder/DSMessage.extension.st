Extension { #name : #DSMessage }

{ #category : #'*DiscordRecorder' }
DSMessage >> printOn: stream [
	stream 
		<< self timestamp asDateAndTime asStringYMDHM 
		<< ': '
		<< self author asString
]
