
class UserModel {
  int? userid;
  String? timeStamp;
  String? tripId;
  String? token;

  UserModel({this.userid, this.timeStamp, this.tripId, this.token});

  UserModel.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    timeStamp = json['timeStamp'];
    tripId = json['tripId'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userid'] = userid;
    data['timeStamp'] = timeStamp;
    data['tripId'] = tripId;
    data['token'] = token;
    return data;
  }
}
