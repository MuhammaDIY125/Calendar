class AppConstants {
  AppConstants._();

  static const int minYear = 1950;
  static const int maxYear = 2950;

  static const int totalYears = maxYear - minYear + 1;
  static const int totalMonths = totalYears * 12;

  static const double cardBorderRadius = 10.0;
  static const double inputBorderRadius = 12.0;
  static const double buttonBorderRadius = 12.0;

  static const double eventColorBarWidth = 4.0;

  static const int maxEventDotsVisible = 3;
}
