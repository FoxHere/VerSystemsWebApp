class UserContactModel {
  String cellphone;

  String phone;

  UserContactModel({required this.cellphone, required this.phone});

  UserContactModel.fromJson(Map<String, dynamic> json)
    : cellphone = json['cellphone'] as String,
      phone = json['phone'] as String;

  Map<String, dynamic> toJson() => {'cellphone': cellphone, 'phone': phone};

  factory UserContactModel.empty() => UserContactModel(cellphone: '', phone: '');
}
