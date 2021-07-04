import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:inkling_personal/APICalls/FileCalls.dart';
import 'package:inkling_personal/Models/FileItem.dart';

abstract class FileViewEvent extends Equatable {
  const FileViewEvent();
  List<Object> get props => [];
}

class LoadUserFilesEvent extends FileViewEvent {}

class LoadStoreFilesEvent extends FileViewEvent {}

class FilterFilesEvent extends FileViewEvent {
  final bool isStore;
  final String query;
  final List<FileItem> docs;
  const FilterFilesEvent({this.query, this.docs, this.isStore});
  List<Object> get props => [query, docs, isStore];
}

abstract class FileViewState extends Equatable {
  const FileViewState();
  List<Object> get props => [];
}

class FilesLoading extends FileViewState {}

class UserFilesLoaded extends FileViewState {
  final int numberOfFiles;
  final List<String> fileNames;
  const UserFilesLoaded({this.fileNames, this.numberOfFiles});
  List<Object> get props => [numberOfFiles, fileNames];
}

class StoreFilesLoaded extends FileViewState {
  final int numberOfFiles;
  final List<FileItem> docs;
  const StoreFilesLoaded({this.docs, this.numberOfFiles});
  List<Object> get props => [docs, numberOfFiles];
}

class FilesLoadingError extends FileViewState {
  final String error;
  const FilesLoadingError({this.error});
  List<Object> get props => [error];
}

class FileViewBloc extends Bloc<FileViewEvent, FileViewState> {
  FileCalls _fileCalls = FileCalls();
  FileViewBloc() : super(FilesLoading());

  @override
  Stream<FileViewState> mapEventToState(FileViewEvent event) async* {
    if (event is LoadUserFilesEvent) {
      yield FilesLoading();
      await Future.delayed(Duration(seconds: 1));
      try {
        var dta = await _fileCalls.getUserFileData();
        List<String> resDocs = List.empty(growable: true);
        dta['fileNames'].forEach((ele) => resDocs.add(ele));
        yield UserFilesLoaded(
          numberOfFiles: dta['fileNumber'],
          fileNames: resDocs,
        );
      } catch (e) {
        yield FilesLoadingError(error: e.toString());
      }
    }
    if (event is LoadStoreFilesEvent) {
      yield FilesLoading();
      await Future.delayed(Duration(seconds: 1));
      try {
        var dta = await _fileCalls.getStoreFileData();
        dta = await getDataChecked(dta['documents']);
        List<FileItem> resDocs = List.empty(growable: true);
        dta.forEach((ele) => resDocs.add(FileItem.fromJson(ele)));
        yield StoreFilesLoaded(
          docs: resDocs,
          numberOfFiles: resDocs.length,
        );
      } catch (e) {
        yield FilesLoadingError(error: e.toString());
      }
    }
    if (event is FilterFilesEvent) {
      if (event.isStore) {
        if (event.query == "")
          yield StoreFilesLoaded(
            docs: event.docs,
            numberOfFiles: event.docs.length,
          );
        List<FileItem> resDocs = List.from(
          event.docs.where(
            (vl) => vl.name.contains(event.query),
          ),
        );
        yield StoreFilesLoaded(
          docs: resDocs,
          numberOfFiles: resDocs.length,
        );
      } else {
        if (event.query == "")
          yield StoreFilesLoaded(
            docs: event.docs,
            numberOfFiles: event.docs.length,
          );
        List<FileItem> fileItemDocs = List.from(
          event.docs.where(
            (vl) => vl.name.contains(event.query),
          ),
        );
        List<String> resDocs = List.empty(growable: true);
        fileItemDocs.forEach((ele) => resDocs.add(ele.name));
        yield UserFilesLoaded(
          fileNames: resDocs,
          numberOfFiles: resDocs.length,
        );
      }
    }
  }

  Future<List<dynamic>> getDataChecked(List<dynamic> dta) async {
    var userFiles = await _fileCalls.getUserFileData();
    userFiles = userFiles['fileNames'];
    if (userFiles.length == 0) {
      dta.forEach((dynamic x) {
        x['isBought'] = false;
      });
      return dta;
    }
    userFiles.sort((a, b) => a.toString().compareTo(b.toString()));
    dta.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    int i = 0;
    int j = 0;
    dta.forEach((dynamic x) {
      x['isBought'] = false;
    });
    while (i < dta.length && j < userFiles.length) {
      if (userFiles[j] == dta[i]['name']) {
        dta[i]['isBought'] = true;
        j++;
      }
      i++;
    }
    return dta;
  }
}
