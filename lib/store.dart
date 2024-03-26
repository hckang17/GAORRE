import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'table.dart'; // RestaurantTable을 불러옵니다.

class StorePage extends StatelessWidget {
  final String storeCode;

  StorePage({required this.storeCode});

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    // args가 null인 경우를 처리
    // 여기서, storeCode를 입력받지 않으면 페이지 접속자체가 불가능하게 막아야 함.
    // final String storeCode = args?['storeCode'] ?? 'No Store Code Found';


    List<Reservation> reservations = [
      Reservation(reservationNumber: 1, name: 'John Doe', contact: '123-456-7890'),
      Reservation(reservationNumber: 2, name: 'Jane Smith', contact: '987-654-3210'),
      // 서버측으로부터 데이터를 수신해서 리스트화 할 것임.
    ];
    int waitingTeams = reservations.length;



    return Scaffold(
      appBar: AppBar(
        title: Text('Store Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Master of $storeCode',
            style: TextStyle(fontSize: 40),
            ),
            GestureDetector(
              onTap: () {
                _showReservationList(context, reservations);
              },
              child: Text(
                'Waiting Teams: $waitingTeams',
                style: TextStyle(fontSize: 24),
              ),
            ),
            // 여기서 RestaurantTable 위젯을 사용합니다.
            // const RestaurantTable(), // RestaurantTable을 추가합니다.
            ElevatedButton(
              onPressed: () {
                callGuest(context, reservations[0]);
              },
              child: Text('Call Guest'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReservationList(BuildContext context, List<Reservation> reservations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservation List'),
          content: SingleChildScrollView(
            child: ListBody(
              children: reservations.map((reservation) {
                return ListTile(
                  title: Text('Reservation Number: ${reservation.reservationNumber}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${reservation.name}'),
                      Text('Contact: ${reservation.contact}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class Reservation {
  final int reservationNumber;
  final String name;
  final String contact;

  Reservation({required this.reservationNumber, required this.name, required this.contact});
}

void callGuest(BuildContext context, Reservation guest) {
  String guestName = guest.name;
  int waitingNumber = guest.reservationNumber;
  String guestContact = guest.contact;

  //       Reservation(reservationNumber: 1, name: 'John Doe', contact: '123-456-7890'),

  // CallGuest API 호출예정임.
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('알림'),
        content: Text('CallGuest 함수가 실행되었습니다.\n대기번호 $waitingNumber번의 $guestName님이 호출되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
      );
    },
  );
}