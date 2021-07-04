import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/FileCalls.dart';
import 'package:inkling_personal/Models/FileItem.dart';
import 'package:inkling_personal/UI/Common%20Widgets/CommonWidgets.dart';
import 'package:inkling_personal/UI/PDFPage.dart';
import 'package:inkling_personal/blocs/FileViewBloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController;
  List<FileItem> _dataList;
  FileCalls _fileCall;
  FileViewBloc _fileBloc;
  @override
  void initState() {
    _dataList = List.empty(growable: true);
    _searchController = TextEditingController();
    _fileCall = FileCalls();
    _fileBloc = BlocProvider.of<FileViewBloc>(context);
    _fileBloc.add(LoadUserFilesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
            child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: "Search",
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.blue[800],
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.blue[800],
                    ),
                    onPressed: () => _searchController.clear(),
                  ),
                ),
                onChanged: (qry) {
                  //print("Query: $qry");
                  _fileBloc.add(FilterFilesEvent(
                    docs: _dataList,
                    query: qry,
                    isStore: false,
                  ));
                }),
          ),
          BlocBuilder<FileViewBloc, FileViewState>(
            bloc: _fileBloc,
            builder: (context, state) {
              if (state is FilesLoading)
                return Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 7,
                      color: Colors.amber,
                    ),
                  ),
                );
              else if (state is UserFilesLoaded) {
                if (state.numberOfFiles == 0 && _dataList.isEmpty)
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: getReloadFilesWidget(
                      blc: _fileBloc,
                      txt:
                          'No files Found. Try reloading or adding files if Admin',
                      isStore: false,
                    ),
                  );
                else if (state.numberOfFiles == 0 && _dataList.isNotEmpty)
                  return Center(
                    child: Text(
                      "No such File",
                      textScaleFactor: 2,
                    ),
                  );
                else {
                  if (state.numberOfFiles > _dataList.length) {
                    _dataList.clear();
                    state.fileNames.forEach(
                      (f) => _dataList.add(FileItem(name: f)),
                    );
                  }
                  return getGridViewBuilder(state);
                }
              } else if (state is FilesLoadingError)
                return getReloadFilesWidget(
                  blc: _fileBloc,
                  txt: 'Error Occured: ${state.error}. Try reloading',
                  isStore: false,
                );
              return getReloadFilesWidget(
                blc: _fileBloc,
                txt: 'Oopsie. Something Unexpected Happened. Try reloading',
                isStore: false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getGridViewBuilder(UserFilesLoaded state) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: state.numberOfFiles,
      padding: EdgeInsets.symmetric(vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => fileTapped(state.fileNames[index]),
          child: getFileCard(state.fileNames[index]),
        );
      },
    );
  }

  void fileTapped(String fileName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => getLoadingDialog(),
    );
    String fileUrl = await getFileUrl(fileName: fileName);
    Navigator.pop(context);
    if (fileUrl != 'error')
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFPage(
            url: fileUrl,
            name: fileName,
          ),
        ),
      );
  }

  Widget getFileCard(String fileName) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset('assets/images/book.png'),
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                fileName,
                textScaleFactor: 1.5,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getFileUrl({@required String fileName}) async {
    try {
      return await _fileCall.getPDFFile(fileName: fileName);
    } catch (err) {
      showDialog(
        context: context,
        builder: (context) => getErrorDialog(
          context: context,
          title: 'File Loading Error',
          msg: err.toString(),
        ),
      );
    }
    return 'error';
  }
}
