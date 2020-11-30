import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _FxPickerTextStyle = TextStyle(fontSize: 14, color: Color(0xFF262626));
const _FxPickerTitleStyle = TextStyle(fontSize: 16, color: Color(0xFF262626));
const _FxPickerCanCelStyle = TextStyle(fontSize: 14, color: Color(0xFF8C8C8C));
const _FxPickerSureStyle = TextStyle(fontSize: 14, color: Color(0xFF726FFF));

class FxPkInfo {
  final String id;
  final String name;

  /// [id] 唯一标识
  /// [name] 显示的名称
  FxPkInfo({
    this.id,
    this.name
  });
}

class FxPkItemsInfo extends FxPkInfo {
  final List<FxPkInfo> items;

  /// [items] 对应的二级数据源，比如省下面的市
  FxPkItemsInfo({
    String id,
    String name,
    List<FxPkInfo> items
  }) :  items = items ?? [],
        super(id: id, name: name);
}

/* -------------------------------------分割线----------------------------------------*/

class FxPickerController {
  int _sectionCount;
  List<String> _initSelectedIdOrNames;

  List<FixedExtentScrollController> pickerScrollControllers = [];
  List<FxPkInfo> _dataSource;
  List<FxPkInfo> _currentSelecteds = [];

  List<FxPkInfo> _selectedOnes = [];
  List<FxPkInfo> _selectedTwos = [];
  List<FxPkInfo> _selectedThrees = [];
  List<FxPkInfo> _selectedFour = [];

  /// [sectionCount] 指定 FxPickerView 多少列，默认1列，省市区则为3列，最大4列
  /// [defSelectedIdOrNames] 指定默认选中的行，提供id或者name去判断 ['id1', 'id2', 'id3']
  FxPickerController({
    int sectionCount,
    List<String> defSelectedIdOrNames,
  }) : assert(sectionCount == null || (sectionCount < 5 && sectionCount > 0), '支持最少1和最大5'),
      _initSelectedIdOrNames = defSelectedIdOrNames ?? []
  {
    if (sectionCount != null){
      sectionCount = sectionCount;
    }
  }

  int get sectionCount {
    return _sectionCount;
  }

  set selectedIdOrNames(List<String> list) {
    _initSelectedIdOrNames = list;
  }

  set sectionCount(int count) {
    _sectionCount = count;
    for (int i=_initSelectedIdOrNames.length; i<count; i++) {
      _initSelectedIdOrNames.add('###');
    }
    pickerScrollControllers.clear();
    // for (int i=0; i<count; i++) {
    //   pickerScrollControllers.add(FixedExtentScrollController());
    // }
  }

  set dataSource(List<FxPkInfo> list) {
    _dataSource = list;
    _currentSelecteds.clear();
    _selectIndexsStep1(_initSelectedIdOrNames, 0, _dataSource);
  }

  // 选择回调
  void selectedCallBack(List<FxPkInfo> selecteds)  {
    // value = selecteds;
  }

  void _addCurrentSelected(FxPkInfo pickerInfo) {
    _currentSelecteds.add(pickerInfo);
    if (_currentSelecteds.length == 1) {
      _selectedOnes = _dataSource;
    }else if (_currentSelecteds.length == 2) {
      _selectedTwos = (_currentSelecteds[0] as FxPkItemsInfo).items;
    }else if (_currentSelecteds.length == 3) {
      _selectedThrees = (_currentSelecteds[1] as FxPkItemsInfo).items;
    }else if (_currentSelecteds.length == 4) {
      _selectedFour = (_currentSelecteds[2] as FxPkItemsInfo).items;
    }
  }

  void _selectIndexsStep1(List<String> list, int index, List<FxPkInfo> data) {
    assert(list.length == this.sectionCount, '数据源列表count 与 sectionCount 不相等');
    bool isExit = false;

    for (FxPkInfo info in data) {
      if (info.id == list[index] || info.name == list[index]) {
        isExit = true;
        pickerScrollControllers.add(FixedExtentScrollController(initialItem: data.indexOf(info)));
        _addCurrentSelected(info);
        if (index == list.length - 1) {
          break;
        }
        if (info is FxPkItemsInfo) {
          _selectIndexsStep1(list, index+1, info.items);
        }else {
          assert(false, '类型错误');
        }
        break;
      }
    }
    if (isExit) return;
    _selectIndexsStep2(list, index, data);
  }

  void _selectIndexsStep2(List<String> list, int index, List<FxPkInfo> data) {
    FxPkInfo info = data.first;
    pickerScrollControllers.add(FixedExtentScrollController(initialItem: 0));
    _addCurrentSelected(info);

    if (index == list.length - 1) {
        return;
    }
    if (info is FxPkItemsInfo) {
      _selectIndexsStep1(list, index+1, info.items);
    }else {
      assert(false, '类型错误');
    }
  }

  void _updateSelectIndexs() {
    for (int i=0; i<_currentSelecteds.length; i++) {
      FxPkInfo info = _currentSelecteds[i];
      if (i == 0) {
        int index =_dataSource.indexOf(info);
        pickerScrollControllers[0] = FixedExtentScrollController(initialItem: index);
      }else if (i == 1) {
        int index = (_currentSelecteds[0] as FxPkItemsInfo).items.indexOf(info);
        pickerScrollControllers[1] = FixedExtentScrollController(initialItem: index);
      }else if (i == 2) {
        int index = (_currentSelecteds[1] as FxPkItemsInfo).items.indexOf(info);
        pickerScrollControllers[2] = FixedExtentScrollController(initialItem: index);
      }else if (i == 3) {
        int index = (_currentSelecteds[2] as FxPkItemsInfo).items.indexOf(info);
        pickerScrollControllers[3] = FixedExtentScrollController(initialItem: index);
      }
    }
  }
}


/* -------------------------------------分割线----------------------------------------*/

class _FxLinkPickerView extends StatelessWidget {
  final FixedExtentScrollController fixedExtentScrollController;
  final List<FxPkInfo> data;
  final void Function(FxPkInfo pickerInfo) pickerCallback;

  _FxLinkPickerView({
    Key key,
    this.fixedExtentScrollController,
    this.data,
    this.pickerCallback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
        scrollController: fixedExtentScrollController,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              data[index].name,
              style: _FxPickerTextStyle,
            ),
          );
        },
        onSelectedItemChanged: (index) {
          pickerCallback(data[index]);
        },
        itemExtent: 50,
        childCount: data.length,
        backgroundColor: Colors.white,
      );
  }
}

/* -------------------------------------分割线----------------------------------------*/

class FxPickerView extends StatefulWidget {

  final String title;
  final FxPickerController selectController;
  final void Function(List<FxPkInfo> selecteds) selectedCallBack;

  /// [title] 选择器的标题
  /// [selectController] 控制器（提供数据源，提供外部控制选中行）
  /// [selectedCallBack] 选中回调
  FxPickerView({
    Key key,
    this.title,
    @required this.selectedCallBack,
    @required this.selectController
  }) : super(key: key);

  @override
  _FxPickerViewState createState() => _FxPickerViewState();
}

class _FxPickerViewState extends State<FxPickerView> {
  Widget header() {
    return Container(
      height: 60,
      child: Row(
        children: [
          CupertinoButton(
            child: Text(
              '取消',
              style: _FxPickerCanCelStyle,
            ),
            onPressed: ()  {
              widget.selectedCallBack([]);
            }
          ),
          Expanded(
            child: Text(
              widget.title,
              style: _FxPickerTitleStyle,
              textAlign: TextAlign.center,
            ),
          ),
          CupertinoButton(
            child: Text(
              '确定',
              style: _FxPickerSureStyle,
            ),
            onPressed: () {
              widget.selectedCallBack(widget.selectController._currentSelecteds);
              widget.selectController._updateSelectIndexs();
            },
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 0.5)),
        color: Colors.white
      ),
    );
  }

  Widget content() {
    List<Widget> pickers = [];
    for (int i=0; i<widget.selectController.sectionCount; i++) {
      if (i == 0) {
        pickers.add(Flexible(
          child: _FxLinkPickerView(
            key: Key('Fx_pickerview_0'),
            data: widget.selectController._selectedOnes,
            fixedExtentScrollController: widget.selectController.pickerScrollControllers[0],
            pickerCallback: (pickerInfo) {
              widget.selectController._currentSelecteds[0] = pickerInfo;
              // 修改 二级 列表当前选中为 第一行
              if (widget.selectController.sectionCount > 1) {
                setState(() {
                  widget.selectController._selectedTwos = (pickerInfo as FxPkItemsInfo).items;
                  widget.selectController.pickerScrollControllers[1].jumpToItem(0);
                });
                widget.selectController._currentSelecteds[1] = (pickerInfo as FxPkItemsInfo).items[0];
              }
              // 修改 三级 列表当前选中为 第一行
              if (widget.selectController.sectionCount > 2) {
                FxPkInfo nextPickerInfo = widget.selectController._currentSelecteds[1];
                setState(() {
                  widget.selectController._selectedThrees = (nextPickerInfo as FxPkItemsInfo).items;
                  widget.selectController.pickerScrollControllers[2].jumpToItem(0);
                });
                widget.selectController._currentSelecteds[2] = (nextPickerInfo as FxPkItemsInfo).items[0];
              }
              // 修改 四级 列表当前选中为 第一行
              if (widget.selectController.sectionCount > 3) {
                FxPkInfo nextPickerInfo = widget.selectController._currentSelecteds[2];
                setState(() {
                  widget.selectController._selectedFour = (nextPickerInfo as FxPkItemsInfo).items;
                  widget.selectController.pickerScrollControllers[3].jumpToItem(0);
                });
                widget.selectController._currentSelecteds[3] = (nextPickerInfo as FxPkItemsInfo).items[0];
              }
            },
          ),
        ));
      }else if (i == 1) {
        pickers.add(Flexible(
          child: _FxLinkPickerView(
            key: Key('Fx_pickerview_1'),
            data: widget.selectController._selectedTwos,
            fixedExtentScrollController: widget.selectController.pickerScrollControllers[1],
            pickerCallback: (pickerInfo) {
              widget.selectController._currentSelecteds[1] = pickerInfo;
              // 修改 三级 列表当前选中为 第一行
              if (widget.selectController.sectionCount > 2) {
                setState(() {
                  widget.selectController._selectedThrees = (pickerInfo as FxPkItemsInfo).items;
                  widget.selectController.pickerScrollControllers[2].jumpToItem(0);
                });
                widget.selectController._currentSelecteds[2] = (pickerInfo as FxPkItemsInfo).items[0];
              }
              // 修改 四级 列表当前选中为 第一行
              if (widget.selectController.sectionCount > 3) {
                FxPkInfo nextPickerInfo = widget.selectController._currentSelecteds[2];
                setState(() {
                  widget.selectController._selectedFour = (nextPickerInfo as FxPkItemsInfo).items;
                  widget.selectController.pickerScrollControllers[3].jumpToItem(0);
                });
                widget.selectController._currentSelecteds[3] = (nextPickerInfo as FxPkItemsInfo).items[0];
              }
            },
          ),
        ));
      }else if (i == 2) {
        pickers.add(Flexible(
          child:_FxLinkPickerView(
            key: Key('Fx_pickerview_2'),
            data: widget.selectController._selectedThrees,
            fixedExtentScrollController: widget.selectController.pickerScrollControllers[2],
            pickerCallback: (pickerInfo) {
              widget.selectController._currentSelecteds[2] = pickerInfo;
              // 修改 四级 列表当前选中为 第一行
              if (widget.selectController.sectionCount > 3) {
                setState(() {
                  widget.selectController._selectedFour = (pickerInfo as FxPkItemsInfo).items;
                  widget.selectController.pickerScrollControllers[3].jumpToItem(0);
                });
                widget.selectController._currentSelecteds[3] = (pickerInfo as FxPkItemsInfo).items[0];
              }
            },
          ),
        ));
      }else if (i == 3) {
        pickers.add(Flexible(
          child:_FxLinkPickerView(
            key: Key('Fx_pickerview_3'),
            data: widget.selectController._selectedFour,
            fixedExtentScrollController: widget.selectController.pickerScrollControllers[3],
            pickerCallback: (pickerInfo) {
              widget.selectController._currentSelecteds[3] = pickerInfo;
            },
          ),
        ));
      }else {
        assert(i < 4, '超出限制');
      }
    }
    return Row(
      children: pickers
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            child: header(),
          ),
          Flexible(
            child: content(),
          )
        ],
      ),
    );
  }
}