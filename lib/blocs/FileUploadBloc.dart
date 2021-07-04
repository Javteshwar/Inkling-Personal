import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FileUploadEvent extends Equatable {
  List<Object> get props => [];
}

class FileLoadedEvent extends FileUploadEvent {
  final String filePath;
  FileLoadedEvent({this.filePath});
  List<Object> get props => [filePath];
}

class FileUnloadedEvent extends FileUploadEvent {}

abstract class FileUploadState extends Equatable {
  List<Object> get props => [];
}

class FileUploadingState extends FileUploadState {}

class FileUploadingErrorState extends FileUploadState {
  final String err;
  FileUploadingErrorState({this.err});
  List<Object> get props => [err];
}

class FileUploadSuccessState extends FileUploadState {
  final String filePath;
  FileUploadSuccessState({this.filePath});
  List<Object> get props => [filePath];
}

class FileNotUploadedState extends FileUploadState {}

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  FileUploadBloc() : super(FileNotUploadedState());

  Stream<FileUploadState> mapEventToState(FileUploadEvent event) async* {
    if (event is FileLoadedEvent)
      yield FileUploadSuccessState(filePath: event.filePath);
    else if (event is FileUnloadedEvent) yield FileNotUploadedState();
  }
}
