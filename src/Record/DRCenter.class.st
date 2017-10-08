"
I'm a record center. 
I keep guild and channels I'm analysing.
"
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
		'messagesByChannel',
		'queries'
	],
	#classVars : [
		'Current'
	],
	#category : #Record-Core
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

{ #category : #descriptions }
DRCenter >> descriptionContainer [
	^ super descriptionContainer
		label: 'Record center';
		yourself
]

{ #category : #descriptions }
DRCenter >> descriptionEmail [
	<magritteDescription>
	
	^ MAStringDescription new
		priority: 20;
		label: 'Email';
		accessor: #email;
		beRequired;
		yourself
]

{ #category : #descriptions }
DRCenter >> descriptionGuild [
	<magritteDescription>
	
	^ MAStringDescription new
		priority: 10;
		label: 'Guild';
		accessor: #guildName;
		beRequired;
		yourself
]

{ #category : #descriptions }
DRCenter >> descriptionPassword [
	<magritteDescription>
	
	^ MAPasswordDescription new
		priority: 30;
		label: 'Password';
		accessor: #password;
		beRequired;
		yourself
]

{ #category : #private }
DRCenter >> email [
	^ email
]

{ #category : #private }
DRCenter >> email: anObject [
	email := anObject
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
	messagesByChannel := Dictionary new.
	queries := ''
]

{ #category : #'private loading' }
DRCenter >> loadAllMessagesFrom: aChannel [
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
			DRUpdateProgressNotification signal: stream size.
			lastId := messages first id ] ]
]

{ #category : #accessing }
DRCenter >> messagesByChannel [
	^ messagesByChannel
]

{ #category : #accessing }
DRCenter >> messagesForChannel: aChannel [
	^ messagesByChannel at: aChannel ifAbsent: [ #() ]
]

{ #category : #'private factory' }
DRCenter >> newClient [
	^ DSClient new
	email: email password: password;
	login
]

{ #category : #accessing }
DRCenter >> numberOfMessagesForChannel: aChannel [
	^ (self messagesForChannel: aChannel) size
]

{ #category : #private }
DRCenter >> password [
	^ password
]

{ #category : #private }
DRCenter >> password: anObject [
	password := anObject
]

{ #category : #accessing }
DRCenter >> queries [
	^ queries ifNil: [ queries := '' ]
]

{ #category : #accessing }
DRCenter >> recordChannel: channel [
	(channels includes: channel) ifTrue: [ ^ self ].
	channels := channels copyWith: channel.
	^ channel
]

{ #category : #accessing }
DRCenter >> recordChannelNamed: aString [
	| channel |
	channels 
		detect: [ :each | each name = aString ]
		ifFound: [ ^ self ].
	channel := 	self findChannelNamed: aString.	
	^ self recordChannel: channel
]

{ #category : #accessing }
DRCenter >> removeChannel: aChannel [
	channels := channels copyWithout: aChannel.
	messagesByChannel removeKey: aChannel ifAbsent: []
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
		messages := messagesByChannel at: aChannel put: (self loadAllMessagesFrom: aChannel) ].
	messages ifEmpty: [ ^ self ].
	
	"Now update"
	newMessages := self loadNewMessagesFrom: aChannel lastMessage: messages first.
	newMessages ifNotEmpty: [ 
		messages addAll: newMessages ]
]
