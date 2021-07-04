import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/FileCalls.dart';
import 'package:inkling_personal/Models/FileItem.dart';
import 'package:inkling_personal/UI/Common%20Widgets/CommonWidgets.dart';
import 'package:inkling_personal/blocs/FileViewBloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  TextEditingController _searchController;
  List<FileItem> _dataList;
  Razorpay _razorpay;
  FileViewBloc _fileBloc;
  FileCalls _fileCall;
  String fileBought;
  @override
  void initState() {
    _dataList = List.empty(growable: true);
    _searchController = TextEditingController();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _paymentSuccessCallback);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _paymentErrorCallback);
    _fileBloc = BlocProvider.of<FileViewBloc>(context);
    _fileBloc.add(LoadStoreFilesEvent());
    _fileCall = FileCalls();
    fileBought = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          getSearchBox(),
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
              else if (state is StoreFilesLoaded) {
                if (state.numberOfFiles == 0 && _dataList.length == 0)
                  return getReloadFilesWidget(
                    blc: _fileBloc,
                    txt: 'No files Found. Try reloading or add files if Admin',
                    isStore: true,
                  );
                else if (state.numberOfFiles == 0 && _dataList.length != 0)
                  return Center(
                    child: Text(
                      "No such File",
                      textScaleFactor: 2,
                    ),
                  );
                else {
                  if (state.numberOfFiles > _dataList.length) {
                    _dataList.clear();
                    state.docs.forEach((f) => _dataList.add(f));
                  }
                  return getGridViewBuilder(state.docs);
                }
              } else if (state is FilesLoadingError)
                return getReloadFilesWidget(
                  blc: _fileBloc,
                  txt: 'Error Occured: ${state.error}. Try reloading',
                  isStore: true,
                );
              return getReloadFilesWidget(
                blc: _fileBloc,
                txt: 'Oopsie. Something Unexpected Happened. Try reloading',
                isStore: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getSearchBox() {
    return Padding(
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
              isStore: true,
            ));
          }),
    );
  }

  Widget getGridViewBuilder(List<FileItem> resList) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: resList.length,
      padding: EdgeInsets.symmetric(vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: ((context, index) {
        return GestureDetector(
          onTap: () {
            gestureDetectorTapHandler(fileItm: resList[index]);
          },
          child: getFileCard(resList[index]),
        );
      }),
    );
  }

  Widget getFileCard(FileItem fItm) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.blue[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 12,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                fItm.name.substring(0, fItm.name.length - 4),
                textScaleFactor: 1.3,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '₹ ${fItm.price.toString()}',
                textAlign: TextAlign.center,
                textScaleFactor: 1.2,
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              getIsBoughtWidget(isBought: fItm.isBought),
            ],
          ),
        ),
      ),
    );
  }

  Widget getIsBoughtWidget({bool isBought}) {
    Widget res = isBought
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                'Purchased',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          )
        : SizedBox.shrink();
    return res;
  }

  void gestureDetectorTapHandler({FileItem fileItm}) {
    if (fileItm.isBought)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('File Purchased'),
          content: Text(
            'File Already Purchased. Go to Home Page to access purchased Files',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      );
    else
      storeFileTapped(fileItm: fileItm);
  }

  void storeFileTapped({@required FileItem fileItm}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are You Sure?'),
        content: Text(
          'Do you want to buy ${fileItm.name} for ₹ ${fileItm.price}?',
          textScaleFactor: 1.2,
        ),
        actions: [
          TextButton(
            child: Text(
              'Yes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => getLoadingDialog(title: 'Adding File'),
              );
              await paymentGateway(fileItm: fileItm);
            },
          ),
          TextButton(
            child: Text(
              'No',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> paymentGateway({FileItem fileItm}) async {
    var rzrPayKey = dotenv.env['RZRPAY_KEY'];
    var options = {
      'key': rzrPayKey,
      'amount': fileItm.price * 100,
      'name': 'Inkling Personal',
      'description': fileItm.name,
      'prefill': {
        'contact': '8888888888',
        'email': 'test@inkling.com',
      },
    };
    try {
      fileBought = fileItm.name;
      Navigator.pop(context);
      _razorpay.open(options);
    } catch (e) {
      //debugPrint(e);
      PaymentFailureResponse(400, e.toString());
    }
  }

  void _paymentSuccessCallback(PaymentSuccessResponse resp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          "Payment Success\nOrder ID: ${resp.orderId}\nPayment ID: ${resp.paymentId}",
        ),
        actions: [
          TextButton(
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await addFileToUser();
              _fileBloc.add(LoadStoreFilesEvent());
            },
          ),
        ],
      ),
    );
  }

  void _paymentErrorCallback(PaymentFailureResponse resp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          "Payment Success\nError Code: ${resp.code}\nMessage: ${resp.message}",
        ),
        actions: [
          TextButton(
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> addFileToUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => getLoadingDialog(title: 'Adding File'),
    );
    try {
      await _fileCall.addFileToUser(fileName: fileBought);
      Navigator.pop(context);
    } catch (e) {
      //print(e);
    }
  }
}
