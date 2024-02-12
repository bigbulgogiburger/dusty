import 'package:dusty/component/category_card.dart';
import 'package:dusty/component/hourly_card.dart';
import 'package:dusty/component/main_app_bar.dart';
import 'package:dusty/component/main_drawer.dart';
import 'package:dusty/const/colors.dart';
import 'package:dusty/const/regions.dart';
import 'package:dusty/model/stat_and_status_model.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/repository/stat_repository.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';

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
  void initState(){
    super.initState();
    scrollController.addListener(scrollListener);
  }


  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }
  @override
  Future<Map<ItemCode, List<StatModel>>> fetchData() async {
    Map<ItemCode, List<StatModel>> stats = {};

    List<Future> futures = [];

    for (ItemCode itemCode in ItemCode.values) {
      futures.add(StatRepository.fetchData(itemCode: itemCode));
    }

    //이렇게 하면 한번에 기다릴 수 있음
    final result = await Future.wait(futures);
    for (int i = 0; i < result.length; i++) {
      final key = ItemCode.values[i];
      final value = result[i];
      stats.addAll({key: value});
    }

    return stats;
  }

  scrollListener(){
    bool isExpanded = scrollController.offset <500 -kToolbarHeight;

    if(isExpanded != this.isExpanded){
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<ItemCode, List<StatModel>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('에러가 있습니다.'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          Map<ItemCode, List<StatModel>> stats = snapshot.data!;
          StatModel pm10RecentStat = stats[ItemCode.PM10]![0];

          // 1 - 5, 6 - 10, 11 - 15
          // 7
          // 미세먼지 최근 데이터
          final status = DataUtils.getStatusFromItemCodeAndValue(
              value: pm10RecentStat.seoul, itemCode: ItemCode.PM10);

          final ssModel = stats.keys.map((key) {
            final value = stats[key];
            final stat = value![0];
            return StatAndStatusModel(
                itemCode: key,
                status: DataUtils.getStatusFromItemCodeAndValue(
                    value: stat.getLevelFromRegion(region), itemCode: key),
                stat: stat);
          }).toList();
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
              body:Container(
                color: status.primaryColor,
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    MainAppBar(
                      isExpanded: isExpanded,
                      region: region,
                      stat: pm10RecentStat,
                      status: status,
                      dateTime: pm10RecentStat.dataTime,
                    ),
                    // slivertobox하면 sliver하지 않은 위젯도 넣을 수 있음
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CategoryCard(
                            models: ssModel,
                            region: region,
                            darkColor: status.darkColor,
                            lightColor: status.lightColor,
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          //List 안에 list -> cascadeOperator
                          ...stats.keys.map((itemCode) {
                            final stat = stats[itemCode]!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: HourlyCard(
                                category: DataUtils.getItemCodeKrString(itemCode: itemCode),
                                stats: stat!,
                                region: region,
                                darkColor: status.darkColor,
                                lightColor: status.lightColor,
                              ),
                            );}).toList(),
                          const SizedBox(
                            height: 16.0,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          );
        });
  }
}
