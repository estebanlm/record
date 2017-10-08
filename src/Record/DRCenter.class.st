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
DRCenter >> addChannel: aChannel [
	aChannel center: self.
	channels := channels copyWith: aChannel.
	^ aChannel
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
DRCenter >> findDiscordChannelNamed: aString [ 
	^ self client meGuilds 
		detect: [ :each | each name = self guildName ]
		ifFound: [ :each | each channelNamed: aString ]
		ifNone: [ DRError signal: ('Channel "{1}" not found.' format: {aString}) ]
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

{ #category : #'private factory' }
DRCenter >> newClient [
	^ DSClient new
	email: email password: password;
	login
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
DRCenter >> queries: aStringOrText [
	queries := aStringOrText asString
]

{ #category : #accessing }
DRCenter >> recordChannelNamed: aString [
	| channel |
	channels 
		detect: [ :each | each name = aString ]
		ifFound: [ ^ self ].
	channel := 	self findDiscordChannelNamed: aString.	
	^ self recordDiscordChannel: channel
]

{ #category : #private }
DRCenter >> recordDiscordChannel: channel [
	(channels anySatisfy: [ :each | each discordChannel = channel]) ifTrue: [ ^ self ].
	^ self addChannel: (DRDiscordChannel on: channel) 
]

{ #category : #accessing }
DRCenter >> removeChannel: aChannel [
	channels := channels copyWithout: aChannel
	
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
	self channels do: [ :each | each update ]
]
