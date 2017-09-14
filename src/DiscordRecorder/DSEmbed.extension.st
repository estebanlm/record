Extension { #name : #DSEmbed }

{ #category : #'*DiscordRecorder' }
DSEmbed >> printOn: stream [
	stream << (self fieldsAt: #type) << ': ' << self title
]
