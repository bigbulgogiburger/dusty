import 'package:dio/dio.dart';
import 'package:dusty/container/category_card.dart';
import 'package:dusty/container/hourly_card.dart';
import 'package:dusty/component/main_app_bar.dart';
import 'package:dusty/component/main_drawer.dart';
import 'package:dusty/const/colors.dart';
import 'package:dusty/const/regions.dart';
import 'package:dusty/model/stat_and_status_model.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/repository/stat_repository.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    fetchData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final now = DateTime.now().add(Duration(hours: 9));
      final fetchTime = DateTime(now.year, now.month, now.day, now.hour);

      final box = Hive.box<StatModel>(ItemCode.PM10.name);

      if (box.values.isNotEmpty &&
          (box.values.last as StatModel).dataTime.isAtSameMomentAs(fetchTime)) {
        print('이미 최신 데이터가 있습니다.');
        return;
      }
      List<Future> futures = [];

      for (ItemCode itemCode in ItemCode.values) {
        futures.add(StatRepository.fetchData(itemCode: itemCode));
      }

      //이렇게 하면 한번에 기다릴 수 있음
      final result = await Future.wait(futures);

      // hive에 데이터 넣기.
      for (int i = 0; i < result.length; i++) {
        // ItemCode
        final key = ItemCode.values[i];
        // List<StatModel>
        final value = result[i];

        final box = Hive.box<StatModel>(key.name);

        for (StatModel stat in value) {
          box.put(stat.dataTime.toString(), stat);
        }

        final allKeys = box.keys.toList();

        if (allKeys.length > 24) {
          final deleteKeys = allKeys.sublist(0, allKeys.length - 24);
          box.deleteAll(deleteKeys);
        }
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인터넷 연결이 원활하지 않습니다.'),
        ),
      );
    }

    //
    // return ItemCode.values.fold<Map<ItemCode,List<StatModel>>>({}, (previousValue, itemCode) {
    //   final box = Hive.box<StatModel>(itemCode.name);
    //   previousValue.addAll({
    //     itemCode : box.values.toList()
    //   });
    //   return previousValue;
    // });
  }

  scrollListener() {
    bool isExpanded = scrollController.offset < 500 - kToolbarHeight;

    if (isExpanded != this.isExpanded) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box<StatModel>(ItemCode.PM10.name).listenable(),
        builder: (context, box, widget) {
          //PM10 (미세먼지)
          //
          if (box.values.isEmpty) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final recentStat = box.values.toList().last;

          final status = DataUtils.getStatusFromItemCodeAndValue(
            value: recentStat.getLevelFromRegion(region),
            itemCode: ItemCode.PM10,
          );

          return Scaffold(
              drawer: MainDrawer(
                darkColor: status.darkColor,
                lightColor: status.lightColor,
                selectedRegion: region,
                onRegionTap: (String region) {
                  setState(() {
                    this.region = region;
                  });
                  Navigator.of(context).pop();
                },
              ),
              body: Container(
                color: status.primaryColor,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await fetchData();
                  },
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      MainAppBar(
                        isExpanded: isExpanded,
                        region: region,
                        stat: recentStat,
                        status: status,
                        dateTime: recentStat.dataTime,
                      ),
                      // slivertobox하면 sliver하지 않은 위젯도 넣을 수 있음
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CategoryCard(
                              region: region,
                              darkColor: status.darkColor,
                              lightColor: status.lightColor,
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            //List 안에 list -> cascadeOperator
                            ...ItemCode.values.map((itemCode) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: HourlyCard(
                                    region: region,
                                    darkColor: status.darkColor,
                                    lightColor: status.lightColor,
                                    itemCode: itemCode),
                              );
                            }).toList(),
                            const SizedBox(
                              height: 16.0,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}
