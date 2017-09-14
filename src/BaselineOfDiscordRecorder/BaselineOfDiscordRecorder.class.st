Class {
	#name : #BaselineOfDiscordRecorder,
	#superclass : #BaselineOf,
	#category : #BaselineOfDiscordRecorder
}

{ #category : #baselines }
BaselineOfDiscordRecorder >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec	
			baseline: 'DiscordSt' with: [
				spec repository: 'github://JurajKubelka/DiscordSt:client/src' ];
			package: #'DiscordRecorder' ].
]
