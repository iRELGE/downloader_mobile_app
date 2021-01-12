part of 'downloader_bloc.dart';

@immutable
abstract class DownloaderEvent {}

class GetInitialPage extends DownloaderEvent {
  GetInitialPage();
}
