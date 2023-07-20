class SamitiListItem {
  final String id;
  final String name;
  final String permission;

  SamitiListItem({required this.id, required this.name, required this.permission});

  factory SamitiListItem.fromJson(Map<String, dynamic> json) {
    return SamitiListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      permission: json['permission'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permission': permission,
    };
  }
}


class SamitiListResponse {
  final List<SamitiListItem> items;

  SamitiListResponse({required this.items});

  factory SamitiListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<SamitiListItem> itemsList = list.map((i) => SamitiListItem.fromJson(i)).toList();

    return SamitiListResponse(
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map> items = this.items.map((i) => i.toJson()).toList();

    return {
      'items': items,
    };
  }
}