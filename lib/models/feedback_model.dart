class FeedbackModel {
  late String feedbackId;
  late int starLevel;
  late int billPayment;
  late int busSchedule;
  late int emergencyButton;
  late int liveVideo;
  late int talikhidmat;
  late int tourismInformation;
  late int trafficImages;
  late int others;
  late String? remarks;
  late String createTime;

  FeedbackModel({
    required this.feedbackId,
    required this.starLevel,
    required this.billPayment,
    required this.busSchedule,
    required this.emergencyButton,
    required this.liveVideo,
    required this.talikhidmat,
    required this.tourismInformation,
    required this.trafficImages,
    required this.others,
    required this.remarks,
    required this.createTime,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        feedbackId: json["feedbackId"],
        starLevel: json["starLevel"],
        billPayment: json["billPayment"],
        busSchedule: json["busSchedule"],
        emergencyButton: json["emergencyButton"],
        liveVideo: json["liveVideo"],
        talikhidmat: json["talikhidmat"],
        tourismInformation: json["tourismInformation"],
        trafficImages: json["trafficImages"],
        others: json["others"],
        remarks: json["marks"] ?? "No remarks",
        createTime: json["createTime"],
      );
}
