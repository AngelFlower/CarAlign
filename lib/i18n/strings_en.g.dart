///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'CarAlign'
	String get appName => 'CarAlign';

	/// en: '.'
	String get decimalSeparator => '.';

	late final Translations$common$en common = Translations$common$en.internal(_root);
	late final Translations$audioSource$en audioSource = Translations$audioSource$en.internal(_root);
	late final Translations$band$en band = Translations$band$en.internal(_root);
	late final Translations$phase$en phase = Translations$phase$en.internal(_root);
	late final Translations$notice$en notice = Translations$notice$en.internal(_root);
	late final Translations$home$en home = Translations$home$en.internal(_root);
	late final Translations$advanced$en advanced = Translations$advanced$en.internal(_root);
	late final Translations$diagnostics$en diagnostics = Translations$diagnostics$en.internal(_root);
	late final Translations$guard$en guard = Translations$guard$en.internal(_root);
	late final Translations$resultMessage$en resultMessage = Translations$resultMessage$en.internal(_root);
	late final Translations$reason$en reason = Translations$reason$en.internal(_root);
	late final Translations$placement$en placement = Translations$placement$en.internal(_root);
}

// Path: common
class Translations$common$en {
	Translations$common$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Stop'
	String get stop => 'Stop';

	/// en: 'Start'
	String get start => 'Start';

	/// en: 'Left'
	String get sideLeft => 'Left';

	/// en: 'Right'
	String get sideRight => 'Right';

	/// en: 'L'
	String get sideLeftShort => 'L';

	/// en: 'R'
	String get sideRightShort => 'R';

	/// en: '$value ms'
	String millisecondsValue({required Object value}) => '${value} ms';
}

// Path: audioSource
class Translations$audioSource$en {
	Translations$audioSource$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Android Auto'
	String get androidAuto => 'Android Auto';

	/// en: 'Bluetooth'
	String get bluetooth => 'Bluetooth';

	/// en: 'Phone speaker'
	String get phoneSpeaker => 'Phone speaker';

	/// en: 'USB'
	String get usb => 'USB';

	/// en: 'Unrecognized source'
	String get unrecognized => 'Unrecognized source';

	/// en: 'Unknown source'
	String get unknown => 'Unknown source';
}

// Path: band
class Translations$band$en {
	Translations$band$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'broad'
	String get broad => 'broad';

	/// en: 'low'
	String get low => 'low';

	/// en: 'mid'
	String get mid => 'mid';

	/// en: 'high'
	String get high => 'high';
}

// Path: phase
class Translations$phase$en {
	Translations$phase$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Preparing'
	String get preparing => 'Preparing';

	/// en: 'Adjusting level'
	String get adjustingLevel => 'Adjusting level';

	/// en: 'Measuring'
	String get measuring => 'Measuring';

	/// en: 'Verifying'
	String get verifying => 'Verifying';

	/// en: 'Stopping capture'
	String get stoppingCapture => 'Stopping capture';

	/// en: 'Done'
	String get done => 'Done';
}

// Path: notice
class Translations$notice$en {
	Translations$notice$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The app that is playing doesn't allow its audio to be processed (capture blocked). Alignment was stopped and the original audio was restored.'
	String get captureBlocked => 'The app that is playing doesn\'t allow its audio to be processed (capture blocked). Alignment was stopped and the original audio was restored.';

	/// en: 'Without the guard the original audio can't be muted; reopen the app or check the setup steps in Diagnostics.'
	String get demoNeedsGuard => 'Without the guard the original audio can\'t be muted; reopen the app or check the setup steps in Diagnostics.';

	/// en: 'Add a song to the player first, then run the demo.'
	String get demoNeedsMusic => 'Add a song to the player first, then run the demo.';
}

// Path: home
class Translations$home$en {
	Translations$home$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How to place the phone'
	String get guideTooltip => 'How to place the phone';

	/// en: 'Advanced'
	String get advancedTooltip => 'Advanced';

	late final Translations$home$readiness$en readiness = Translations$home$readiness$en.internal(_root);
	late final Translations$home$status$en status = Translations$home$status$en.internal(_root);
	late final Translations$home$align$en align = Translations$home$align$en.internal(_root);
	late final Translations$home$countdown$en countdown = Translations$home$countdown$en.internal(_root);
	late final Translations$home$measuring$en measuring = Translations$home$measuring$en.internal(_root);
	late final Translations$home$result$en result = Translations$home$result$en.internal(_root);
	late final Translations$home$profiles$en profiles = Translations$home$profiles$en.internal(_root);
	late final Translations$home$player$en player = Translations$home$player$en.internal(_root);
	late final Translations$home$delay$en delay = Translations$home$delay$en.internal(_root);
}

// Path: advanced
class Translations$advanced$en {
	Translations$advanced$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Advanced'
	String get title => 'Advanced';

	late final Translations$advanced$manual$en manual = Translations$advanced$manual$en.internal(_root);
	late final Translations$advanced$demo$en demo = Translations$advanced$demo$en.internal(_root);
	late final Translations$advanced$diagnostics$en diagnostics = Translations$advanced$diagnostics$en.internal(_root);
	late final Translations$advanced$capture$en capture = Translations$advanced$capture$en.internal(_root);
}

// Path: diagnostics
class Translations$diagnostics$en {
	Translations$diagnostics$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Diagnostics'
	String get title => 'Diagnostics';

	/// en: 'What this phone supports. If something doesn't work on another phone, copy the report and share it.'
	String get intro => 'What this phone supports. If something doesn\'t work on another phone, copy the report and share it.';

	/// en: 'Loading…'
	String get loading => 'Loading…';

	/// en: 'No data'
	String get noData => 'No data';

	/// en: 'No response'
	String get noResponse => 'No response';

	/// en: 'Test muting'
	String get testMute => 'Test muting';

	/// en: 'Copy report'
	String get copyReport => 'Copy report';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Battery saver'
	String get batterySaver => 'Battery saver';

	/// en: 'Report copied'
	String get reportCopied => 'Report copied';

	/// en: 'The muting channel works on this phone. $detail'
	String muteWorks({required Object detail}) => 'The muting channel works on this phone.\n${detail}';

	/// en: 'The muting channel does NOT work yet. $detail'
	String muteFails({required Object detail}) => 'The muting channel does NOT work yet.\n${detail}';

	/// en: 'Important limitation'
	String get limitationTitle => 'Important limitation';

	/// en: 'The built-in player needs nothing special. Capture mode (delaying other music apps) is different: Android doesn't let a regular app mute another one, so it needs an ADB channel, enabled from a computer (adb tcpip 5555) every time the phone restarts, or Shizuku. Without that channel capture mode can't mute the original audio and won't start.'
	String get limitationBody => 'The built-in player needs nothing special. Capture mode (delaying other music apps) is different: Android doesn\'t let a regular app mute another one, so it needs an ADB channel, enabled from a computer (adb tcpip 5555) every time the phone restarts, or Shizuku. Without that channel capture mode can\'t mute the original audio and won\'t start.';

	/// en: 'Set up capture mode on another phone'
	String get setupTitle => 'Set up capture mode on another phone';

	/// en: 'Enable developer options: Settings → About phone → tap "Build number" 7 times.'
	String get step1 => 'Enable developer options: Settings → About phone → tap "Build number" 7 times.';

	/// en: 'In developer options, enable "USB debugging".'
	String get step2 => 'In developer options, enable "USB debugging".';

	/// en: 'Connect the phone to a computer with ADB and run adb tcpip 5555 . It must be repeated every time the phone restarts.'
	String get step3 => 'Connect the phone to a computer with ADB and run  adb tcpip 5555 . It must be repeated every time the phone restarts.';

	/// en: 'Open CarAlign. If "Allow debugging?" appears, accept it and tick "Always allow".'
	String get step4 => 'Open CarAlign. If "Allow debugging?" appears, accept it and tick "Always allow".';

	/// en: 'Tap "Test muting". If it fails, read the reason: some brands need more settings (Xiaomi/Redmi/POCO: "USB debugging (security settings)"; Samsung: turn off Auto Blocker's USB command blocking).'
	String get step5 => 'Tap "Test muting". If it fails, read the reason: some brands need more settings (Xiaomi/Redmi/POCO: "USB debugging (security settings)"; Samsung: turn off Auto Blocker\'s USB command blocking).';

	/// en: 'Tap "Battery saver" and allow CarAlign to run unrestricted so it isn't closed in the background.'
	String get step6 => 'Tap "Battery saver" and allow CarAlign to run unrestricted so it isn\'t closed in the background.';

	/// en: 'Without this channel, capture mode can't mute the original audio and you would hear it doubled.'
	String get footer => 'Without this channel, capture mode can\'t mute the original audio and you would hear it doubled.';
}

// Path: guard
class Translations$guard$en {
	Translations$guard$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Network ADB is not active. Shizuku isn't running either: open Shizuku and tap Start (wireless debugging), or connect the cable and run adb tcpip 5555 from a computer.'
	String get adbInactiveNoShizuku => 'Network ADB is not active. Shizuku isn\'t running either: open Shizuku and tap Start (wireless debugging), or connect the cable and run adb tcpip 5555 from a computer.';

	/// en: 'Couldn't use the phone's ADB: $error. Shizuku isn't running either: open Shizuku and tap Start (wireless debugging), or connect the cable and run adb tcpip 5555 from a computer.'
	String adbFailedNoShizuku({required Object error}) => 'Couldn\'t use the phone\'s ADB: ${error}. Shizuku isn\'t running either: open Shizuku and tap Start (wireless debugging), or connect the cable and run adb tcpip 5555 from a computer.';

	/// en: 'Shizuku is active but failed: $error'
	String shizukuFailed({required Object error}) => 'Shizuku is active but failed: ${error}';

	/// en: 'The guard did not start.'
	String get notStarted => 'The guard did not start.';
}

// Path: resultMessage
class Translations$resultMessage$en {
	Translations$resultMessage$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'The audio output is the phone speaker, not the car. Connect Android Auto or the car's Bluetooth and try again.'
	String get speakerOutput => 'The audio output is the phone speaker, not the car. Connect Android Auto or the car\'s Bluetooth and try again.';

	/// en: 'Audio is going through the Bluetooth call line (mono, low quality). On the phone, go to Bluetooth > car > enable "Media audio" and try again.'
	String get bluetoothCallLine => 'Audio is going through the Bluetooth call line (mono, low quality). On the phone, go to Bluetooth > car > enable "Media audio" and try again.';

	/// en: 'The signal can't be heard well: raise the car volume, close the windows or reduce the noise and try again.'
	String get noSignal => 'The signal can\'t be heard well: raise the car volume, close the windows or reduce the noise and try again.';

	/// en: 'The signal was clipping; the measurement level was lowered.'
	String get clipped => 'The signal was clipping; the measurement level was lowered.';

	/// en: 'The measurement was not reliable: $reason.'
	String measurementUnreliable({required Object reason}) => 'The measurement was not reliable: ${reason}.';

	/// en: 'The verification was not reliable: $reason.'
	String verificationUnreliable({required Object reason}) => 'The verification was not reliable: ${reason}.';

	/// en: 'The measured difference is very large; check the phone's position.'
	String get differenceTooLarge => 'The measured difference is very large; check the phone\'s position.';

	/// en: 'The adjustment could not be verified, so it is not applied.'
	String get notVerifiable => 'The adjustment could not be verified, so it is not applied.';

	/// en: 'Left and right sound identical (same arrival and level). If you didn't expect that, the output may be mono or mixed; check balance, fader and that the audio is stereo.'
	String get identicalChannels => 'Left and right sound identical (same arrival and level). If you didn\'t expect that, the output may be mono or mixed; check balance, fader and that the audio is stereo.';

	/// en: 'The adjustment doesn't fully converge; a residual of $us µs remains.'
	String notConverging({required Object us}) => 'The adjustment doesn\'t fully converge; a residual of ${us} µs remains.';

	/// en: 'The adjustment doesn't converge (residual $us µs); it is not applied.'
	String notConvergingRejected({required Object us}) => 'The adjustment doesn\'t converge (residual ${us} µs); it is not applied.';

	/// en: 'Internal error: $detail'
	String internalError({required Object detail}) => 'Internal error: ${detail}';

	/// en: 'Unknown message ($code)'
	String unknown({required Object code}) => 'Unknown message (${code})';
}

// Path: reason
class Translations$reason$en {
	Translations$reason$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'too few valid repetitions ($count)'
	String fewValidReps({required Object count}) => 'too few valid repetitions (${count})';

	/// en: 'low repeatability (spread $us µs)'
	String lowRepeatability({required Object us}) => 'low repeatability (spread ${us} µs)';

	/// en: 'recording too short'
	String get recordingTooShort => 'recording too short';

	/// en: 'recording is silent'
	String get recordingSilent => 'recording is silent';

	/// en: 'unknown cause'
	String get unknown => 'unknown cause';
}

// Path: placement
class Translations$placement$en {
	Translations$placement$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How to place the phone'
	String get title => 'How to place the phone';

	/// en: 'Top view: the phone takes the place of the head.'
	String get topCaption => 'Top view: the phone takes the place of the head.';

	/// en: 'Side view: at ear height, lying flat, with the microphone facing forward.'
	String get sideCaption => 'Side view: at ear height, lying flat, with the microphone facing forward.';

	/// en: 'Where the head goes'
	String get step1Title => 'Where the head goes';

	/// en: 'At ear height and centered between both ears, not against the door. A centimeter of difference already changes the result, so always place it the same way.'
	String get step1Body => 'At ear height and centered between both ears, not against the door. A centimeter of difference already changes the result, so always place it the same way.';

	/// en: 'Microphone facing forward'
	String get step2Title => 'Microphone facing forward';

	/// en: 'The bottom edge of the phone (where the microphone is) points at the windshield. Don't cover it with your hand or a thick case.'
	String get step2Body => 'The bottom edge of the phone (where the microphone is) points at the windshield. Don\'t cover it with your hand or a thick case.';

	/// en: 'Still and firm'
	String get step3Title => 'Still and firm';

	/// en: 'Resting or in a holder, never in your hand. If it moves, the measurement is discarded.'
	String get step3Body => 'Resting or in a holder, never in your hand. If it moves, the measurement is discarded.';

	/// en: 'In the car'
	String get carTitle => 'In the car';

	/// en: 'Windows closed and nobody talking'
	String get car1 => 'Windows closed and nobody talking';

	/// en: 'Engine off or steady'
	String get car2 => 'Engine off or steady';

	/// en: 'Car volume at mid level'
	String get car3 => 'Car volume at mid level';

	/// en: 'Fader fully forward (rear speakers off)'
	String get car4 => 'Fader fully forward (rear speakers off)';

	/// en: 'Balance centered and tone controls flat'
	String get car5 => 'Balance centered and tone controls flat';

	/// en: 'Connected through Android Auto or Bluetooth, with the music paused'
	String get car6 => 'Connected through Android Auto or Bluetooth, with the music paused';

	/// en: 'With the rear speakers on, the sound "comes from behind" and the measurement is skewed.'
	String get rearWarning => 'With the rear speakers on, the sound "comes from behind" and the measurement is skewed.';

	/// en: 'You'll have 10 s to leave the phone; then test sounds play for a little over a minute. A rising tone at the end means success; a low one means you need to repeat.'
	String get firstRunInfo => 'You\'ll have 10 s to leave the phone; then test sounds play for a little over a minute. A rising tone at the end means success; a low one means you need to repeat.';

	/// en: 'When measuring you'll have 10 s to leave the phone. A rising tone at the end means success; a low one means you need to repeat.'
	String get info => 'When measuring you\'ll have 10 s to leave the phone. A rising tone at the end means success; a low one means you need to repeat.';

	/// en: 'Don't show again'
	String get dontShowAgain => 'Don\'t show again';

	/// en: 'You can always find it with the help icon'
	String get dontShowAgainHint => 'You can always find it with the help icon';

	/// en: 'Got it, start'
	String get gotIt => 'Got it, start';

	late final Translations$placement$figure$en figure = Translations$placement$figure$en.internal(_root);
}

// Path: home.readiness
class Translations$home$readiness$en {
	Translations$home$readiness$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All set · guard connected'
	String get ready => 'All set · guard connected';

	/// en: 'Microphone permission is missing'
	String get micMissingTitle => 'Microphone permission is missing';

	/// en: 'Measuring is not possible without it.'
	String get micMissingSubtitle => 'Measuring is not possible without it.';

	/// en: 'Grant permission'
	String get grantPermission => 'Grant permission';

	/// en: 'Connecting the guard…'
	String get connectingTitle => 'Connecting the guard…';

	/// en: 'If the phone shows "Allow debugging?", accept it and tick "Always allow".'
	String get connectingSubtitle => 'If the phone shows "Allow debugging?", accept it and tick "Always allow".';

	/// en: 'Waiting for Shizuku authorization…'
	String get shizukuTitle => 'Waiting for Shizuku authorization…';

	/// en: 'Accept the Shizuku prompt so CarAlign can start its guard.'
	String get shizukuSubtitle => 'Accept the Shizuku prompt so CarAlign can start its guard.';

	/// en: 'Starting the guard…'
	String get startingTitle => 'Starting the guard…';

	/// en: 'The audio guard is off'
	String get offTitle => 'The audio guard is off';

	/// en: 'Without it the original audio isn't muted and capture doesn't start on its own.'
	String get offSubtitle => 'Without it the original audio isn\'t muted and capture doesn\'t start on its own.';

	/// en: 'Retry'
	String get retry => 'Retry';
}

// Path: home.status
class Translations$home$status$en {
	Translations$home$status$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Alignment active'
	String get active => 'Alignment active';

	/// en: 'Alignment stopped'
	String get stopped => 'Alignment stopped';

	/// en: 'Processing the phone's audio'
	String get processing => 'Processing the phone\'s audio';

	/// en: 'Last saved setting'
	String get lastSaved => 'Last saved setting';

	/// en: '$side +$ms ms'
	String value({required Object side, required Object ms}) => '${side} +${ms} ms';
}

// Path: home.align
class Translations$home$align$en {
	Translations$home$align$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Align automatically'
	String get first => 'Align automatically';

	/// en: 'Align again'
	String get again => 'Align again';

	/// en: 'Measures with the phone's microphone, applies the delay and verifies it (~1 min).'
	String get hint => 'Measures with the phone\'s microphone, applies the delay and verifies it (~1 min).';
}

// Path: home.countdown
class Translations$home$countdown$en {
	Translations$home$countdown$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Leave the phone in place'
	String get title => 'Leave the phone in place';

	/// en: 'Microphone facing forward and still'
	String get subtitle => 'Microphone facing forward and still';
}

// Path: home.measuring
class Translations$home$measuring$en {
	Translations$home$measuring$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '$phase…'
	String title({required Object phase}) => '${phase}…';

	/// en: 'Don't move the phone'
	String get stayStill => 'Don\'t move the phone';
}

// Path: home.result
class Translations$home$result$en {
	Translations$home$result$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Delay the left channel $ms ms'
	String delayLeft({required Object ms}) => 'Delay the left channel ${ms} ms';

	/// en: 'Delay the right channel $ms ms'
	String delayRight({required Object ms}) => 'Delay the right channel ${ms} ms';

	/// en: 'No change was applied'
	String get nothingApplied => 'No change was applied';

	/// en: 'Measured through $name'
	String measuredVia({required Object name}) => 'Measured through ${name}';

	/// en: 'Measured with the phone speaker (not the car's)'
	String get measuredPhoneSpeaker => 'Measured with the phone speaker (not the car\'s)';

	/// en: 'Measured through USB'
	String get measuredUsb => 'Measured through USB';

	/// en: 'Audio source not recognized'
	String get sourceUnrecognized => 'Audio source not recognized';

	/// en: 'Details'
	String get details => 'Details';

	/// en: 'Verified: residual $residual µs · spread $sigma µs · $valid/$reps valid · $band band'
	String verified({required Object residual, required Object sigma, required Object valid, required Object reps, required Object band}) => 'Verified: residual ${residual} µs · spread ${sigma} µs · ${valid}/${reps} valid · ${band} band';

	/// en: 'Without delay, R−L per band: low $low · mid $mid · high $high ms'
	String bandsLine({required Object low, required Object mid, required Object high}) => 'Without delay, R−L per band: low ${low} · mid ${mid} · high ${high} ms';

	/// en: 'Output: $name'
	String output({required Object name}) => 'Output: ${name}';

	/// en: 'Output: $name ($raw)'
	String outputRaw({required Object name, required Object raw}) => 'Output: ${name} (${raw})';

	/// en: 'Microphone: $name'
	String microphone({required Object name}) => 'Microphone: ${name}';

	/// en: 'Noise: $db dBFS'
	String noise({required Object db}) => 'Noise: ${db} dBFS';
}

// Path: home.profiles
class Translations$home$profiles$en {
	Translations$home$profiles$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profiles'
	String get title => 'Profiles';

	/// en: 'Save current'
	String get saveCurrent => 'Save current';

	/// en: 'No profiles yet. Every automatic alignment saves one.'
	String get empty => 'No profiles yet. Every automatic alignment saves one.';

	/// en: 'Tap a profile to apply it; swipe to delete it.'
	String get hint => 'Tap a profile to apply it; swipe to delete it.';

	/// en: 'Auto $time'
	String autoName({required Object time}) => 'Auto ${time}';

	/// en: 'Save profile'
	String get dialogTitle => 'Save profile';

	/// en: 'Name (e.g. Driver)'
	String get dialogHint => 'Name (e.g. Driver)';
}

// Path: home.player
class Translations$home$player$en {
	Translations$home$player$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Play your music here'
	String get emptyTitle => 'Play your music here';

	/// en: 'Add songs from your phone. CarAlign plays them with the left/right delay applied, so nothing else needs to be set up.'
	String get emptySubtitle => 'Add songs from your phone. CarAlign plays them with the left/right delay applied, so nothing else needs to be set up.';

	/// en: 'Add music'
	String get addMusic => 'Add music';

	/// en: 'Add more'
	String get addMore => 'Add more';

	/// en: 'Queue'
	String get queue => 'Queue';

	/// en: 'Clear queue'
	String get clearQueue => 'Clear queue';

	/// en: 'Tap a song to play it; swipe to remove it.'
	String get queueHint => 'Tap a song to play it; swipe to remove it.';

	/// en: 'Unknown artist'
	String get unknownArtist => 'Unknown artist';

	/// en: 'Play'
	String get play => 'Play';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Previous'
	String get previous => 'Previous';

	/// en: '$position / $duration'
	String time({required Object position, required Object duration}) => '${position} / ${duration}';
}

// Path: home.delay
class Translations$home$delay$en {
	Translations$home$delay$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Applied to the player: $side +$ms ms'
	String applied({required Object side, required Object ms}) => 'Applied to the player: ${side} +${ms} ms';

	/// en: 'No delay yet. Run the automatic alignment.'
	String get none => 'No delay yet. Run the automatic alignment.';
}

// Path: advanced.manual
class Translations$advanced$manual$en {
	Translations$advanced$manual$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Manual adjustment'
	String get title => 'Manual adjustment';

	/// en: 'Changes apply live if the alignment is active.'
	String get subtitle => 'Changes apply live if the alignment is active.';

	/// en: '≈ $cm cm difference'
	String difference({required Object cm}) => '≈ ${cm} cm difference';

	/// en: 'Delay left'
	String get delayLeft => 'Delay left';

	/// en: 'Delay right'
	String get delayRight => 'Delay right';
}

// Path: advanced.demo
class Translations$advanced$demo$en {
	Translations$advanced$demo$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Demo'
	String get title => 'Demo';

	/// en: 'Goes from 0 ms to a profile with music playing: you can hear the stage centering.'
	String get description => 'Goes from 0 ms to a profile with music playing: you can hear the stage centering.';

	/// en: 'Save a profile first (align, or use "Save current").'
	String get needsProfile => 'Save a profile first (align, or use "Save current").';

	/// en: 'Stop demo'
	String get stop => 'Stop demo';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: '$name · $ms ms $side'
	String profileItem({required Object name, required Object ms, required Object side}) => '${name} · ${ms} ms ${side}';

	/// en: 'Duration'
	String get duration => 'Duration';

	/// en: 'Steps'
	String get steps => 'Steps';

	/// en: '$n s'
	String seconds({required Object n}) => '${n} s';

	/// en: '0 → profile'
	String get toProfile => '0 → profile';

	/// en: 'Back and forth'
	String get roundTrip => 'Back and forth';

	/// en: 'Preparing'
	String get preparing => 'Preparing';

	/// en: 'Not aligned'
	String get unaligned => 'Not aligned';

	/// en: 'Centering'
	String get centering => 'Centering';

	/// en: 'Aligned'
	String get aligned => 'Aligned';

	/// en: 'Removing'
	String get removing => 'Removing';

	/// en: '$label (step $k of $n)'
	String stepOf({required Object label, required Object k, required Object n}) => '${label}  (step ${k} of ${n})';
}

// Path: advanced.diagnostics
class Translations$advanced$diagnostics$en {
	Translations$advanced$diagnostics$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Diagnostics and compatibility'
	String get title => 'Diagnostics and compatibility';

	/// en: 'What this phone supports and how to set it up'
	String get subtitle => 'What this phone supports and how to set it up';
}

// Path: advanced.capture
class Translations$advanced$capture$en {
	Translations$advanced$capture$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Other music apps (advanced)'
	String get title => 'Other music apps (advanced)';

	/// en: 'Instead of the built-in player, CarAlign can capture the audio of Tidal, Spotify and other apps, delay it, and mute the original. This needs an ADB or Shizuku channel on the phone (see Diagnostics).'
	String get description => 'Instead of the built-in player, CarAlign can capture the audio of Tidal, Spotify and other apps, delay it, and mute the original. This needs an ADB or Shizuku channel on the phone (see Diagnostics).';

	/// en: 'Delay other apps' audio instead of the built-in player'
	String get switchHint => 'Delay other apps\' audio instead of the built-in player';

	/// en: 'Capture mode'
	String get switchLabel => 'Capture mode';
}

// Path: placement.figure
class Translations$placement$figure$en {
	Translations$placement$figure$en.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Windshield (front)'
	String get windshieldFront => 'Windshield (front)';

	/// en: 'L'
	String get leftMarker => 'L';

	/// en: 'R'
	String get rightMarker => 'R';

	/// en: 'Centered'
	String get centered => 'Centered';

	/// en: 'Microphone facing forward'
	String get micForward => 'Microphone\nfacing forward';

	/// en: 'Not against the door'
	String get notAgainstDoor => 'Not against\nthe door';

	/// en: 'Windshield'
	String get windshield => 'Windshield';

	/// en: 'Ear height'
	String get earHeight => 'Ear height';

	/// en: 'Microphone (bottom edge) facing forward'
	String get micBottomEdge => 'Microphone (bottom edge)\nfacing forward';

	/// en: 'Phone lying flat'
	String get phoneLying => 'Phone\nlying flat';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'CarAlign',
			'decimalSeparator' => '.',
			'common.cancel' => 'Cancel',
			'common.save' => 'Save',
			'common.close' => 'Close',
			'common.stop' => 'Stop',
			'common.start' => 'Start',
			'common.sideLeft' => 'Left',
			'common.sideRight' => 'Right',
			'common.sideLeftShort' => 'L',
			'common.sideRightShort' => 'R',
			'common.millisecondsValue' => ({required Object value}) => '${value} ms',
			'audioSource.androidAuto' => 'Android Auto',
			'audioSource.bluetooth' => 'Bluetooth',
			'audioSource.phoneSpeaker' => 'Phone speaker',
			'audioSource.usb' => 'USB',
			'audioSource.unrecognized' => 'Unrecognized source',
			'audioSource.unknown' => 'Unknown source',
			'band.broad' => 'broad',
			'band.low' => 'low',
			'band.mid' => 'mid',
			'band.high' => 'high',
			'phase.preparing' => 'Preparing',
			'phase.adjustingLevel' => 'Adjusting level',
			'phase.measuring' => 'Measuring',
			'phase.verifying' => 'Verifying',
			'phase.stoppingCapture' => 'Stopping capture',
			'phase.done' => 'Done',
			'notice.captureBlocked' => 'The app that is playing doesn\'t allow its audio to be processed (capture blocked). Alignment was stopped and the original audio was restored.',
			'notice.demoNeedsGuard' => 'Without the guard the original audio can\'t be muted; reopen the app or check the setup steps in Diagnostics.',
			'notice.demoNeedsMusic' => 'Add a song to the player first, then run the demo.',
			'home.guideTooltip' => 'How to place the phone',
			'home.advancedTooltip' => 'Advanced',
			'home.readiness.ready' => 'All set · guard connected',
			'home.readiness.micMissingTitle' => 'Microphone permission is missing',
			'home.readiness.micMissingSubtitle' => 'Measuring is not possible without it.',
			'home.readiness.grantPermission' => 'Grant permission',
			'home.readiness.connectingTitle' => 'Connecting the guard…',
			'home.readiness.connectingSubtitle' => 'If the phone shows "Allow debugging?", accept it and tick "Always allow".',
			'home.readiness.shizukuTitle' => 'Waiting for Shizuku authorization…',
			'home.readiness.shizukuSubtitle' => 'Accept the Shizuku prompt so CarAlign can start its guard.',
			'home.readiness.startingTitle' => 'Starting the guard…',
			'home.readiness.offTitle' => 'The audio guard is off',
			'home.readiness.offSubtitle' => 'Without it the original audio isn\'t muted and capture doesn\'t start on its own.',
			'home.readiness.retry' => 'Retry',
			'home.status.active' => 'Alignment active',
			'home.status.stopped' => 'Alignment stopped',
			'home.status.processing' => 'Processing the phone\'s audio',
			'home.status.lastSaved' => 'Last saved setting',
			'home.status.value' => ({required Object side, required Object ms}) => '${side} +${ms} ms',
			'home.align.first' => 'Align automatically',
			'home.align.again' => 'Align again',
			'home.align.hint' => 'Measures with the phone\'s microphone, applies the delay and verifies it (~1 min).',
			'home.countdown.title' => 'Leave the phone in place',
			'home.countdown.subtitle' => 'Microphone facing forward and still',
			'home.measuring.title' => ({required Object phase}) => '${phase}…',
			'home.measuring.stayStill' => 'Don\'t move the phone',
			'home.result.delayLeft' => ({required Object ms}) => 'Delay the left channel ${ms} ms',
			'home.result.delayRight' => ({required Object ms}) => 'Delay the right channel ${ms} ms',
			'home.result.nothingApplied' => 'No change was applied',
			'home.result.measuredVia' => ({required Object name}) => 'Measured through ${name}',
			'home.result.measuredPhoneSpeaker' => 'Measured with the phone speaker (not the car\'s)',
			'home.result.measuredUsb' => 'Measured through USB',
			'home.result.sourceUnrecognized' => 'Audio source not recognized',
			'home.result.details' => 'Details',
			'home.result.verified' => ({required Object residual, required Object sigma, required Object valid, required Object reps, required Object band}) => 'Verified: residual ${residual} µs · spread ${sigma} µs · ${valid}/${reps} valid · ${band} band',
			'home.result.bandsLine' => ({required Object low, required Object mid, required Object high}) => 'Without delay, R−L per band: low ${low} · mid ${mid} · high ${high} ms',
			'home.result.output' => ({required Object name}) => 'Output: ${name}',
			'home.result.outputRaw' => ({required Object name, required Object raw}) => 'Output: ${name} (${raw})',
			'home.result.microphone' => ({required Object name}) => 'Microphone: ${name}',
			'home.result.noise' => ({required Object db}) => 'Noise: ${db} dBFS',
			'home.profiles.title' => 'Profiles',
			'home.profiles.saveCurrent' => 'Save current',
			'home.profiles.empty' => 'No profiles yet. Every automatic alignment saves one.',
			'home.profiles.hint' => 'Tap a profile to apply it; swipe to delete it.',
			'home.profiles.autoName' => ({required Object time}) => 'Auto ${time}',
			'home.profiles.dialogTitle' => 'Save profile',
			'home.profiles.dialogHint' => 'Name (e.g. Driver)',
			'home.player.emptyTitle' => 'Play your music here',
			'home.player.emptySubtitle' => 'Add songs from your phone. CarAlign plays them with the left/right delay applied, so nothing else needs to be set up.',
			'home.player.addMusic' => 'Add music',
			'home.player.addMore' => 'Add more',
			'home.player.queue' => 'Queue',
			'home.player.clearQueue' => 'Clear queue',
			'home.player.queueHint' => 'Tap a song to play it; swipe to remove it.',
			'home.player.unknownArtist' => 'Unknown artist',
			'home.player.play' => 'Play',
			'home.player.pause' => 'Pause',
			'home.player.next' => 'Next',
			'home.player.previous' => 'Previous',
			'home.player.time' => ({required Object position, required Object duration}) => '${position} / ${duration}',
			'home.delay.applied' => ({required Object side, required Object ms}) => 'Applied to the player: ${side} +${ms} ms',
			'home.delay.none' => 'No delay yet. Run the automatic alignment.',
			'advanced.title' => 'Advanced',
			'advanced.manual.title' => 'Manual adjustment',
			'advanced.manual.subtitle' => 'Changes apply live if the alignment is active.',
			'advanced.manual.difference' => ({required Object cm}) => '≈ ${cm} cm difference',
			'advanced.manual.delayLeft' => 'Delay left',
			'advanced.manual.delayRight' => 'Delay right',
			'advanced.demo.title' => 'Demo',
			'advanced.demo.description' => 'Goes from 0 ms to a profile with music playing: you can hear the stage centering.',
			'advanced.demo.needsProfile' => 'Save a profile first (align, or use "Save current").',
			'advanced.demo.stop' => 'Stop demo',
			'advanced.demo.profile' => 'Profile',
			'advanced.demo.profileItem' => ({required Object name, required Object ms, required Object side}) => '${name} · ${ms} ms ${side}',
			'advanced.demo.duration' => 'Duration',
			'advanced.demo.steps' => 'Steps',
			'advanced.demo.seconds' => ({required Object n}) => '${n} s',
			'advanced.demo.toProfile' => '0 → profile',
			'advanced.demo.roundTrip' => 'Back and forth',
			'advanced.demo.preparing' => 'Preparing',
			'advanced.demo.unaligned' => 'Not aligned',
			'advanced.demo.centering' => 'Centering',
			'advanced.demo.aligned' => 'Aligned',
			'advanced.demo.removing' => 'Removing',
			'advanced.demo.stepOf' => ({required Object label, required Object k, required Object n}) => '${label}  (step ${k} of ${n})',
			'advanced.diagnostics.title' => 'Diagnostics and compatibility',
			'advanced.diagnostics.subtitle' => 'What this phone supports and how to set it up',
			'advanced.capture.title' => 'Other music apps (advanced)',
			'advanced.capture.description' => 'Instead of the built-in player, CarAlign can capture the audio of Tidal, Spotify and other apps, delay it, and mute the original. This needs an ADB or Shizuku channel on the phone (see Diagnostics).',
			'advanced.capture.switchHint' => 'Delay other apps\' audio instead of the built-in player',
			'advanced.capture.switchLabel' => 'Capture mode',
			'diagnostics.title' => 'Diagnostics',
			'diagnostics.intro' => 'What this phone supports. If something doesn\'t work on another phone, copy the report and share it.',
			'diagnostics.loading' => 'Loading…',
			'diagnostics.noData' => 'No data',
			'diagnostics.noResponse' => 'No response',
			'diagnostics.testMute' => 'Test muting',
			'diagnostics.copyReport' => 'Copy report',
			'diagnostics.refresh' => 'Refresh',
			'diagnostics.batterySaver' => 'Battery saver',
			'diagnostics.reportCopied' => 'Report copied',
			'diagnostics.muteWorks' => ({required Object detail}) => 'The muting channel works on this phone.\n${detail}',
			'diagnostics.muteFails' => ({required Object detail}) => 'The muting channel does NOT work yet.\n${detail}',
			'diagnostics.limitationTitle' => 'Important limitation',
			'diagnostics.limitationBody' => 'The built-in player needs nothing special. Capture mode (delaying other music apps) is different: Android doesn\'t let a regular app mute another one, so it needs an ADB channel, enabled from a computer (adb tcpip 5555) every time the phone restarts, or Shizuku. Without that channel capture mode can\'t mute the original audio and won\'t start.',
			'diagnostics.setupTitle' => 'Set up capture mode on another phone',
			'diagnostics.step1' => 'Enable developer options: Settings → About phone → tap "Build number" 7 times.',
			'diagnostics.step2' => 'In developer options, enable "USB debugging".',
			'diagnostics.step3' => 'Connect the phone to a computer with ADB and run  adb tcpip 5555 . It must be repeated every time the phone restarts.',
			'diagnostics.step4' => 'Open CarAlign. If "Allow debugging?" appears, accept it and tick "Always allow".',
			'diagnostics.step5' => 'Tap "Test muting". If it fails, read the reason: some brands need more settings (Xiaomi/Redmi/POCO: "USB debugging (security settings)"; Samsung: turn off Auto Blocker\'s USB command blocking).',
			'diagnostics.step6' => 'Tap "Battery saver" and allow CarAlign to run unrestricted so it isn\'t closed in the background.',
			'diagnostics.footer' => 'Without this channel, capture mode can\'t mute the original audio and you would hear it doubled.',
			'guard.adbInactiveNoShizuku' => 'Network ADB is not active. Shizuku isn\'t running either: open Shizuku and tap Start (wireless debugging), or connect the cable and run adb tcpip 5555 from a computer.',
			'guard.adbFailedNoShizuku' => ({required Object error}) => 'Couldn\'t use the phone\'s ADB: ${error}. Shizuku isn\'t running either: open Shizuku and tap Start (wireless debugging), or connect the cable and run adb tcpip 5555 from a computer.',
			'guard.shizukuFailed' => ({required Object error}) => 'Shizuku is active but failed: ${error}',
			'guard.notStarted' => 'The guard did not start.',
			'resultMessage.speakerOutput' => 'The audio output is the phone speaker, not the car. Connect Android Auto or the car\'s Bluetooth and try again.',
			'resultMessage.bluetoothCallLine' => 'Audio is going through the Bluetooth call line (mono, low quality). On the phone, go to Bluetooth > car > enable "Media audio" and try again.',
			'resultMessage.noSignal' => 'The signal can\'t be heard well: raise the car volume, close the windows or reduce the noise and try again.',
			'resultMessage.clipped' => 'The signal was clipping; the measurement level was lowered.',
			'resultMessage.measurementUnreliable' => ({required Object reason}) => 'The measurement was not reliable: ${reason}.',
			'resultMessage.verificationUnreliable' => ({required Object reason}) => 'The verification was not reliable: ${reason}.',
			'resultMessage.differenceTooLarge' => 'The measured difference is very large; check the phone\'s position.',
			'resultMessage.notVerifiable' => 'The adjustment could not be verified, so it is not applied.',
			'resultMessage.identicalChannels' => 'Left and right sound identical (same arrival and level). If you didn\'t expect that, the output may be mono or mixed; check balance, fader and that the audio is stereo.',
			'resultMessage.notConverging' => ({required Object us}) => 'The adjustment doesn\'t fully converge; a residual of ${us} µs remains.',
			'resultMessage.notConvergingRejected' => ({required Object us}) => 'The adjustment doesn\'t converge (residual ${us} µs); it is not applied.',
			'resultMessage.internalError' => ({required Object detail}) => 'Internal error: ${detail}',
			'resultMessage.unknown' => ({required Object code}) => 'Unknown message (${code})',
			'reason.fewValidReps' => ({required Object count}) => 'too few valid repetitions (${count})',
			'reason.lowRepeatability' => ({required Object us}) => 'low repeatability (spread ${us} µs)',
			'reason.recordingTooShort' => 'recording too short',
			'reason.recordingSilent' => 'recording is silent',
			'reason.unknown' => 'unknown cause',
			'placement.title' => 'How to place the phone',
			'placement.topCaption' => 'Top view: the phone takes the place of the head.',
			'placement.sideCaption' => 'Side view: at ear height, lying flat, with the microphone facing forward.',
			'placement.step1Title' => 'Where the head goes',
			'placement.step1Body' => 'At ear height and centered between both ears, not against the door. A centimeter of difference already changes the result, so always place it the same way.',
			'placement.step2Title' => 'Microphone facing forward',
			'placement.step2Body' => 'The bottom edge of the phone (where the microphone is) points at the windshield. Don\'t cover it with your hand or a thick case.',
			'placement.step3Title' => 'Still and firm',
			'placement.step3Body' => 'Resting or in a holder, never in your hand. If it moves, the measurement is discarded.',
			'placement.carTitle' => 'In the car',
			'placement.car1' => 'Windows closed and nobody talking',
			'placement.car2' => 'Engine off or steady',
			'placement.car3' => 'Car volume at mid level',
			'placement.car4' => 'Fader fully forward (rear speakers off)',
			'placement.car5' => 'Balance centered and tone controls flat',
			'placement.car6' => 'Connected through Android Auto or Bluetooth, with the music paused',
			'placement.rearWarning' => 'With the rear speakers on, the sound "comes from behind" and the measurement is skewed.',
			'placement.firstRunInfo' => 'You\'ll have 10 s to leave the phone; then test sounds play for a little over a minute. A rising tone at the end means success; a low one means you need to repeat.',
			'placement.info' => 'When measuring you\'ll have 10 s to leave the phone. A rising tone at the end means success; a low one means you need to repeat.',
			'placement.dontShowAgain' => 'Don\'t show again',
			'placement.dontShowAgainHint' => 'You can always find it with the help icon',
			'placement.gotIt' => 'Got it, start',
			'placement.figure.windshieldFront' => 'Windshield (front)',
			'placement.figure.leftMarker' => 'L',
			'placement.figure.rightMarker' => 'R',
			'placement.figure.centered' => 'Centered',
			'placement.figure.micForward' => 'Microphone\nfacing forward',
			'placement.figure.notAgainstDoor' => 'Not against\nthe door',
			'placement.figure.windshield' => 'Windshield',
			'placement.figure.earHeight' => 'Ear height',
			'placement.figure.micBottomEdge' => 'Microphone (bottom edge)\nfacing forward',
			'placement.figure.phoneLying' => 'Phone\nlying flat',
			_ => null,
		};
	}
}
