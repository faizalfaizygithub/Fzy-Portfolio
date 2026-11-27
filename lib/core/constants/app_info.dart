/// Personal details, links and copy that appear in several places.
///
/// To update contact details or add GitHub, change the values here only.
abstract final class AppInfo {
  static const name = 'Muhammed Faisal V';
  static const shortName = 'Muhammed Faisal';
  static const firstName = 'Faisal';
  static const initials = 'MF';
  static const role = 'Flutter Developer';
  static const roleDetail = 'Mobile & Web';

  /// Portrait used in the hero and about sections (white background).
  static const portrait = 'assets/images/profile/portrait.jpg';
  static const experience = '2.4';
  static const location = 'Calicut, Kerala, India';
  static const email = 'faizalfaizy648@gmail.com';
  static const phone = '+91 98479 59648';
  static const phoneUri = 'tel:+919847959648';
  static const linkedInLabel = 'linkedin.com/in/muhammed-faizal-v-528a6b279';
  static const linkedInUrl =
      'https://www.linkedin.com/in/muhammed-faizal-v-528a6b279';

  /// Leave empty until a GitHub profile is ready; all GitHub links hide
  /// themselves while this is empty.
  static const gitHubUrl = '';
  static bool get hasGitHub => gitHubUrl.isNotEmpty;

  static const emailUri = 'mailto:$email';

  /// Served from `web/documents/` so the browser downloads the original PDF.
  static const resumePath = 'documents/Muhammed_Faisal_V_Resume.pdf';
  static const resumeFileName = 'Muhammed_Faisal_V_Resume.pdf';

  static const copyrightYear = 2026;
}
