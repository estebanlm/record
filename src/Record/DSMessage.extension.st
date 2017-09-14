Extension { #name : #DSMessage }

{ #category : #'*Record' }
DSMessage >> printOn: stream [
	stream 
		<< self timestamp asDateAndTime asStringYMDHM 
		<< ': '
		<< self author asString
]
