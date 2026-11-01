import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ku'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// No description provided for @applyHost.
  ///
  /// In en, this message translates to:
  /// **'Host Approval'**
  String get applyHost;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Tom Chat'**
  String get appName;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String id(Object id);

  /// No description provided for @changePicture.
  ///
  /// In en, this message translates to:
  /// **'Change Picture'**
  String get changePicture;

  /// No description provided for @agencyName.
  ///
  /// In en, this message translates to:
  /// **'Agency Name'**
  String get agencyName;

  /// No description provided for @agencyId.
  ///
  /// In en, this message translates to:
  /// **'Agency ID'**
  String get agencyId;

  /// No description provided for @agencyOwner.
  ///
  /// In en, this message translates to:
  /// **'Agency Owner'**
  String get agencyOwner;

  /// No description provided for @ownerId.
  ///
  /// In en, this message translates to:
  /// **'Owner ID'**
  String get ownerId;

  /// No description provided for @hostCounts.
  ///
  /// In en, this message translates to:
  /// **'Total Hosts'**
  String get hostCounts;

  /// No description provided for @createDate.
  ///
  /// In en, this message translates to:
  /// **'Creation Date'**
  String get createDate;

  /// No description provided for @notics.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notics;

  /// No description provided for @hostManagement.
  ///
  /// In en, this message translates to:
  /// **'Host Management'**
  String get hostManagement;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agency;

  /// No description provided for @editFile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editFile;

  /// No description provided for @totalMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Monthly Income'**
  String get totalMonthlyIncome;

  /// No description provided for @totalWeeklyIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Weekly Income'**
  String get totalWeeklyIncome;

  /// No description provided for @totalDayIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Income'**
  String get totalDayIncome;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @actibeHosts.
  ///
  /// In en, this message translates to:
  /// **'Active Hosts'**
  String get actibeHosts;

  /// No description provided for @hostOrder.
  ///
  /// In en, this message translates to:
  /// **'Host Requests'**
  String get hostOrder;

  /// No description provided for @newHost.
  ///
  /// In en, this message translates to:
  /// **'New Hosts'**
  String get newHost;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @inviteHost.
  ///
  /// In en, this message translates to:
  /// **'Invite Host'**
  String get inviteHost;

  /// No description provided for @activeHost.
  ///
  /// In en, this message translates to:
  /// **'Active Hosts'**
  String get activeHost;

  /// No description provided for @agencyRoom.
  ///
  /// In en, this message translates to:
  /// **'Agency Rooms'**
  String get agencyRoom;

  /// No description provided for @medalsList.
  ///
  /// In en, this message translates to:
  /// **'Medals List'**
  String get medalsList;

  /// No description provided for @wear.
  ///
  /// In en, this message translates to:
  /// **'Wear'**
  String get wear;

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

  /// No description provided for @takeOff.
  ///
  /// In en, this message translates to:
  /// **'Take Off'**
  String get takeOff;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chats;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get systemNotifications;

  /// No description provided for @agencyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Agency Notifications'**
  String get agencyNotifications;

  /// No description provided for @tomChatTeam.
  ///
  /// In en, this message translates to:
  /// **'TomChat Team'**
  String get tomChatTeam;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthday;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get selectCountry;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @fmale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get fmale;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @readPolcy.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get readPolcy;

  /// No description provided for @policy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get policy;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameMustBeMoreThan3.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 4 characters long'**
  String get nameMustBeMoreThan3;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @enterYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Type something...'**
  String get enterYourMessage;

  /// No description provided for @ertbat.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get ertbat;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @cp.
  ///
  /// In en, this message translates to:
  /// **'CP'**
  String get cp;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @ifollow.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get ifollow;

  /// No description provided for @last.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get last;

  /// No description provided for @thereAreNoResult.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get thereAreNoResult;

  /// No description provided for @therAreNoNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No Notifications Yet'**
  String get therAreNoNotificationsYet;

  /// No description provided for @copyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy Message'**
  String get copyMessage;

  /// No description provided for @plsChooseImage.
  ///
  /// In en, this message translates to:
  /// **'Please choose an image'**
  String get plsChooseImage;

  /// No description provided for @titleIsRequird.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleIsRequird;

  /// No description provided for @thePostCreatedSuccessfuly.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully'**
  String get thePostCreatedSuccessfuly;

  /// No description provided for @enterComment.
  ///
  /// In en, this message translates to:
  /// **'Enter a comment'**
  String get enterComment;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @postImage.
  ///
  /// In en, this message translates to:
  /// **'Post Image'**
  String get postImage;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Title'**
  String get postTitle;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;

  /// No description provided for @postDesc.
  ///
  /// In en, this message translates to:
  /// **'Post Description'**
  String get postDesc;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @noPostsFound.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get noPostsFound;

  /// No description provided for @editInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Info'**
  String get editInfo;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get state;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @followBack.
  ///
  /// In en, this message translates to:
  /// **'Follow Back'**
  String get followBack;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @entries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entries;

  /// No description provided for @thereAreNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries'**
  String get thereAreNoEntries;

  /// No description provided for @frames.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get frames;

  /// No description provided for @thereAreNoFrams.
  ///
  /// In en, this message translates to:
  /// **'No frames'**
  String get thereAreNoFrams;

  /// No description provided for @gifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get gifts;

  /// No description provided for @thereAreNoGifts.
  ///
  /// In en, this message translates to:
  /// **'No gifts'**
  String get thereAreNoGifts;

  /// No description provided for @medals.
  ///
  /// In en, this message translates to:
  /// **'Medals'**
  String get medals;

  /// No description provided for @thereAreNoMedalsYet.
  ///
  /// In en, this message translates to:
  /// **'No medals yet'**
  String get thereAreNoMedalsYet;

  /// No description provided for @visitors.
  ///
  /// In en, this message translates to:
  /// **'Visitors'**
  String get visitors;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @moments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get moments;

  /// No description provided for @thereAreNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get thereAreNoDataYet;

  /// No description provided for @basicTools.
  ///
  /// In en, this message translates to:
  /// **'Basic Tools'**
  String get basicTools;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @micMode.
  ///
  /// In en, this message translates to:
  /// **'Seat Mode'**
  String get micMode;

  /// No description provided for @roomSettings.
  ///
  /// In en, this message translates to:
  /// **'Room Settings'**
  String get roomSettings;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get keep;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @gameList.
  ///
  /// In en, this message translates to:
  /// **'Games List'**
  String get gameList;

  /// No description provided for @micModeNum.
  ///
  /// In en, this message translates to:
  /// **'{mode} Mic'**
  String micModeNum(Object mode);

  /// No description provided for @onlineList.
  ///
  /// In en, this message translates to:
  /// **'Online Users'**
  String get onlineList;

  /// No description provided for @hsot.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get hsot;

  /// No description provided for @removeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin'**
  String get removeAdmin;

  /// No description provided for @setAdmin.
  ///
  /// In en, this message translates to:
  /// **'Set Admin'**
  String get setAdmin;

  /// No description provided for @kickUser.
  ///
  /// In en, this message translates to:
  /// **'Kick User'**
  String get kickUser;

  /// No description provided for @chooseImageFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Choose from device'**
  String get chooseImageFromDevice;

  /// No description provided for @templetes.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templetes;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @roomInfo.
  ///
  /// In en, this message translates to:
  /// **'Room Level'**
  String get roomInfo;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendGift.
  ///
  /// In en, this message translates to:
  /// **'Send Gift'**
  String get sendGift;

  /// No description provided for @down.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get down;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @askChair.
  ///
  /// In en, this message translates to:
  /// **'Request Seat'**
  String get askChair;

  /// No description provided for @takeTheMic.
  ///
  /// In en, this message translates to:
  /// **'Take Seat'**
  String get takeTheMic;

  /// No description provided for @leaveTheMic.
  ///
  /// In en, this message translates to:
  /// **'Leave Seat'**
  String get leaveTheMic;

  /// No description provided for @openTheMic.
  ///
  /// In en, this message translates to:
  /// **'Open Seat'**
  String get openTheMic;

  /// No description provided for @closeTheMic.
  ///
  /// In en, this message translates to:
  /// **'Close Seat'**
  String get closeTheMic;

  /// No description provided for @seatRequest.
  ///
  /// In en, this message translates to:
  /// **'Seat Request'**
  String get seatRequest;

  /// No description provided for @seatReuestBy.
  ///
  /// In en, this message translates to:
  /// **'{user} requested to take the seat?'**
  String seatReuestBy(Object user);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @recharged.
  ///
  /// In en, this message translates to:
  /// **'Recharged'**
  String get recharged;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @thisLiveEnded.
  ///
  /// In en, this message translates to:
  /// **'This room has ended'**
  String get thisLiveEnded;

  /// No description provided for @ops.
  ///
  /// In en, this message translates to:
  /// **'Oops'**
  String get ops;

  /// No description provided for @roomBackground.
  ///
  /// In en, this message translates to:
  /// **'Room Background'**
  String get roomBackground;

  /// No description provided for @roomIcon.
  ///
  /// In en, this message translates to:
  /// **'Room Icon'**
  String get roomIcon;

  /// No description provided for @allowUsersToTakeMic.
  ///
  /// In en, this message translates to:
  /// **'Allow users to take seats'**
  String get allowUsersToTakeMic;

  /// No description provided for @allowUsersToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow users to send messages'**
  String get allowUsersToSendMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @rich.
  ///
  /// In en, this message translates to:
  /// **'Wealth'**
  String get rich;

  /// No description provided for @gathib.
  ///
  /// In en, this message translates to:
  /// **'Attraction'**
  String get gathib;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get pay;

  /// No description provided for @orderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmation'**
  String get orderConfirmation;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @userID.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userID;

  /// No description provided for @wrongId.
  ///
  /// In en, this message translates to:
  /// **'Invalid User ID'**
  String get wrongId;

  /// No description provided for @backpack.
  ///
  /// In en, this message translates to:
  /// **'Backpack'**
  String get backpack;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @bubles.
  ///
  /// In en, this message translates to:
  /// **'Bubbles'**
  String get bubles;

  /// No description provided for @soundWave.
  ///
  /// In en, this message translates to:
  /// **'Sound Waves'**
  String get soundWave;

  /// No description provided for @vip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get vip;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @mas.
  ///
  /// In en, this message translates to:
  /// **'Diamonds'**
  String get mas;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutMsg;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @emptyValue.
  ///
  /// In en, this message translates to:
  /// **'Empty value'**
  String get emptyValue;

  /// No description provided for @errorNumberValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get errorNumberValue;

  /// No description provided for @plsChoose.
  ///
  /// In en, this message translates to:
  /// **'Please choose'**
  String get plsChoose;

  /// No description provided for @youShouldGivePremissionToTheApp.
  ///
  /// In en, this message translates to:
  /// **'You must grant the app camera access'**
  String get youShouldGivePremissionToTheApp;

  /// No description provided for @theOperatorIsDoneSeccessfuly.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get theOperatorIsDoneSeccessfuly;

  /// No description provided for @errorOcoredPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again'**
  String get errorOcoredPleaseTryAgain;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @minte.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minte;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @newRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get newRoom;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @mine.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get mine;

  /// No description provided for @clickAginToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get clickAginToExit;

  /// No description provided for @noGuestUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'You must choose a guest'**
  String get noGuestUsersTitle;

  /// No description provided for @dayly.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dayly;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'users'**
  String get users;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @upgradeSpace.
  ///
  /// In en, this message translates to:
  /// **'Upgrade distance {space} EXP value'**
  String upgradeSpace(Object space);

  /// No description provided for @showLevelDesc.
  ///
  /// In en, this message translates to:
  /// **'Show level description'**
  String get showLevelDesc;

  /// No description provided for @levelPoint1.
  ///
  /// In en, this message translates to:
  /// **'1. 1 Coinza = 1 level point'**
  String get levelPoint1;

  /// No description provided for @endAfter.
  ///
  /// In en, this message translates to:
  /// **'End after'**
  String get endAfter;

  /// No description provided for @joinAgency.
  ///
  /// In en, this message translates to:
  /// **'Join Agency'**
  String get joinAgency;

  /// No description provided for @youHaveSentJoin.
  ///
  /// In en, this message translates to:
  /// **'You have already sent a join request to the {agency}. Do you want to continue?'**
  String youHaveSentJoin(Object agency);

  /// No description provided for @continue0.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue0;

  /// No description provided for @areYouSrueYouWantToLeve.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave?'**
  String get areYouSrueYouWantToLeve;

  /// No description provided for @areYouSrueYouWantToLeveDesc.
  ///
  /// In en, this message translates to:
  /// **'You are currently a guest, and another person is watching you.'**
  String get areYouSrueYouWantToLeveDesc;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @incomes.
  ///
  /// In en, this message translates to:
  /// **'Agency Incomes'**
  String get incomes;

  /// No description provided for @agencyNotice.
  ///
  /// In en, this message translates to:
  /// **'Agency notice'**
  String get agencyNotice;

  /// No description provided for @blockList.
  ///
  /// In en, this message translates to:
  /// **'Bloock List'**
  String get blockList;

  /// No description provided for @typeGift.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get typeGift;

  /// No description provided for @typeCp.
  ///
  /// In en, this message translates to:
  /// **'CP'**
  String get typeCp;

  /// No description provided for @typeCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get typeCountry;

  /// No description provided for @typeLuck.
  ///
  /// In en, this message translates to:
  /// **'Lucky'**
  String get typeLuck;

  /// No description provided for @typeGifter_level.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get typeGifter_level;

  /// No description provided for @typeVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get typeVip;

  /// No description provided for @typeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special Gifts'**
  String get typeSpecial;

  /// No description provided for @notEnoughGiftCount.
  ///
  /// In en, this message translates to:
  /// **'You do not have enough of this gift.'**
  String get notEnoughGiftCount;

  /// No description provided for @withdrawHistory.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal History'**
  String get withdrawHistory;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get noDataFound;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @withdrawProcessing.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal is being processed'**
  String get withdrawProcessing;

  /// No description provided for @withdrawApproved.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal approved successfully'**
  String get withdrawApproved;

  /// No description provided for @withdrawRejected.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal was rejected'**
  String get withdrawRejected;

  /// No description provided for @remainingCoins.
  ///
  /// In en, this message translates to:
  /// **'Remaining Coins'**
  String get remainingCoins;

  /// No description provided for @coinHistory.
  ///
  /// In en, this message translates to:
  /// **'Coin History'**
  String get coinHistory;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @recharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get recharge;

  /// No description provided for @coins_balance.
  ///
  /// In en, this message translates to:
  /// **'Coins Balance'**
  String get coins_balance;

  /// No description provided for @noCointPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recharge plans available'**
  String get noCointPlansAvailable;

  /// No description provided for @cannot_recharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge is currently unavailable'**
  String get cannot_recharge;

  /// No description provided for @recharge_not_available.
  ///
  /// In en, this message translates to:
  /// **'Recharge service is not available'**
  String get recharge_not_available;

  /// No description provided for @exchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get exchange;

  /// No description provided for @switch_account.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get switch_account;

  /// No description provided for @add_account.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get add_account;

  /// No description provided for @showSvgaEnteries.
  ///
  /// In en, this message translates to:
  /// **'Show special entries'**
  String get showSvgaEnteries;

  /// No description provided for @showSvgaGifts.
  ///
  /// In en, this message translates to:
  /// **'Show special gifts'**
  String get showSvgaGifts;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @treasureBoxEngageMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Treasure Boxes to engage with your LIVE viewers'**
  String get treasureBoxEngageMessage;

  /// No description provided for @quantityOption.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {count}'**
  String quantityOption(Object count);

  /// No description provided for @collectCoinsOption.
  ///
  /// In en, this message translates to:
  /// **'{count} people can collect Coins.'**
  String collectCoinsOption(Object count);

  /// No description provided for @otherOptions.
  ///
  /// In en, this message translates to:
  /// **'Other options >'**
  String get otherOptions;

  /// No description provided for @treasureBoxAgreementText.
  ///
  /// In en, this message translates to:
  /// **'By tapping on \"Send\", you agree to the Treasure Box Rules.\nA Treasure Box cannot be recalled once it is sent.'**
  String get treasureBoxAgreementText;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @treasureBoxSuccess.
  ///
  /// In en, this message translates to:
  /// **'Treasure Box Sent Successfully!'**
  String get treasureBoxSuccess;

  /// No description provided for @treasureBoxTab.
  ///
  /// In en, this message translates to:
  /// **'Treasure Box'**
  String get treasureBoxTab;

  /// No description provided for @portalTab.
  ///
  /// In en, this message translates to:
  /// **'Portal'**
  String get portalTab;

  /// No description provided for @reachViewers.
  ///
  /// In en, this message translates to:
  /// **'Reach {count} viewers'**
  String reachViewers(Object count);

  /// No description provided for @reachingViewers.
  ///
  /// In en, this message translates to:
  /// **'Reaching viewers'**
  String get reachingViewers;

  /// No description provided for @treasureBox.
  ///
  /// In en, this message translates to:
  /// **'Treasure Box'**
  String get treasureBox;

  /// No description provided for @coinsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Coins'**
  String coinsCount(Object count);

  /// No description provided for @sendPortalHeader.
  ///
  /// In en, this message translates to:
  /// **'Send Portal to reach more\nviewers'**
  String get sendPortalHeader;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @customizePortalOptions.
  ///
  /// In en, this message translates to:
  /// **'Customize portal options'**
  String get customizePortalOptions;

  /// No description provided for @customizeButton.
  ///
  /// In en, this message translates to:
  /// **'Customize >'**
  String get customizeButton;

  /// No description provided for @portalAgreementText.
  ///
  /// In en, this message translates to:
  /// **'By tapping Send, you accept the Portal Terms and Treasure Box Rules.\nSending Portals and Treasure Boxes can\'t be undone.'**
  String get portalAgreementText;

  /// No description provided for @sentTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentTitle;

  /// No description provided for @portalSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Portal sent successfully!'**
  String get portalSentSuccess;

  /// No description provided for @customTreasureBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Treasure Box'**
  String get customTreasureBoxTitle;

  /// No description provided for @customTreasureBoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send Treasure Boxes to engage with your LIVE viewers'**
  String get customTreasureBoxSubtitle;

  /// No description provided for @totalCoinsHint.
  ///
  /// In en, this message translates to:
  /// **'Total (2000–1000000)'**
  String get totalCoinsHint;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'Quantity (1–500)'**
  String get quantityHint;

  /// No description provided for @countdownHint.
  ///
  /// In en, this message translates to:
  /// **'Countdown period (1–5)'**
  String get countdownHint;

  /// No description provided for @coinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coinsLabel;

  /// No description provided for @peopleLabel.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get peopleLabel;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesLabel;

  /// No description provided for @treasureBoxInfo.
  ///
  /// In en, this message translates to:
  /// **'By tapping on \"Send\", you agree to the Treasure Box Rules.\nA Treasure Box cannot be recalled once it is sent.'**
  String get treasureBoxInfo;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @errorTotalCoinsRange.
  ///
  /// In en, this message translates to:
  /// **'Total coins must be between 20 and 10000'**
  String get errorTotalCoinsRange;

  /// No description provided for @errorQuantityRange.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be between 1 and 500'**
  String get errorQuantityRange;

  /// No description provided for @errorCountdownRange.
  ///
  /// In en, this message translates to:
  /// **'Countdown must be between 1 and 5 minutes'**
  String get errorCountdownRange;

  /// No description provided for @youGetCoins.
  ///
  /// In en, this message translates to:
  /// **'You get {reward} coin from this box'**
  String youGetCoins(Object reward);

  /// No description provided for @allCoinsCollected.
  ///
  /// In en, this message translates to:
  /// **'All coins were collected. Be quicker next time!'**
  String get allCoinsCollected;

  /// No description provided for @treasureBoxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Treasure box is empty'**
  String get treasureBoxEmpty;

  /// No description provided for @getIt.
  ///
  /// In en, this message translates to:
  /// **'Get it'**
  String get getIt;

  /// No description provided for @viewersCanCollectCoins.
  ///
  /// In en, this message translates to:
  /// **'{coins} viewers can collect these Coins by opening the Treasure Box.\nNo purchase is necessary.'**
  String viewersCanCollectCoins(Object coins);

  /// No description provided for @errorInvalidValues.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid values'**
  String get errorInvalidValues;

  /// No description provided for @errorCoinsRange.
  ///
  /// In en, this message translates to:
  /// **'Coins must be between 2000 and 1000000'**
  String get errorCoinsRange;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get opened;

  /// No description provided for @userSentRedBox.
  ///
  /// In en, this message translates to:
  /// **'{user} Sent Treasure Boxes'**
  String userSentRedBox(Object user);

  /// No description provided for @effect.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get effect;

  /// No description provided for @unSamePassword.
  ///
  /// In en, this message translates to:
  /// **'Unmatched password'**
  String get unSamePassword;

  /// No description provided for @repeatedPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get repeatedPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @sendCpToFriend.
  ///
  /// In en, this message translates to:
  /// **'Send {cpName} to apply for {user}\'s {cpName}. If the application is not accepted, the cost will be refund.'**
  String sendCpToFriend(Object cpName, Object user);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get active;

  /// No description provided for @unactive.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get unactive;

  /// No description provided for @roomDescription.
  ///
  /// In en, this message translates to:
  /// **'Room Description'**
  String get roomDescription;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the account?'**
  String get deleteAccountMsg;

  /// No description provided for @deleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Once confirmed, you will not be able to recover this account.'**
  String get deleteAccountDesc;

  /// No description provided for @closeCp.
  ///
  /// In en, this message translates to:
  /// **'Disconnect from {user}'**
  String closeCp(Object user);

  /// No description provided for @plsSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get plsSelectCountry;

  /// No description provided for @plsSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get plsSelectGender;

  /// No description provided for @plsSelectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date of birth'**
  String get plsSelectBirthDate;

  /// No description provided for @mustAcceptUsagePolicy.
  ///
  /// In en, this message translates to:
  /// **'You must accept the usage policy'**
  String get mustAcceptUsagePolicy;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @unableSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in with Google'**
  String get unableSignInWithGoogle;

  /// No description provided for @attractionLevelReached.
  ///
  /// In en, this message translates to:
  /// **'Attraction level reached {level}'**
  String attractionLevelReached(Object level);

  /// No description provided for @notificationStoryLike.
  ///
  /// In en, this message translates to:
  /// **'{user} liked your story'**
  String notificationStoryLike(Object user);

  /// No description provided for @notificationVideoLike.
  ///
  /// In en, this message translates to:
  /// **'{user} liked your video'**
  String notificationVideoLike(Object user);

  /// No description provided for @notificationVideoPost.
  ///
  /// In en, this message translates to:
  /// **'{user} posted a new video'**
  String notificationVideoPost(Object user);

  /// No description provided for @notificationVideoRepost.
  ///
  /// In en, this message translates to:
  /// **'{user} reposted your video'**
  String notificationVideoRepost(Object user);

  /// No description provided for @notificationCommentAdd.
  ///
  /// In en, this message translates to:
  /// **'{user} commented: {comment}'**
  String notificationCommentAdd(Object comment, Object user);

  /// No description provided for @notificationCommentLike.
  ///
  /// In en, this message translates to:
  /// **'{user} liked your comment: {comment}'**
  String notificationCommentLike(Object comment, Object user);

  /// No description provided for @notificationCommentReply.
  ///
  /// In en, this message translates to:
  /// **'{user} replied to your comment: {comment}'**
  String notificationCommentReply(Object comment, Object user);

  /// No description provided for @notificationLiveStart.
  ///
  /// In en, this message translates to:
  /// **'{user} started a live stream'**
  String notificationLiveStart(Object user);

  /// No description provided for @notificationPersonFollow.
  ///
  /// In en, this message translates to:
  /// **'{user} started following you'**
  String notificationPersonFollow(Object user);

  /// No description provided for @notificationStory.
  ///
  /// In en, this message translates to:
  /// **'{user} added a story'**
  String notificationStory(Object user);

  /// No description provided for @notificationPost.
  ///
  /// In en, this message translates to:
  /// **'{user} created a new post'**
  String notificationPost(Object user);

  /// No description provided for @notificationMention.
  ///
  /// In en, this message translates to:
  /// **'{user} mentioned you'**
  String notificationMention(Object user);

  /// No description provided for @notificationGift.
  ///
  /// In en, this message translates to:
  /// **'{user} sent you a gift'**
  String notificationGift(Object user);

  /// No description provided for @notificationSystem.
  ///
  /// In en, this message translates to:
  /// **'{user} sent a system notification'**
  String notificationSystem(Object user);

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @charge.
  ///
  /// In en, this message translates to:
  /// **'Charge'**
  String get charge;

  /// No description provided for @send1.
  ///
  /// In en, this message translates to:
  /// **'Send Coins'**
  String get send1;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @notEnoughMoney.
  ///
  /// In en, this message translates to:
  /// **'Not enough money'**
  String get notEnoughMoney;

  /// No description provided for @iWantMakeCpWithU.
  ///
  /// In en, this message translates to:
  /// **'I want to establish a close friend relationship with you'**
  String get iWantMakeCpWithU;

  /// No description provided for @acceptCp.
  ///
  /// In en, this message translates to:
  /// **'The relationship has been successfully established'**
  String get acceptCp;

  /// No description provided for @rejectCp.
  ///
  /// In en, this message translates to:
  /// **'The relationship has been successfully rejected'**
  String get rejectCp;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @permissionsRequired.
  ///
  /// In en, this message translates to:
  /// **'Permissions Required'**
  String get permissionsRequired;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @joinedToRoom.
  ///
  /// In en, this message translates to:
  /// **'Joined to room'**
  String get joinedToRoom;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @thisAccountUnderBannded.
  ///
  /// In en, this message translates to:
  /// **'You have been banned from using the app.'**
  String get thisAccountUnderBannded;

  /// No description provided for @rechargeDiamond.
  ///
  /// In en, this message translates to:
  /// **'Exchange Diamond'**
  String get rechargeDiamond;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamond;

  /// No description provided for @myAccounts.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get myAccounts;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @areYouSrueYouWantToDelteThisAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account?'**
  String get areYouSrueYouWantToDelteThisAccount;

  /// No description provided for @withdraw1.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw1;

  /// No description provided for @plsChooseAccount.
  ///
  /// In en, this message translates to:
  /// **'Please choose account.'**
  String get plsChooseAccount;

  /// No description provided for @youCanSendOrdersBetween.
  ///
  /// In en, this message translates to:
  /// **'You can only send orders between {start} and {end} of each month'**
  String youCanSendOrdersBetween(Object end, Object start);

  /// No description provided for @youHaveAlreadyMaxOrders.
  ///
  /// In en, this message translates to:
  /// **'You have already reached the maximum number of orders for this month.'**
  String get youHaveAlreadyMaxOrders;

  /// No description provided for @minAmountis.
  ///
  /// In en, this message translates to:
  /// **'The minimum withdrawal amount is {price}\$'**
  String minAmountis(Object price);

  /// No description provided for @withdrawAgencyies.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Agencies'**
  String get withdrawAgencyies;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get win;

  /// No description provided for @withdrawOrders.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Orders'**
  String get withdrawOrders;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @pending1.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending1;

  /// No description provided for @rejected1.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected1;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get onHold;

  /// No description provided for @active1.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get active1;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order No'**
  String get orderNumber;

  /// No description provided for @withdrawAgencyId.
  ///
  /// In en, this message translates to:
  /// **'withdraw Agency ID'**
  String get withdrawAgencyId;

  /// No description provided for @blocks.
  ///
  /// In en, this message translates to:
  /// **'Block List'**
  String get blocks;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @youAreBlockedFromLive.
  ///
  /// In en, this message translates to:
  /// **'You have been blocked from accessing this live stream'**
  String get youAreBlockedFromLive;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Recharge via the website and get a discount 20%'**
  String get discount;

  /// No description provided for @unFollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unFollow;

  /// No description provided for @iFollow.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get iFollow;

  /// No description provided for @profileFrame.
  ///
  /// In en, this message translates to:
  /// **'Profile Frame'**
  String get profileFrame;

  /// No description provided for @enterRoomPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter room password...'**
  String get enterRoomPassword;

  /// No description provided for @thisIsPrivateRoom.
  ///
  /// In en, this message translates to:
  /// **'This is a private room!'**
  String get thisIsPrivateRoom;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @errorPasswordPlsPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get errorPasswordPlsPleaseTryAgain;

  /// No description provided for @thisUserNotExis.
  ///
  /// In en, this message translates to:
  /// **'This user does not exist'**
  String get thisUserNotExis;

  /// No description provided for @mic.
  ///
  /// In en, this message translates to:
  /// **'Grant the mic'**
  String get mic;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @paymentsOrders.
  ///
  /// In en, this message translates to:
  /// **'Recharge Orders'**
  String get paymentsOrders;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order Id'**
  String get orderId;

  /// No description provided for @inviteToSeat.
  ///
  /// In en, this message translates to:
  /// **'You have been invited to take a seat'**
  String get inviteToSeat;

  /// No description provided for @buyDeleteCart.
  ///
  /// In en, this message translates to:
  /// **'يجب شراء بطاقة حذف CP لإكمال العملية'**
  String get buyDeleteCart;

  /// No description provided for @noImagesAvilableInGallery.
  ///
  /// In en, this message translates to:
  /// **'No images available in gallery'**
  String get noImagesAvilableInGallery;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @carizma.
  ///
  /// In en, this message translates to:
  /// **'Carizma'**
  String get carizma;

  /// No description provided for @resetCarizma.
  ///
  /// In en, this message translates to:
  /// **'Reset Carizma'**
  String get resetCarizma;

  /// No description provided for @thereAreNoCp.
  ///
  /// In en, this message translates to:
  /// **'There are no relationships to cancel'**
  String get thereAreNoCp;

  /// No description provided for @ranking.
  ///
  /// In en, this message translates to:
  /// **'ranking'**
  String get ranking;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Prize'**
  String get reward;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @bomb.
  ///
  /// In en, this message translates to:
  /// **'exploded'**
  String get bomb;

  /// No description provided for @inKey.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inKey;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @live_started.
  ///
  /// In en, this message translates to:
  /// **'Live started by followed user'**
  String get live_started;

  /// No description provided for @new_follower.
  ///
  /// In en, this message translates to:
  /// **'New follower'**
  String get new_follower;

  /// No description provided for @post_interaction.
  ///
  /// In en, this message translates to:
  /// **'Post interaction'**
  String get post_interaction;

  /// No description provided for @store_item_or_vip.
  ///
  /// In en, this message translates to:
  /// **'Store item / VIP received'**
  String get store_item_or_vip;

  /// No description provided for @private_message.
  ///
  /// In en, this message translates to:
  /// **'Private message'**
  String get private_message;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Disabling a type affects Firebase push only. System notifications still appear in the app..'**
  String get notificationSettingsDesc;

  /// No description provided for @diceTitle.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get diceTitle;

  /// No description provided for @diceExit.
  ///
  /// In en, this message translates to:
  /// **'Do you want to leave the game?'**
  String get diceExit;

  /// No description provided for @diceLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get diceLeave;

  /// No description provided for @diceStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get diceStay;

  /// No description provided for @diceRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get diceRetry;

  /// No description provided for @diceNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection interrupted. Retry to recover your round safely.'**
  String get diceNetwork;

  /// No description provided for @diceAuth.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to play.'**
  String get diceAuth;

  /// No description provided for @diceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get diceLoading;

  /// No description provided for @diceClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get diceClose;

  /// No description provided for @rechargeAgencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge Agency'**
  String get rechargeAgencyTitle;

  /// No description provided for @rechargeViaAgency.
  ///
  /// In en, this message translates to:
  /// **'Recharge through an agency'**
  String get rechargeViaAgency;

  /// No description provided for @agencyDiscount.
  ///
  /// In en, this message translates to:
  /// **'{percent}% discount'**
  String agencyDiscount(String percent);

  /// No description provided for @withdrawalAgencyNumber.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal agency number'**
  String get withdrawalAgencyNumber;

  /// No description provided for @withdrawalAgencyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the agency number or select from the list'**
  String get withdrawalAgencyHint;

  /// No description provided for @agencyInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid agency number'**
  String get agencyInvalidNumber;

  /// No description provided for @agencyWhatsAppError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open WhatsApp for this agency'**
  String get agencyWhatsAppError;

  /// No description provided for @agencyConfirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal delivery'**
  String get agencyConfirmDelivery;

  /// No description provided for @agencyConfirmPaid.
  ///
  /// In en, this message translates to:
  /// **'Have you paid {amount} USD to user #{userId}?'**
  String agencyConfirmPaid(String amount, String userId);

  /// No description provided for @agencyPaidDelivered.
  ///
  /// In en, this message translates to:
  /// **'Paid and delivered'**
  String get agencyPaidDelivered;

  /// No description provided for @agencyOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the operation. Check your connection and try again.'**
  String get agencyOperationFailed;

  /// No description provided for @agencyCoinsBalance.
  ///
  /// In en, this message translates to:
  /// **'Agency coins balance: {balance}'**
  String agencyCoinsBalance(String balance);

  /// No description provided for @agencyUsdBalance.
  ///
  /// In en, this message translates to:
  /// **'Agency USD balance: {balance} USD'**
  String agencyUsdBalance(String balance);

  /// No description provided for @agencySendCoins.
  ///
  /// In en, this message translates to:
  /// **'Send Coins'**
  String get agencySendCoins;

  /// No description provided for @agencyNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending withdrawal requests'**
  String get agencyNoPending;

  /// No description provided for @agencyRequestSummary.
  ///
  /// In en, this message translates to:
  /// **'Request #{id} · {amount} USD'**
  String agencyRequestSummary(String id, String amount);

  /// No description provided for @agencyAccountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account holder: {name}'**
  String agencyAccountHolder(String name);

  /// No description provided for @agencyAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account: {account}'**
  String agencyAccountNumber(String account);

  /// No description provided for @agencyAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account type: {type}'**
  String agencyAccountType(String type);

  /// No description provided for @agencyMarkDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as delivered'**
  String get agencyMarkDelivered;

  /// No description provided for @agencySendCoinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Send coins from the agency balance'**
  String get agencySendCoinsTitle;

  /// No description provided for @agencyCoinAmount.
  ///
  /// In en, this message translates to:
  /// **'Number of coins'**
  String get agencyCoinAmount;

  /// No description provided for @agencyPositiveInteger.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number greater than zero'**
  String get agencyPositiveInteger;

  /// No description provided for @agencyAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not own this recharge agency.'**
  String get agencyAccessDenied;

  /// No description provided for @agencyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Agency not found or unavailable.'**
  String get agencyNotFound;

  /// No description provided for @agencyInvalidAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a valid withdrawal account.'**
  String get agencyInvalidAccount;

  /// No description provided for @agencyInsufficientCoins.
  ///
  /// In en, this message translates to:
  /// **'The agency has insufficient coins.'**
  String get agencyInsufficientCoins;

  /// No description provided for @agencyInsufficientWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'The user has insufficient USD for this withdrawal.'**
  String get agencyInsufficientWithdrawal;

  /// No description provided for @agencyWithdrawalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request not found for this agency.'**
  String get agencyWithdrawalUnavailable;

  /// No description provided for @agencyWithdrawalProcessed.
  ///
  /// In en, this message translates to:
  /// **'This withdrawal request has already been processed.'**
  String get agencyWithdrawalProcessed;

  /// No description provided for @agencyTransferConflict.
  ///
  /// In en, this message translates to:
  /// **'This transfer request has changed. Close the form and try again.'**
  String get agencyTransferConflict;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ku',
    'tr',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ku':
      return AppLocalizationsKu();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
