class BusinessSettings {
  final String deliveryOption; // 'pickup' | 'postal' | 'both'

  const BusinessSettings({this.deliveryOption = 'pickup'});

  factory BusinessSettings.fromJson(Map<String, dynamic> json) {
    return BusinessSettings(
      deliveryOption: json['deliveryOption'] as String? ?? 'pickup',
    );
  }

  Map<String, dynamic> toJson() => {'deliveryOption': deliveryOption};

  BusinessSettings copyWith({String? deliveryOption}) {
    return BusinessSettings(
      deliveryOption: deliveryOption ?? this.deliveryOption,
    );
  }
}
