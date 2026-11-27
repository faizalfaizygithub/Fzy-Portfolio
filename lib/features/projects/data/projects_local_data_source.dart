import '../../../core/constants/app_colors.dart';
import '../domain/project.dart';

/// Project content taken from the CV.
///
/// Only list features that were actually built. To add real screenshots,
/// put them in `assets/images/projects/<id>/` (WebP preferred, portrait
/// phone ratio) and list their paths in `screenshots`.
abstract final class ProjectsLocalDataSource {
  static const projects = <Project>[
    Project(
      id: 'ealzo',
      number: '01',
      name: 'Ealzo',
      category: 'Healthcare · Doctor Booking',
      summary: 'A doctor booking application that helps users discover doctors and book appointments.',
      overview:
          'Ealzo is a doctor booking application that helps users discover doctors and book appointments. '
          'My work focused on the discovery and booking journey: finding doctors by specialty or location, '
          'booking appointments and paying for them.',
      contributions: [
        'Developed doctor discovery and appointment booking flows.',
        'Implemented doctor and specialty-based search.',
        'Integrated REST APIs.',
        'Implemented location-based doctor discovery.',
        'Developed appointment payment options.',
        'Integrated payment gateways.',
      ],
      keyFeatures: [
        'Doctor discovery',
        'Doctor & specialty search',
        'Location-based discovery',
        'Appointment booking',
        'Appointment payments',
      ],
      technologies: [
        'Flutter',
        'Dart',
        'REST APIs',
        'Location Services',
        'Razorpay / Payment Integration',
      ],
      accent: AppColors.healthcare,
      mockupKind: MockupKind.booking,
      isSpotlight: true,
      websiteUrl: 'https://landing.ealzo.com/',
      screenshots: [
        'assets/images/projects/ealzo/01_splash.jpg',
        'assets/images/projects/ealzo/02_home.jpg',
        'assets/images/projects/ealzo/03_hospital_details.jpg',
        'assets/images/projects/ealzo/04_doctor_booking.jpg',
        'assets/images/projects/ealzo/05_onboarding.jpg',
      ],
      screenshotsFramed: true,
    ),
    Project(
      id: 'furnyshop',
      number: '02',
      name: 'Furnyshop',
      category: 'E-commerce · Furniture Shopping',
      summary: 'A furniture e-commerce application designed for smooth product browsing and shopping.',
      overview:
          'Furnyshop is a furniture e-commerce application designed to provide a smooth product browsing '
          'and shopping experience, from exploring the catalog to completing checkout.',
      contributions: [
        'Developed product catalog functionality.',
        'Implemented multi-category filtering.',
        'Developed product search.',
        'Built checkout workflows.',
        'Implemented SQLite/Hive local persistence.',
        'Integrated payment gateways.',
      ],
      keyFeatures: [
        'Product catalog',
        'Multi-category filtering',
        'Product search',
        'Checkout workflow',
        'Local persistence',
      ],
      technologies: [
        'Flutter',
        'Dart',
        'REST APIs',
        'SQLite / Hive',
        'Payment Gateway Integration',
      ],
      accent: AppColors.commerce,
      mockupKind: MockupKind.commerce,
      screenshots: [
        'assets/images/projects/furnyshop/01_splash.jpg',
        'assets/images/projects/furnyshop/02_home.jpg',
        'assets/images/projects/furnyshop/03_products.jpg',
        'assets/images/projects/furnyshop/04_filters.jpg',
        'assets/images/projects/furnyshop/05_order_confirmed.jpg',
      ],
      screenshotsFramed: true,
    ),
    Project(
      id: 'mindiko',
      number: '03',
      name: 'Mindiko',
      category: 'Real-Time Communication',
      summary: 'A real-time communication application with audio and video calling capabilities.',
      overview:
          'Mindiko is a real-time communication application with audio and video calling capabilities, '
          'backed by push notifications so calls and messages reach users even when the app is in the background.',
      contributions: [
        'Developed audio/video calling functionality.',
        'Integrated Agora/WebRTC technologies.',
        'Integrated Firebase Cloud Messaging.',
        'Implemented call notifications.',
        'Supported background chat alerts.',
      ],
      keyFeatures: [
        'Audio calling',
        'Video calling',
        'Call notifications',
        'Background chat alerts',
      ],
      technologies: ['Flutter', 'Agora SDK', 'WebRTC', 'Firebase', 'FCM'],
      accent: AppColors.realtime,
      mockupKind: MockupKind.calling,
    ),
    Project(
      id: 'washsouq',
      number: '04',
      name: 'Washsouq',
      category: 'Car Wash Booking · Saudi Arabia',
      summary: 'A car wash marketplace app to find nearby car washes, compare offers and book in advance.',
      overview:
          'Washsouq is a Saudi Arabia based car wash booking app. Customers pick their vehicle and location, '
          'find nearby car washes sorted by offers or rating, apply coupons, add extra services at checkout '
          'and manage their bookings in one place.',
      contributions: [
        'Developed nearby car wash discovery with offer and rating sorting.',
        'Built the coupons and offers flow.',
        'Implemented advance booking with time slots and add-on services.',
        'Built checkout with pay now and pay on hand options.',
        'Developed booking management with OTP, directions and calling the vendor.',
      ],
      keyFeatures: [
        'Nearby car washes',
        'Sort by offer & rating',
        'Coupons & offers',
        'Advance booking',
        'Add-on services',
        'Pay now / pay on hand',
        'Booking OTP & directions',
      ],
      technologies: [
        'Flutter',
        'Dart',
        'REST APIs',
        'Location Services',
        'Payment Gateway Integration',
      ],
      accent: AppColors.washsouq,
      mockupKind: MockupKind.booking,
      screenshots: [
        'assets/images/projects/washsouq/01_home.jpg',
        'assets/images/projects/washsouq/02_nearby_carwashes.jpg',
        'assets/images/projects/washsouq/03_offers.jpg',
        'assets/images/projects/washsouq/04_checkout_addons.jpg',
        'assets/images/projects/washsouq/05_bookings.jpg',
      ],
      screenshotsFramed: true,
    ),
    Project(
      id: 'sharetok',
      number: '05',
      name: 'ShareTok',
      category: 'Communication · Social Application',
      summary: 'A social communication application with real-time audio/video communication and social sharing.',
      overview:
          'ShareTok is a social communication application featuring real-time audio/video communication '
          'and social-sharing functionality.',
      contributions: [
        'Integrated audio/video calling.',
        'Implemented call notifications.',
        'Developed contact synchronization.',
        'Implemented social-sharing functionality.',
      ],
      keyFeatures: [
        'Audio/video calling',
        'Call notifications',
        'Contact synchronization',
        'Social sharing',
      ],
      technologies: ['Flutter', 'Agora SDK / WebRTC', 'Firebase', 'FCM'],
      accent: AppColors.socialAlt,
      mockupKind: MockupKind.calling,
    ),
  ];
}
