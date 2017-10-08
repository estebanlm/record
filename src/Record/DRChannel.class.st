Class {
	#name : #DRChannel,
	#superclass : #Object,
	#instVars : [
		'messages',
		'center'
	],
	#category : #Record-Core
}

{ #category : #accessing }
DRChannel >> center [
	^ center
]

{ #category : #accessing }
DRChannel >> center: aCenter [
	center := aCenter
]

{ #category : #accessing }
DRChannel >> discordChannel [
	^ nil
]

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
