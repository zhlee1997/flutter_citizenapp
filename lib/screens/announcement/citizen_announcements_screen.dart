import 'package:flutter/material.dart';

import '../../models/announcement_model.dart';

class CitizenAnnouncementsScreen extends StatefulWidget {
  static const String routeName = "citizen-announcements-screen";

  const CitizenAnnouncementsScreen({super.key});

  @override
  State<CitizenAnnouncementsScreen> createState() =>
      _CitizenAnnouncementsScreenState();
}

class _CitizenAnnouncementsScreenState
    extends State<CitizenAnnouncementsScreen> {
  int _page = 1;
  bool _noMoreData = false;
  late ScrollController _scrollController;

  List<AnnouncementModel> _announcements = [];

  Future<void> _getCitizenAnnouncements(int page) async {
    try {} catch (e) {}
  }

  void _handleNavigateToAnnouncementDetail(BuildContext context) {
    // Navigator.of(context).pushNamed(
    //   AnnouncementDetailScreen.routeName,
    //   arguments: {'id': citizenAnnouncements[i].annId, 'isMajor': false},
    // );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // TODO: GET CITIZEN ANN API
    // TODO: LOADING STATE
    // TODO: INFINITE SCROLL
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          // infinite scrolling
          var maxScroll = _scrollController.position.maxScrollExtent;
          var pixels = _scrollController.position.pixels;
          if (maxScroll == pixels && !_noMoreData) {
            // execute when scroll up
            _page++;
            _getCitizenAnnouncements(_page);
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: screenSize.height * 0.3,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Citizen Announcements"),
              background: Image.asset(
                "assets/images/pictures/announcement/citizen_announcement.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Card(
                elevation: 3.0,
                margin: EdgeInsets.only(
                  top: index == 0 ? 10.0 : 5.0,
                  bottom: index == 19 ? 30.0 : 5.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: SizedBox(
                      width: screenSize.width * 0.22,
                      height: screenSize.width * 0.22,
                      child: Image.asset(
                        "assets/images/pictures/announcement/citizen_announcement.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: const Text(
                    'Storm causes tree to uproot in front of Kg Luak house',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.primary,
                    size: 15.0,
                  ),
                  onTap: () {
                    // navigate to announcement detail screen
                    _handleNavigateToAnnouncementDetail(context);
                    print("citizen announcement detail pressed $index");
                  },
                ),
              ),
              childCount: 20,
            ),
          )
        ],
        controller: _scrollController,
      ),
    );
  }
}
