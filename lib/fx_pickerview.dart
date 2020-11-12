import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _FXPickerTextStyle = TextStyle(fontSize: 14, color: Color(0xFF262626));

class FxPkInfo {
  final String id;
  final String name;

  FxPkInfo({
    this.id,
    this.name
  });
}

class FxPkItemsInfo extends FxPkInfo {
  final List<FxPkInfo> items;

  FxPkItemsInfo({
    String id,
    String name,
    List<FxPkInfo> items
  }) :  items = items ?? [],
        super(id: id, name: name);
}

/* -------------------------------------分割线----------------------------------------*/

class FxPickerController {
  final int sectionCount;
  List<String> _initSelectedIdOrNames;

  List<FixedExtentScrollController> pickerScrollControllers = [];
  List<FxPkInfo> _dataSource;
  List<FxPkInfo> _currentSelecteds = [];

  List<FxPkInfo> _selectedOnes = [];
  List<FxPkInfo> _selectedTwos = [];
  List<FxPkInfo> _selectedThrees = [];
  List<FxPkInfo> _selectedFour = [];

  FxPickerController({
    this.sectionCount = 1,
    List<String> defSelectedIdOrNames,
  }) : assert(sectionCount < 5 && sectionCount > 0),
      _initSelectedIdOrNames = defSelectedIdOrNames ?? []
  {
    defSelectedIdOrNames = _initSelectedIdOrNames;
    for (int i=defSelectedIdOrNames.length; i<sectionCount; i++) {
      _initSelectedIdOrNames.add('###');
    }
  }

  set dataSource(List<FxPkInfo> list) {
    _dataSource = list;
    _currentSelecteds.clear();
    _selectIndexsStep1(_initSelectedIdOrNames, 0, _dataSource);
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
    assert(list.length == this.sectionCount);
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
          print('类型错误');
          assert(false);
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
      print('类型错误');
      assert(false);
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

  const _FxLinkPickerView({
    Key key,
    this.fixedExtentScrollController,
    this.data,
    this.pickerCallback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  CupertinoPicker.builder(
        scrollController: fixedExtentScrollController,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              data[index].name,
              style: _FXPickerTextStyle,
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

class FxBottomPickerView extends StatefulWidget {

  final String title;
  final FxPickerController selectController;
  final void Function(List<FxPkInfo> selecteds) selectedCallBack;

  FxBottomPickerView({
    Key key,
    this.title,
    @required this.selectedCallBack,
    @required this.selectController
  }) : super(key: key);

  @override
  _FxBottomPickerViewState createState() => _FxBottomPickerViewState(
    title: title,
    selectedCallBack: selectedCallBack,
    selectController: selectController
  );
}

class _FxBottomPickerViewState extends State<FxBottomPickerView> {

  final String title;
  final FxPickerController selectController;
  final void Function(List<FxPkInfo> selecteds) selectedCallBack;

  _FxBottomPickerViewState({
    this.title,
    this.selectedCallBack,
    this.selectController
  });

  Widget header() {
    return Container(
      height: 60,
      child: Row(
        children: [
          CupertinoButton(
            child: Text(
              '取消',
              style: TextStyle(fontSize: 14, color: Color(0xFF8C8C8C)),
            ),
            onPressed: ()  {
              selectedCallBack([]);
            }
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: Color(0xFF262626)),
              textAlign: TextAlign.center,
            ),
          ),
          CupertinoButton(
            child: Text(
              '确定',
              style: TextStyle(fontSize: 14, color: Color(0xFF726FFF)),
            ),
            onPressed: () {
              selectedCallBack(selectController._currentSelecteds);
              selectController._updateSelectIndexs();
            },
          ),
        ],
      ),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 0.5))
      ),
    );
  }

  Widget content() {
    List<Widget> pickers = [];
    for (int i=0; i<selectController.sectionCount; i++) {
      if (i == 0) {
        pickers.add(Flexible(
          child: _FxLinkPickerView(
            data: selectController._selectedOnes,
            fixedExtentScrollController: selectController.pickerScrollControllers[0],
            pickerCallback: (pickerInfo) {
              selectController._currentSelecteds[0] = pickerInfo;
              if (selectController.sectionCount > 1) {
                setState(() {
                  selectController._selectedTwos = (pickerInfo as FxPkItemsInfo).items;
                  selectController.pickerScrollControllers[1].jumpToItem(0);
                });
              }
            },
          ),
        ));
      }else if (i == 1) {
        pickers.add(Flexible(
          child: _FxLinkPickerView(
            data: selectController._selectedTwos,
            fixedExtentScrollController: selectController.pickerScrollControllers[1],
            pickerCallback: (pickerInfo) {
              selectController._currentSelecteds[1] = pickerInfo;
              if (selectController.sectionCount > 2) {
                setState(() {
                  selectController._selectedThrees = (pickerInfo as FxPkItemsInfo).items;
                  selectController.pickerScrollControllers[2].jumpToItem(0);
                });
              }
            },
          ),
        ));
      }else if (i == 2) {
        pickers.add(Flexible(
          child:_FxLinkPickerView(
            data: selectController._selectedThrees,
            fixedExtentScrollController: selectController.pickerScrollControllers[2],
            pickerCallback: (pickerInfo) {
              selectController._currentSelecteds[2] = pickerInfo;
              if (selectController.sectionCount > 3) {
                setState(() {
                  selectController._selectedFour = (pickerInfo as FxPkItemsInfo).items;
                  selectController.pickerScrollControllers[3].jumpToItem(0);
                });
              }
            },
          ),
        ));
      }else if (i == 3) {
        pickers.add(Flexible(
          child:_FxLinkPickerView(
            data: selectController._selectedFour,
            fixedExtentScrollController: selectController.pickerScrollControllers[3],
            pickerCallback: (pickerInfo) {
              selectController._currentSelecteds[3] = pickerInfo;
            },
          ),
        ));
      }else {
        print('超出限制');
        assert(i < 4);
      }
    }
    return Row(
      children: pickers
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.5)
            ),
          ),
        ),
        Container(
          child: header(),
          decoration: BoxDecoration(
            color: Colors.white
          ),
        ),
        Flexible(
          child: content(),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }
}