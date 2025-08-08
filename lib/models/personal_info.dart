class PersonalInfo {
  final int? id;
  final String? name;
  final String? gender;
  final DateTime? dob;
  final String? height;
  final String? weight;
  final String? bodyFatEstimate;
  final String? weightTrend;
  final String? activityLevel;

  PersonalInfo({
    this.id,
    this.name,
    this.gender,
    this.dob,
    this.height,
    this.weight,
    this.bodyFatEstimate,
    this.weightTrend,
    this.activityLevel,
  });

  factory PersonalInfo.fromMap(Map<String, dynamic> m) => PersonalInfo(
    id:               m['id'] as int?,
    name:             m['name'] as String?,
    gender:           m['gender'] as String?,
    dob:              (m['dob'] == null || (m['dob'] as String).isEmpty)
                        ? null
                        : DateTime.tryParse(m['dob'] as String),
    height:           m['height'] as String?,
    weight:           m['weight'] as String?,
    bodyFatEstimate:  m['bodyfat_estimate'] as String?,
    weightTrend:      m['weight_trend'] as String?,
    activityLevel:    m['activity_level'] as String?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id!,
    'name':              name,
    'gender':            gender,
    'dob':               dob?.toIso8601String(),
    'height':            height,
    'weight':            weight,
    'bodyfat_estimate':  bodyFatEstimate,
    'weight_trend':      weightTrend,
    'activity_level':    activityLevel,
  };
}
