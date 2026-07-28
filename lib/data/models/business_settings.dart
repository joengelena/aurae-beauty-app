class BusinessSettings {
  final String deliveryOption; // 'pickup' | 'postal' | 'both'

  // Days every dress must stay unavailable after a rental ends (cleaning
  // time) before the next booking can start. Applies to all of this owner's
  // dresses. Minimum 1 day.
  final int cleaningBufferDays;

  const BusinessSettings({
    this.deliveryOption = 'pickup',
    this.cleaningBufferDays = 1,
  });

  factory BusinessSettings.fromJson(Map<String, dynamic> json) {
    return BusinessSettings(
      deliveryOption: json['deliveryOption'] as String? ?? 'pickup',
      cleaningBufferDays: json['cleaningBufferDays'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'deliveryOption': deliveryOption,
        'cleaningBufferDays': cleaningBufferDays,
      };

  BusinessSettings copyWith({String? deliveryOption, int? cleaningBufferDays}) {
    return BusinessSettings(
      deliveryOption: deliveryOption ?? this.deliveryOption,
      cleaningBufferDays: cleaningBufferDays ?? this.cleaningBufferDays,
    );
  }
}
