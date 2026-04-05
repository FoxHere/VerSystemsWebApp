import 'package:flutter/widgets.dart';

sealed class PageStatus {}

class PageStatusIdle extends PageStatus {}

class PageStatusLoading extends PageStatus {}

class PageStatusError extends PageStatus {
  final String message;
  PageStatusError(this.message);
}

class PageStatusEmpty extends PageStatus {
  final String title;
  final String? description;
  final Widget? action;
  PageStatusEmpty({required this.title, this.description, this.action});
}

class PageStatusSuccess<T> extends PageStatus {
  T data;
  PageStatusSuccess(this.data);
}
