Extension { #name : #DSMessage }

{ #category : #'*Record' }
DSMessage >> printOn: stream [
	stream 
		<< self timestamp asDateAndTime asStringYMDHM 
		<< ': '
		<< self author asString
]

{ #category : #'*Record' }
DSMessage >> timestampString [
	| local |
	
	self timestamp ifNil: [ ^ nil ].
	local := self timestamp asDateAndTime asLocal.
	^ local asDate = Date today
		ifTrue: [ local asTime print24 ]
		ifFalse: [ local asStringYMDHM ]
]
