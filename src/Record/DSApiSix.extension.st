Extension { #name : #DSApiSix }

{ #category : #'*Record' }
DSApiSix >> messagesForChannel: channelId after: id limit: limit [
	"Returns the messages for a channel. If operating on a guild channel, 
	this endpoint requires the 'READ_MESSAGES' permission to be present on the current user. 
	Returns an array of message objects on success.
	See https://discordapp.com/developers/docs/resources/channel#get-channel-messages"
	| url response |
	url := self channelMessagesUrlForId: channelId.
	response := (self newZnClientAuthenticated)
		url: url;
		queryAt: 'after' put: id asString;
		queryAt: 'limit' put: limit asString;
		get;
		response.
	^ response isSuccess 
		ifTrue: [ DSMessage collectionFromJsonString: response contents api: self ]
		ifFalse: [ DSUnauthorizedOperationError new
			response: response;
			signal: response contents ]
]

{ #category : #'*Record' }
DSApiSix >> messagesForChannel: channelId before: id limit: limit [
	"Returns the messages for a channel. If operating on a guild channel, 
	this endpoint requires the 'READ_MESSAGES' permission to be present on the current user. 
	Returns an array of message objects on success.
	See https://discordapp.com/developers/docs/resources/channel#get-channel-messages"
	| url response |
	url := self channelMessagesUrlForId: channelId.
	response := (self newZnClientAuthenticated)
		url: url;
		queryAt: 'before' put: id asString;
		queryAt: 'limit' put: limit asString;
		get;
		response.
	^ response isSuccess 
		ifTrue: [ DSMessage collectionFromJsonString: response contents api: self ]
		ifFalse: [ DSUnauthorizedOperationError new
			response: response;
			signal: response contents ]
]
