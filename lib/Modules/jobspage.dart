import 'dart:convert';
import 'dart:io';
import 'package:connect/DataModels/jobs.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class JobsPage extends StatefulWidget {
  @override
  JobsPageState createState() {
    return new JobsPageState();
  }
}

class JobsPageState extends State<JobsPage> {
  List<Jobs> posts = List<Jobs>();
  List<Jobs> filteredWordsList = List<Jobs>();
  FocusNode _focusNode;
  TextEditingController _textFieldController = new TextEditingController();
  bool isSearching = false;
  ScrollController _rrectController = ScrollController();

  @override
  void initState() {
    _focusNode = FocusNode();
    //getdData();
    load();
    isSearching = false;
    super.initState();
  }

  load() async {
    String url = "https://spmconnect.localtunnel.me/api/jobs";
    var res = await http.get(url);
    if (res.statusCode == HttpStatus.ok) {
      List data = json.decode(res.body);
      for (var i = 0; i < data.length; i++) {
        posts.add(Jobs.fromJson(data[i]));
      }
      print(posts[0].jobNumber);
      setState(() {
        filteredWordsList = posts;
      });
      return posts;
    }
  }

  Future<List> getdData() async {
    var httpClient = new HttpClient();
    var request = await httpClient.get("192.168.199.241", 8080, '/api/jobs');
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      var jsonString = await response.transform(utf8.decoder).join();
      List data = json.decode(jsonString);
      for (var i = 0; i < data.length; i++) {
        posts.add(Jobs.fromJson(data[i]));
      }

      //posts = json.decode(jsonString);

      print(posts[0].jobNumber);
      setState(() {
        filteredWordsList = posts;
      });
      return posts;
    } else {
      setState(() {});
      return posts;
    }
  }

  Widget appBarTitle = new Text(
    "SPM Connect Jobs",
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );

  void _handleSearchStart() {
    setState(() {
      isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "SPM Connect Jobs",
        style: new TextStyle(color: Colors.white),
      );
      isSearching = false;
      _textFieldController.clear();
      filteredWordsList = posts;
    });
  }

  void _onSearch(value) {
    setState(() {
      filteredWordsList = posts
          .where((item) => item.fullSearch
              .toString()
              .toLowerCase()
              .contains('$value'.toLowerCase()))
          .toList();
    });
  }

  Widget buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      backgroundColor: Colors.cyan,
      title: appBarTitle,
      actions: <Widget>[
        isSearching
            ? Container()
            : IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    posts.clear();
                    filteredWordsList.clear();
                  });
                  getdData();
                },
              ),
        IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(
                  Icons.close,
                  color: Colors.white,
                );
                this.appBarTitle = new TextField(
                  focusNode: _focusNode,
                  autofocus: true,
                  controller: _textFieldController,
                  onChanged: _onSearch,
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  decoration: new InputDecoration(
                    prefixIcon: new Icon(Icons.search, color: Colors.white),
                    hintText: "Search...",
                    hintStyle: new TextStyle(color: Colors.white),
                  ),
                );
                _rrectController.animateTo(
                  0.0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );

                _handleSearchStart();
                FocusScope.of(context).requestFocus(_focusNode);
              } else {
                _handleSearchEnd();
              }
            });
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.pop(context);
        },
      ),
    );
  }

  final _itemExtent = 100.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildBar(context),
      body: filteredWordsList.length > 0
          ? DraggableScrollbar.arrows(
              alwaysVisibleScrollThumb: false,
              backgroundColor: Colors.grey[850],
              padding: EdgeInsets.only(right: 4.0),
              labelTextBuilder: (double offset) {
                final int currentItem = offset ~/ 100;
                var letter = currentItem <= filteredWordsList.length - 1
                    ? filteredWordsList[currentItem].jobNumber
                    : filteredWordsList[currentItem].jobNumber;
                return Text(
                  "$letter",
                  style: TextStyle(color: Colors.white),
                );
              },
              controller: _rrectController,
              child: ListView.builder(
                controller: _rrectController,
                itemCount: filteredWordsList.length,
                itemExtent: _itemExtent,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.cyan[index % 9 * 100],
                      child: Center(
                          child: ListTile(
                        // subtitle: Text(
                        //     '${filteredWordsList[index].jobNumber} - ${filteredWordsList[index].description}'),
                        title: Text(
                            '${filteredWordsList[index].jobNumber} - ${filteredWordsList[index].description}'),
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ItemDetail(
                          //               item: filteredWordsList[index],
                          //             )));
                        },
                      )),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
