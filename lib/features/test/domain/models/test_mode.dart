enum TestBatteryMode {
  quick(
    id: 'quick',
    plateCount: 6,
    title: 'Quick Check',
    subtitle: '6 Plates • ~30 seconds',
    badge: 'Express',
    description: 'Fast evaluation for high-confidence screening.',
  ),
  standard(
    id: 'standard',
    plateCount: 14,
    title: 'Standard Screening',
    subtitle: '14 Plates • ~90 seconds',
    badge: 'Recommended',
    description: 'Clinical standard covering Red-Green, Protan/Deutan, and Tritan axes.',
  ),
  comprehensive(
    id: 'comprehensive',
    plateCount: 24,
    title: 'Comprehensive Battery',
    subtitle: '24 Plates • ~2.5 minutes',
    badge: 'Full Clinical',
    description: 'Extended diagnostic test with hidden digit & redundancy plates.',
  );

  final String id;
  final int plateCount;
  final String title;
  final String subtitle;
  final String badge;
  final String description;

  const TestBatteryMode({
    required this.id,
    required this.plateCount,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.description,
  });
}
