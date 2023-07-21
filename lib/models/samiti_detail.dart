class DetailedSamitiApiResponse {
  DetailedSamiti item;

  DetailedSamitiApiResponse({required this.item});


  factory DetailedSamitiApiResponse.fromJson(Map<String, dynamic> json) {
    return DetailedSamitiApiResponse(
      item: DetailedSamiti.fromJson(json['item']),
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
  };


}

class DetailedSamiti {
  String id;
  String name;
  String creator;
  Map<String, SamitiMember> members;
  String description;
  int createdAt;
  int updatedAt;
  int balance;

  DetailedSamiti({
    required this.id,
    required this.name,
    required this.creator,
    required this.members,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.balance,
  });

  factory DetailedSamiti.fromJson(Map<String, dynamic> json) {
    return DetailedSamiti(
      id: json['id'],
      name: json['name'],
      creator: json['creator'],
      members: Map.from(json['members']).map((k, v) => MapEntry<String, SamitiMember>(k, SamitiMember.fromJson(v))),
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      balance: json['balance'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'creator': creator,
        'members': members.map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class SamitiMember {
  String id;
  String userId;
  String permission;
  String userName;
  String samitiId;
  String samitiName;

  SamitiMember({
    required this.id,
    required this.userId,
    required this.permission,
    required this.userName,
    required this.samitiId,
    required this.samitiName,
  });

  factory SamitiMember.fromJson(Map<String, dynamic> json) {
    return SamitiMember(
      id: json['id'],
      userId: json['user_id'],
      permission: json['permission'],
      userName: json['user_name'],
      samitiId: json['samiti_id'],
      samitiName: json['samiti_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'permission': permission,
        'user_name': userName,
        'samiti_id': samitiId,
        'samiti_name': samitiName,
      };
}
