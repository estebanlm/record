Extension { #name : #DSEmbed }

{ #category : #'*Record' }
DSEmbed >> printOn: stream [
	stream << (self fieldsAt: #type) << ': ' << self title
]
