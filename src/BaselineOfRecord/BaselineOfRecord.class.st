Class {
	#name : #BaselineOfRecord,
	#superclass : #BaselineOf,
	#category : #BaselineOfRecord
}

{ #category : #baselines }
BaselineOfRecord >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec	
			baseline: 'DiscordSt' with: [
				spec repository: 'github://JurajKubelka/DiscordSt:client/src' ];
			package: #'DiscordRecorder' ].
]
