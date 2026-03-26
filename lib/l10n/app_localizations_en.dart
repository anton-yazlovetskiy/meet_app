// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MeetApp';

  @override
  String get eventListTitle => 'Events';

  @override
  String get eventsPageTitle => 'Events';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get createEventButton => 'Create';

  @override
  String get createEventPageTitle => 'Create Event';

  @override
  String get eventDetailsPageTitle => 'Event Details';

  @override
  String get votingPageTitle => 'Voting';

  @override
  String get refreshButton => 'Refresh';

  @override
  String get noEventsFound => 'No events found';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get allEventsFilter => 'All';

  @override
  String get plannedEventsFilter => 'Planned';

  @override
  String get activeEventsFilter => 'Active';

  @override
  String get fixedEventsFilter => 'Fixed';

  @override
  String get interfaceLanguage => 'Interface Language';

  @override
  String get russian => 'Russian';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get participants => 'Participants';

  @override
  String get eventStatus => 'Status';

  @override
  String get eventType => 'Type';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get description => 'Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get loginWith => 'Sign in with';

  @override
  String get rulesTitle => 'Service Rules';

  @override
  String get rules1 => '• Spam and fraud prohibition';

  @override
  String get rules2 => '• Insults and discrimination prohibition';

  @override
  String get rules3 => '• Illegal actions prohibition';

  @override
  String get rules4 => '• Disclaimer for user actions';

  @override
  String get licenseButton => 'License Agreement';

  @override
  String get licenseText =>
      'By registering, you confirm that you have read and agree to all terms of the license agreement.';

  @override
  String get tariffsTitle => 'Tariffs';

  @override
  String get tariffPhysicalTitle => 'Individuals';

  @override
  String get tariffPhysicalDesc => 'Basic access';

  @override
  String get tariffPhysicalPrice => '0 ₽';

  @override
  String get tariffPhysicalFeature1 => 'View events';

  @override
  String get tariffPhysicalFeature2 => 'Participate in voting';

  @override
  String get searchEventsInYourCity => 'Search for events in your city';

  @override
  String get tagsLabel => 'Tags';

  @override
  String get myEventsFilter => 'Created by me';

  @override
  String get participatingFilter => 'Participating';

  @override
  String get appliedFilter => 'Applied';

  @override
  String get archivedFilter => 'Archived';

  @override
  String get applicationCancelled => 'You cancelled your application for';

  @override
  String get applicationSubmitted => 'You applied for';

  @override
  String get errorMessage => 'Error';

  @override
  String get invalidMapUrl => 'Invalid map URL';

  @override
  String get failedOpenMap => 'Failed to open map';

  @override
  String get tariffBusiness1Title => 'Business L1';

  @override
  String get tariffBusiness1Desc => 'Advanced tools';

  @override
  String get tariffBusiness1Price => '1490 ₽';

  @override
  String get tariffBusiness1Feature1 => 'Create events';

  @override
  String get tariffBusiness1Feature2 => 'Manage participants';

  @override
  String get tariffBusiness1Feature3 => 'Statistics';

  @override
  String get tariffBusiness2Title => 'Business L2';

  @override
  String get tariffBusiness2Desc => 'Priority support';

  @override
  String get tariffBusiness2Price => '2990 ₽';

  @override
  String get tariffBusiness2Feature1 => 'All from L1';

  @override
  String get tariffBusiness2Feature2 => 'Priority support';

  @override
  String get tariffBusiness2Feature3 => 'API access';

  @override
  String get tariffBusiness3Title => 'Business L3';

  @override
  String get tariffBusiness3Desc => 'Maximum capabilities';

  @override
  String get tariffBusiness3Price => '4990 ₽';

  @override
  String get tariffBusiness3Feature1 => 'All from L2';

  @override
  String get tariffBusiness3Feature2 => 'Auto moderation';

  @override
  String get tariffBusiness3Feature3 => 'Customization';

  @override
  String get locationParsingError_invalidUrl =>
      'The provided link is not a valid URL.';

  @override
  String get locationParsingError_unsupportedMapProvider =>
      'Only Google Maps and Yandex Maps links are supported.';

  @override
  String get locationParsingError_parsingFailed =>
      'Could not extract coordinates from the link. Please check the link or enter the address manually.';

  @override
  String get locationParsingError_networkError =>
      'Network error. Could not resolve the short link. Please check your internet connection.';

  @override
  String get eventSearchHint => 'Search events';

  @override
  String get cityNotSelected => 'City not selected';

  @override
  String get resetAll => 'Reset all';

  @override
  String get sortDate => 'Date sort';

  @override
  String get sortPrice => 'Price sort';

  @override
  String get filterAllSimple => 'All';

  @override
  String get filterMine => 'Mine';

  @override
  String get filterParticipating => 'Participating';

  @override
  String get filterAppliedSimple => 'Applied';

  @override
  String get filterArchive => 'Archive';

  @override
  String get joinEvent => 'Join';

  @override
  String get leaveEvent => 'Leave';

  @override
  String get noPhotoLabel => 'No photo';

  @override
  String get tableLabel => 'Table';

  @override
  String get listLabel => 'List';

  @override
  String get topSlotsLabel => 'Top slots';

  @override
  String get addressLabel => 'Address';

  @override
  String get fixedSlotLabel => 'Slot: fixed';

  @override
  String get priceFreeLabel => 'Price: free';

  @override
  String get priceLabel => 'Price';

  @override
  String get messageLabel => 'Message';

  @override
  String get memberLabel => 'Member';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get messageSubtitle => 'Discussing slot and details.';

  @override
  String get tagsTooltip => 'Tags';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get profileLabel => 'Profile';

  @override
  String get themeLabel => 'Theme';

  @override
  String get top3SlotsLabel => 'Top-3 slots';

  @override
  String get newestLabel => 'Newest';

  @override
  String get oldestLabel => 'Oldest';

  @override
  String get cityPlaceholder => 'City not selected';

  @override
  String get dayLabel => 'Day';

  @override
  String get chatInputHint => 'Write a message';

  @override
  String get sendLabel => 'Send';

  @override
  String get replyLabel => 'Reply';

  @override
  String get tagMismatchLabel => 'Tag does not match';

  @override
  String get collapseLabel => 'Collapse';

  @override
  String get expandLabel => 'Expand';
}
