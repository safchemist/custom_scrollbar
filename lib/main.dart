import 'package:custom_scrollbar/components/custom_scrollbar.dart';
import 'package:custom_scrollbar/components/list_item.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: ScrollbarExample(),
    );
  }
}

class ScrollbarExample extends StatefulWidget {
  @override
  _ScrollbarExampleState createState() => _ScrollbarExampleState();
}

class _ScrollbarExampleState extends State<ScrollbarExample> {
  final items = [];
  final scrollController = ScrollController();
  final smallListSize = 5;
  final bigListSize = 20;
  final floatButtonTooltip = 'Modify list';

  @override
  void initState() {
    _generateItems(n: bigListSize);
    super.initState();
  }

  void _generateItems({required int n}) {
    items.clear();
    for (var i = 0; i < n; i++) {
      items.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Icon(
          Icons.circle,
          color: Colors.purple.withOpacity(0.3),
        ),
      ),
      body: CustomScrollbar(
        controller: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var item = items[index];
                  return ListItem(item: item);
                },
                childCount: items.length,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFloatButtonAction,
        tooltip: floatButtonTooltip,
        child: _getFloatButtonIcon(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onFloatButtonAction() {
    items.length > smallListSize
        ? _modifyList(n: smallListSize)
        : _modifyList(n: bigListSize);
  }

  Icon _getFloatButtonIcon() {
    return items.length > smallListSize ? Icon(Icons.cut) : Icon(Icons.add);
  }

  void _modifyList({required int n}) {
    setState(() {
      _generateItems(n: n);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
