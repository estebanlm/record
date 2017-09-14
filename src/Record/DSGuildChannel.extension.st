Extension { #name : #DSGuildChannel }

{ #category : #'*Record' }
DSGuildChannel >> updateFrom: aChannel [
	fields := aChannel fields.
	api := aChannel restApi.
]
