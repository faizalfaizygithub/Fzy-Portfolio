import 'package:flutter/foundation.dart';

@immutable
class Experience {
  const Experience({
    required this.company,
    required this.role,
    required this.period,
    required this.location,
    required this.responsibilities,
    this.current = false,
  });

  final String company;
  final String role;
  final String period;
  final String location;
  final List<String> responsibilities;
  final bool current;
}

abstract final class ExperienceData {
  static const items = <Experience>[
    Experience(
      company: 'Noviindus Technologies',
      role: 'Flutter Developer',
      period: 'June 2024 – Present',
      location: 'Calicut, Kerala',
      current: true,
      responsibilities: [
        'Develop and maintain cross-platform Flutter applications.',
        'Build responsive interfaces from UI/UX designs.',
        'Implement smooth navigation and secure transaction workflows.',
        'Improve application performance through state management and lazy loading.',
        'Integrate REST APIs and Firebase services.',
        'Implement real-time communication features.',
        'Integrate payment gateways.',
        'Manage Google Play Console app transfers and account migrations.',
      ],
    ),
    Experience(
      company: 'Doctosmart Software Development',
      role: 'Junior Flutter Developer',
      period: '3 Months',
      location: 'Cyberpark, Calicut',
      responsibilities: [
        'Contributed to healthcare-focused software modules.',
        'Improved patient-doctor data flow.',
        'Developed responsive mobile interfaces.',
        'Debugged and resolved UI issues.',
        'Assisted with REST API integration and data synchronization.',
      ],
    ),
  ];
}
