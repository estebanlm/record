Extension { #name : #DSGuildChannel }

{ #category : #'*DiscordRecorder' }
DSGuildChannel >> updateFrom: aChannel [
	fields := aChannel fields.
	api := aChannel restApi.
]
