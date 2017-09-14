Extension { #name : #DSGuildTextChannel }

{ #category : #'*DiscordRecorder' }
DSGuildTextChannel >> messagesAfter: id limit: limit [ 
	"Returns the messages for a channel. If operating on a guild channel, 
	this endpoint requires the 'READ_MESSAGES' permission to be present on the current user. 
	Returns an array of message objects on success.
	See https://discordapp.com/developers/docs/resources/channel#get-channel-messages"

	^ self restApi 
		messagesForChannel: self id 
		after: id 
		limit: limit
]

{ #category : #'*DiscordRecorder' }
DSGuildTextChannel >> messagesBefore: id limit: limit [ 
	"Returns the messages for a channel. If operating on a guild channel, 
	this endpoint requires the 'READ_MESSAGES' permission to be present on the current user. 
	Returns an array of message objects on success.
	See https://discordapp.com/developers/docs/resources/channel#get-channel-messages"

	^ self restApi 
		messagesForChannel: self id 
		before: id 
		limit: limit
]
