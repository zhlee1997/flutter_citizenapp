class MajorAnnouncementModel {
  late String sid;
  late String image;
  late String title;
  late String description;
  late String date;

  // model constructor
  MajorAnnouncementModel({
    required this.sid,
    required this.image,
    required this.title,
    required this.description,
    this.date = "",
  });
}
