
import 'dart:io';
import 'dart:async';
import 'terminal_service.dart';
import 'controllabels.dart';

class ConexionSocket {
  
  final String host;
  final int puerto;
  late Socket socket;
  bool success = false;
  int maxRetries;
  int attempts = 0;
  Duration timeoutDuration;
  Stream<List<int>>? _socketStream;
  StreamSubscription<List<int>>? _socketStreamSubscription;
  final eol = "\r\n";
  
  ConexionSocket(this.host, this.puerto, {
    this.maxRetries = 10, 
    this.timeoutDuration = const Duration(seconds: 2), 
    this.success=false,
  });
    
  //Connect -----------------------------------------   
  Future<void> connect() async {
    while ((attempts < maxRetries)) {
      try {
        
        socket = await Socket.connect(host, puerto, timeout: timeoutDuration);
        printRed('Connected to $host:$puerto');
        success=true;
        _socketStream = socket.asBroadcastStream();
        _socketStreamSubscription = _socketStream!.listen((_){});
        //print("code: ${_socketStream.hashCode.toString()}");
        processStream(_socketStream!);
        break;

      } on TimeoutException {
        success=false;
        print('TimeoutExeption Error...');
      } on SocketException {
          success=false;
          print('SocketException Error....');
      }

      attempts++;
      printGreen('nº attempts: $attempts');
      if (attempts >= maxRetries) {
        print('number of attempts reached.');
        socket.close();
        exit(-1);
      }
      await Future.delayed(Duration(seconds: 2));
    }
  }

  // Send data -----------------------------------
  bool  sendData(String message) {
    if (!success) {
      print('not active connetión.');
      return false;
    }
    socket.write(message);
    printRed('TX: ${message.trim()}'); 
    return true;
  }

  // Close conecction-------------------------
  void close() async { 
      socket.flush();
      await socket.close();
      socket.destroy();
      success=false;
      print('close connetion.');
  }

  //Reconecc -----------------------
  Future <void> reconnect() async{
    print('trying to reconnect...$attempts');
    attempts = 0;
    await connect();
  }

  //Process socket-------------------------------------------
  Future<void> processStream(Stream<List<int>> stream ) async {
    StringBuffer buffer = StringBuffer();
   try {
      await for (var chunk in stream ) {
      var chunkString = String.fromCharCodes(chunk);
      if (!chunkString.contains(eol)) {
        printGreen("RX: ${ControlLabels.labels[chunkString.codeUnits[0]]}");
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
      print('No network connection error: $e');
      exit(-1);
    }
    finally {
      success = false;
      printGreen("processStream client error reconeccting in 2 sec");
      _socketStreamSubscription!.cancel();
      socket.destroy();
      await Future.delayed(Duration(seconds:2));
      reconnect();
    }
  }

  // Extracc line----------------------------------------
  String _extractLine(StringBuffer buffer) {
    int index = buffer.toString().indexOf(eol);
    String line = buffer.toString().substring(0, index);
    String rest=buffer.toString().substring(index +2);
    buffer.clear();
    buffer.write(rest);
    return line;
  }
}