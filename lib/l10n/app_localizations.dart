import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'SIRAT'**
  String get appName;

  /// No description provided for @greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greeting_morning;

  /// No description provided for @greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greeting_evening;

  /// No description provided for @greeting_night.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get greeting_night;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_prayer_times.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get nav_prayer_times;

  /// No description provided for @nav_qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get nav_qibla;

  /// No description provided for @nav_quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get nav_quran;

  /// No description provided for @nav_zikirmatik.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Counter'**
  String get nav_zikirmatik;

  /// No description provided for @nav_ai_assistant.
  ///
  /// In en, this message translates to:
  /// **'Islam-AI'**
  String get nav_ai_assistant;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @zikirmatik.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Counter'**
  String get zikirmatik;

  /// No description provided for @qiblaFinder.
  ///
  /// In en, this message translates to:
  /// **'Qibla Finder'**
  String get qiblaFinder;

  /// No description provided for @readQuran.
  ///
  /// In en, this message translates to:
  /// **'Read Quran'**
  String get readQuran;

  /// No description provided for @findMosque.
  ///
  /// In en, this message translates to:
  /// **'Find Mosque'**
  String get findMosque;

  /// No description provided for @aiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Islam-AI Suggestion'**
  String get aiSuggestion;

  /// No description provided for @prayer_fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayer_fajr;

  /// No description provided for @prayer_sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayer_sunrise;

  /// No description provided for @prayer_dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayer_dhuhr;

  /// No description provided for @prayer_asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayer_asr;

  /// No description provided for @prayer_maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayer_maghrib;

  /// No description provided for @prayer_isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayer_isha;

  /// No description provided for @next_prayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get next_prayer;

  /// No description provided for @time_remaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get time_remaining;

  /// No description provided for @pray_now.
  ///
  /// In en, this message translates to:
  /// **'Pray Now'**
  String get pray_now;

  /// No description provided for @remind_later.
  ///
  /// In en, this message translates to:
  /// **'Remind Later'**
  String get remind_later;

  /// No description provided for @qibla_direction.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qibla_direction;

  /// No description provided for @qibla_calibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Compass'**
  String get qibla_calibrate;

  /// No description provided for @qibla_ar_mode.
  ///
  /// In en, this message translates to:
  /// **'Open AR Mode'**
  String get qibla_ar_mode;

  /// No description provided for @qibla_interference.
  ///
  /// In en, this message translates to:
  /// **'Magnetic interference detected. Please move away from metal objects.'**
  String get qibla_interference;

  /// No description provided for @zikirmatik_title.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Counter'**
  String get zikirmatik_title;

  /// No description provided for @zikirmatik_tap.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get zikirmatik_tap;

  /// No description provided for @zikirmatik_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get zikirmatik_reset;

  /// No description provided for @zikirmatik_select.
  ///
  /// In en, this message translates to:
  /// **'Select Dhikr'**
  String get zikirmatik_select;

  /// No description provided for @zikirmatik_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get zikirmatik_total;

  /// No description provided for @zikirmatik_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get zikirmatik_today;

  /// No description provided for @ai_title.
  ///
  /// In en, this message translates to:
  /// **'Islam-AI Assistant'**
  String get ai_title;

  /// No description provided for @ai_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Do you have a question on your mind today?'**
  String get ai_placeholder;

  /// No description provided for @ai_thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get ai_thinking;

  /// No description provided for @ai_share.
  ///
  /// In en, this message translates to:
  /// **'Share Card'**
  String get ai_share;

  /// No description provided for @ai_source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get ai_source;

  /// No description provided for @onboarding_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SIRAT'**
  String get onboarding_welcome;

  /// No description provided for @onboarding_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get onboarding_language;

  /// No description provided for @onboarding_madhab.
  ///
  /// In en, this message translates to:
  /// **'Select Your Madhab'**
  String get onboarding_madhab;

  /// No description provided for @onboarding_location.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get onboarding_location;

  /// No description provided for @onboarding_location_desc.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show you the nearest mosque and accurate Qibla direction.'**
  String get onboarding_location_desc;

  /// No description provided for @onboarding_notification.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get onboarding_notification;

  /// No description provided for @onboarding_notification_desc.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to alert you at prayer times.'**
  String get onboarding_notification_desc;

  /// No description provided for @onboarding_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboarding_start;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboarding_back;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_madhab.
  ///
  /// In en, this message translates to:
  /// **'Madhab'**
  String get settings_madhab;

  /// No description provided for @settings_calculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get settings_calculation;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_azan_sound.
  ///
  /// In en, this message translates to:
  /// **'Azan Sound'**
  String get settings_azan_sound;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_auto.
  ///
  /// In en, this message translates to:
  /// **'Auto (Day/Night)'**
  String get settings_theme_auto;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_terms;

  /// No description provided for @error_location.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get error_location;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_network;

  /// No description provided for @error_general.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_general;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
