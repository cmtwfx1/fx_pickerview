# fx_pickerview

A new Flutter package project.

效果：
![](https://worldruning.com/post-images/1605152779281.png)

## 1：布局说明
#### 1.1：FxPickerView 多级联动的PickerView
```
  /// [title] 选择器的标题
  /// [selectController] 控制器（提供数据源，提供外部控制选中行）
  /// [selectedCallBack] 选中回调
  FxPickerView({
    Key key,
    this.title,
    @required this.selectedCallBack,
    @required this.selectController
  }) : super(key: key);
```
#### 1.2：FxPickerController 提供数据源，外部控制api

* 数据源说明：
`FxPkInfo`：每个可滚动的`item`对象
```
  /// [id] 唯一标识
  /// [name] 显示的名称
  FxPkInfo({
    this.id,
    this.name
  });
```
* 数据源说明：
`FxPkItemsInfo`：包含第二级列表的数据源，为了实现联动效果，比如省后面包含市，需要在 `items`中设置省对应的市的数据源
```
  /// [items] 对应的二级数据源，比如省下面的市
  FxPkItemsInfo({
    String id,
    String name,
    List<FxPkInfo> items
  }) :  items = items ?? [],
        super(id: id, name: name);
```

`FxPickerController` 提供 `dataSource` 设置`FxPickerView`的数据源，`pickerScrollControllers`保存了每列的控制器，外部可以获取控制器去控制`FxPickerView`的选择行

```
  /// [sectionCount] 指定 FxPickerView 多少列，默认1列，省市区则为3列，最大4列
  /// [defSelectedIdOrNames] 指定默认选中的行，提供id或者name去判断 ['id1', 'id2', 'id3']
  FxPickerController({
    this.sectionCount = 1,
    List<String> defSelectedIdOrNames,
  }) : assert(sectionCount < 5 && sectionCount > 0),
      _initSelectedIdOrNames = defSelectedIdOrNames ?? []
```

支持使用一个 `FxPickerController` 动态显示不同的选择器，如下修改数据源即可：
```
  _FxPickerController.selectedIdOrNames = ['浙江省', '杭州市', '江干区'];
  _FxPickerController.sectionCount = 3;
  _FxPickerController.dataSource = _cityList;
```

## 2：使用事列

#### 2.1：布局参考

底部弹出的布局，需要使用`Stack`来实现图层覆盖，`Offstage`控制弹框的显示与隐藏
```
void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  final List<FxPkInfo> _cityList = []; // 数据源参 2.2
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
```
#### 2.2：数据源参考

* 注意：
sectionCount 指定显示多少列与数据源定义的结构一致; 
defSelectedIdOrNames 可传，指定默认选中的行
FxPkItemsInfo 结构表示 存在 二级 数据源
FxPkInfo 结构表示 不存在二级 数据源

数据源定义如下：
```
[ 
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
```
项目路径：<https://github.com/cmtwfx1/fx_pickerview.git>
