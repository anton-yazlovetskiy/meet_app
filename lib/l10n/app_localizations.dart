import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MeetApp'**
  String get appTitle;

  /// No description provided for @eventListTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventListTitle;

  /// No description provided for @eventsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsPageTitle;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @createEventButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createEventButton;

  /// No description provided for @createEventPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get createEventPageTitle;

  /// No description provided for @eventDetailsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Details'**
  String get eventDetailsPageTitle;

  /// No description provided for @votingPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get votingPageTitle;

  /// No description provided for @refreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshButton;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get noEventsFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @allEventsFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allEventsFilter;

  /// No description provided for @plannedEventsFilter.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get plannedEventsFilter;

  /// No description provided for @activeEventsFilter.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeEventsFilter;

  /// No description provided for @fixedEventsFilter.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixedEventsFilter;

  /// No description provided for @interfaceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface Language'**
  String get interfaceLanguage;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @eventStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get eventStatus;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get eventType;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @loginWith.
  ///
  /// In en, this message translates to:
  /// **'Sign in with'**
  String get loginWith;

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Rules'**
  String get rulesTitle;

  /// No description provided for @rules1.
  ///
  /// In en, this message translates to:
  /// **'• Spam and fraud prohibition'**
  String get rules1;

  /// No description provided for @rules2.
  ///
  /// In en, this message translates to:
  /// **'• Insults and discrimination prohibition'**
  String get rules2;

  /// No description provided for @rules3.
  ///
  /// In en, this message translates to:
  /// **'• Illegal actions prohibition'**
  String get rules3;

  /// No description provided for @rules4.
  ///
  /// In en, this message translates to:
  /// **'• Disclaimer for user actions'**
  String get rules4;

  /// No description provided for @licenseButton.
  ///
  /// In en, this message translates to:
  /// **'License Agreement'**
  String get licenseButton;

  /// No description provided for @licenseText.
  ///
  /// In en, this message translates to:
  /// **'By registering, you confirm that you have read and agree to all terms of the license agreement.'**
  String get licenseText;

  /// No description provided for @tariffsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tariffs'**
  String get tariffsTitle;

  /// No description provided for @tariffPhysicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Individuals'**
  String get tariffPhysicalTitle;

  /// No description provided for @tariffPhysicalDesc.
  ///
  /// In en, this message translates to:
  /// **'Basic access'**
  String get tariffPhysicalDesc;

  /// No description provided for @tariffPhysicalPrice.
  ///
  /// In en, this message translates to:
  /// **'0 ₽'**
  String get tariffPhysicalPrice;

  /// No description provided for @tariffPhysicalFeature1.
  ///
  /// In en, this message translates to:
  /// **'View events'**
  String get tariffPhysicalFeature1;

  /// No description provided for @tariffPhysicalFeature2.
  ///
  /// In en, this message translates to:
  /// **'Participate in voting'**
  String get tariffPhysicalFeature2;

  /// No description provided for @searchEventsInYourCity.
  ///
  /// In en, this message translates to:
  /// **'Search for events in your city'**
  String get searchEventsInYourCity;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @myEventsFilter.
  ///
  /// In en, this message translates to:
  /// **'Created by me'**
  String get myEventsFilter;

  /// No description provided for @participatingFilter.
  ///
  /// In en, this message translates to:
  /// **'Participating'**
  String get participatingFilter;

  /// No description provided for @appliedFilter.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get appliedFilter;

  /// No description provided for @archivedFilter.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedFilter;

  /// No description provided for @applicationCancelled.
  ///
  /// In en, this message translates to:
  /// **'You cancelled your application for'**
  String get applicationCancelled;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'You applied for'**
  String get applicationSubmitted;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorMessage;

  /// No description provided for @invalidMapUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid map URL'**
  String get invalidMapUrl;

  /// No description provided for @failedOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Failed to open map'**
  String get failedOpenMap;

  /// No description provided for @tariffBusiness1Title.
  ///
  /// In en, this message translates to:
  /// **'Business L1'**
  String get tariffBusiness1Title;

  /// No description provided for @tariffBusiness1Desc.
  ///
  /// In en, this message translates to:
  /// **'Advanced tools'**
  String get tariffBusiness1Desc;

  /// No description provided for @tariffBusiness1Price.
  ///
  /// In en, this message translates to:
  /// **'1490 ₽'**
  String get tariffBusiness1Price;

  /// No description provided for @tariffBusiness1Feature1.
  ///
  /// In en, this message translates to:
  /// **'Create events'**
  String get tariffBusiness1Feature1;

  /// No description provided for @tariffBusiness1Feature2.
  ///
  /// In en, this message translates to:
  /// **'Manage participants'**
  String get tariffBusiness1Feature2;

  /// No description provided for @tariffBusiness1Feature3.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tariffBusiness1Feature3;

  /// No description provided for @tariffBusiness2Title.
  ///
  /// In en, this message translates to:
  /// **'Business L2'**
  String get tariffBusiness2Title;

  /// No description provided for @tariffBusiness2Desc.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get tariffBusiness2Desc;

  /// No description provided for @tariffBusiness2Price.
  ///
  /// In en, this message translates to:
  /// **'2990 ₽'**
  String get tariffBusiness2Price;

  /// No description provided for @tariffBusiness2Feature1.
  ///
  /// In en, this message translates to:
  /// **'All from L1'**
  String get tariffBusiness2Feature1;

  /// No description provided for @tariffBusiness2Feature2.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get tariffBusiness2Feature2;

  /// No description provided for @tariffBusiness2Feature3.
  ///
  /// In en, this message translates to:
  /// **'API access'**
  String get tariffBusiness2Feature3;

  /// No description provided for @tariffBusiness3Title.
  ///
  /// In en, this message translates to:
  /// **'Business L3'**
  String get tariffBusiness3Title;

  /// No description provided for @tariffBusiness3Desc.
  ///
  /// In en, this message translates to:
  /// **'Maximum capabilities'**
  String get tariffBusiness3Desc;

  /// No description provided for @tariffBusiness3Price.
  ///
  /// In en, this message translates to:
  /// **'4990 ₽'**
  String get tariffBusiness3Price;

  /// No description provided for @tariffBusiness3Feature1.
  ///
  /// In en, this message translates to:
  /// **'All from L2'**
  String get tariffBusiness3Feature1;

  /// No description provided for @tariffBusiness3Feature2.
  ///
  /// In en, this message translates to:
  /// **'Auto moderation'**
  String get tariffBusiness3Feature2;

  /// No description provided for @tariffBusiness3Feature3.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get tariffBusiness3Feature3;

  /// No description provided for @locationParsingError_invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'The provided link is not a valid URL.'**
  String get locationParsingError_invalidUrl;

  /// No description provided for @locationParsingError_unsupportedMapProvider.
  ///
  /// In en, this message translates to:
  /// **'Only Google Maps and Yandex Maps links are supported.'**
  String get locationParsingError_unsupportedMapProvider;

  /// No description provided for @locationParsingError_parsingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not extract coordinates from the link. Please check the link or enter the address manually.'**
  String get locationParsingError_parsingFailed;

  /// No description provided for @locationParsingError_networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Could not resolve the short link. Please check your internet connection.'**
  String get locationParsingError_networkError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
