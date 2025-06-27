import 'package:agnostiko/agnostiko.dart';

List<Iterable<int>>? getEMVTestSetRanges(String testSetName, String pan, String entryMode, String transactionType) {
  if (testSetName == "Willians") {
    if(transactionType == "sale"){
      if(entryMode == "icc"){
        if (pan == "5413330089604111") {
          return [
            // Internal Authenticate Data
            range(0x469, 0x46D),
            // Internal Authenticate Response - Data de tag 9F4B
            range(0x476, 0x526),
            // Fecha
            range(0x552, 0x555),
            // Número random del terminal
            range(0x556, 0x55A),
            // 9F45 + 9F4C
            range(0x55B, 0x565),
            // Hora
            range(0x568, 0x56B),
            // Tag 9F36 (ATC)
            range(0x58A, 0x58C),
            // Tag 9F26 (Application Cryptogram - Primero)
            range(0x58F, 0x597),
            // Tag 9F10 (Issuer Application Data)
            range(0x59A, 0x5AC),
            // Número random del terminal + 9F4C
            range(0x5C7, 0x5D3),
            // Tag 9F36 (ATC)
            range(0x5DE, 0x5E0),
            // Tag 9F26 (Application Cryptogram - Segundo)
            range(0x5E3, 0x5EB),
            // Tag 9F10 (Issuer Application Data)
            range(0x5EE, 0x600),
          ];
        } else if (pan == "4761731000000043") {
          return [
            // Internal Authenticate Data
            range(0x3F6, 0x3FA),
            // Internal Authenticate Response
            range(0x3FE, 0x46E),
            // Fecha
            range(0x49A, 0x49D),
            // Número random generado en la transacción
            range(0x49E, 0x4A2),
            // Tag 9F36 (ATC) + Tag 9F26 (Application Cryptogram - Primero)
            range(0x4A7, 0x4B1),
            // Fecha
            range(0x4D9, 0x4DC),
            // Número random generado en la transacción
            range(0x4DD, 0x4E1),
            // Tag 9F36 (ATC) + Tag 9F26 (Application Cryptogram - Segundo)
            range(0x4E6, 0x4F0),
          ];
        } else {
          return null;
        }
      }else{
        return null;
      }
    }else{
      return null;
    }
  } else if (testSetName == "Yura") {
    if(transactionType == "sale"){
      if(entryMode == "icc"){
        if (pan == "5413330089604111") {
          return [
            //Fecha
            range(1132, 1135),
            // Número random generado en la transacción
            range(1136, 1140),
            // Hora
            range(1154, 1157),
            // Tag 9F36 (ATC)
            range(1188, 1190),
            // Tag 9F26 - Application Cryptogram - Primero
            range(1193, 1201),
            // Tag 9F10 - Issuer Application Data
            range(1204, 1222),
            // Número random generado en la transacción
            range(1249, 1253),
            // Tag 9F36 (ATC)
            range(1272, 1274),
            // Tag 9F26 - Application Cryptogram - Segundo
            range(1277, 1285),
            // Tag 9F10 - Issuer Application Data
            range(1288, 1306),
          ];
        } else if (pan == "4761731000000043") {
          return [
            // Número random generado en la transacción
            range(1010, 1014),
            // Internal Authenticate Response
            range(1018, 1130),
            // Fecha
            range(1174, 1177),
            // Número random generado en la transacción
            range(1178, 1182),
            // ATC
            range(1187, 1189),
            // Application Cryptogram - Primero
            range(1189, 1204),
            // Fecha
            range(1237, 1240),
            // Número random generado en la transacción
            range(1241, 1245),
            // ATC
            range(1250, 1252),
            //  Application Cryptogram - Segundo
            range(1252, 1267),
          ];
        }
        else if (pan == "374245001751006") {
          return [
            // Fecha
            range(545, 548),
            // Número random generado en la transacción
            range(549, 553),
            // Application Cryptogram - Primero
            range(558, 575),
            // Fecha
            range(608, 612),
            // Número random generado en la transacción
            range(612, 616),
            // Application Cryptogram - Segundo
            range(621, 638),
          ];
        }
        else if (pan == "6510000000000216") {
          return [
            // Fecha
            range(462, 465),
            // Número random generado en la transacción
            range(466, 470),
            // Tag 9F36 (ATC)
            range(485, 487),
            // Tag 9F26 Application Cryptogram - Primero
            range(490, 498),
            // Tag 9F10 - Issuer Application Data
            range(501, 509),
            // Número random generado en la transacción
            range(536, 540),
            // Tag 9F36 (ATC)
            range(551, 553),
            // Tag 9F26 Application Cryptogram - Segundo
            range(556, 564),
            // Tag 9F10 - Issuer Application Data
            range(567, 575),
          ];
        }
        else {
          return null;
        }
      }else{
        if (pan == "4761731000000043") {
          return [
            // Fecha
            range(200, 203),
            // Número random generado en la transacción
            range(204, 208),
            // Tag 9F26 Application Cryptogram - Primero
            range(254, 262),
            // Tag 9F36 (ATC)
            range(269, 271),
          ];
        } else if (pan == "5413330089604111") {
          return [
            // Fecha
            range(994, 997),
            // Número random generado en la transacción
            range(998, 1002),
            // Hora
            range(1016, 1019),
            // Tag 9F36 (ATC)
            range(1051, 1053),
            // Tag 9F4B - Signed Dynamic Application Data
            range(1057, 1254),

          ];
        } else if (pan == "374245001751006") {
          return [
            // Fecha
            range(483, 486),
            // Número random generado en la transacción
            range(487, 491),
            // Application Cryptogram - Primero
            range(496, 513),
          ];
        }

      }
    }else{
      return null;
    }
  }
}
