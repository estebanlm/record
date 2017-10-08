Class {
	#name : #DRVolatileChannel,
	#superclass : #DRChannel,
	#category : #Record-Core
}

{ #category : #'instance creation' }
DRVolatileChannel class >> messages: aCollection [
	^ self basicNew 
		initializeMessages: aCollection;
		yourself
]

{ #category : #'instance creation' }
DRVolatileChannel class >> new [
	self error: 'Use #messages:'
]

{ #category : #initialization }
DRVolatileChannel >> initializeMessages: aCollection [
	self initialize.
	messages := aCollection.
	
]

{ #category : #accessing }
DRVolatileChannel >> name [
	^ '<Volatile>'
]
