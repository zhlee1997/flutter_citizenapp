import 'package:flutter/material.dart';

import '../../services/event_services.dart';
import '../../models/case_model.dart';
import '../../utils/global_dialog_helper.dart';
import '../../utils/lazy_load_scroll_view.dart';
import '../../utils/app_localization.dart';
import '../../widgets/reported_cases/case_card.dart';

class EmergencyCasesScreen extends StatefulWidget {
  static const String routeName = "emergency-cases-screen";

  const EmergencyCasesScreen({super.key});

  @override
  State<EmergencyCasesScreen> createState() => _EmergencyCasesScreenState();
}

class _EmergencyCasesScreenState extends State<EmergencyCasesScreen> {
  int _page = 1;
  int _PendingPage = 1;
  int _ResolvedPage = 1;

  bool _noMoreLoad = false;
  bool _noPendingMoreLoad = false;
  bool _noResolvedMoreLoad = false;

  bool isLoading = false;
  bool isPendingLoading = false;
  bool isResolvedLoading = false;

  List<EmergencyCaseModel> _cases = [];
  List<EmergencyCaseModel> _pendingCases = [];
  List<EmergencyCaseModel> _resolvedCases = [];

  final EventServices _eventServices = EventServices();

  /// Get the list of Talikhidmat Case or Emergency Case
  /// When screen first renders
  /// When scrolling down the list
  /// When selecting on Talikhidmat Case or Emergency Case
  /// Using queryPageList API
  ///
  /// Receives [categoryInt] as the type of cases chosen
  /// For example, Talikhidmat Case or Emergency Case
  /// [filterType] as the type of filters chosen
  /// For example, New or Pending or Resolved
  Future<void> setCases(int filterType) async {
    bool noMoreData = _noMoreLoad;
    int page = _page;
    List<EmergencyCaseModel> data = _cases;

    try {
      if (!noMoreData) {
        Map<String, dynamic> paramater = {
          'eventUrgency': "2",
          'pageNum': page,
          'pageSize': 20,
          'eventStatus': filterType
        };

        var response = await _eventServices.queryEventPageList(paramater);
        if (response.containsKey('data') &&
            response['data']['list'].length > 0) {
          var caseData = response['data']['list'] as List;

          // determine whether to load more
          if (caseData.length < 20) {
            _noMoreLoad = true;
          } else {
            _page++;
          }

          if (page == 1) {
            data = caseData.map((e) => EmergencyCaseModel.fromJson(e)).toList();
            _cases = data;
          } else {
            data.addAll(
                caseData.map((e) => EmergencyCaseModel.fromJson(e)).toList());
          }
          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            _cases = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('setCases error: ${e.toString()}');
    }
  }

  Future<void> setPendingCases(int filterType) async {
    bool noMoreData = _noPendingMoreLoad;
    int page = _PendingPage;
    List<EmergencyCaseModel> data = _pendingCases;

    try {
      if (!noMoreData) {
        Map<String, dynamic> paramater = {
          'eventUrgency': "2",
          'pageNum': page,
          'pageSize': 20,
          'eventStatus': filterType
        };

        var response = await _eventServices.queryEventPageList(paramater);
        if (response.containsKey('data') &&
            response['data']['list'].length > 0) {
          var caseData = response['data']['list'] as List;

          // determine whether to load more
          if (caseData.length < 20) {
            _noPendingMoreLoad = true;
          } else {
            _PendingPage++;
          }

          if (page == 1) {
            data = caseData.map((e) => EmergencyCaseModel.fromJson(e)).toList();
            _pendingCases = data;
          } else {
            data.addAll(
                caseData.map((e) => EmergencyCaseModel.fromJson(e)).toList());
          }
          setState(() {
            isPendingLoading = false;
          });
        } else {
          setState(() {
            _pendingCases = [];
            isPendingLoading = false;
          });
        }
      }
    } catch (e) {
      print('setPendingCases error: ${e.toString()}');
    }
  }

  Future<void> setResolvedCases(int filterType) async {
    bool noMoreData = _noResolvedMoreLoad;
    int page = _ResolvedPage;
    List<EmergencyCaseModel> data = _resolvedCases;

    try {
      if (!noMoreData) {
        Map<String, dynamic> paramater = {
          'eventUrgency': "2",
          'pageNum': page,
          'pageSize': 20,
          'eventStatus': filterType
        };

        var response = await _eventServices.queryEventPageList(paramater);
        if (response.containsKey('data') &&
            response['data']['list'].length > 0) {
          var caseData = response['data']['list'] as List;

          // determine whether to load more
          if (caseData.length < 20) {
            _noResolvedMoreLoad = true;
          } else {
            _ResolvedPage++;
          }

          if (page == 1) {
            data = caseData.map((e) => EmergencyCaseModel.fromJson(e)).toList();
            _resolvedCases = data;
          } else {
            data.addAll(
                caseData.map((e) => EmergencyCaseModel.fromJson(e)).toList());
          }
          setState(() {
            isResolvedLoading = false;
          });
        } else {
          setState(() {
            _resolvedCases = [];
            isResolvedLoading = false;
          });
        }
      }
    } catch (e) {
      print('setResolvedCases error: ${e.toString()}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    isPendingLoading = true;
    isResolvedLoading = true;
    setCases(0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Emergency Cases"),
          bottom: TabBar(
            onTap: (int index) async {
              print(index);
              if (index == 0) {
                if (isLoading) await setCases(0);
              } else if (index == 1) {
                if (isPendingLoading) await setPendingCases(1);
              } else {
                if (isResolvedLoading) await setResolvedCases(2);
              }
            },
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle: const TextStyle(
              fontSize: 15.0,
            ),
            indicatorWeight: 5.0,
            labelStyle: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            labelPadding: const EdgeInsets.only(
              bottom: 5.0,
            ),
            tabs: const [
              Tab(
                text: 'New',
              ),
              Tab(
                text: "Pending",
              ),
              Tab(
                text: "Resolved",
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(
            top: 5.0,
            bottom: 10.0,
            left: 10.0,
            right: 10.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    isLoading
                        ? GlobalDialogHelper().showLoadingSpinner()
                        : LazyLoadScrollView(
                            onEndOfPage: () async {
                              await setCases(0);
                            },
                            child: _cases.length == 0
                                ? GlobalDialogHelper().buildCenterNoData(
                                    context,
                                    message: AppLocalization.of(context)!
                                        .translate('no_reported_case')!,
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 10.0,
                                      left: 10.0,
                                      right: 10.0,
                                    ),
                                    itemCount: _cases.length + 1,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      if (_cases.length == index) {
                                        return GlobalDialogHelper()
                                            .buildLinearProgressIndicator(
                                          context: context,
                                          currentLength: _cases.length,
                                          noMoreData: _noMoreLoad,
                                          handleLoadMore: () async {
                                            await setCases(0);
                                          },
                                        );
                                      } else {
                                        return CaseCard(
                                          caseId: _cases[index].eventId,
                                          caseNo: _cases[index].eventDesc,
                                          caseDate: _cases[index].eventTime,
                                          caseStatus: _cases[index].eventStatus,
                                          caseCategory: _cases[index].eventType,
                                          caseType: 2,
                                        );
                                      }
                                    },
                                  ),
                          ),
                    isPendingLoading
                        ? GlobalDialogHelper().showLoadingSpinner()
                        : LazyLoadScrollView(
                            onEndOfPage: () async {
                              await setPendingCases(1);
                            },
                            child: _pendingCases.length == 0
                                ? GlobalDialogHelper().buildCenterNoData(
                                    context,
                                    message: AppLocalization.of(context)!
                                        .translate('no_reported_case')!,
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 10.0,
                                      left: 10.0,
                                      right: 10.0,
                                    ),
                                    itemCount: _pendingCases.length + 1,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      if (_pendingCases.length == index) {
                                        return GlobalDialogHelper()
                                            .buildLinearProgressIndicator(
                                          context: context,
                                          currentLength: _pendingCases.length,
                                          noMoreData: _noPendingMoreLoad,
                                          handleLoadMore: () async {
                                            await setPendingCases(1);
                                          },
                                        );
                                      } else {
                                        return CaseCard(
                                          caseId: _pendingCases[index].eventId,
                                          caseNo:
                                              _pendingCases[index].eventDesc,
                                          caseDate:
                                              _pendingCases[index].eventTime,
                                          caseStatus:
                                              _pendingCases[index].eventStatus,
                                          caseCategory: _cases[index].eventType,
                                          caseType: 2,
                                        );
                                      }
                                    },
                                  ),
                          ),
                    isResolvedLoading
                        ? GlobalDialogHelper().showLoadingSpinner()
                        : LazyLoadScrollView(
                            onEndOfPage: () async {
                              await setResolvedCases(2);
                            },
                            child: _resolvedCases.length == 0
                                ? GlobalDialogHelper().buildCenterNoData(
                                    context,
                                    message: AppLocalization.of(context)!
                                        .translate('no_reported_case')!,
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 10.0,
                                      left: 10.0,
                                      right: 10.0,
                                    ),
                                    itemCount: _resolvedCases.length + 1,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      if (_resolvedCases.length == index) {
                                        return GlobalDialogHelper()
                                            .buildLinearProgressIndicator(
                                          context: context,
                                          currentLength: _resolvedCases.length,
                                          noMoreData: _noResolvedMoreLoad,
                                          handleLoadMore: () async {
                                            await setResolvedCases(2);
                                          },
                                        );
                                      } else {
                                        return CaseCard(
                                          caseId: _resolvedCases[index].eventId,
                                          caseNo:
                                              _resolvedCases[index].eventDesc,
                                          caseDate:
                                              _resolvedCases[index].eventTime,
                                          caseStatus:
                                              _resolvedCases[index].eventStatus,
                                          caseCategory: _cases[index].eventType,
                                          caseType: 2,
                                        );
                                      }
                                    },
                                  ),
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
