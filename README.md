# terminaltcp
- Terminaltcp is a little terminal to open tcp socket to server written in dart.
- Read ascci and control characters - non utf-8, the protocol used is described in the images below.
- The main source is in /bin/main.dart.

## To run test:
 - first install Dart or Flutter.
 - install pub dependencies.
    -  the data in raw socket shoultbe in ascci
 - use in the terminal  > dart run :main

## To Compile 
- You need the visual studio for Windows
- You need the xcode for Mac or for other platforms see
    - https://docs.flutter.dev/get-started/install
- to compile use > dart compile exe main.dart

## Use
- by default connect to : 192.168.1.9 in the port 2020
- but you can use >  main ip port  > example: main 10.10.5.2 1024
- commands: CLEAN (clear terminal), EXIT(kill the terminal) and GET (keep alive to http test)

## Protocol

### From Master to Slave
![](./images/up.png)
### From Slave to Master
![](./images/down.png)



 