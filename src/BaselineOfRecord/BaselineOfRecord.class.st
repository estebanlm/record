Class {
	#name : #BaselineOfRecord,
	#superclass : #BaselineOf,
	#category : #BaselineOfRecord
}

{ #category : #baselines }
BaselineOfRecord >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		self discord: spec.
		self toolkit: spec.
		spec package: #'Record' with: [ 
			spec requires: #(DiscordSt Toolkit) ] ].
]

{ #category : #baselines }
BaselineOfRecord >> discord: spec [
	spec 
		baseline: 'DiscordSt' 
		with: [ spec repository: 'github://JurajKubelka/DiscordSt:client/src' ]
]

{ #category : #baselines }
BaselineOfRecord >> toolkit: spec [
	spec 
		baseline: 'Toolkit' 
		with: [ spec repository: 'github://estebanlm/toolkit/src' ]
]
