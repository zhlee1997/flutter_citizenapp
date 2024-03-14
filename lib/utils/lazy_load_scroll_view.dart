library lazy_load_scrollview;

import 'package:flutter/widgets.dart';

enum LoadingStatus { LOADING, STABLE }

/// Signature for EndOfPageListeners
typedef void EndOfPageListenerCallback();

/// A widget that wraps a [Widget] and will trigger [onEndOfPage] when it reaches the bottom of the list
// ignore: must_be_immutable
class LazyLoadScrollView extends StatefulWidget {
  /// The [Widget] that this widget watches for changes on
  final Widget child;

  /// Called when the [child] reaches the end of the list
  final EndOfPageListenerCallback onEndOfPage;

  /// The offset to take into account when triggering [onEndOfPage] in pixels
  final int scrollOffset;

  /// Used to determine if loading of new data has finished. You should use set this if you aren't using a FutureBuilder or StreamBuilder
  bool isLoading;

  /// Prevented update nested listview with other axis direction
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() => LazyLoadScrollViewState();

  LazyLoadScrollView({
    Key? key,
    required this.child,
    required this.onEndOfPage,
    this.scrollDirection = Axis.vertical,
    this.isLoading = false,
    this.scrollOffset = 100,
  }) : super(key: key);
}

class LazyLoadScrollViewState extends State<LazyLoadScrollView> {
  LoadingStatus loadMoreStatus = LoadingStatus.STABLE;

  @override
  void didUpdateWidget(covariant LazyLoadScrollView oldWidget) {
    if (!widget.isLoading) {
      loadMoreStatus = LoadingStatus.STABLE;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      child: widget.child,
      onNotification: (ScrollNotification notification) =>
          _onNotification(notification, context),
    );
  }

  // Called when a notification of the appropriate type arrives at this location in the tree
  bool _onNotification(ScrollNotification notification, BuildContext context) {
    if (widget.scrollDirection == notification.metrics.axis) {
      if (notification is ScrollUpdateNotification) {
        if (notification.metrics.maxScrollExtent >
                notification.metrics.pixels &&
            notification.metrics.maxScrollExtent -
                    notification.metrics.pixels <=
                widget.scrollOffset) {
          _loadMore();
        }
        return true;
      }

      if (notification is OverscrollNotification) {
        if (notification.overscroll > 0) {
          _loadMore();
        }
        return true;
      }
    }
    return false;
  }

  // load more data
  void _loadMore() {
    if (loadMoreStatus == LoadingStatus.STABLE && !widget.isLoading) {
      loadMoreStatus = LoadingStatus.LOADING;
      widget.isLoading = true;
      widget.onEndOfPage();
      widget.isLoading = false;
    }
  }
}
