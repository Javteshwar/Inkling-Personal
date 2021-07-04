import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/AuthCalls.dart';
import 'package:inkling_personal/Models/BottomNavBarItem.dart';
import 'package:inkling_personal/UI/AddFilePage.dart';
import 'package:inkling_personal/UI/Common%20Widgets/CommonWidgets.dart';
import 'package:inkling_personal/UI/HomePage.dart';
import 'package:inkling_personal/UI/StorePage.dart';
import 'package:inkling_personal/UI/UpgradeAccountPage.dart';
import 'package:inkling_personal/blocs/AuthenticationBloc.dart';
import 'package:inkling_personal/blocs/FileViewBloc.dart';

class HomeController extends StatefulWidget {
  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  bool _isAdmin;
  List<CustomBottomNavBarItem> _appBarItems;
  int _pageController;
  AuthorizationCalls _authCall;
  AuthenticationBloc _authBloc;
  FileViewBloc _fileBloc;
  bool _isLoading;
  @override
  void initState() {
    _authCall = AuthorizationCalls();
    _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _appBarItems = List.empty(growable: true);
    _isAdmin = false;
    _isLoading = true;
    _pageController = 0;
    _authCall.getUserDetails().then((dta) {
      _isAdmin = dta['isAdmin'];
      getAppBarItems();
      _isLoading = false;
      setState(() {});
    });
    _fileBloc = FileViewBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            backgroundColor: Colors.blueGrey,
            body: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  color: Colors.amber,
                  strokeWidth: 7,
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.blueGrey,
            appBar: AppBar(
              title: Text(
                _appBarItems[_pageController].label,
                textScaleFactor: 1.5,
              ),
              backgroundColor: _appBarItems[_pageController].backgroundColor,
              elevation: 12,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  if (_pageController == 0)
                    _fileBloc.add(LoadUserFilesEvent());
                  else if (_pageController == 1)
                    _fileBloc.add(LoadStoreFilesEvent());
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => getUserDetailsDialog(),
                  ),
                ),
              ],
            ),
            body: BlocProvider(
              create: (context) => _fileBloc,
              child: getBodyPage(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _pageController,
              items: _appBarItems.map((x) {
                return BottomNavigationBarItem(
                  label: x.label,
                  icon: x.icon,
                  backgroundColor: x.backgroundColor,
                );
              }).toList(),
              onTap: (value) {
                setState(() {
                  _pageController = value;
                });
              },
            ),
          );
  }

  Widget getUserDetailsDialog() {
    return AlertDialog(
      title: Text('Profile'),
      backgroundColor: Colors.blue[800],
      content: FutureBuilder(
        future: _authCall.getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Email: ${snapshot.data['email']}',
                  textScaleFactor: 1.3,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      snapshot.data['isAdmin']
                          ? Icons.admin_panel_settings
                          : Icons.account_circle,
                    ),
                    SizedBox(width: 8),
                    Text(
                      snapshot.data['isAdmin']
                          ? 'Administrator'
                          : 'Standard User',
                      textScaleFactor: 1.2,
                    ),
                  ],
                )
              ],
            );
          } else if (snapshot.hasError)
            return Text(snapshot.error.toString());
          else
            return CircularProgressIndicator(
              strokeWidth: 7,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]),
            );
        },
      ),
      actions: [
        TextButton(
          child: Text(
            'Log Out',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () async {
            try {
              Navigator.pop(context);
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => getLoadingDialog(title: 'Logging Out'),
              );
              await _authCall.logOutUser();
              await Future.delayed(Duration(seconds: 1));
              Navigator.pop(context);
              _authBloc.add(LogOut());
            } catch (err) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => getErrorDialog(
                  context: context,
                  title: 'Log Out Error',
                  msg: err.toString(),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void getAppBarItems() {
    _appBarItems.add(
      CustomBottomNavBarItem(
        'Home',
        Icon(Icons.home),
        Colors.red,
      ),
    );
    _appBarItems.add(
      CustomBottomNavBarItem(
        'Store',
        Icon(Icons.store),
        Colors.green,
      ),
    );
    _appBarItems.add(
      CustomBottomNavBarItem(
        _isAdmin ? 'Upload File' : 'Upgrade',
        Icon(_isAdmin ? Icons.add : Icons.upgrade),
        Colors.blue[800],
      ),
    );
  }

  Widget getBodyPage() {
    switch (_pageController) {
      case 0:
        return HomePage();
        break;
      case 1:
        return StorePage();
        break;
      case 2:
        return _isAdmin ? AddFilePage() : UpgradeAccountPage();
        break;
    }
    return Container();
  }
}
