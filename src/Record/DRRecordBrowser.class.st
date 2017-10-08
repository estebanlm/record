Class {
	#name : #DRRecordBrowser,
	#superclass : #GLMCompositePresentation,
	#category : #Record-View
}

{ #category : #building }
DRRecordBrowser >> buildOn: browser [
	browser 
		column: #channels;
		column: [ :c |
			c 
				row: #messages;
				row: #detail span: 2 ]
			span: 4.

	browser transmit to: #channels; andShow: [ :a |
		a fastList 
			title: 'Channels';
			display: [ self channels ];
			format: #name ].
		
	browser transmit from: #channels; to: #messages; andShow: [ :a |
		a table
			display: [ :channel | channel messages ];
			column: 'Date' evaluated: [ :message | message timestamp ];
			column: 'Author' evaluated: [ :message | message author ] ].
		
	browser transmit from: #messages; to: #detail; andShow: [ :a |
		a text 
			title: [ :message | 'Message: {1}: {2}' format: { message timestamp. message author }];
			display: [ :message | message content ]
		 ]
]

{ #category : #building }
DRRecordBrowser >> channels [
	^ DRCenter current channels
]

{ #category : #building }
DRRecordBrowser >> compose [
	self tabulator with: [ :browser |
		self buildOn: browser ]
]

{ #category : #showing }
DRRecordBrowser >> open [
	self openOn: Object new
]
