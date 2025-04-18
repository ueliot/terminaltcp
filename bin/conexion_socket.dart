
import 'dart:io';
import 'dart:async';
import 'terminal_service.dart';
import 'controllabels.dart';

class ConnectionSocket {
  
  final String host;
  final int puerto;
  final StreamController<String> _rxController = StreamController.broadcast();
  Socket? _socket;
  int attempts = 0;
  Duration timeoutDuration;
  final eol = "\r";  // can be "\r\n"
  bool connected = false;
  int backoffDuration = 1; // Start whit 1 sec
  
  ConnectionSocket(this.host, this.puerto, {
    this.timeoutDuration = const Duration(seconds: 5), 
  });
    
  //Connect -----------------------------------------   
  Future<void> connect() async {
    try {
      
      _socket = await Socket.connect(host, puerto, timeout: timeoutDuration);
      connected=true;
      
      processStream(_socket!);
      printRed('Connected to $host:$puerto');
      
    } on TimeoutException catch(e) {
      printRed("Timeout Error");
      _rxController.addError(e);
      //throw 'TimeoutExeption Error...';
      
    } on SocketException catch(e) {
      printRed("SocketException Error");
      _rxController.addError(e);
      //exit(-1);
      //throw 'SocketException Error....';
      
     } catch (e) {
      _rxController.addError(e);
      //throw 'unexpected error: $e';
    } 
  }

  // Send data ---------------------------------
  void sendData(String message) {
    if (connected) {
       _socket?.write(message);
      //printRed('TX: ${message.trim()}'); 
      return;
    } 
    printRed('not active connetión.');
  }

  // Close conecction-------------------------
  void close() async { 
      _rxController.close();
      _socket?.destroy();
      _socket?.close();
      //connected=false;
  }

  //Reconnect -------------------------------
  Future<void> reconnect() async {
    printRed('reconnecting...');
    connected=false;
    attempts++;
    try {
      backoffDuration *= 2; // Doubling the time between attempts
       printGreen('attemps $attempts in $backoffDuration sec' );
      await Future.delayed(Duration(seconds: backoffDuration));
      await connect();
    } catch (e) {
      print('reconnectión error: $e');
  }
}

  //Process _socket-------------------------------------------
  Future<void> processStream(Socket stream ) async {
    StringBuffer buffer = StringBuffer();
   try {
      await for (var chunk in stream ) {
        connected=true;
      var chunkString = String.fromCharCodes(chunk);
      if (!chunkString.contains(eol)) {
        //printGreen("RX--: ${ControlLabels.labels[chunkString.codeUnits[0]]}");
         _rxController.add( ControlLabels.labels[chunkString.codeUnits[0]]!); // Enviar datos recibidos 
        buffer.clear();   
      } 
      buffer.write(chunkString);
      while (buffer.toString().contains(eol)) {
        var line = _extractLine(buffer);
         _rxController.add(line);
        //printGreen('RX: $line');
      }  
    } 
   } //try
   on SocketException catch(e) {
    if (e.osError != null && e.osError!.errorCode == 121) {
      printRed('timeout in the network OS: ${e.message}');
    } else {
      printRed('Error OS: ${e.message}');
    }
    _rxController.addError(e);
    //exit(-1);
   }
    catch (error){
      _rxController.addError(error);
      _socket?.destroy();
      connected = false;
      //throw "Not network connection error: $error";
    }
    finally {
      _socket?.destroy();
      _socket?.close();
      connected=false;
      _rxController.addError(Error());
      //throw "finally in socket processStream";
    }
  }

  //TODO: Periodic heartbeat
  

  // Extracc line----------------------------------------
  String _extractLine(StringBuffer buffer) {
    int index = buffer.toString().indexOf(eol);
    String line = buffer.toString().substring(0, index);
    String rest=buffer.toString().substring(index + eol.length);
    buffer.clear();
    buffer.write(rest);
    return line;
  }

  /// return stream whit data receibed
  Stream<String> get onData => _rxController.stream;

}