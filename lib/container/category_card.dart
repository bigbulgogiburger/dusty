import 'package:dusty/component/card_title.dart';
import 'package:dusty/component/main_card.dart';
import 'package:dusty/component/main_stat.dart';
import 'package:dusty/const/colors.dart';
import 'package:dusty/model/stat_and_status_model.dart';
import 'package:dusty/model/stat_model.dart';
import 'package:dusty/utils/data_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryCard extends StatelessWidget {
  final String region;
  final Color darkColor;
  final Color lightColor;

  const CategoryCard(
      {required this.darkColor, required this.lightColor, required this.region, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: MainCard(
        backgroundColor: lightColor,
        child: LayoutBuilder(builder: (context, constraint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                backgroundColor: darkColor,
                title: '종류별 통계',
              ),
              //Column 안에서 ListView는 무조건 Expanded를 넣어야 한다.
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: PageScrollPhysics(),
                  children: ItemCode.values.map(
                          (ItemCode itemCode) =>
                          ValueListenableBuilder<Box>(
                              valueListenable: Hive.box<StatModel>(
                                  itemCode.name).listenable(),
                              builder: (context, box, widget) {
                                final stat = box.values
                                    .toList()
                                    .last as StatModel;
                                final status = DataUtils
                                    .getStatusFromItemCodeAndValue(
                                    value: stat.getLevelFromRegion(region),
                                    itemCode: itemCode);
                                return MainStat(
                                    category: DataUtils.getItemCodeKrString(
                                        itemCode: itemCode),
                                    imgPath: status.imagePath,
                                    level: status.label,
                                    stat:
                                    '${stat.getLevelFromRegion(
                                        region)}${DataUtils
                                        .getUnitFromItemCode(
                                        itemCode: itemCode)}',
                                    width: constraint.maxWidth / 3);
                              }))
                      .toList(),
                  // List.generate(
                  //   20,
                  //   (index) => MainStat(
                  //     category: '미세먼지${index + 1}',
                  //     imgPath: 'asset/img/best.png',
                  //     level: '최고',
                  //     stat: '0㎍/㎥',
                  //     width: (constraint.maxWidth / 3),
                  //   ),
                  // ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
