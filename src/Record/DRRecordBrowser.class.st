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
			'{1} ({2})' format: { channel name. channel numberOfMessages } ]
]

{ #category : #building }
DRRecordBrowser >> addChannelMessageListOn: a [
	a fastTable
		title: [ :channel | '{1} ({2} messages)' format: { channel name. channel numberOfMessages } ];
		display: [ :channel | channel messages ];
		column: 'Date' evaluated: [ :message | message timestampString ];
		column: 'Author' evaluated: [ :message | message author username ]
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
DRRecordBrowser >> addQueryOn: aPresenter [
	aPresenter pharoScript
		title: 'Query';
		display: [ self center queries ];
		variableBindings: [ :channel | 
			{ #channel -> (self center messagesForChannel: channel).
			  #allChannels -> (DRCompositeChannelSelector on: self center) } ];
		onChangeOfPort: #text act: [ :presentation | self center queries: presentation text ];
		installDefaultSelectionActions
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
			self addQueryOn: a ].
		
	browser transmit 
		from: #channels; 
		to: #messages; 
		andShow: [ :a | self addChannelMessageListOn: a ].
		
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
	^ self center channels
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
	(TkMagritteEditor object: DRCenterOld current) go
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
