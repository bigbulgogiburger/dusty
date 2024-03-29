import 'package:dusty/const/colors.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/model/status_model.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  final String region;
  final StatusModel status;
  final StatModel stat;
  final DateTime dateTime;
  final bool isExpanded;
  MainAppBar({required this.isExpanded, required this.dateTime,required this.region,required this.stat, required this.status,super.key});

  @override
  Widget build(BuildContext context) {

    final ts = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
    );
    return SliverAppBar(
      pinned: true,
      title: isExpanded? null : Text('$region ${DataUtils.getTimeFromDateTime(dateTime: dateTime)}'),
      centerTitle: true,
      backgroundColor: status.primaryColor,
      expandedHeight: 500,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Container(
            // ktoolbar height를 쓰면 앱바의 간격만큼 띄어진다.
            margin: EdgeInsets.only(top:kToolbarHeight),
            child: Column(
              children: [
                Text(
                  region,
                  style: ts.copyWith(
                      fontSize: 40.0, fontWeight: FontWeight.w700),
                ),
                Text(
                  DataUtils.getTimeFromDateTime(dateTime: stat.dataTime),
                  style: ts.copyWith(
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Image.asset(
                  status.imagePath,
                  width: MediaQuery.of(context).size.width / 2,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  status.label,
                  style: ts.copyWith(
                      fontSize: 40.0, fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  status.comment,
                  style: ts.copyWith(
                      fontSize: 20.0, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
