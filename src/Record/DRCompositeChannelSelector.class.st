Class {
	#name : #DRCompositeChannelSelector,
	#superclass : #Object,
	#instVars : [
		'center'
	],
	#category : #Record-Core
}

{ #category : #'instance creation' }
DRCompositeChannelSelector class >> new [
	self error: 'Use #on:'
]

{ #category : #'instance creation' }
DRCompositeChannelSelector class >> on: aCenter [
	^ self basicNew initializeCenter: aCenter
]

{ #category : #accessing }
DRCompositeChannelSelector >> center [
	^ center
]

{ #category : #initialization }
DRCompositeChannelSelector >> initializeCenter: aCenter [ 
	self initialize.
	center := aCenter
]

{ #category : #enumerating }
DRCompositeChannelSelector >> select: aBlock [
	^ self center channels 
		inject: (OrderedCollection new: 1000)
		into: [ :all :each | 
			all addAll: ((self center messagesForChannel: each) select: aBlock); yourself ]
]
