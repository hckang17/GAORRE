import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orre_manager/Model/waiting_data_model.dart';
import 'package:orre_manager/provider/DataProvider/waiting_provider.dart';

void _showReservationList(BuildContext context, WidgetRef ref) {
  List<WaitingTeam?> teamList = ref.watch(waitingProvider.select((value) => value!.teamInfoList));
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Waiting Team List'),
        content: SingleChildScrollView(
          child: Column(
            children: teamList.map((team) {
              return ListTile(
                title: Text('Reservation Number: ${team?.waitingNumber}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${team?.status}'),
                    Text('Contact: ${team?.phoneNumber}'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: <Widget>[
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