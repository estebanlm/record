Class {
	#name : #DRChannel,
	#superclass : #Object,
	#instVars : [
		'messages'
	],
	#category : #Record-Core
}

{ #category : #accessing }
DRChannel >> messages [
	^ messages
]

{ #category : #accessing }
DRChannel >> name [
	^ self subclassResponsibility
]

{ #category : #accessing }
DRChannel >> numberOfMessages [
	^ self messages 
		ifNotNil: #size
		ifNil: [ 0 ]
]

{ #category : #updating }
DRChannel >> update [
	self subclassResponsibility
]
