# CarAlign

Alinea en el tiempo los canales izquierdo y derecho del audio de un auto, sin DSP. Mide con el micrófono del teléfono la diferencia de llegada entre los dos lados y retrasa el canal que llega antes (del orden de 1 ms) para que el sonido se centre.

Pensado para estéreos de fábrica con Android Auto o Bluetooth, donde no hay ajuste de retardo por altavoz.

<p align="center">
  <img src="capturas/inicio.png" width="22%" alt="Inicio">
  <img src="capturas/avanzado.png" width="22%" alt="Ajuste manual">
  <img src="capturas/guia1.png" width="22%" alt="Guía de colocación">
  <img src="capturas/guia2.png" width="22%" alt="Guía de colocación, pasos">
</p>

## Por qué existe

En un auto el conductor no está en el centro: el altavoz izquierdo queda más cerca que el derecho, el sonido de ese lado llega antes y la imagen estéreo se corre hacia la puerta. Los procesadores de audio (DSP) lo corrigen con un retardo por canal, pero los estéreos de fábrica no lo traen. CarAlign aplica ese retardo desde el teléfono, que es lo que llega al estéreo por Android Auto o Bluetooth.

Nació para un VW Vento con estéreo RCD, un amplificador Jensen JA4B y altavoces Infinity pasivos de 2 vías, y se probó ahí.

## En qué se inspira

No imita a una app en concreto. Junta ideas conocidas:

- **Alineación de tiempo de los DSP de audio para auto**: el mismo ajuste, pero en el teléfono y solo con dos canales.
- **Barrido sinusoidal exponencial** (método de Farina), usado en mediciones de acústica: da buena relación señal/ruido y permite medir tiempos de llegada de microsegundos, con correlación cruzada e interpolación parabólica.
- **Captura de audio de Android (AudioPlaybackCapture) y apps que usan ADB o Shizuku** para hacer lo que Android no deja a una app normal. Por eso existe la limitación de más abajo.
- Librerías: [dadb](https://github.com/mobile-dev-inc/dadb) (ADB desde la propia app) y [Shizuku](https://shizuku.rikka.app/).

## Qué esperar

- **Efecto**: la voz y el escenario se centran frente a ti. En mi auto, la diferencia medida fue de alrededor de 1.1 a 1.3 ms (el lado derecho llegaba después, así que se retrasa el izquierdo), y a oído quedó mejor un poco por debajo de lo medido (~0.96 ms). Por eso hay ajuste manual: la medición es un buen punto de partida, no la última palabra.
- **Con qué sistema**: el efecto es sutil y depende del auto. Si tu estéreo ya tiene alineación de tiempo, no lo necesitas.
- **Latencia**: pasar el audio por la app suma entre ~90 y ~170 ms. Sirve para música; **no para ver video** (el sonido llegará tarde).
- **Un solo valor**: con dos canales solo se alinea izquierda contra derecha. No ajusta cada altavoz por separado, ni agudos contra graves.
- **Fader**: si los altavoces traseros están activos, el sonido puede parecer venir de atrás; conviene dejar el balance hacia el frente.
- **Mediciones**: la colocación del teléfono importa (un centímetro cambia el resultado), así que se muestra una guía en la app y debe colocarse siempre igual.
- **Estado de las pruebas**: lo medido en un auto real fue en un solo auto y un solo teléfono. Bluetooth, Spotify y otras marcas de teléfono no están comprobados en uso real.

## Cómo funciona

1. Captura el audio de la app de música (AudioPlaybackCapture).
2. Retrasa un canal con una línea de retardo de pasos suaves.
3. Lo reproduce y silencia el original.
4. La alineación automática emite barridos, los graba con el micrófono y calcula la diferencia por correlación cruzada, en lazo cerrado (mide, aplica, verifica).

## Limitación importante

Android no permite que una app normal silencie a otra. Para silenciar el audio original CarAlign necesita un canal de shell (ADB):

- Con un ordenador: `adb tcpip 5555` una vez cada vez que se reinicia el teléfono. Después la app se las arregla sola por loopback.
- O con [Shizuku](https://shizuku.rikka.app/) (respaldo, sin probar a fondo).

Sin ese canal la app no se activa (falla de forma segura: no silencia nada). Esto no se puede resolver solo con código, por eso no es una app de instalar y usar.

## Compatibilidad

- Android 10 o superior. Probada en emuladores Android 11, 14 y 16 y en un Pixel 6.
- Sin probar: Android 10/12/13 reales y otras marcas (Xiaomi y Samsung pueden pedir ajustes extra de depuración USB).
- Funciona con cualquier app que permita la captura de audio. Tidal y Spotify están en la lista conocida; las apps que bloquean la captura activan un freno de seguridad que devuelve el sonido.
- En *Avanzado → Diagnóstico y compatibilidad* hay un informe copiable y un botón "Probar silenciado".

## Compilar

```
flutter pub get
flutter build apk --release        # o: flutter build appbundle --release
```

Para firmar, crea `android/key.properties` (no se sube al repo):

```
storeFile=/ruta/a/tu.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Pruebas de simulación (Java, sin teléfono): `herramientas/pruebas_jvm/run.sh`.

## Privacidad

Todo ocurre en el teléfono. No hay cuentas, anuncios ni análisis, y el audio y el micrófono no salen del dispositivo. Ver [PRIVACY.md](PRIVACY.md).

## Licencia

MIT
