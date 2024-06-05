import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaorre/widget/text/text_widget.dart';
import 'package:intl/intl.dart';
import 'package:gaorre/provider/Data/UserLogProvider.dart';
import 'package:permission_handler/permission_handler.dart';

void showWaitingLog(WidgetRef ref) {
  String toKRStatus(String status){
    if(status.startsWith('called')){
      status = 'called';
    }
    switch (status) {
      case 'called':
        status = '호출됨';
      break;
      case 'store canceled':
        status = '가게취소';
      break;
      case 'user canceled':
        status = '유저취소';
      break;
      case 'entered':
        status = '입장';
      break;
      case 'waiting':
        status = '대기중';
      default:
        status;
    }
    return status;
  }

  Color Cstatus = Colors.black;

  Color statusColor(String status){
    if(status.startsWith('called')){
      status = 'called';
    }
    switch (status) {
      case 'called':
        Cstatus = Colors.green;
      break;
      case 'store canceled':
        Cstatus = Colors.orange;
      break;
      case 'user canceled':
        Cstatus = Color.fromARGB(255, 255, 43, 43);
      break;
      case 'entered':
        Cstatus = Colors.blue;
      break;
      case 'waiting':
        Cstatus = Colors.deepPurpleAccent;
      break;
      default:
        Cstatus;
    }
    return Cstatus;
  }
  
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
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 32, bottom: 32),
                  child: TextWidget(
                    '웨이팅리스트 변동 내역',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF72AAD8),
                    
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: userLogs.userLogs?.length ?? 0,
                    itemBuilder: (context, index) {
                      final log = userLogs.userLogs![index];
                      return Padding(padding: EdgeInsets.all(16), 
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          TextWidget('${log.waitingNumber} 번 손님',fontSize: 18, fontWeight: FontWeight.bold,),
                          SizedBox(height: 8,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2, 
                                child: TextWidget('연락처 : ${log.userPhoneNumber}', fontSize: 16,textAlign: TextAlign.start,)
                              ),
                              Expanded(
                                flex: 1, 
                                child: TextWidget('일행 수 : ${log.personNumber} 명', fontSize: 16,textAlign: TextAlign.right,)
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start, 
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              TextWidget('최종 상태: ', fontSize: 16,textAlign: TextAlign.start,),
                              TextWidget('${toKRStatus(log.status)}', fontSize: 16,color: statusColor(log.status), textAlign: TextAlign.start,),
                            ],),
                          Divider(
                              color: Color(0xFFDFDFDF),
                              thickness: 1,
                            ),
                        ],
                        
                      ),
                      );
                      // ListTile(
                      //   title: Text(
                      //       '[${log.waitingNumber} 번 손님] 연락처 : ${log.userPhoneNumber}'),
                      //   subtitle: Text(
                      //       '최종 상태: ${log.status} - 상태 변경 시간: ${log.statusChangeTime != null ? formatStatusChangeTime(log.statusChangeTime) : "해당사항 없음"}'),
                      //   trailing: Text('일행수: ${log.personNumber} 명'),
                      // );
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
