Class {
	#name : #DRUpdateProgressNotification,
	#superclass : #Notification,
	#category : #Record-Core
}

{ #category : #exceptiondescription }
DRUpdateProgressNotification >> defaultAction [
	self resume
]
