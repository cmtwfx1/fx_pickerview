import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fx_pickerview/fx_pickerview.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  final List<FxPkInfo> _cityList = [ 
      FxPkItemsInfo(id: '1', name: '浙江省', items: [
        FxPkItemsInfo(id: '11', name: '杭州市', items: [ 
          FxPkInfo(id: '111', name: '1区'),
          FxPkInfo(id: '112', name: '2区'),
          FxPkInfo(id: '113', name: '3区'),
          FxPkInfo(id: '114', name: '4区')]), 
        FxPkItemsInfo(id: '12', name: '宁波市', items: [
          FxPkInfo(id: '121', name: '5区'),
          FxPkInfo(id: '122', name: '6区')]),
        FxPkItemsInfo(id: '13', name: '金华市', items: [ 
          FxPkInfo(id: '131', name: '7区')])
      ]), 
      FxPkItemsInfo(id: '2', name: '安徽省', items: [
        FxPkItemsInfo(id: '21', name: '合肥市', items: [ 
          FxPkInfo(id: '211', name: '1区'),
          FxPkInfo(id: '212', name: '2区'),
          FxPkInfo(id: '213', name: '3区'),
          FxPkInfo(id: '214', name: '4区')]), 
        FxPkItemsInfo(id: '22', name: '芜湖市', items: [ 
          FxPkInfo(id: '221', name: '11区'),
          FxPkInfo(id: '222', name: '21区'),
          FxPkInfo(id: '223', name: '31区'),
          FxPkInfo(id: '224', name: '41区')]),
        FxPkItemsInfo(id: '23', name: '宣城市', items: [ 
          FxPkInfo(id: '231', name: '41区'),
          FxPkInfo(id: '232', name: '42区'),
          FxPkInfo(id: '233', name: '43区'),
          FxPkInfo(id: '234', name: '44区')]),
        FxPkItemsInfo(id: '24', name: '马鞍山', items: [
          FxPkInfo(id: '241', name: '61区'),
          FxPkInfo(id: '242', name: '62区'),
          FxPkInfo(id: '243', name: '63区'),
          FxPkInfo(id: '244', name: '64区')]),
        FxPkItemsInfo(id: '25', name: '黄山市', items: [
          FxPkInfo(id: '251', name: '71区'),
          FxPkInfo(id: '2511', name: '611区'),
          FxPkInfo(id: '2512', name: '612区'),
          FxPkInfo(id: '2513', name: '613区'),
          FxPkInfo(id: '2514', name: '614区'),
          FxPkInfo(id: '252', name: '72区')])
        ]), 

    ];
  final FxPickerController _fxPickerController = FxPickerController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Center(
          child: InkWell(
            child: Text('xxxx'),
            onTap: () => showPicker(context),
          )
          
        ),
      ),
    );
  }

  void showPicker(BuildContext context) {
    _fxPickerController.selectedIdOrNames = ['浙江省', '杭州市', '江干区'];
    _fxPickerController.sectionCount = 3;
    _fxPickerController.dataSource = _cityList;

    var sheetWidget = (ctx) => FxPickerView(
      title: '选择' + '地区',
      selectController: _fxPickerController,
      selectedCallBack: (selecteds) {
        Navigator.of(ctx).pop();
        debugPrint('$selecteds');
      },
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0x00ffffff),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      builder: sheetWidget
    );
  }
}
