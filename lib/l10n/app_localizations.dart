import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Mihwar'**
  String get app_name;

  /// No description provided for @select_role.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get select_role;

  /// No description provided for @role_entry_data_truck.
  ///
  /// In en, this message translates to:
  /// **'Data Collection Truck'**
  String get role_entry_data_truck;

  /// No description provided for @role_entry_smart_truck.
  ///
  /// In en, this message translates to:
  /// **'Smart Prediction Truck'**
  String get role_entry_smart_truck;

  /// No description provided for @role_entry_area_supervisor.
  ///
  /// In en, this message translates to:
  /// **'Area Supervisor'**
  String get role_entry_area_supervisor;

  /// No description provided for @role_entry_governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate Manager'**
  String get role_entry_governorate;

  /// No description provided for @choose_access_level.
  ///
  /// In en, this message translates to:
  /// **'Choose your access level to continue.'**
  String get choose_access_level;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @governorate_manager.
  ///
  /// In en, this message translates to:
  /// **'Governorate Manager'**
  String get governorate_manager;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @start_trip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get start_trip;

  /// No description provided for @end_trip.
  ///
  /// In en, this message translates to:
  /// **'End Trip'**
  String get end_trip;

  /// No description provided for @serviced.
  ///
  /// In en, this message translates to:
  /// **'Serviced'**
  String get serviced;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @half.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get half;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @broken.
  ///
  /// In en, this message translates to:
  /// **'Broken'**
  String get broken;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @export_report.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get export_report;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @routing_error.
  ///
  /// In en, this message translates to:
  /// **'Routing Error'**
  String get routing_error;

  /// No description provided for @route_error.
  ///
  /// In en, this message translates to:
  /// **'Route error: {error}'**
  String route_error(Object error);

  /// No description provided for @open_login_screen.
  ///
  /// In en, this message translates to:
  /// **'Open Login Screen'**
  String get open_login_screen;

  /// No description provided for @government_waste_login.
  ///
  /// In en, this message translates to:
  /// **'Government Waste Login'**
  String get government_waste_login;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @use_employee_id_pin.
  ///
  /// In en, this message translates to:
  /// **'Use your employee ID and PIN.'**
  String get use_employee_id_pin;

  /// No description provided for @employee_id.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employee_id;

  /// No description provided for @password_pin.
  ///
  /// In en, this message translates to:
  /// **'Password / PIN'**
  String get password_pin;

  /// No description provided for @login_demo.
  ///
  /// In en, this message translates to:
  /// **'Login (Demo)'**
  String get login_demo;

  /// No description provided for @driver_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Driver Dashboard'**
  String get driver_dashboard;

  /// No description provided for @driver_operations.
  ///
  /// In en, this message translates to:
  /// **'Driver Operations'**
  String get driver_operations;

  /// No description provided for @baseline_smart_demo.
  ///
  /// In en, this message translates to:
  /// **'Baseline + smart route demo screens'**
  String get baseline_smart_demo;

  /// No description provided for @map_start_trip.
  ///
  /// In en, this message translates to:
  /// **'Map Start Trip'**
  String get map_start_trip;

  /// No description provided for @route_map.
  ///
  /// In en, this message translates to:
  /// **'Route Map'**
  String get route_map;

  /// No description provided for @bin_status_modal.
  ///
  /// In en, this message translates to:
  /// **'Bin Status Modal'**
  String get bin_status_modal;

  /// No description provided for @driver_profile.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driver_profile;

  /// No description provided for @achievement_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Achievement Dashboard'**
  String get achievement_dashboard;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @trip_ready.
  ///
  /// In en, this message translates to:
  /// **'Trip Ready'**
  String get trip_ready;

  /// No description provided for @priority_bins_today.
  ///
  /// In en, this message translates to:
  /// **'Priority bins today: {count}'**
  String priority_bins_today(int count);

  /// No description provided for @today_route.
  ///
  /// In en, this message translates to:
  /// **'Today Route'**
  String get today_route;

  /// No description provided for @planned_stops.
  ///
  /// In en, this message translates to:
  /// **'Planned Stops'**
  String get planned_stops;

  /// No description provided for @bin_status.
  ///
  /// In en, this message translates to:
  /// **'Bin Status'**
  String get bin_status;

  /// No description provided for @bin_status_update.
  ///
  /// In en, this message translates to:
  /// **'Bin Status Update'**
  String get bin_status_update;

  /// No description provided for @percent_full.
  ///
  /// In en, this message translates to:
  /// **'{percent}% full'**
  String percent_full(int percent);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @highlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get highlights;

  /// No description provided for @back_to_driver_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Driver Dashboard'**
  String get back_to_driver_dashboard;

  /// No description provided for @truck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get truck;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @morning_shift.
  ///
  /// In en, this message translates to:
  /// **'Morning (06:00 - 14:00)'**
  String get morning_shift;

  /// No description provided for @area_supervisor_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Area Supervisor Dashboard'**
  String get area_supervisor_dashboard;

  /// No description provided for @today_kpis.
  ///
  /// In en, this message translates to:
  /// **'Today KPIs'**
  String get today_kpis;

  /// No description provided for @area_alerts.
  ///
  /// In en, this message translates to:
  /// **'Area Alerts'**
  String get area_alerts;

  /// No description provided for @alert_bins_broken.
  ///
  /// In en, this message translates to:
  /// **'3 bins reported as broken'**
  String get alert_bins_broken;

  /// No description provided for @alert_drivers_behind.
  ///
  /// In en, this message translates to:
  /// **'2 drivers running behind schedule'**
  String get alert_drivers_behind;

  /// No description provided for @alert_fuel_above_baseline.
  ///
  /// In en, this message translates to:
  /// **'Fuel consumption above baseline by 4%'**
  String get alert_fuel_above_baseline;

  /// No description provided for @governorate_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Governorate Dashboard'**
  String get governorate_dashboard;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @service_distribution.
  ///
  /// In en, this message translates to:
  /// **'Service Distribution'**
  String get service_distribution;

  /// No description provided for @gov_stats.
  ///
  /// In en, this message translates to:
  /// **'Gov\\nStats'**
  String get gov_stats;

  /// No description provided for @active_drivers.
  ///
  /// In en, this message translates to:
  /// **'Active Drivers'**
  String get active_drivers;

  /// No description provided for @completed_stops.
  ///
  /// In en, this message translates to:
  /// **'Completed Stops'**
  String get completed_stops;

  /// No description provided for @open_issues.
  ///
  /// In en, this message translates to:
  /// **'Open Issues'**
  String get open_issues;

  /// No description provided for @on_time_service.
  ///
  /// In en, this message translates to:
  /// **'On-time Service'**
  String get on_time_service;

  /// No description provided for @areas_covered.
  ///
  /// In en, this message translates to:
  /// **'Areas Covered'**
  String get areas_covered;

  /// No description provided for @total_trucks.
  ///
  /// In en, this message translates to:
  /// **'Total Trucks'**
  String get total_trucks;

  /// No description provided for @daily_km_smart.
  ///
  /// In en, this message translates to:
  /// **'Daily Km (Smart)'**
  String get daily_km_smart;

  /// No description provided for @fuel_saved.
  ///
  /// In en, this message translates to:
  /// **'Fuel Saved'**
  String get fuel_saved;

  /// No description provided for @route_distance_reduced.
  ///
  /// In en, this message translates to:
  /// **'Route distance reduced by 18%'**
  String get route_distance_reduced;

  /// No description provided for @estimated_fuel_saved.
  ///
  /// In en, this message translates to:
  /// **'Estimated fuel saved: 14.2 L'**
  String get estimated_fuel_saved;

  /// No description provided for @priority_bins_ontime.
  ///
  /// In en, this message translates to:
  /// **'Priority bins serviced on time: 96%'**
  String get priority_bins_ontime;

  /// No description provided for @msar_branding_title.
  ///
  /// In en, this message translates to:
  /// **'Mihwar'**
  String get msar_branding_title;

  /// No description provided for @msar_branding_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with problem study (Before) or the smart solution (After).'**
  String get msar_branding_subtitle;

  /// No description provided for @login_hint_drivers.
  ///
  /// In en, this message translates to:
  /// **'Use your government ID and password (drivers 1001, 1006).'**
  String get login_hint_drivers;

  /// No description provided for @invalid_credentials_hint.
  ///
  /// In en, this message translates to:
  /// **'Invalid ID or password. Try drivers 1001 or 1006 / 1234, 2001/1234, or 3001/1234.'**
  String get invalid_credentials_hint;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @compliance_label.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get compliance_label;

  /// No description provided for @trip_completed_title.
  ///
  /// In en, this message translates to:
  /// **'Trip Completed'**
  String get trip_completed_title;

  /// No description provided for @trip_completed_message.
  ///
  /// In en, this message translates to:
  /// **'You have completed all planned stops.'**
  String get trip_completed_message;

  /// No description provided for @distance_traveled.
  ///
  /// In en, this message translates to:
  /// **'Distance Traveled'**
  String get distance_traveled;

  /// No description provided for @exit_label.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit_label;

  /// No description provided for @currency_jod.
  ///
  /// In en, this message translates to:
  /// **'JOD'**
  String get currency_jod;

  /// No description provided for @km_unit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km_unit;

  /// No description provided for @liter_unit.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get liter_unit;

  /// No description provided for @training_title.
  ///
  /// In en, this message translates to:
  /// **'Training / Data Collection (Demo)'**
  String get training_title;

  /// No description provided for @training_start_trip.
  ///
  /// In en, this message translates to:
  /// **'Start Training Trip'**
  String get training_start_trip;

  /// No description provided for @training_pick_status.
  ///
  /// In en, this message translates to:
  /// **'Choose Bin Status'**
  String get training_pick_status;

  /// No description provided for @training_completed.
  ///
  /// In en, this message translates to:
  /// **'Training trip completed'**
  String get training_completed;

  /// No description provided for @training_trip_ended.
  ///
  /// In en, this message translates to:
  /// **'Trip finished'**
  String get training_trip_ended;

  /// No description provided for @training_moving_next.
  ///
  /// In en, this message translates to:
  /// **'Moving to next bin...'**
  String get training_moving_next;

  /// No description provided for @smart_hint_start_trip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get smart_hint_start_trip;

  /// No description provided for @smart_hint_priority_bins.
  ///
  /// In en, this message translates to:
  /// **'Only dark bins are predicted to be near full today. Faded bins are skipped to save diesel.'**
  String get smart_hint_priority_bins;

  /// No description provided for @smart_hint_diesel_shortest_visual.
  ///
  /// In en, this message translates to:
  /// **'Route is optimized to reduce diesel.'**
  String get smart_hint_diesel_shortest_visual;

  /// No description provided for @driver_compliance_title.
  ///
  /// In en, this message translates to:
  /// **'Driver Compliance'**
  String get driver_compliance_title;

  /// No description provided for @driver_compliance_formula.
  ///
  /// In en, this message translates to:
  /// **'Compliance = confirmed_stops / planned_stops'**
  String get driver_compliance_formula;

  /// No description provided for @supervisor_skipped_bins.
  ///
  /// In en, this message translates to:
  /// **'Skipped bins'**
  String get supervisor_skipped_bins;

  /// No description provided for @supervisor_bypass_attempts.
  ///
  /// In en, this message translates to:
  /// **'Bypass attempts'**
  String get supervisor_bypass_attempts;

  /// No description provided for @supervisor_late_route.
  ///
  /// In en, this message translates to:
  /// **'Late route'**
  String get supervisor_late_route;

  /// No description provided for @supervisor_low_compliance.
  ///
  /// In en, this message translates to:
  /// **'Low compliance'**
  String get supervisor_low_compliance;

  /// No description provided for @supervisor_yes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get supervisor_yes;

  /// No description provided for @supervisor_no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get supervisor_no;

  /// No description provided for @demo_loaded.
  ///
  /// In en, this message translates to:
  /// **'Demo scenario loaded.'**
  String get demo_loaded;

  /// No description provided for @demo_reset_done.
  ///
  /// In en, this message translates to:
  /// **'Demo reset completed.'**
  String get demo_reset_done;

  /// No description provided for @reset_demo.
  ///
  /// In en, this message translates to:
  /// **'Reset Demo'**
  String get reset_demo;

  /// No description provided for @ai_predictive_engine.
  ///
  /// In en, this message translates to:
  /// **'AI / Predictive Engine'**
  String get ai_predictive_engine;

  /// No description provided for @governorate_before_after_title.
  ///
  /// In en, this message translates to:
  /// **'Before vs After Diesel Impact'**
  String get governorate_before_after_title;

  /// No description provided for @governorate_optimize_hint.
  ///
  /// In en, this message translates to:
  /// **'We optimize for diesel, not distance.'**
  String get governorate_optimize_hint;

  /// No description provided for @governorate_route_time.
  ///
  /// In en, this message translates to:
  /// **'Route Time'**
  String get governorate_route_time;

  /// No description provided for @governorate_route_time_value.
  ///
  /// In en, this message translates to:
  /// **'{before} min -> {after} min'**
  String governorate_route_time_value(int before, int after);

  /// No description provided for @governorate_unnecessary_stops.
  ///
  /// In en, this message translates to:
  /// **'Unnecessary Stops Reduced'**
  String get governorate_unnecessary_stops;

  /// No description provided for @governorate_stops_per_day_value.
  ///
  /// In en, this message translates to:
  /// **'{count} stops/day'**
  String governorate_stops_per_day_value(int count);

  /// No description provided for @governorate_co2_saved.
  ///
  /// In en, this message translates to:
  /// **'Estimated CO2 Saved'**
  String get governorate_co2_saved;

  /// No description provided for @governorate_kg_per_year_value.
  ///
  /// In en, this message translates to:
  /// **'{count} kg/year'**
  String governorate_kg_per_year_value(Object count);

  /// No description provided for @governorate_route_demo_failed.
  ///
  /// In en, this message translates to:
  /// **'Route demo failed'**
  String get governorate_route_demo_failed;

  /// No description provided for @governorate_demo_controls.
  ///
  /// In en, this message translates to:
  /// **'Demo Scenario Controls'**
  String get governorate_demo_controls;

  /// No description provided for @governorate_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings / About'**
  String get governorate_settings_title;

  /// No description provided for @governorate_about_title.
  ///
  /// In en, this message translates to:
  /// **'About This Demo'**
  String get governorate_about_title;

  /// No description provided for @governorate_about_threshold.
  ///
  /// In en, this message translates to:
  /// **'Priority threshold is 85% predicted fill.'**
  String get governorate_about_threshold;

  /// No description provided for @governorate_about_frequency.
  ///
  /// In en, this message translates to:
  /// **'Residential bins are serviced 2 times/day, commercial bins 4 times/day in seeded history.'**
  String get governorate_about_frequency;

  /// No description provided for @governorate_about_seasonality.
  ///
  /// In en, this message translates to:
  /// **'Seasonality modifiers include Ramadan and summer/holiday windows.'**
  String get governorate_about_seasonality;

  /// No description provided for @governorate_about_diesel_model.
  ///
  /// In en, this message translates to:
  /// **'Route optimization prefers lower diesel usage, not just shortest distance.'**
  String get governorate_about_diesel_model;

  /// No description provided for @governorate_load_demo.
  ///
  /// In en, this message translates to:
  /// **'Load Demo Scenario'**
  String get governorate_load_demo;

  /// No description provided for @governorate_predictive_failed.
  ///
  /// In en, this message translates to:
  /// **'Predictive engine failed'**
  String get governorate_predictive_failed;

  /// No description provided for @governorate_score.
  ///
  /// In en, this message translates to:
  /// **'score'**
  String get governorate_score;

  /// No description provided for @governorate_todo_export.
  ///
  /// In en, this message translates to:
  /// **'TODO: integrate PDF export in next phase.'**
  String get governorate_todo_export;

  /// No description provided for @governorate_before_after_map.
  ///
  /// In en, this message translates to:
  /// **'Before vs After Route Map'**
  String get governorate_before_after_map;

  /// No description provided for @governorate_why_route.
  ///
  /// In en, this message translates to:
  /// **'Why this route?'**
  String get governorate_why_route;

  /// No description provided for @governorate_route_before_label.
  ///
  /// In en, this message translates to:
  /// **'Before (Fixed Route)'**
  String get governorate_route_before_label;

  /// No description provided for @governorate_route_after_label.
  ///
  /// In en, this message translates to:
  /// **'After (Smart Priority Route)'**
  String get governorate_route_after_label;

  /// No description provided for @governorate_short_uphill_demo.
  ///
  /// In en, this message translates to:
  /// **'Short uphill vs long flat demo'**
  String get governorate_short_uphill_demo;

  /// No description provided for @governorate_road_profile_effect.
  ///
  /// In en, this message translates to:
  /// **'Road profile affects diesel strongly, so the optimizer minimizes fuel usage, not only kilometers.'**
  String get governorate_road_profile_effect;

  /// No description provided for @governorate_period_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get governorate_period_daily;

  /// No description provided for @governorate_period_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get governorate_period_weekly;

  /// No description provided for @governorate_period_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get governorate_period_monthly;

  /// No description provided for @governorate_period_yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get governorate_period_yearly;

  /// No description provided for @supervisor_diesel_before_after.
  ///
  /// In en, this message translates to:
  /// **'Diesel Before / After'**
  String get supervisor_diesel_before_after;

  /// No description provided for @supervisor_totals_title.
  ///
  /// In en, this message translates to:
  /// **'Area Totals (All Drivers)'**
  String get supervisor_totals_title;

  /// No description provided for @predict_reason_commercial_fast.
  ///
  /// In en, this message translates to:
  /// **'Commercial zone has faster fill pattern.'**
  String get predict_reason_commercial_fast;

  /// No description provided for @predict_reason_commercial_high.
  ///
  /// In en, this message translates to:
  /// **'Commercial density is high in this zone.'**
  String get predict_reason_commercial_high;

  /// No description provided for @predict_reason_commercial_medium.
  ///
  /// In en, this message translates to:
  /// **'Commercial density is medium in this zone.'**
  String get predict_reason_commercial_medium;

  /// No description provided for @predict_reason_commercial_low.
  ///
  /// In en, this message translates to:
  /// **'Commercial activity is lighter in this zone.'**
  String get predict_reason_commercial_low;

  /// No description provided for @predict_reason_residential_slow.
  ///
  /// In en, this message translates to:
  /// **'Residential zone usually fills slower.'**
  String get predict_reason_residential_slow;

  /// No description provided for @predict_reason_residential_high.
  ///
  /// In en, this message translates to:
  /// **'Residential density is high in this zone.'**
  String get predict_reason_residential_high;

  /// No description provided for @predict_reason_residential_medium.
  ///
  /// In en, this message translates to:
  /// **'Residential density is medium in this zone.'**
  String get predict_reason_residential_medium;

  /// No description provided for @predict_reason_residential_low.
  ///
  /// In en, this message translates to:
  /// **'Residential density is lower in this zone.'**
  String get predict_reason_residential_low;

  /// No description provided for @predict_reason_history_full.
  ///
  /// In en, this message translates to:
  /// **'Historical full readings support prioritization.'**
  String get predict_reason_history_full;

  /// No description provided for @predict_reason_ramadan_multiplier.
  ///
  /// In en, this message translates to:
  /// **'Seasonal pattern increases fill during Ramadan-like month.'**
  String get predict_reason_ramadan_multiplier;

  /// No description provided for @predict_reason_summer_multiplier.
  ///
  /// In en, this message translates to:
  /// **'Summer period increases overall fill rates.'**
  String get predict_reason_summer_multiplier;

  /// No description provided for @predict_reason_weekend_increase.
  ///
  /// In en, this message translates to:
  /// **'Weekend pattern increases expected fill.'**
  String get predict_reason_weekend_increase;

  /// No description provided for @predict_reason_early_week_reduction.
  ///
  /// In en, this message translates to:
  /// **'Early-week pattern slightly reduces expected fill.'**
  String get predict_reason_early_week_reduction;

  /// No description provided for @predict_reason_last_service_stale.
  ///
  /// In en, this message translates to:
  /// **'Time since last service increases current fill probability.'**
  String get predict_reason_last_service_stale;

  /// No description provided for @predict_reason_avg_daily_fill_high.
  ///
  /// In en, this message translates to:
  /// **'Average daily fill profile is high for this bin.'**
  String get predict_reason_avg_daily_fill_high;

  /// No description provided for @predict_reason_avg_daily_fill_medium.
  ///
  /// In en, this message translates to:
  /// **'Average daily fill profile is medium for this bin.'**
  String get predict_reason_avg_daily_fill_medium;

  /// No description provided for @predict_reason_avg_daily_fill_low.
  ///
  /// In en, this message translates to:
  /// **'Average daily fill profile is lower for this bin.'**
  String get predict_reason_avg_daily_fill_low;

  /// No description provided for @predict_reason_fallback_top3.
  ///
  /// In en, this message translates to:
  /// **'No bins crossed threshold; showing top 3 candidates.'**
  String get predict_reason_fallback_top3;

  /// No description provided for @predict_reason_generic_fallback.
  ///
  /// In en, this message translates to:
  /// **'Predicted by model factors for this shift.'**
  String get predict_reason_generic_fallback;

  /// No description provided for @predict_reason_weekend_commercial.
  ///
  /// In en, this message translates to:
  /// **'Weekend effect increases commercial demand.'**
  String get predict_reason_weekend_commercial;

  /// No description provided for @predict_reason_weekday_residential.
  ///
  /// In en, this message translates to:
  /// **'Weekday household pattern is moderate.'**
  String get predict_reason_weekday_residential;

  /// No description provided for @predict_reason_priority_today.
  ///
  /// In en, this message translates to:
  /// **'Predicted as priority for today.'**
  String get predict_reason_priority_today;

  /// No description provided for @area_name_1001.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Al Karama North'**
  String get area_name_1001;

  /// No description provided for @area_name_1002.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Al Karama East'**
  String get area_name_1002;

  /// No description provided for @area_name_1003.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Al Karama South'**
  String get area_name_1003;

  /// No description provided for @area_name_1004.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Al Karama West'**
  String get area_name_1004;

  /// No description provided for @area_name_1005.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Al Karama Central'**
  String get area_name_1005;

  /// No description provided for @area_name_1006.
  ///
  /// In en, this message translates to:
  /// **'Training Yard'**
  String get area_name_1006;

  /// No description provided for @area_name_generic.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Al Karama'**
  String get area_name_generic;

  /// No description provided for @before_label.
  ///
  /// In en, this message translates to:
  /// **'BEFORE'**
  String get before_label;

  /// No description provided for @after_label.
  ///
  /// In en, this message translates to:
  /// **'AFTER'**
  String get after_label;

  /// No description provided for @before_study_title.
  ///
  /// In en, this message translates to:
  /// **'Before: Problem Study'**
  String get before_study_title;

  /// No description provided for @before_study_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Problem-study dashboard will be added in Step 2 (no maps, detailed wasted visits and diesel study).'**
  String get before_study_placeholder;

  /// No description provided for @supervisor_section_driver_info.
  ///
  /// In en, this message translates to:
  /// **'Driver Info'**
  String get supervisor_section_driver_info;

  /// No description provided for @supervisor_route_compliance_efficiency.
  ///
  /// In en, this message translates to:
  /// **'Route compliance efficiency'**
  String get supervisor_route_compliance_efficiency;

  /// No description provided for @supervisor_section_compliance_summary.
  ///
  /// In en, this message translates to:
  /// **'Compliance Summary'**
  String get supervisor_section_compliance_summary;

  /// No description provided for @supervisor_section_stops_summary.
  ///
  /// In en, this message translates to:
  /// **'Stops Summary'**
  String get supervisor_section_stops_summary;

  /// No description provided for @supervisor_section_diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel (Before / After / Savings)'**
  String get supervisor_section_diesel;

  /// No description provided for @supervisor_section_compliance_explanation.
  ///
  /// In en, this message translates to:
  /// **'Why score decreased?'**
  String get supervisor_section_compliance_explanation;

  /// No description provided for @supervisor_fully_compliant.
  ///
  /// In en, this message translates to:
  /// **'Fully compliant'**
  String get supervisor_fully_compliant;

  /// No description provided for @supervisor_trips_title.
  ///
  /// In en, this message translates to:
  /// **'Trips per day'**
  String get supervisor_trips_title;

  /// No description provided for @supervisor_trip_label.
  ///
  /// In en, this message translates to:
  /// **'Trip {number}'**
  String supervisor_trip_label(int number);

  /// No description provided for @supervisor_predicted_bins_count.
  ///
  /// In en, this message translates to:
  /// **'Predicted bins count'**
  String get supervisor_predicted_bins_count;

  /// No description provided for @supervisor_serviced_bins_count.
  ///
  /// In en, this message translates to:
  /// **'Serviced bins count'**
  String get supervisor_serviced_bins_count;

  /// No description provided for @supervisor_missed_bins_count.
  ///
  /// In en, this message translates to:
  /// **'Missed bins'**
  String get supervisor_missed_bins_count;

  /// No description provided for @supervisor_route_deviation_level.
  ///
  /// In en, this message translates to:
  /// **'Route deviation level'**
  String get supervisor_route_deviation_level;

  /// No description provided for @supervisor_route_penalty_points.
  ///
  /// In en, this message translates to:
  /// **'Route penalty'**
  String get supervisor_route_penalty_points;

  /// No description provided for @supervisor_app_penalty_points.
  ///
  /// In en, this message translates to:
  /// **'App adherence penalty'**
  String get supervisor_app_penalty_points;

  /// No description provided for @supervisor_route_deviation_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get supervisor_route_deviation_none;

  /// No description provided for @supervisor_route_deviation_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get supervisor_route_deviation_low;

  /// No description provided for @supervisor_route_deviation_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get supervisor_route_deviation_medium;

  /// No description provided for @supervisor_route_deviation_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get supervisor_route_deviation_high;

  /// No description provided for @supervisor_route_deviation_severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get supervisor_route_deviation_severe;

  /// No description provided for @supervisor_no_non_compliant_alerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts for non-compliant drivers.'**
  String get supervisor_no_non_compliant_alerts;

  /// No description provided for @supervisor_liters_label.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get supervisor_liters_label;

  /// No description provided for @supervisor_cost_label.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get supervisor_cost_label;

  /// No description provided for @supervisor_savings_label.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get supervisor_savings_label;

  /// No description provided for @supervisor_saved_liters_label.
  ///
  /// In en, this message translates to:
  /// **'Saved liters'**
  String get supervisor_saved_liters_label;

  /// No description provided for @supervisor_saved_cost_label.
  ///
  /// In en, this message translates to:
  /// **'Saved cost'**
  String get supervisor_saved_cost_label;

  /// No description provided for @supervisor_percent_label.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get supervisor_percent_label;

  /// No description provided for @supervisor_points_unit.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get supervisor_points_unit;

  /// No description provided for @supervisor_score_formula.
  ///
  /// In en, this message translates to:
  /// **'Final compliance = 100 - (bin penalty + route penalty + app penalty). Weights: bins 60, route 30, app 10.'**
  String get supervisor_score_formula;

  /// No description provided for @supervisor_bin_penalty.
  ///
  /// In en, this message translates to:
  /// **'Bin penalty'**
  String get supervisor_bin_penalty;

  /// No description provided for @supervisor_route_penalty.
  ///
  /// In en, this message translates to:
  /// **'Route penalty'**
  String get supervisor_route_penalty;

  /// No description provided for @supervisor_app_penalty.
  ///
  /// In en, this message translates to:
  /// **'App penalty'**
  String get supervisor_app_penalty;

  /// No description provided for @supervisor_final_result.
  ///
  /// In en, this message translates to:
  /// **'Final result'**
  String get supervisor_final_result;

  /// No description provided for @supervisor_alert_reason_missed_bins.
  ///
  /// In en, this message translates to:
  /// **'Skipped predicted bins'**
  String get supervisor_alert_reason_missed_bins;

  /// No description provided for @supervisor_alert_reason_route_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium route deviation from planned path'**
  String get supervisor_alert_reason_route_medium;

  /// No description provided for @supervisor_alert_reason_route_high.
  ///
  /// In en, this message translates to:
  /// **'High route deviation from planned path'**
  String get supervisor_alert_reason_route_high;

  /// No description provided for @supervisor_alert_reason_app.
  ///
  /// In en, this message translates to:
  /// **'Incomplete app workflow adherence'**
  String get supervisor_alert_reason_app;

  /// No description provided for @governorate_manager_dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Governorate Manager Dashboard'**
  String get governorate_manager_dashboard_title;

  /// No description provided for @governorate_zarqa_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Zarqa Governorate'**
  String get governorate_zarqa_subtitle;

  /// No description provided for @governorate_dashboard_note.
  ///
  /// In en, this message translates to:
  /// **'View all governorate areas, each area supervisor, and driver summary.'**
  String get governorate_dashboard_note;

  /// No description provided for @governorate_area_supervisor_label.
  ///
  /// In en, this message translates to:
  /// **'Area Supervisor'**
  String get governorate_area_supervisor_label;

  /// No description provided for @governorate_supervisor_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get governorate_supervisor_unavailable;

  /// No description provided for @governorate_area_drivers_title.
  ///
  /// In en, this message translates to:
  /// **'Area Drivers'**
  String get governorate_area_drivers_title;

  /// No description provided for @governorate_expected_daily_label.
  ///
  /// In en, this message translates to:
  /// **'Expected (Daily)'**
  String get governorate_expected_daily_label;

  /// No description provided for @governorate_actual_daily_label.
  ///
  /// In en, this message translates to:
  /// **'Actual (Daily)'**
  String get governorate_actual_daily_label;

  /// No description provided for @governorate_area_totals_diesel_title.
  ///
  /// In en, this message translates to:
  /// **'Area Totals - Diesel'**
  String get governorate_area_totals_diesel_title;

  /// No description provided for @governorate_non_compliant_drivers_count.
  ///
  /// In en, this message translates to:
  /// **'Non-compliant drivers'**
  String get governorate_non_compliant_drivers_count;

  /// No description provided for @governorate_empty_area_state.
  ///
  /// In en, this message translates to:
  /// **'No data available for this area in the current demo.'**
  String get governorate_empty_area_state;

  /// No description provided for @governorate_status_below_expected.
  ///
  /// In en, this message translates to:
  /// **'Below expected'**
  String get governorate_status_below_expected;

  /// No description provided for @governorate_status_within_expected.
  ///
  /// In en, this message translates to:
  /// **'Within expected'**
  String get governorate_status_within_expected;

  /// No description provided for @governorate_status_above_expected.
  ///
  /// In en, this message translates to:
  /// **'Above expected'**
  String get governorate_status_above_expected;

  /// No description provided for @governorate_alerts_non_compliant.
  ///
  /// In en, this message translates to:
  /// **'Alerts (Non-compliant only)'**
  String get governorate_alerts_non_compliant;

  /// No description provided for @governorate_alert_reason_missed_bins.
  ///
  /// In en, this message translates to:
  /// **'Skipped predicted bin(s)'**
  String get governorate_alert_reason_missed_bins;

  /// No description provided for @governorate_alert_reason_route_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium route deviation from planned path'**
  String get governorate_alert_reason_route_medium;

  /// No description provided for @governorate_alert_reason_route_high.
  ///
  /// In en, this message translates to:
  /// **'High route deviation from planned path'**
  String get governorate_alert_reason_route_high;

  /// No description provided for @governorate_alert_reason_app.
  ///
  /// In en, this message translates to:
  /// **'Incomplete app workflow adherence'**
  String get governorate_alert_reason_app;

  /// No description provided for @governorate_liters_label.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get governorate_liters_label;

  /// No description provided for @governorate_cost_label.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get governorate_cost_label;

  /// No description provided for @governorate_savings_label.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get governorate_savings_label;

  /// No description provided for @governorate_saved_liters_label.
  ///
  /// In en, this message translates to:
  /// **'Saved liters'**
  String get governorate_saved_liters_label;

  /// No description provided for @governorate_saved_cost_label.
  ///
  /// In en, this message translates to:
  /// **'Saved cost'**
  String get governorate_saved_cost_label;

  /// No description provided for @governorate_percent_label.
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get governorate_percent_label;

  /// No description provided for @governorate_area_karama_street.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Al Karama Street'**
  String get governorate_area_karama_street;

  /// No description provided for @governorate_area_new_zarqa.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - New Zarqa'**
  String get governorate_area_new_zarqa;

  /// No description provided for @governorate_area_russeifa.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Russeifa'**
  String get governorate_area_russeifa;

  /// No description provided for @governorate_area_hashmiya.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Hashmiya'**
  String get governorate_area_hashmiya;

  /// No description provided for @governorate_area_old_zarqa.
  ///
  /// In en, this message translates to:
  /// **'Zarqa - Downtown'**
  String get governorate_area_old_zarqa;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
