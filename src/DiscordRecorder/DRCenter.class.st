Class {
	#name : #DRCenter,
	#superclass : #Object,
	#instVars : [
		'session',
		'client',
		'guildName',
		'email',
		'password',
		'channels',
		'messagesByChannel'
	],
	#classVars : [
		'Current'
	],
	#category : #DiscordRecorder
}

{ #category : #accessing }
DRCenter class >> current [
	^ Current ifNil: [ Current := self new ]
]

{ #category : #accessing }
DRCenter >> channels [
	^ channels
]

{ #category : #private }
DRCenter >> client [
	self session == Smalltalk session 
		ifFalse: [ 
			client := nil.
			session := Smalltalk session ].
	^ client ifNil: [ client := self newClient ]
]

{ #category : #accessing }
DRCenter >> email: anEmail password: aPassword [ 
	email := anEmail.
	password := aPassword
]

{ #category : #private }
DRCenter >> findChannelNamed: aString [ 
	^ self client meGuilds 
		detect: [ :each | each name = self guildName ]
		ifFound: [ :each | each channelNamed: aString ]
		ifNone: [ DRError signal: ('Channel "{1}" not found.' format: {aString}) ]
]

{ #category : #gt-inspector-extension }
DRCenter >> gtInspectorChannelsIn: composite [
	<gtInspectorPresentationOrder: 0> 

	^ (composite fastTable)
		title: 'Channels';
		display: [ messagesByChannel associations ];
		column: 'Channel' 
			evaluated: [:each | GTObjectPrinter asTruncatedTextFrom: each key ];
		column: 'Messages' 
			evaluated: [:each | GTObjectPrinter asTruncatedTextFrom: each value ];
		selectionAct: [ :table |
			table rawSelection do: [ :assoc | self removeKey: assoc key ].
			table update ]
			entitled: 'Remove item(s)';
		selectionPopulate: #selection 
			entitled: 'Open key'
			with: [ :table | (table rawSelection collect: #key) gtInspectorInterestingObject ];
		beMultiple;
		send: [ :selection | 
			selection isNil 
			ifTrue:[nil]
			ifFalse:[ (selection size = 1) 
				ifTrue: [ selection anyOne value ] 
				ifFalse: [ selection collect: #value ] ] ]

]

{ #category : #private }
DRCenter >> guild [
	^ self client meGuilds 
		detect: [ :each | each name = self guildName ]
		ifNone: [ DRError signal: ('Guild "{1}" not found.' format: { self guildName }) ]
]

{ #category : #accessing }
DRCenter >> guildName [
	^ guildName
]

{ #category : #accessing }
DRCenter >> guildName: anObject [
	guildName := anObject
]

{ #category : #initialization }
DRCenter >> initialize [
	super initialize.
	channels := #().
	messagesByChannel := Dictionary new
]

{ #category : #'private loading' }
DRCenter >> loadAllMessagesFrom: aChannel [
	^ OrderedCollection new: 1000 streamContents: [ :stream | 
		| messages |
		messages := aChannel messages. 
		[ messages notEmpty ]
		whileTrue: [ 
			stream nextPutAll: messages.
			messages := aChannel 
				messagesBefore: (messages last id)
				limit: 100 ] ]
]

{ #category : #'private loading' }
DRCenter >> loadNewMessagesFrom: aChannel lastMessage: message [
	| lastId |
	lastId := message id.
	^ OrderedCollection new: 1000 streamContents: [ :stream | 
		| messages |
		[ 
			messages := aChannel messagesAfter: lastId limit: 100.
			messages notEmpty ]
		whileTrue: [ 
			stream nextPutAll: messages.
			lastId := messages first id ] ]
]

{ #category : #accessing }
DRCenter >> messagesByChannel [
	^ messagesByChannel
]

{ #category : #'private factory' }
DRCenter >> newClient [
	^ DSClient new
	email: email password: password;
	login
]

{ #category : #accessing }
DRCenter >> recordChannel: channel [
	(channels includes: channel) ifTrue: [ ^ self ].
	channels := channels copyWith: channel
]

{ #category : #accessing }
DRCenter >> recordChannelNamed: aString [
	| channel |
	channels 
		detect: [ :each | each name = aString ]
		ifFound: [ ^ self ].
	channel := 	self findChannelNamed: aString.	
	self recordChannel: channel
]

{ #category : #accessing }
DRCenter >> removeChannel: aChannel [
	channels := channels copyWithout: aChannel.
	messagesByChannel removeKey: aChannel
]

{ #category : #accessing }
DRCenter >> removeChannelNamed: aString [ 
	channels 
		detect: [ :each | each name = aString ] 
		ifFound: [ :each | self removeChannel: each ]
	
]

{ #category : #private }
DRCenter >> session [
	^ session
]

{ #category : #storing }
DRCenter >> store [
	| file |
	
	file := 'record.fuel' asFileReference nextVersion.
	FLSerializer serialize: self toFileNamed:  file fullName.
]

{ #category : #updating }
DRCenter >> updateAll [
	self channels do: [ :each | self updateChannel: each ]
]

{ #category : #updating }
DRCenter >> updateChannel: aChannel [
	| messages channel newMessages |
	
	"Update channel itself"
	channel := self guild channelNamed: aChannel name.
	aChannel updateFrom: channel.
	
	"Initial load (if needed)"
	messages := messagesByChannel at: aChannel ifAbsent: [ nil ].
	messages isEmptyOrNil ifTrue: [ 
		messages := messagesByChannel 
			at: aChannel
			put: (self loadAllMessagesFrom: aChannel) ].
	messages ifEmpty: [ ^ self ].
	
	"Now update"
	newMessages := self loadNewMessagesFrom: aChannel lastMessage: messages first.
	newMessages ifNotEmpty: [ 
		messagesByChannel 
			at: aChannel
			put: newMessages, messages ]
]
