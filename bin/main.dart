
import 'dart:io';
import 'dart:async';
import 'terminal_service.dart';
import 'conexion_socket.dart';

void main(List<String> arguments) async{

  //Read IP and Port of the console
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
  //Create connection, listen and print data received----------------
  var connection = ConnectionSocket(ip, port);
  try {
      await connection.connect();
       
        connection.onData.listen(printGreen,
        onError: (error) { 
        printRed("Main Error:$error");
         exit(-1);
        },
        onDone: ()=>printRed("Close conecction")
      );
  //Send Commands ---------------------------------------------------
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
        if (message.toLowerCase() == 'reconnect') { 
          if (!connection.connected){
            connection.reconnect();
          }
          printRed("already connected");
          return;
        }
        if (message.toLowerCase() == 'exit') { 
        connection.close();
        subscription.cancel();
        exit(-1);
        }
        if (message.toLowerCase() == 'get') { 
        // conexion.sendData("GET /Dynamic.js\r\n");
          connection.sendData('GET /  HTTP/1.1\r\n'
          'Host: $ip\r\n'
          'Connection: keep-alive\r\n'
          'User-Agent: Misco/1.0\r\n'
          '\r\n');
        
        return;
        }
        connection.sendData("$message\r");      
      });
  });

  } on Error catch (e) {
    printRed(e.toString());
  }
  
}