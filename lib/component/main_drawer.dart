import 'package:dusty/const/regions.dart';
import 'package:flutter/material.dart';


typedef OnRegionTap = void Function(String region);

class MainDrawer extends StatelessWidget {
  final OnRegionTap onRegionTap;
  final String selectedRegion;
  final Color darkColor;
  final Color lightColor;
  MainDrawer({required this.lightColor,required this.darkColor,required this.selectedRegion,required this.onRegionTap,super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkColor,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              '지역 선택',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0
              ),
            ),
          ),
          //cascading operator ...
          ...regions.map((e) => ListTile(
            tileColor: Colors.white,
            selectedTileColor: lightColor,
            selectedColor: Colors.black,
            selected: e == selectedRegion,
            onTap: (){
              onRegionTap(e);
              //클릭 시에 드로어가 닫히게 하는 방법 1.
              // Navigator.of(context).pop();
            },
            title: Text(
              e,
            ),
          ))
        ],
      ),
    );
  }
}
