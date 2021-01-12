import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'downloader_event.dart';
part 'downloader_state.dart';

class DownloaderBloc extends Bloc<DownloaderEvent, DownloaderState> {
  DownloaderBloc() : super(DownloaderInitial());

  @override
  Stream<DownloaderState> mapEventToState(
    DownloaderEvent event,
  ) async* {}
}
