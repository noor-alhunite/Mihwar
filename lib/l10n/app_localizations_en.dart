// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Mihwar';

  @override
  String get select_role => 'Select Role';

  @override
  String get role_entry_data_truck => 'Data Collection Truck';

  @override
  String get role_entry_smart_truck => 'Smart Prediction Truck';

  @override
  String get role_entry_area_supervisor => 'Area Supervisor';

  @override
  String get role_entry_governorate => 'Governorate Manager';

  @override
  String get choose_access_level => 'Choose your access level to continue.';

  @override
  String get driver => 'Driver';

  @override
  String get supervisor => 'Supervisor';

  @override
  String get governorate_manager => 'Governorate Manager';

  @override
  String get login => 'Login';

  @override
  String get id => 'ID';

  @override
  String get password => 'Password';

  @override
  String get start_trip => 'Start Trip';

  @override
  String get end_trip => 'End Trip';

  @override
  String get serviced => 'Serviced';

  @override
  String get submit => 'Submit';

  @override
  String get skip => 'Skip';

  @override
  String get full => 'Full';

  @override
  String get half => 'Half';

  @override
  String get empty => 'Empty';

  @override
  String get broken => 'Broken';

  @override
  String get profile => 'Profile';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get export_report => 'Export Report';

  @override
  String get language => 'Language';

  @override
  String get routing_error => 'Routing Error';

  @override
  String route_error(Object error) {
    return 'Route error: $error';
  }

  @override
  String get open_login_screen => 'Open Login Screen';

  @override
  String get government_waste_login => 'Government Waste Login';

  @override
  String get sign_in => 'Sign In';

  @override
  String get use_employee_id_pin => 'Use your employee ID and PIN.';

  @override
  String get employee_id => 'Employee ID';

  @override
  String get password_pin => 'Password / PIN';

  @override
  String get login_demo => 'Login (Demo)';

  @override
  String get driver_dashboard => 'Driver Dashboard';

  @override
  String get driver_operations => 'Driver Operations';

  @override
  String get baseline_smart_demo => 'Baseline + smart route demo screens';

  @override
  String get map_start_trip => 'Map Start Trip';

  @override
  String get route_map => 'Route Map';

  @override
  String get bin_status_modal => 'Bin Status Modal';

  @override
  String get driver_profile => 'Driver Profile';

  @override
  String get achievement_dashboard => 'Achievement Dashboard';

  @override
  String get back => 'Back';

  @override
  String get trip_ready => 'Trip Ready';

  @override
  String priority_bins_today(int count) {
    return 'Priority bins today: $count';
  }

  @override
  String get today_route => 'Today Route';

  @override
  String get planned_stops => 'Planned Stops';

  @override
  String get bin_status => 'Bin Status';

  @override
  String get bin_status_update => 'Bin Status Update';

  @override
  String percent_full(int percent) {
    return '$percent% full';
  }

  @override
  String get today => 'Today';

  @override
  String get highlights => 'Highlights';

  @override
  String get back_to_driver_dashboard => 'Back to Driver Dashboard';

  @override
  String get truck => 'Truck';

  @override
  String get shift => 'Shift';

  @override
  String get contact => 'Contact';

  @override
  String get morning_shift => 'Morning (06:00 - 14:00)';

  @override
  String get area_supervisor_dashboard => 'Area Supervisor Dashboard';

  @override
  String get today_kpis => 'Today KPIs';

  @override
  String get area_alerts => 'Area Alerts';

  @override
  String get alert_bins_broken => '3 bins reported as broken';

  @override
  String get alert_drivers_behind => '2 drivers running behind schedule';

  @override
  String get alert_fuel_above_baseline =>
      'Fuel consumption above baseline by 4%';

  @override
  String get governorate_dashboard => 'Governorate Dashboard';

  @override
  String get overview => 'Overview';

  @override
  String get service_distribution => 'Service Distribution';

  @override
  String get gov_stats => 'Gov\\nStats';

  @override
  String get active_drivers => 'Active Drivers';

  @override
  String get completed_stops => 'Completed Stops';

  @override
  String get open_issues => 'Open Issues';

  @override
  String get on_time_service => 'On-time Service';

  @override
  String get areas_covered => 'Areas Covered';

  @override
  String get total_trucks => 'Total Trucks';

  @override
  String get daily_km_smart => 'Daily Km (Smart)';

  @override
  String get fuel_saved => 'Fuel Saved';

  @override
  String get route_distance_reduced => 'Route distance reduced by 18%';

  @override
  String get estimated_fuel_saved => 'Estimated fuel saved: 14.2 L';

  @override
  String get priority_bins_ontime => 'Priority bins serviced on time: 96%';

  @override
  String get msar_branding_title => 'Mihwar';

  @override
  String get msar_branding_subtitle =>
      'Start with problem study (Before) or the smart solution (After).';

  @override
  String get login_hint_drivers =>
      'Use your government ID and password (drivers 1001, 1006).';

  @override
  String get invalid_credentials_hint =>
      'Invalid ID or password. Try drivers 1001 or 1006 / 1234, 2001/1234, or 3001/1234.';

  @override
  String get logout => 'Logout';

  @override
  String get compliance_label => 'Compliance';

  @override
  String get trip_completed_title => 'Trip Completed';

  @override
  String get trip_completed_message => 'You have completed all planned stops.';

  @override
  String get distance_traveled => 'Distance Traveled';

  @override
  String get exit_label => 'Exit';

  @override
  String get currency_jod => 'JOD';

  @override
  String get km_unit => 'km';

  @override
  String get liter_unit => 'L';

  @override
  String get training_title => 'Training / Data Collection (Demo)';

  @override
  String get training_start_trip => 'Start Training Trip';

  @override
  String get training_pick_status => 'Choose Bin Status';

  @override
  String get training_completed => 'Training trip completed';

  @override
  String get training_trip_ended => 'Trip finished';

  @override
  String get training_moving_next => 'Moving to next bin...';

  @override
  String get smart_hint_start_trip => 'Start Trip';

  @override
  String get smart_hint_priority_bins =>
      'Only dark bins are predicted to be near full today. Faded bins are skipped to save diesel.';

  @override
  String get smart_hint_diesel_shortest_visual =>
      'Route is optimized to reduce diesel.';

  @override
  String get driver_compliance_title => 'Driver Compliance';

  @override
  String get driver_compliance_formula =>
      'Compliance = confirmed_stops / planned_stops';

  @override
  String get supervisor_skipped_bins => 'Skipped bins';

  @override
  String get supervisor_bypass_attempts => 'Bypass attempts';

  @override
  String get supervisor_late_route => 'Late route';

  @override
  String get supervisor_low_compliance => 'Low compliance';

  @override
  String get supervisor_yes => 'YES';

  @override
  String get supervisor_no => 'NO';

  @override
  String get demo_loaded => 'Demo scenario loaded.';

  @override
  String get demo_reset_done => 'Demo reset completed.';

  @override
  String get reset_demo => 'Reset Demo';

  @override
  String get ai_predictive_engine => 'AI / Predictive Engine';

  @override
  String get governorate_before_after_title => 'Before vs After Diesel Impact';

  @override
  String get governorate_optimize_hint =>
      'We optimize for diesel, not distance.';

  @override
  String get governorate_route_time => 'Route Time';

  @override
  String governorate_route_time_value(int before, int after) {
    return '$before min -> $after min';
  }

  @override
  String get governorate_unnecessary_stops => 'Unnecessary Stops Reduced';

  @override
  String governorate_stops_per_day_value(int count) {
    return '$count stops/day';
  }

  @override
  String get governorate_co2_saved => 'Estimated CO2 Saved';

  @override
  String governorate_kg_per_year_value(Object count) {
    return '$count kg/year';
  }

  @override
  String get governorate_route_demo_failed => 'Route demo failed';

  @override
  String get governorate_demo_controls => 'Demo Scenario Controls';

  @override
  String get governorate_settings_title => 'Settings / About';

  @override
  String get governorate_about_title => 'About This Demo';

  @override
  String get governorate_about_threshold =>
      'Priority threshold is 85% predicted fill.';

  @override
  String get governorate_about_frequency =>
      'Residential bins are serviced 2 times/day, commercial bins 4 times/day in seeded history.';

  @override
  String get governorate_about_seasonality =>
      'Seasonality modifiers include Ramadan and summer/holiday windows.';

  @override
  String get governorate_about_diesel_model =>
      'Route optimization prefers lower diesel usage, not just shortest distance.';

  @override
  String get governorate_load_demo => 'Load Demo Scenario';

  @override
  String get governorate_predictive_failed => 'Predictive engine failed';

  @override
  String get governorate_score => 'score';

  @override
  String get governorate_todo_export =>
      'TODO: integrate PDF export in next phase.';

  @override
  String get governorate_before_after_map => 'Before vs After Route Map';

  @override
  String get governorate_why_route => 'Why this route?';

  @override
  String get governorate_route_before_label => 'Before (Fixed Route)';

  @override
  String get governorate_route_after_label => 'After (Smart Priority Route)';

  @override
  String get governorate_short_uphill_demo => 'Short uphill vs long flat demo';

  @override
  String get governorate_road_profile_effect =>
      'Road profile affects diesel strongly, so the optimizer minimizes fuel usage, not only kilometers.';

  @override
  String get governorate_period_daily => 'Daily';

  @override
  String get governorate_period_weekly => 'Weekly';

  @override
  String get governorate_period_monthly => 'Monthly';

  @override
  String get governorate_period_yearly => 'Yearly';

  @override
  String get supervisor_diesel_before_after => 'Diesel Before / After';

  @override
  String get supervisor_totals_title => 'Area Totals (All Drivers)';

  @override
  String get predict_reason_commercial_fast =>
      'Commercial zone has faster fill pattern.';

  @override
  String get predict_reason_commercial_high =>
      'Commercial density is high in this zone.';

  @override
  String get predict_reason_commercial_medium =>
      'Commercial density is medium in this zone.';

  @override
  String get predict_reason_commercial_low =>
      'Commercial activity is lighter in this zone.';

  @override
  String get predict_reason_residential_slow =>
      'Residential zone usually fills slower.';

  @override
  String get predict_reason_residential_high =>
      'Residential density is high in this zone.';

  @override
  String get predict_reason_residential_medium =>
      'Residential density is medium in this zone.';

  @override
  String get predict_reason_residential_low =>
      'Residential density is lower in this zone.';

  @override
  String get predict_reason_history_full =>
      'Historical full readings support prioritization.';

  @override
  String get predict_reason_ramadan_multiplier =>
      'Seasonal pattern increases fill during Ramadan-like month.';

  @override
  String get predict_reason_summer_multiplier =>
      'Summer period increases overall fill rates.';

  @override
  String get predict_reason_weekend_increase =>
      'Weekend pattern increases expected fill.';

  @override
  String get predict_reason_early_week_reduction =>
      'Early-week pattern slightly reduces expected fill.';

  @override
  String get predict_reason_last_service_stale =>
      'Time since last service increases current fill probability.';

  @override
  String get predict_reason_avg_daily_fill_high =>
      'Average daily fill profile is high for this bin.';

  @override
  String get predict_reason_avg_daily_fill_medium =>
      'Average daily fill profile is medium for this bin.';

  @override
  String get predict_reason_avg_daily_fill_low =>
      'Average daily fill profile is lower for this bin.';

  @override
  String get predict_reason_fallback_top3 =>
      'No bins crossed threshold; showing top 3 candidates.';

  @override
  String get predict_reason_generic_fallback =>
      'Predicted by model factors for this shift.';

  @override
  String get predict_reason_weekend_commercial =>
      'Weekend effect increases commercial demand.';

  @override
  String get predict_reason_weekday_residential =>
      'Weekday household pattern is moderate.';

  @override
  String get predict_reason_priority_today =>
      'Predicted as priority for today.';

  @override
  String get area_name_1001 => 'Zarqa - Al Karama North';

  @override
  String get area_name_1002 => 'Zarqa - Al Karama East';

  @override
  String get area_name_1003 => 'Zarqa - Al Karama South';

  @override
  String get area_name_1004 => 'Zarqa - Al Karama West';

  @override
  String get area_name_1005 => 'Zarqa - Al Karama Central';

  @override
  String get area_name_1006 => 'Training Yard';

  @override
  String get area_name_generic => 'Zarqa - Al Karama';

  @override
  String get before_label => 'BEFORE';

  @override
  String get after_label => 'AFTER';

  @override
  String get before_study_title => 'Before: Problem Study';

  @override
  String get before_study_placeholder =>
      'Problem-study dashboard will be added in Step 2 (no maps, detailed wasted visits and diesel study).';

  @override
  String get supervisor_section_driver_info => 'Driver Info';

  @override
  String get supervisor_route_compliance_efficiency =>
      'Route compliance efficiency';

  @override
  String get supervisor_section_compliance_summary => 'Compliance Summary';

  @override
  String get supervisor_section_stops_summary => 'Stops Summary';

  @override
  String get supervisor_section_diesel => 'Diesel (Before / After / Savings)';

  @override
  String get supervisor_section_compliance_explanation =>
      'Why score decreased?';

  @override
  String get supervisor_fully_compliant => 'Fully compliant';

  @override
  String get supervisor_trips_title => 'Trips per day';

  @override
  String supervisor_trip_label(int number) {
    return 'Trip $number';
  }

  @override
  String get supervisor_predicted_bins_count => 'Predicted bins count';

  @override
  String get supervisor_serviced_bins_count => 'Serviced bins count';

  @override
  String get supervisor_missed_bins_count => 'Missed bins';

  @override
  String get supervisor_route_deviation_level => 'Route deviation level';

  @override
  String get supervisor_route_penalty_points => 'Route penalty';

  @override
  String get supervisor_app_penalty_points => 'App adherence penalty';

  @override
  String get supervisor_route_deviation_none => 'None';

  @override
  String get supervisor_route_deviation_low => 'Low';

  @override
  String get supervisor_route_deviation_medium => 'Medium';

  @override
  String get supervisor_route_deviation_high => 'High';

  @override
  String get supervisor_route_deviation_severe => 'Severe';

  @override
  String get supervisor_no_non_compliant_alerts =>
      'No alerts for non-compliant drivers.';

  @override
  String get supervisor_liters_label => 'Liters';

  @override
  String get supervisor_cost_label => 'Cost';

  @override
  String get supervisor_savings_label => 'Savings';

  @override
  String get supervisor_saved_liters_label => 'Saved liters';

  @override
  String get supervisor_saved_cost_label => 'Saved cost';

  @override
  String get supervisor_percent_label => 'Percent';

  @override
  String get supervisor_points_unit => 'points';

  @override
  String get supervisor_score_formula =>
      'Final compliance = 100 - (bin penalty + route penalty + app penalty). Weights: bins 60, route 30, app 10.';

  @override
  String get supervisor_bin_penalty => 'Bin penalty';

  @override
  String get supervisor_route_penalty => 'Route penalty';

  @override
  String get supervisor_app_penalty => 'App penalty';

  @override
  String get supervisor_final_result => 'Final result';

  @override
  String get supervisor_alert_reason_missed_bins => 'Skipped predicted bins';

  @override
  String get supervisor_alert_reason_route_medium =>
      'Medium route deviation from planned path';

  @override
  String get supervisor_alert_reason_route_high =>
      'High route deviation from planned path';

  @override
  String get supervisor_alert_reason_app => 'Incomplete app workflow adherence';

  @override
  String get governorate_manager_dashboard_title =>
      'Governorate Manager Dashboard';

  @override
  String get governorate_zarqa_subtitle => 'Zarqa Governorate';

  @override
  String get governorate_dashboard_note =>
      'View all governorate areas, each area supervisor, and driver summary.';

  @override
  String get governorate_area_supervisor_label => 'Area Supervisor';

  @override
  String get governorate_supervisor_unavailable => 'Unavailable';

  @override
  String get governorate_area_drivers_title => 'Area Drivers';

  @override
  String get governorate_expected_daily_label => 'Expected (Daily)';

  @override
  String get governorate_actual_daily_label => 'Actual (Daily)';

  @override
  String get governorate_area_totals_diesel_title => 'Area Totals - Diesel';

  @override
  String get governorate_non_compliant_drivers_count => 'Non-compliant drivers';

  @override
  String get governorate_empty_area_state =>
      'No data available for this area in the current demo.';

  @override
  String get governorate_status_below_expected => 'Below expected';

  @override
  String get governorate_status_within_expected => 'Within expected';

  @override
  String get governorate_status_above_expected => 'Above expected';

  @override
  String get governorate_alerts_non_compliant => 'Alerts (Non-compliant only)';

  @override
  String get governorate_alert_reason_missed_bins => 'Skipped predicted bin(s)';

  @override
  String get governorate_alert_reason_route_medium =>
      'Medium route deviation from planned path';

  @override
  String get governorate_alert_reason_route_high =>
      'High route deviation from planned path';

  @override
  String get governorate_alert_reason_app =>
      'Incomplete app workflow adherence';

  @override
  String get governorate_liters_label => 'Liters';

  @override
  String get governorate_cost_label => 'Cost';

  @override
  String get governorate_savings_label => 'Savings';

  @override
  String get governorate_saved_liters_label => 'Saved liters';

  @override
  String get governorate_saved_cost_label => 'Saved cost';

  @override
  String get governorate_percent_label => 'Percent';

  @override
  String get governorate_area_karama_street => 'Zarqa - Al Karama Street';

  @override
  String get governorate_area_new_zarqa => 'Zarqa - New Zarqa';

  @override
  String get governorate_area_russeifa => 'Zarqa - Russeifa';

  @override
  String get governorate_area_hashmiya => 'Zarqa - Hashmiya';

  @override
  String get governorate_area_old_zarqa => 'Zarqa - Downtown';
}
