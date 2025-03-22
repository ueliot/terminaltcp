
class ControlLabels {
  // Map of ASCII codes control whit label
  static Map<int, String> labels = {
    0: 'NULL (NUL)',
    1: 'START OF HEADING (SOH)',
    2: 'START OF TEXT (STX)',
    3: 'END OF TEXT (ETX)',
    4: 'END OF TRANSMISSION (EOT)',
    5: 'ENQUIRY (ENQ)',
    6: 'ACKNOWLEDGE (ACK)',
    7: 'BELL (BEL)',
    8: 'BACKSPACE (BS)',
    9: 'HORIZONTAL TAB (HT)',
    10: 'LINE FEED (LF)',
    11: 'VERTICAL TAB (VT)',
    12: 'FORM FEED (FF)',
    13: 'CARRIAGE RETURN (CR)',
    14: 'SHIFT OUT (SO)',
    15: 'SHIFT IN (SI)',
    16: 'DATA LINK ESCAPE (DLE)',
    17: 'DEVICE CONTROL 1 (DC1)',
    18: 'DEVICE CONTROL 2 (DC2)',
    19: 'DEVICE CONTROL 3 (DC3)',
    20: 'DEVICE CONTROL 4 (DC4)',
    21: 'NEGATIVE ACKNOWLEDGE (NAK)',
    22: 'SYNCHRONOUS IDLE (SYN)',
    23: 'END OF TRANSMISSION BLOCK (ETB)',
    24: 'CANCEL (CAN)',
    25: 'END OF MEDIUM (EM)',
    26: 'SUBSTITUTE (SUB)',
    27: 'ESCAPE (ESC)',
    28: 'FILE SEPARATOR (FS)',
    29: 'GROUP SEPARATOR (GS)',
    30: 'RECORD SEPARATOR (RS)',
    31: 'UNIT SEPARATOR (US)',
  };
}

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