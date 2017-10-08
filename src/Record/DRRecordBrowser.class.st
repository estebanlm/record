"
I'm a browser for record/discord.
"
Class {
	#name : #DRRecordBrowser,
	#superclass : #GLMCompositePresentation,
	#category : #Record-View
}

{ #category : #building }
DRRecordBrowser >> addChannelListOn: aPresenter [
	aPresenter fastList 
		title: 'Channels';
		act: [ :presentation | self doAddChannelThen: [ presentation update ] ] 
			icon: #add asIcon 
			entitled: 'Add channel';
		act: [ :presentation | self doUpdateAllChannelsThen: [ presentation update ] ] 
			icon: #glamorousRefresh asIcon 
			entitled: 'Refresh all channels';
		selectionAct: [ :presentation | 
			self 
				doUpdateChannel: presentation selection
				then: [ presentation update ] ] 
			icon: #glamorousRefresh asIcon 
			entitled: 'Update channel';
		selectionAct: [ :presentation | 
			self 
				doRemoveChannel: presentation selection 
				then: [ presentation update ] ] 
			icon: #remove asIcon 
			entitled: 'Remove channel';
		display: [ self channels sorted: [ :a :b | a name < b name ] ];
		format: [ :channel | 
			'{1} ({2})' format: { channel name. (self center numberOfMessagesForChannel: channel) } ]
]

{ #category : #building }
DRRecordBrowser >> addChannelMessageListOn: a [
	a fastTable
		title: [ :channel | '{1} ({2} messages)' format: { channel name. self center numberOfMessagesForChannel: channel } ];
		display: [ :channel | self center messagesForChannel: channel ];
		column: 'Date' evaluated: [ :message | message timestampString ];
		column: 'Author' evaluated: [ :message | message author username ]";
		column: 'Embeds' 
			evaluated: [ :message | 
				message embeds 
					ifNotEmpty: [ :embeds | embeds size ]
					ifEmpty: [ '' ] ]"
]

{ #category : #building }
DRRecordBrowser >> addMessageContentOn: a [
	a text 
		title: [ :message | 
			'at {1} by {2}' format: { 
				message timestampString. 
				message author username }];
		display: [ :message | message content ]
]

{ #category : #building }
DRRecordBrowser >> addMessageEmbedsOn: aPresenter [
	aPresenter fastList 
		title: 'Embeds';
		display: [ :message | message embeds ];
		when: #hasEmbeds
]

{ #category : #building }
DRRecordBrowser >> addMessageOn: aPresenter [
	self addMessageContentOn: aPresenter.
	self addMessageEmbedsOn: aPresenter
]

{ #category : #building }
DRRecordBrowser >> addQueryListOn: aPresenter [
	aPresenter fastList 
		title: 'Queries';
		display: [ self center queries sorted: [ :a :b | a description < b description ] ];
		format: #shortDescription;
		yourself
]

{ #category : #building }
DRRecordBrowser >> addQueryOn: a [
	a pharoScript
		title: 'Query';
		display: [ self center queries ];
		variableBindings: [ :channel | 
			{ #channel -> channel.
			  #allChannels -> (DRCompositeChannelSelector on: self center) } ]
]

{ #category : #building }
DRRecordBrowser >> buildOn: browser [
	browser 
		column: #channels;
		column: [ :c |
			c 
				row: #messages;
				row: #detail span: 2 ]
			span: 3.

	browser transmit 
		to: #channels; 
		andShow: [ :a | 
			self addChannelListOn: a.
			"self addQueryListOn: a" ].
		
	browser transmit 
		from: #channels; 
		to: #messages; 
		andShow: [ :a | 
			self addChannelMessageListOn: a.
			self addQueryOn: a ].
		
	browser transmit 
		from: #messages; 
		to: #detail; 
		andShow: [ :a | self addMessageOn: a ]
]

{ #category : #accessing }
DRRecordBrowser >> center [
	^ DRCenter current
]

{ #category : #accessing }
DRRecordBrowser >> channels [
	^ DRCenter current channels
]

{ #category : #building }
DRRecordBrowser >> compose [
	self 		
		act: [ :presentation | self doConfigureThen: [ presentation update ] ] 
		icon: #configuration asIcon 
		entitled: 'Configure'.

	self tabulator with: [ :browser |
		self buildOn: browser ]
]

{ #category : #actions }
DRRecordBrowser >> doAddChannelThen: aBlock [
	| channelName channel |

	channelName := UIManager default 
		request: 'Channel name' 
		initialAnswer: '' 
		title: 'Add new channel'.
	channelName ifNil: [ ^ self ].
	channel := self center recordChannelNamed: channelName.
	UIManager default informUserDuring: [ :bar | 
		bar label: ('Updating channel "{1}".' format: { channel name }).
		[ self center updateChannel: channel ]
		on: DRUpdateProgressNotification 
		do: [ :e | 
			bar label: ('Updating channel "{1}" ({2}).' format: { channel name. e messageText }).
			e resume ] ].
	
	aBlock value
]

{ #category : #actions }
DRRecordBrowser >> doConfigureThen: aBlock [
	(TkMagritteEditor object: DRCenter current) go
		ifNotNil: aBlock
]

{ #category : #actions }
DRRecordBrowser >> doRemoveChannel: aChannel then: aBlock [
	(self confirm: ('You are going to remove "{1}". Are you sure?' format: { aChannel name }))
		ifFalse: [ ^ self ].
	self center removeChannel: aChannel.
	aBlock value
]

{ #category : #actions }
DRRecordBrowser >> doUpdateAllChannelsThen: aBlock [
	UIManager default informUserDuring: [ :bar | 
		self center channels do: [ :eachChannel | 
			bar label: ('Updating channel "{1}".' format: { eachChannel name }).
			[ self center updateChannel: eachChannel ]
			on: DRUpdateProgressNotification 
			do: [ :e | 
				bar label: ('Updating channel "{1}" ({2}).' format: { eachChannel name. e messageText }).
				e resume ] ] ].
	aBlock value
]

{ #category : #actions }
DRRecordBrowser >> doUpdateChannel: aChannel then: aBlock [
	UIManager default informUserDuring: [ :bar | 
		bar label: ('Updating channel "{1}".' format: { aChannel name }).
		[ self center updateChannel: aChannel ]
		on: DRUpdateProgressNotification 
		do: [ :e | 
			bar label: ('Updating channel "{1}" ({2}).' format: { aChannel name. e messageText }).
			e resume ] ].
	aBlock value
]

{ #category : #showing }
DRRecordBrowser >> open [
	self openOn: Object new
]

{ #category : #accessing }
DRRecordBrowser >> title [
	^ 'Record browser'
]
