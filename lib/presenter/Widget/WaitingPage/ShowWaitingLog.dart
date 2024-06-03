import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gaorre/provider/Data/UserLogProvider.dart';

void showWaitingLog(WidgetRef ref) {
  showModalBottomSheet(
      context: ref.context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, watch, child) {
            final userLogs = ref.watch(userLogProvider);
            if (userLogs == null) {
              return Center(child: Text("아직 웨이팅 로그가 존재하지 않습니다"));
            }

            // 시간에 따라 정렬
            userLogs.userLogs?.sort((a, b) => DateFormat(
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
                .parse(b.statusChangeTime ?? "1970-01-01T00:00:00.000+00:00")
                .compareTo(DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").parse(
                    a.statusChangeTime ?? "1970-01-01T00:00:00.000+00:00")));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '웨이팅리스트 변동 내역',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: userLogs.userLogs?.length ?? 0,
                    itemBuilder: (context, index) {
                      final log = userLogs.userLogs![index];
                      return ListTile(
                        title: Text(
                            '[${log.waitingNumber} 번 손님] 연락처 : ${log.userPhoneNumber}'),
                        subtitle: Text(
                            '최종 상태: ${log.status} - 상태 변경 시간: ${log.statusChangeTime != null ? formatStatusChangeTime(log.statusChangeTime) : "해당사항 없음"}'),
                        trailing: Text('일행수: ${log.personNumber} 명'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      });
}

// 유저로그 용
String formatStatusChangeTime(String? isoTime) {
  if (isoTime == null) return "시간 미확인";

  try {
    DateTime parsedTime =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ").parse(isoTime, true);
    return DateFormat("yyyy년 MM월 dd일 HH시 mm분 ss초").format(parsedTime);
  } catch (e) {
    print("Date parsing error: $e");
    return "시간 형식 오류";
  }
}
