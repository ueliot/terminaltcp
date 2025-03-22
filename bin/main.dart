import 'conexion_socket.dart';
import 'dart:io';
import 'dart:async';

void main(List<String> arguments)  {

  //Read IP and Port in the console ex: 10.10.10.10 1024
   String?  ip;
   int? port;

  if (arguments.length == 2) {
      ip = arguments[0];
      port = int.tryParse(arguments[1])!;
      print('Using :> $ip : $port');
  }

 if ( port == null || ip== null  ) {
    print('Error: ip:$ip or port:$port.....try by default');
    ip="192.168.1.9";
    port=2020; 
  }

  var conexion = ConexionSocket(ip, port);
  conexion.connect();
  Future.microtask(()  
  {
      Stream console = stdin.asBroadcastStream();
      StreamSubscription? subscription = console.listen(print);
      subscription.onData((data){
        String message = String.fromCharCodes(data).trim();
        if (message.toLowerCase() == 'clear') {
          stdout.write('\x1B[2J\x1B[0;0H');  //clear terminal
          return;
          }
          if (message.toLowerCase() == 'exit') { 
          conexion.close();
          subscription.cancel();
          exit(-1);
          }
        try { 
          
          conexion.sendData("$message\r");
          } catch(e) {
          print("Error..... $e");
        }
      });
  });
}