

import 'dart:io';
import 'dart:async';
import 'terminal_service.dart';

/*
PROTOCOL - TX- RX
Character Function Decimal Hex
[ACK] Acknowledge 6 06
[LF] Line Feed 10 0A
[CR] Carriage return 13 0D
[X-ON] Software Handshake (device on) 17 11
[X-OFF] Software Handshake (device off) 19 13
[NAK] Negative Acknowledge 21 15 
[SP] Space 32 20
[EOT] End of Transmission 4 04
[ENQ] End of Inquire 5 05
[STX] Start of Text 2 02
[ETX] End of Text 3 03

*/


class ConexionSocket {
  final String host;
  final int puerto;
  late Socket socket;
  late StreamSubscription reader;
  bool success;
  int maxReintentos;
  int intentos = 0;
  Duration timeoutDuration;

  final nak = String.fromCharCode(21); 
  final ack = String.fromCharCode(6); 
  final sp = String.fromCharCode(32);
  final eot = String.fromCharCode(4);
  final enq = String.fromCharCode(5);
  final stx = String.fromCharCode(2);
  final etx = String.fromCharCode(3);
  final xon = String.fromCharCode(17);
  final xoff = String.fromCharCode(19);
  final eol = "\r\n";

  

  
  ConexionSocket(this.host, this.puerto, {this.maxReintentos = 3, this.timeoutDuration = const Duration(seconds: 2), this.success=false});

  Future<void> conectar() async {
    while ((intentos < maxReintentos)) {
      try {
        
        socket = await Socket.connect(host, puerto, timeout: timeoutDuration);
        printRed('Conectado a $host:$puerto');
        success=true;
        processStream(socket);
        break;

      } on TimeoutException {
        success=false;
        print('Error: Timeout al conectar. Reintentando...');
      } on SocketException {
        success=false;
        print('Error al conectar. Intentando reconectar...');
      }

      intentos++;
      printGreen('nº intentos: $intentos');
      if (intentos >= maxReintentos) {
        print('Se alcanzó el máximo de reintentos. No se pudo conectar.');
        break;
      }

      await Future.delayed(Duration(seconds: 2));
      printGreen('esperando dentro de intentos $intentos');
    }
  }

  // Enviar datos al servidor
  void enviarDatos(String mensaje) {
    if (success) {
      socket.write(mensaje);
      printRed('TX: ${mensaje.trim()}'); 
    } else {
      print('No hay conexión activa.');
    }
  }

  // Cerrar la conexión
  void cerrar() {
    if (success) {
      socket.close();
      print('Conexión cerrada.');
    } else {
      print('No hay conexión activa.');
      reconectar();
    }
  }

  // Método para forzar la reconexión
  Future<void> reconectar() async {
    print('Intentando reconectar...$intentos veces');
    intentos = 0;
    await conectar();
  }


  Future<void> processStream(Stream<List<int>> stream) async {
    StringBuffer buffer = StringBuffer();
   
   try {
    await for (var chunk in stream) {
     
      var chunkString = String.fromCharCodes(chunk);
      if (!chunkString.contains(eol)) {
        printGreen("RX: ${chunkString.codeUnits}");
      } 
      buffer.write(chunkString);
      while (buffer.toString().contains(eol)) {
        var line = _extractLine(buffer);
        printGreen('RX: $line');
      } 
    } 
   } //try
    catch (e){
      success = false;
      print('socket broken $e');
    }
    finally {
      //When socket finally by host
      success = false;
    }  
  }

  String _extractLine(StringBuffer buffer) {
    int index = buffer.toString().indexOf(eol);
    String line = buffer.toString().substring(0, index);
  
    String resto=buffer.toString().substring(index +2);
    buffer.clear();
    buffer.write(resto);
    return line;
  }
}


void main() async {
  //IP:    PORT:
  var conexion = ConexionSocket('192.168.1.9', 2020);
  await conexion.conectar();
      Future.microtask(()  {
          stdin.asBroadcastStream().listen((List<int> data) {
          String message = String.fromCharCodes(data).trim();
           if (message.toLowerCase() == 'clear') {
            stdout.write('\x1B[2J\x1B[0;0H');  //clear terminal
            return;
            }
          try { 
            conexion.enviarDatos(message + '\r'); 
          } on SocketException catch (e){
            print("socket error: $e");
          }
        });
      });


  if(conexion.success) return;
  Future.delayed(Duration(seconds: 10), () async {
    print('Intentando reconectar después de 10 segundos...');
    await conexion.reconectar();
    exit(-1);
  });
}