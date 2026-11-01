///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override String get appName => 'CarAlign';
	@override String get decimalSeparator => ',';
	@override late final _Translations$common$es common = _Translations$common$es._(_root);
	@override late final _Translations$audioSource$es audioSource = _Translations$audioSource$es._(_root);
	@override late final _Translations$band$es band = _Translations$band$es._(_root);
	@override late final _Translations$phase$es phase = _Translations$phase$es._(_root);
	@override late final _Translations$notice$es notice = _Translations$notice$es._(_root);
	@override late final _Translations$home$es home = _Translations$home$es._(_root);
	@override late final _Translations$advanced$es advanced = _Translations$advanced$es._(_root);
	@override late final _Translations$diagnostics$es diagnostics = _Translations$diagnostics$es._(_root);
	@override late final _Translations$guard$es guard = _Translations$guard$es._(_root);
	@override late final _Translations$resultMessage$es resultMessage = _Translations$resultMessage$es._(_root);
	@override late final _Translations$reason$es reason = _Translations$reason$es._(_root);
	@override late final _Translations$placement$es placement = _Translations$placement$es._(_root);
}

// Path: common
class _Translations$common$es extends Translations$common$en {
	_Translations$common$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Cancelar';
	@override String get save => 'Guardar';
	@override String get close => 'Cerrar';
	@override String get stop => 'Detener';
	@override String get start => 'Iniciar';
	@override String get sideLeft => 'Izquierdo';
	@override String get sideRight => 'Derecho';
	@override String get sideLeftShort => 'I';
	@override String get sideRightShort => 'D';
	@override String millisecondsValue({required Object value}) => '${value} ms';
}

// Path: audioSource
class _Translations$audioSource$es extends Translations$audioSource$en {
	_Translations$audioSource$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get androidAuto => 'Android Auto';
	@override String get bluetooth => 'Bluetooth';
	@override String get phoneSpeaker => 'Altavoz del teléfono';
	@override String get usb => 'USB';
	@override String get unrecognized => 'Origen no reconocido';
	@override String get unknown => 'Origen desconocido';
}

// Path: band
class _Translations$band$es extends Translations$band$en {
	_Translations$band$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get broad => 'ancha';
	@override String get low => 'graves';
	@override String get mid => 'medios';
	@override String get high => 'agudos';
}

// Path: phase
class _Translations$phase$es extends Translations$phase$en {
	_Translations$phase$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get preparing => 'Preparando';
	@override String get adjustingLevel => 'Ajustando nivel';
	@override String get measuring => 'Midiendo';
	@override String get verifying => 'Verificando';
	@override String get stoppingCapture => 'Deteniendo la captura';
	@override String get done => 'Listo';
}

// Path: notice
class _Translations$notice$es extends Translations$notice$en {
	_Translations$notice$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get captureBlocked => 'La app que está sonando no permite procesar su audio (captura bloqueada). Se detuvo la alineación y se restauró el audio original.';
	@override String get demoNeedsGuard => 'Sin el vigilante no se puede silenciar el original; abre la app de nuevo o revisa los pasos de preparación en Diagnóstico.';
}

// Path: home
class _Translations$home$es extends Translations$home$en {
	_Translations$home$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get guideTooltip => 'Cómo colocar el teléfono';
	@override String get advancedTooltip => 'Avanzado';
	@override late final _Translations$home$readiness$es readiness = _Translations$home$readiness$es._(_root);
	@override late final _Translations$home$status$es status = _Translations$home$status$es._(_root);
	@override late final _Translations$home$align$es align = _Translations$home$align$es._(_root);
	@override late final _Translations$home$countdown$es countdown = _Translations$home$countdown$es._(_root);
	@override late final _Translations$home$measuring$es measuring = _Translations$home$measuring$es._(_root);
	@override late final _Translations$home$result$es result = _Translations$home$result$es._(_root);
	@override late final _Translations$home$profiles$es profiles = _Translations$home$profiles$es._(_root);
}

// Path: advanced
class _Translations$advanced$es extends Translations$advanced$en {
	_Translations$advanced$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Avanzado';
	@override late final _Translations$advanced$manual$es manual = _Translations$advanced$manual$es._(_root);
	@override late final _Translations$advanced$demo$es demo = _Translations$advanced$demo$es._(_root);
	@override late final _Translations$advanced$diagnostics$es diagnostics = _Translations$advanced$diagnostics$es._(_root);
}

// Path: diagnostics
class _Translations$diagnostics$es extends Translations$diagnostics$en {
	_Translations$diagnostics$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Diagnóstico';
	@override String get intro => 'Qué soporta este teléfono. Si algo no funciona en otro móvil, copia el informe y compártelo.';
	@override String get loading => 'Cargando…';
	@override String get noData => 'Sin datos';
	@override String get noResponse => 'Sin respuesta';
	@override String get testMute => 'Probar silenciado';
	@override String get copyReport => 'Copiar informe';
	@override String get refresh => 'Actualizar';
	@override String get batterySaver => 'Ahorro de batería';
	@override String get reportCopied => 'Informe copiado';
	@override String muteWorks({required Object detail}) => 'El canal para silenciar funciona en este teléfono.\n${detail}';
	@override String muteFails({required Object detail}) => 'El canal para silenciar NO funciona todavía.\n${detail}';
	@override String get limitationTitle => 'Limitación importante';
	@override String get limitationBody => 'Android no deja que una app normal silencie a otra. CarAlign necesita un canal de ADB para hacerlo: hay que activarlo con un ordenador (adb tcpip 5555) cada vez que se reinicia el teléfono, o usar Shizuku. Sin ese canal la app no silencia el audio original y no se activa.';
	@override String get setupTitle => 'Preparar otro teléfono';
	@override String get step1 => 'Activa las opciones de desarrollador: Ajustes → Acerca del teléfono → toca 7 veces "Número de compilación".';
	@override String get step2 => 'En Opciones de desarrollador activa "Depuración USB".';
	@override String get step3 => 'Conecta el teléfono a un ordenador con ADB y ejecuta  adb tcpip 5555 . Hay que repetirlo cada vez que se reinicia el teléfono.';
	@override String get step4 => 'Abre CarAlign. Si aparece "¿Permitir depuración?", acéptalo y marca "Siempre permitir".';
	@override String get step5 => 'Pulsa "Probar silenciado". Si falla, mira el motivo: algunas marcas piden más ajustes (Xiaomi/Redmi/POCO: "Depuración USB (ajustes de seguridad)"; Samsung: desactivar el bloqueo de comandos por USB de Auto Blocker).';
	@override String get step6 => 'Pulsa "Ahorro de batería" y permite que CarAlign funcione sin restricciones, para que no la cierren en segundo plano.';
	@override String get footer => 'Sin este canal la app no puede silenciar el audio original y se oiría doble.';
}

// Path: guard
class _Translations$guard$es extends Translations$guard$en {
	_Translations$guard$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get adbInactiveNoShizuku => 'El ADB por red no está activo. Tampoco hay Shizuku en ejecución: abre Shizuku y pulsa Iniciar (depuración inalámbrica), o conecta el cable y ejecuta adb tcpip 5555 desde un ordenador.';
	@override String adbFailedNoShizuku({required Object error}) => 'No se pudo usar el ADB del teléfono: ${error}. Tampoco hay Shizuku en ejecución: abre Shizuku y pulsa Iniciar (depuración inalámbrica), o conecta el cable y ejecuta adb tcpip 5555 desde un ordenador.';
	@override String shizukuFailed({required Object error}) => 'Shizuku está activo pero falló: ${error}';
	@override String get notStarted => 'El vigilante no arrancó.';
}

// Path: resultMessage
class _Translations$resultMessage$es extends Translations$resultMessage$en {
	_Translations$resultMessage$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get speakerOutput => 'La salida de audio es el altavoz del teléfono, no el coche. Conecta Android Auto o el Bluetooth del coche y repite.';
	@override String get bluetoothCallLine => 'El audio va por la línea de llamadas Bluetooth (mono, baja calidad). En el teléfono, Bluetooth > coche > activa "Audio multimedia" y vuelve a intentar.';
	@override String get noSignal => 'No se oye bien la señal: sube el volumen del coche, cierra ventanas o reduce el ruido y repite.';
	@override String get clipped => 'La señal recortaba; se bajó el nivel de la medición.';
	@override String measurementUnreliable({required Object reason}) => 'La medición no fue fiable: ${reason}.';
	@override String verificationUnreliable({required Object reason}) => 'La verificación no fue fiable: ${reason}.';
	@override String get differenceTooLarge => 'La diferencia medida es muy grande; revisa la posición del teléfono.';
	@override String get notVerifiable => 'No se pudo verificar el ajuste, por eso no se aplica.';
	@override String get identicalChannels => 'Izquierdo y derecho suenan idénticos (misma llegada y mismo nivel). Si no lo esperabas, la salida puede ser mono o mezclada; revisa balance, fader y que el audio sea estéreo.';
	@override String notConverging({required Object us}) => 'El ajuste no converge del todo; queda un residuo de ${us} µs.';
	@override String notConvergingRejected({required Object us}) => 'El ajuste no converge (residuo ${us} µs); no se aplica.';
	@override String internalError({required Object detail}) => 'Error interno: ${detail}';
	@override String unknown({required Object code}) => 'Mensaje desconocido (${code})';
}

// Path: reason
class _Translations$reason$es extends Translations$reason$en {
	_Translations$reason$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String fewValidReps({required Object count}) => 'pocas repeticiones válidas (${count})';
	@override String lowRepeatability({required Object us}) => 'poca repetibilidad (dispersión ${us} µs)';
	@override String get recordingTooShort => 'grabación demasiado corta';
	@override String get recordingSilent => 'grabación en silencio';
	@override String get unknown => 'causa desconocida';
}

// Path: placement
class _Translations$placement$es extends Translations$placement$en {
	_Translations$placement$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cómo colocar el teléfono';
	@override String get topCaption => 'Vista desde arriba: el teléfono ocupa el lugar de la cabeza.';
	@override String get sideCaption => 'Vista de lado: a la altura de los oídos, tumbado, con el micrófono hacia adelante.';
	@override String get step1Title => 'Donde va la cabeza';
	@override String get step1Body => 'A la altura de los oídos y centrado entre ambos, no pegado a la puerta. Un centímetro de diferencia ya cambia el resultado, así que colócalo siempre igual.';
	@override String get step2Title => 'Micrófono hacia el frente';
	@override String get step2Body => 'El borde de abajo del teléfono (donde está el micrófono) apunta al parabrisas. No lo tapes con la mano ni con una funda gruesa.';
	@override String get step3Title => 'Quieto y firme';
	@override String get step3Body => 'Apoyado o en un soporte, nunca en la mano. Si se mueve, la medición se descarta.';
	@override String get carTitle => 'En el coche';
	@override String get car1 => 'Ventanas cerradas y nadie hablando';
	@override String get car2 => 'Motor apagado o estable';
	@override String get car3 => 'Volumen del coche en medio';
	@override String get car4 => 'Fader totalmente hacia adelante (traseros apagados)';
	@override String get car5 => 'Balance al centro y tonos en plano';
	@override String get car6 => 'Conectado por Android Auto o Bluetooth, con la música en pausa';
	@override String get rearWarning => 'Con los traseros activos el sonido "viene de atrás" y la medición se sesga.';
	@override String get firstRunInfo => 'Tendrás 10 s para dejar el teléfono; después sonarán sonidos de prueba durante algo más de un minuto. Un tono ascendente al final es éxito; uno grave, que hay que repetir.';
	@override String get info => 'Al medir tendrás 10 s para dejar el teléfono. Un tono ascendente al final es éxito; uno grave, que hay que repetir.';
	@override String get dontShowAgain => 'No volver a mostrar';
	@override String get dontShowAgainHint => 'Siempre la encuentras con el icono de ayuda';
	@override String get gotIt => 'Entendido, empezar';
	@override late final _Translations$placement$figure$es figure = _Translations$placement$figure$es._(_root);
}

// Path: home.readiness
class _Translations$home$readiness$es extends Translations$home$readiness$en {
	_Translations$home$readiness$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get ready => 'Todo listo · vigilante conectado';
	@override String get micMissingTitle => 'Falta el permiso del micrófono';
	@override String get micMissingSubtitle => 'Sin él no se puede medir.';
	@override String get grantPermission => 'Dar permiso';
	@override String get connectingTitle => 'Conectando el vigilante…';
	@override String get connectingSubtitle => 'Si el teléfono muestra "¿Permitir depuración?", acéptalo y marca "Siempre permitir".';
	@override String get shizukuTitle => 'Esperando la autorización de Shizuku…';
	@override String get shizukuSubtitle => 'Acepta el aviso de Shizuku para que CarAlign pueda arrancar su vigilante.';
	@override String get startingTitle => 'Iniciando el vigilante…';
	@override String get offTitle => 'El vigilante de audio está apagado';
	@override String get offSubtitle => 'Sin él no se silencia el original ni se inicia la captura sola.';
	@override String get retry => 'Reintentar';
}

// Path: home.status
class _Translations$home$status$es extends Translations$home$status$en {
	_Translations$home$status$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get active => 'Alineación activa';
	@override String get stopped => 'Alineación detenida';
	@override String get processing => 'Procesando el audio del teléfono';
	@override String get lastSaved => 'Último ajuste guardado';
	@override String value({required Object side, required Object ms}) => '${side} +${ms} ms';
}

// Path: home.align
class _Translations$home$align$es extends Translations$home$align$en {
	_Translations$home$align$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get first => 'Alinear automáticamente';
	@override String get again => 'Volver a alinear';
	@override String get hint => 'Mide con el micrófono del teléfono, aplica el retraso y lo verifica (~1 min).';
}

// Path: home.countdown
class _Translations$home$countdown$es extends Translations$home$countdown$en {
	_Translations$home$countdown$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Deja el teléfono en su sitio';
	@override String get subtitle => 'Micrófono hacia el frente y quieto';
}

// Path: home.measuring
class _Translations$home$measuring$es extends Translations$home$measuring$en {
	_Translations$home$measuring$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String title({required Object phase}) => '${phase}…';
	@override String get stayStill => 'No muevas el teléfono';
}

// Path: home.result
class _Translations$home$result$es extends Translations$home$result$en {
	_Translations$home$result$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String delayLeft({required Object ms}) => 'Retrasar el izquierdo ${ms} ms';
	@override String delayRight({required Object ms}) => 'Retrasar el derecho ${ms} ms';
	@override String get nothingApplied => 'No se aplicó ningún cambio';
	@override String measuredVia({required Object name}) => 'Medido a través de ${name}';
	@override String get measuredPhoneSpeaker => 'Medido con el altavoz del teléfono (no el del coche)';
	@override String get measuredUsb => 'Medido a través de USB';
	@override String get sourceUnrecognized => 'Origen de audio no reconocido';
	@override String get details => 'Detalles';
	@override String verified({required Object residual, required Object sigma, required Object valid, required Object reps, required Object band}) => 'Verificado: residuo ${residual} µs · dispersión ${sigma} µs · ${valid}/${reps} válidas · banda ${band}';
	@override String bandsLine({required Object low, required Object mid, required Object high}) => 'Sin retraso, R−L por banda: graves ${low} · medios ${mid} · agudos ${high} ms';
	@override String output({required Object name}) => 'Salida: ${name}';
	@override String outputRaw({required Object name, required Object raw}) => 'Salida: ${name} (${raw})';
	@override String microphone({required Object name}) => 'Micrófono: ${name}';
	@override String noise({required Object db}) => 'Ruido: ${db} dBFS';
}

// Path: home.profiles
class _Translations$home$profiles$es extends Translations$home$profiles$en {
	_Translations$home$profiles$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Perfiles';
	@override String get saveCurrent => 'Guardar actual';
	@override String get empty => 'Sin perfiles todavía. Cada alineación automática guarda uno.';
	@override String get hint => 'Toca un perfil para aplicarlo; desliza para borrarlo.';
	@override String autoName({required Object time}) => 'Auto ${time}';
	@override String get dialogTitle => 'Guardar perfil';
	@override String get dialogHint => 'Nombre (ej. Conductor)';
}

// Path: advanced.manual
class _Translations$advanced$manual$es extends Translations$advanced$manual$en {
	_Translations$advanced$manual$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajuste manual';
	@override String get subtitle => 'Los cambios se aplican en vivo si la alineación está activa.';
	@override String difference({required Object cm}) => '≈ ${cm} cm de diferencia';
	@override String get delayLeft => 'Retrasar izq.';
	@override String get delayRight => 'Retrasar der.';
	@override String get startAlignment => 'Iniciar alineación';
}

// Path: advanced.demo
class _Translations$advanced$demo$es extends Translations$advanced$demo$en {
	_Translations$advanced$demo$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Demostración';
	@override String get description => 'Va de 0 ms a un perfil con música sonando: se oye cómo el escenario se centra.';
	@override String get needsProfile => 'Guarda un perfil primero (alinea o usa "Guardar actual").';
	@override String get stop => 'Detener demostración';
	@override String get profile => 'Perfil';
	@override String profileItem({required Object name, required Object ms, required Object side}) => '${name} · ${ms} ms ${side}';
	@override String get duration => 'Duración';
	@override String get steps => 'Pasos';
	@override String seconds({required Object n}) => '${n} s';
	@override String get toProfile => '0 → perfil';
	@override String get roundTrip => 'Ida y vuelta';
	@override String get preparing => 'Preparando';
	@override String get unaligned => 'Sin alineación';
	@override String get centering => 'Centrando';
	@override String get aligned => 'Alineado';
	@override String get removing => 'Quitando';
	@override String stepOf({required Object label, required Object k, required Object n}) => '${label}  (paso ${k} de ${n})';
}

// Path: advanced.diagnostics
class _Translations$advanced$diagnostics$es extends Translations$advanced$diagnostics$en {
	_Translations$advanced$diagnostics$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Diagnóstico y compatibilidad';
	@override String get subtitle => 'Qué soporta este teléfono y cómo prepararlo';
}

// Path: placement.figure
class _Translations$placement$figure$es extends Translations$placement$figure$en {
	_Translations$placement$figure$es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get windshieldFront => 'Parabrisas (frente)';
	@override String get leftMarker => 'I';
	@override String get rightMarker => 'D';
	@override String get centered => 'Centrado';
	@override String get micForward => 'Micrófono\nhacia el frente';
	@override String get notAgainstDoor => 'No pegado\na la puerta';
	@override String get windshield => 'Parabrisas';
	@override String get earHeight => 'Altura de los oídos';
	@override String get micBottomEdge => 'Micrófono (borde de abajo)\nhacia el frente';
	@override String get phoneLying => 'Teléfono\ntumbado';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'appName' => 'CarAlign',
			'decimalSeparator' => ',',
			'common.cancel' => 'Cancelar',
			'common.save' => 'Guardar',
			'common.close' => 'Cerrar',
			'common.stop' => 'Detener',
			'common.start' => 'Iniciar',
			'common.sideLeft' => 'Izquierdo',
			'common.sideRight' => 'Derecho',
			'common.sideLeftShort' => 'I',
			'common.sideRightShort' => 'D',
			'common.millisecondsValue' => ({required Object value}) => '${value} ms',
			'audioSource.androidAuto' => 'Android Auto',
			'audioSource.bluetooth' => 'Bluetooth',
			'audioSource.phoneSpeaker' => 'Altavoz del teléfono',
			'audioSource.usb' => 'USB',
			'audioSource.unrecognized' => 'Origen no reconocido',
			'audioSource.unknown' => 'Origen desconocido',
			'band.broad' => 'ancha',
			'band.low' => 'graves',
			'band.mid' => 'medios',
			'band.high' => 'agudos',
			'phase.preparing' => 'Preparando',
			'phase.adjustingLevel' => 'Ajustando nivel',
			'phase.measuring' => 'Midiendo',
			'phase.verifying' => 'Verificando',
			'phase.stoppingCapture' => 'Deteniendo la captura',
			'phase.done' => 'Listo',
			'notice.captureBlocked' => 'La app que está sonando no permite procesar su audio (captura bloqueada). Se detuvo la alineación y se restauró el audio original.',
			'notice.demoNeedsGuard' => 'Sin el vigilante no se puede silenciar el original; abre la app de nuevo o revisa los pasos de preparación en Diagnóstico.',
			'home.guideTooltip' => 'Cómo colocar el teléfono',
			'home.advancedTooltip' => 'Avanzado',
			'home.readiness.ready' => 'Todo listo · vigilante conectado',
			'home.readiness.micMissingTitle' => 'Falta el permiso del micrófono',
			'home.readiness.micMissingSubtitle' => 'Sin él no se puede medir.',
			'home.readiness.grantPermission' => 'Dar permiso',
			'home.readiness.connectingTitle' => 'Conectando el vigilante…',
			'home.readiness.connectingSubtitle' => 'Si el teléfono muestra "¿Permitir depuración?", acéptalo y marca "Siempre permitir".',
			'home.readiness.shizukuTitle' => 'Esperando la autorización de Shizuku…',
			'home.readiness.shizukuSubtitle' => 'Acepta el aviso de Shizuku para que CarAlign pueda arrancar su vigilante.',
			'home.readiness.startingTitle' => 'Iniciando el vigilante…',
			'home.readiness.offTitle' => 'El vigilante de audio está apagado',
			'home.readiness.offSubtitle' => 'Sin él no se silencia el original ni se inicia la captura sola.',
			'home.readiness.retry' => 'Reintentar',
			'home.status.active' => 'Alineación activa',
			'home.status.stopped' => 'Alineación detenida',
			'home.status.processing' => 'Procesando el audio del teléfono',
			'home.status.lastSaved' => 'Último ajuste guardado',
			'home.status.value' => ({required Object side, required Object ms}) => '${side} +${ms} ms',
			'home.align.first' => 'Alinear automáticamente',
			'home.align.again' => 'Volver a alinear',
			'home.align.hint' => 'Mide con el micrófono del teléfono, aplica el retraso y lo verifica (~1 min).',
			'home.countdown.title' => 'Deja el teléfono en su sitio',
			'home.countdown.subtitle' => 'Micrófono hacia el frente y quieto',
			'home.measuring.title' => ({required Object phase}) => '${phase}…',
			'home.measuring.stayStill' => 'No muevas el teléfono',
			'home.result.delayLeft' => ({required Object ms}) => 'Retrasar el izquierdo ${ms} ms',
			'home.result.delayRight' => ({required Object ms}) => 'Retrasar el derecho ${ms} ms',
			'home.result.nothingApplied' => 'No se aplicó ningún cambio',
			'home.result.measuredVia' => ({required Object name}) => 'Medido a través de ${name}',
			'home.result.measuredPhoneSpeaker' => 'Medido con el altavoz del teléfono (no el del coche)',
			'home.result.measuredUsb' => 'Medido a través de USB',
			'home.result.sourceUnrecognized' => 'Origen de audio no reconocido',
			'home.result.details' => 'Detalles',
			'home.result.verified' => ({required Object residual, required Object sigma, required Object valid, required Object reps, required Object band}) => 'Verificado: residuo ${residual} µs · dispersión ${sigma} µs · ${valid}/${reps} válidas · banda ${band}',
			'home.result.bandsLine' => ({required Object low, required Object mid, required Object high}) => 'Sin retraso, R−L por banda: graves ${low} · medios ${mid} · agudos ${high} ms',
			'home.result.output' => ({required Object name}) => 'Salida: ${name}',
			'home.result.outputRaw' => ({required Object name, required Object raw}) => 'Salida: ${name} (${raw})',
			'home.result.microphone' => ({required Object name}) => 'Micrófono: ${name}',
			'home.result.noise' => ({required Object db}) => 'Ruido: ${db} dBFS',
			'home.profiles.title' => 'Perfiles',
			'home.profiles.saveCurrent' => 'Guardar actual',
			'home.profiles.empty' => 'Sin perfiles todavía. Cada alineación automática guarda uno.',
			'home.profiles.hint' => 'Toca un perfil para aplicarlo; desliza para borrarlo.',
			'home.profiles.autoName' => ({required Object time}) => 'Auto ${time}',
			'home.profiles.dialogTitle' => 'Guardar perfil',
			'home.profiles.dialogHint' => 'Nombre (ej. Conductor)',
			'advanced.title' => 'Avanzado',
			'advanced.manual.title' => 'Ajuste manual',
			'advanced.manual.subtitle' => 'Los cambios se aplican en vivo si la alineación está activa.',
			'advanced.manual.difference' => ({required Object cm}) => '≈ ${cm} cm de diferencia',
			'advanced.manual.delayLeft' => 'Retrasar izq.',
			'advanced.manual.delayRight' => 'Retrasar der.',
			'advanced.manual.startAlignment' => 'Iniciar alineación',
			'advanced.demo.title' => 'Demostración',
			'advanced.demo.description' => 'Va de 0 ms a un perfil con música sonando: se oye cómo el escenario se centra.',
			'advanced.demo.needsProfile' => 'Guarda un perfil primero (alinea o usa "Guardar actual").',
			'advanced.demo.stop' => 'Detener demostración',
			'advanced.demo.profile' => 'Perfil',
			'advanced.demo.profileItem' => ({required Object name, required Object ms, required Object side}) => '${name} · ${ms} ms ${side}',
			'advanced.demo.duration' => 'Duración',
			'advanced.demo.steps' => 'Pasos',
			'advanced.demo.seconds' => ({required Object n}) => '${n} s',
			'advanced.demo.toProfile' => '0 → perfil',
			'advanced.demo.roundTrip' => 'Ida y vuelta',
			'advanced.demo.preparing' => 'Preparando',
			'advanced.demo.unaligned' => 'Sin alineación',
			'advanced.demo.centering' => 'Centrando',
			'advanced.demo.aligned' => 'Alineado',
			'advanced.demo.removing' => 'Quitando',
			'advanced.demo.stepOf' => ({required Object label, required Object k, required Object n}) => '${label}  (paso ${k} de ${n})',
			'advanced.diagnostics.title' => 'Diagnóstico y compatibilidad',
			'advanced.diagnostics.subtitle' => 'Qué soporta este teléfono y cómo prepararlo',
			'diagnostics.title' => 'Diagnóstico',
			'diagnostics.intro' => 'Qué soporta este teléfono. Si algo no funciona en otro móvil, copia el informe y compártelo.',
			'diagnostics.loading' => 'Cargando…',
			'diagnostics.noData' => 'Sin datos',
			'diagnostics.noResponse' => 'Sin respuesta',
			'diagnostics.testMute' => 'Probar silenciado',
			'diagnostics.copyReport' => 'Copiar informe',
			'diagnostics.refresh' => 'Actualizar',
			'diagnostics.batterySaver' => 'Ahorro de batería',
			'diagnostics.reportCopied' => 'Informe copiado',
			'diagnostics.muteWorks' => ({required Object detail}) => 'El canal para silenciar funciona en este teléfono.\n${detail}',
			'diagnostics.muteFails' => ({required Object detail}) => 'El canal para silenciar NO funciona todavía.\n${detail}',
			'diagnostics.limitationTitle' => 'Limitación importante',
			'diagnostics.limitationBody' => 'Android no deja que una app normal silencie a otra. CarAlign necesita un canal de ADB para hacerlo: hay que activarlo con un ordenador (adb tcpip 5555) cada vez que se reinicia el teléfono, o usar Shizuku. Sin ese canal la app no silencia el audio original y no se activa.',
			'diagnostics.setupTitle' => 'Preparar otro teléfono',
			'diagnostics.step1' => 'Activa las opciones de desarrollador: Ajustes → Acerca del teléfono → toca 7 veces "Número de compilación".',
			'diagnostics.step2' => 'En Opciones de desarrollador activa "Depuración USB".',
			'diagnostics.step3' => 'Conecta el teléfono a un ordenador con ADB y ejecuta  adb tcpip 5555 . Hay que repetirlo cada vez que se reinicia el teléfono.',
			'diagnostics.step4' => 'Abre CarAlign. Si aparece "¿Permitir depuración?", acéptalo y marca "Siempre permitir".',
			'diagnostics.step5' => 'Pulsa "Probar silenciado". Si falla, mira el motivo: algunas marcas piden más ajustes (Xiaomi/Redmi/POCO: "Depuración USB (ajustes de seguridad)"; Samsung: desactivar el bloqueo de comandos por USB de Auto Blocker).',
			'diagnostics.step6' => 'Pulsa "Ahorro de batería" y permite que CarAlign funcione sin restricciones, para que no la cierren en segundo plano.',
			'diagnostics.footer' => 'Sin este canal la app no puede silenciar el audio original y se oiría doble.',
			'guard.adbInactiveNoShizuku' => 'El ADB por red no está activo. Tampoco hay Shizuku en ejecución: abre Shizuku y pulsa Iniciar (depuración inalámbrica), o conecta el cable y ejecuta adb tcpip 5555 desde un ordenador.',
			'guard.adbFailedNoShizuku' => ({required Object error}) => 'No se pudo usar el ADB del teléfono: ${error}. Tampoco hay Shizuku en ejecución: abre Shizuku y pulsa Iniciar (depuración inalámbrica), o conecta el cable y ejecuta adb tcpip 5555 desde un ordenador.',
			'guard.shizukuFailed' => ({required Object error}) => 'Shizuku está activo pero falló: ${error}',
			'guard.notStarted' => 'El vigilante no arrancó.',
			'resultMessage.speakerOutput' => 'La salida de audio es el altavoz del teléfono, no el coche. Conecta Android Auto o el Bluetooth del coche y repite.',
			'resultMessage.bluetoothCallLine' => 'El audio va por la línea de llamadas Bluetooth (mono, baja calidad). En el teléfono, Bluetooth > coche > activa "Audio multimedia" y vuelve a intentar.',
			'resultMessage.noSignal' => 'No se oye bien la señal: sube el volumen del coche, cierra ventanas o reduce el ruido y repite.',
			'resultMessage.clipped' => 'La señal recortaba; se bajó el nivel de la medición.',
			'resultMessage.measurementUnreliable' => ({required Object reason}) => 'La medición no fue fiable: ${reason}.',
			'resultMessage.verificationUnreliable' => ({required Object reason}) => 'La verificación no fue fiable: ${reason}.',
			'resultMessage.differenceTooLarge' => 'La diferencia medida es muy grande; revisa la posición del teléfono.',
			'resultMessage.notVerifiable' => 'No se pudo verificar el ajuste, por eso no se aplica.',
			'resultMessage.identicalChannels' => 'Izquierdo y derecho suenan idénticos (misma llegada y mismo nivel). Si no lo esperabas, la salida puede ser mono o mezclada; revisa balance, fader y que el audio sea estéreo.',
			'resultMessage.notConverging' => ({required Object us}) => 'El ajuste no converge del todo; queda un residuo de ${us} µs.',
			'resultMessage.notConvergingRejected' => ({required Object us}) => 'El ajuste no converge (residuo ${us} µs); no se aplica.',
			'resultMessage.internalError' => ({required Object detail}) => 'Error interno: ${detail}',
			'resultMessage.unknown' => ({required Object code}) => 'Mensaje desconocido (${code})',
			'reason.fewValidReps' => ({required Object count}) => 'pocas repeticiones válidas (${count})',
			'reason.lowRepeatability' => ({required Object us}) => 'poca repetibilidad (dispersión ${us} µs)',
			'reason.recordingTooShort' => 'grabación demasiado corta',
			'reason.recordingSilent' => 'grabación en silencio',
			'reason.unknown' => 'causa desconocida',
			'placement.title' => 'Cómo colocar el teléfono',
			'placement.topCaption' => 'Vista desde arriba: el teléfono ocupa el lugar de la cabeza.',
			'placement.sideCaption' => 'Vista de lado: a la altura de los oídos, tumbado, con el micrófono hacia adelante.',
			'placement.step1Title' => 'Donde va la cabeza',
			'placement.step1Body' => 'A la altura de los oídos y centrado entre ambos, no pegado a la puerta. Un centímetro de diferencia ya cambia el resultado, así que colócalo siempre igual.',
			'placement.step2Title' => 'Micrófono hacia el frente',
			'placement.step2Body' => 'El borde de abajo del teléfono (donde está el micrófono) apunta al parabrisas. No lo tapes con la mano ni con una funda gruesa.',
			'placement.step3Title' => 'Quieto y firme',
			'placement.step3Body' => 'Apoyado o en un soporte, nunca en la mano. Si se mueve, la medición se descarta.',
			'placement.carTitle' => 'En el coche',
			'placement.car1' => 'Ventanas cerradas y nadie hablando',
			'placement.car2' => 'Motor apagado o estable',
			'placement.car3' => 'Volumen del coche en medio',
			'placement.car4' => 'Fader totalmente hacia adelante (traseros apagados)',
			'placement.car5' => 'Balance al centro y tonos en plano',
			'placement.car6' => 'Conectado por Android Auto o Bluetooth, con la música en pausa',
			'placement.rearWarning' => 'Con los traseros activos el sonido "viene de atrás" y la medición se sesga.',
			'placement.firstRunInfo' => 'Tendrás 10 s para dejar el teléfono; después sonarán sonidos de prueba durante algo más de un minuto. Un tono ascendente al final es éxito; uno grave, que hay que repetir.',
			'placement.info' => 'Al medir tendrás 10 s para dejar el teléfono. Un tono ascendente al final es éxito; uno grave, que hay que repetir.',
			'placement.dontShowAgain' => 'No volver a mostrar',
			'placement.dontShowAgainHint' => 'Siempre la encuentras con el icono de ayuda',
			'placement.gotIt' => 'Entendido, empezar',
			'placement.figure.windshieldFront' => 'Parabrisas (frente)',
			'placement.figure.leftMarker' => 'I',
			'placement.figure.rightMarker' => 'D',
			'placement.figure.centered' => 'Centrado',
			'placement.figure.micForward' => 'Micrófono\nhacia el frente',
			'placement.figure.notAgainstDoor' => 'No pegado\na la puerta',
			'placement.figure.windshield' => 'Parabrisas',
			'placement.figure.earHeight' => 'Altura de los oídos',
			'placement.figure.micBottomEdge' => 'Micrófono (borde de abajo)\nhacia el frente',
			'placement.figure.phoneLying' => 'Teléfono\ntumbado',
			_ => null,
		};
	}
}
