Class {
	#name : #DRDiscordChannel,
	#superclass : #DRChannel,
	#instVars : [
		'discordChannel'
	],
	#category : #Record-Core
}

{ #category : #'instance creation' }
DRDiscordChannel class >> new [
	self error: 'Use #on:'
]

{ #category : #'instance creation' }
DRDiscordChannel class >> on: aDiscordChannel [
	^ self basicNew 
		initializeChannel: aDiscordChannel;
		yourself
]

{ #category : #accessing }
DRDiscordChannel >> discordChannel [
	^ discordChannel
]

{ #category : #accessing }
DRDiscordChannel >> id [
	^ self discordChannel id
	
]

{ #category : #initialization }
DRDiscordChannel >> initializeChannel: aDiscordChannel [
	self initialize.
	discordChannel := aDiscordChannel
]

{ #category : #'private updating' }
DRDiscordChannel >> loadAllMessagesFrom: aChannel [
	^ OrderedCollection new: 1000 streamContents: [ :stream | 
		| messages |
		messages := aChannel messages. 
		[ messages notEmpty ]
		whileTrue: [ 
			stream nextPutAll: messages.
			DRUpdateProgressNotification signal: stream size.
			messages := aChannel 
				messagesBefore: (messages last id)
				limit: 100 ] ]
]

{ #category : #'private updating' }
DRDiscordChannel >> loadNewMessagesFrom: aChannel lastMessage: message [
	| lastId |
	lastId := message id.
	^ OrderedCollection new: 1000 streamContents: [ :stream | 
		| messages |
		[ 
			messages := aChannel messagesAfter: lastId limit: 100.
			messages notEmpty ]
		whileTrue: [ 
			stream nextPutAll: messages.
			DRUpdateProgressNotification signal: stream size.
			lastId := messages first id ] ]
]

{ #category : #accessing }
DRDiscordChannel >> name [
	^ self discordChannel name
]

{ #category : #updating }
DRDiscordChannel >> update [
	| channel newMessages |
	
	"Update channel itself"
	channel := self center guild channelNamed: self name.
	self discordChannel updateFrom: channel.
	
	"Initial load (if needed)"
	messages isEmptyOrNil ifTrue: [ 
		messages := self loadAllMessagesFrom: self discordChannel ].
	messages ifEmpty: [ ^ self ].
	
	"Now update"
	newMessages := self loadNewMessagesFrom: self discordChannel lastMessage: messages first.
	newMessages ifNotEmpty: [ 
		messages addAllFirst: newMessages ]
]
