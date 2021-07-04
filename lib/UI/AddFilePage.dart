import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkling_personal/APICalls/FileCalls.dart';
import 'package:inkling_personal/UI/Common%20Widgets/PasswordFieldWidget.dart';
import 'package:inkling_personal/UI/Common%20Widgets/CommonWidgets.dart';
import 'package:inkling_personal/blocs/FileUploadBloc.dart';
import 'package:file_picker/file_picker.dart';

class AddFilePage extends StatefulWidget {
  @override
  _AddFilePageState createState() => _AddFilePageState();
}

class _AddFilePageState extends State<AddFilePage> {
  var _adminPassFormKey = GlobalKey<FormState>();
  var _adminPassController;
  var _fileNameFormKey = GlobalKey<FormState>();
  var _fileNameController;
  var _filePriceFormKey = GlobalKey<FormState>();
  var _filePriceController;
  FilePickerResult _fileRes;
  FileUploadBloc _fileUploadBloc;
  FileCalls _fileCall;
  @override
  void initState() {
    _fileUploadBloc = FileUploadBloc();
    _adminPassController = TextEditingController();
    _fileNameController = TextEditingController();
    _filePriceController = TextEditingController();
    _fileCall = FileCalls();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Text(
              'Enter details to upload file',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: PasswordField(
              controller: _adminPassController,
              formKey: _adminPassFormKey,
              lbl: "Admin Password",
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: getFileNameTextField(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: getFilePriceTextField(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: getSelectFileButton(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: getFileUploadButton(),
          ),
          BlocBuilder<FileUploadBloc, FileUploadState>(
            bloc: _fileUploadBloc,
            builder: (context, state) {
              if (state is FileUploadSuccessState)
                return ListTile(
                  title: Text('File Path'),
                  subtitle: Text(state.filePath),
                );
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget getFileNameTextField() {
    return Form(
      key: _fileNameFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Material(
        elevation: 12,
        color: Colors.transparent,
        shadowColor: Colors.black54,
        child: TextFormField(
          controller: _fileNameController,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: 'Enter File Name without extension (.pdf)',
            labelText: 'File Name',
            prefixIcon: Icon(
              Icons.file_present,
              color: Colors.blue[800],
            ),
          ),
          validator: (val) {
            if (val.isEmpty) return "Field cannot be Empty";
            return null;
          },
        ),
      ),
    );
  }

  Widget getFilePriceTextField() {
    return Form(
      key: _filePriceFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Material(
        elevation: 12,
        color: Colors.transparent,
        shadowColor: Colors.black54,
        child: TextFormField(
          controller: _filePriceController,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: 'Enter File Price',
            labelText: 'File Price',
            prefixIcon: Icon(
              Icons.attach_money,
              color: Colors.blue[800],
            ),
          ),
          validator: (val) {
            if (val.isEmpty) return "Field cannot be Empty";
            try {
              double.parse(val);
            } catch (e) {
              return "Invalid Price Entered";
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget getSelectFileButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Colors.amber),
      child: Text(
        'Select File',
        textScaleFactor: 1.5,
      ),
      onPressed: submitDataTask,
    );
  }

  Widget getFileUploadButton() {
    return ElevatedButton(
      child: Text(
        'Upload File',
        textScaleFactor: 1.5,
      ),
      onPressed: uploadFileTask,
    );
  }

  void submitDataTask() async {
    _fileRes = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (_fileRes != null && _fileRes.files.isNotEmpty)
      // && _fileRes.files.first.bytes != null)
      _fileUploadBloc.add(
        FileLoadedEvent(filePath: _fileRes.files.first.path),
      );
    else
      ScaffoldMessenger.of(context).showSnackBar(
        getErrorSnackBar(msg: "Error Occured. Try Again"),
      );
  }

  void uploadFileTask() async {
    if (!(_adminPassFormKey.currentState.validate() &&
        _fileNameFormKey.currentState.validate() &&
        _filePriceFormKey.currentState.validate())) return;
    if (_fileRes == null && _fileRes.files.first.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        getErrorSnackBar(msg: "Unable to load File. Ensure File is Selected"),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => getLoadingDialog(title: "Adding File. Please Wait"),
    );
    try {
      await _fileCall.addFileToStore(
        fileName: '${_fileNameController.text.trim()}.pdf',
        filePrice: double.parse(_filePriceController.text.trim()),
        adminPassword: _adminPassController.text.trim(),
      );
      //print(_fileRes.files.first.bytes);
      await _fileCall.uploadTask(
        fileVl: _fileRes.files.first.path,
        fileName: '${_fileNameController.text.trim()}.pdf',
      );
    } catch (e) {
      //print("Exception Caught");
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => getErrorDialog(
          context: context,
          msg: e.toString(),
          title: "Add Task Failed",
        ),
      );
      return;
    } finally {
      _fileNameController.clear();
      _filePriceController.clear();
      _adminPassController.clear();
      FilePicker.platform.clearTemporaryFiles().then((bool vl) {
        if (vl) _fileUploadBloc.add(FileUnloadedEvent());
      });
    }
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("File Added Succesfully"),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
