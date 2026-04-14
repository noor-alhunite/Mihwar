// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_name => 'Mihwar';

  @override
  String get select_role => 'اختر الدور';

  @override
  String get role_entry_data_truck => 'شاحنة جمع البيانات';

  @override
  String get role_entry_smart_truck => 'شاحنة التنبؤ';

  @override
  String get role_entry_area_supervisor => 'مسؤول المنطقة';

  @override
  String get role_entry_governorate => 'مسؤول المحافظة';

  @override
  String get choose_access_level => 'اختر مستوى الصلاحية للمتابعة.';

  @override
  String get driver => 'السائق';

  @override
  String get supervisor => 'المشرف';

  @override
  String get governorate_manager => 'مدير المحافظة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get id => 'المعرّف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get start_trip => 'بدء الرحلة';

  @override
  String get end_trip => 'إنهاء الرحلة';

  @override
  String get serviced => 'تمت الخدمة';

  @override
  String get submit => 'إرسال';

  @override
  String get skip => 'تخطي';

  @override
  String get full => 'ممتلئ';

  @override
  String get half => 'نصف ممتلئ';

  @override
  String get empty => 'فارغ';

  @override
  String get broken => 'معطّل';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get dashboard => 'لوحة المعلومات';

  @override
  String get export_report => 'تصدير التقرير';

  @override
  String get language => 'اللغة';

  @override
  String get routing_error => 'خطأ في التوجيه';

  @override
  String route_error(Object error) {
    return 'خطأ في المسار: $error';
  }

  @override
  String get open_login_screen => 'فتح شاشة تسجيل الدخول';

  @override
  String get government_waste_login => 'تسجيل دخول إدارة النفايات';

  @override
  String get sign_in => 'تسجيل الدخول';

  @override
  String get use_employee_id_pin => 'استخدم رقم الموظف والرقم السري.';

  @override
  String get employee_id => 'رقم الموظف';

  @override
  String get password_pin => 'كلمة المرور / الرقم السري';

  @override
  String get login_demo => 'تسجيل دخول (تجريبي)';

  @override
  String get driver_dashboard => 'لوحة السائق';

  @override
  String get driver_operations => 'عمليات السائق';

  @override
  String get baseline_smart_demo =>
      'شاشات العرض التجريبي للمسار الأساسي والذكي';

  @override
  String get map_start_trip => 'خريطة بدء الرحلة';

  @override
  String get route_map => 'خريطة المسار';

  @override
  String get bin_status_modal => 'نافذة حالة الحاوية';

  @override
  String get driver_profile => 'ملف السائق';

  @override
  String get achievement_dashboard => 'لوحة الإنجازات';

  @override
  String get back => 'رجوع';

  @override
  String get trip_ready => 'الرحلة جاهزة';

  @override
  String priority_bins_today(int count) {
    return 'الحاويات ذات الأولوية اليوم: $count';
  }

  @override
  String get today_route => 'مسار اليوم';

  @override
  String get planned_stops => 'المحطات المخططة';

  @override
  String get bin_status => 'حالة الحاوية';

  @override
  String get bin_status_update => 'تحديث حالة الحاوية';

  @override
  String percent_full(int percent) {
    return 'الامتلاء $percent٪';
  }

  @override
  String get today => 'اليوم';

  @override
  String get highlights => 'أبرز المؤشرات';

  @override
  String get back_to_driver_dashboard => 'العودة إلى لوحة السائق';

  @override
  String get truck => 'الشاحنة';

  @override
  String get shift => 'الوردية';

  @override
  String get contact => 'التواصل';

  @override
  String get morning_shift => 'صباحية (06:00 - 14:00)';

  @override
  String get area_supervisor_dashboard => 'لوحة مشرف المنطقة';

  @override
  String get today_kpis => 'مؤشرات اليوم';

  @override
  String get area_alerts => 'تنبيهات المنطقة';

  @override
  String get alert_bins_broken => 'تم الإبلاغ عن 3 حاويات معطّلة';

  @override
  String get alert_drivers_behind => 'تأخر سائقين اثنين عن الجدول';

  @override
  String get alert_fuel_above_baseline =>
      'استهلاك الوقود أعلى من الأساس بنسبة 4٪';

  @override
  String get governorate_dashboard => 'لوحة المحافظة';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get service_distribution => 'توزيع الخدمة';

  @override
  String get gov_stats => 'إحصاءات\\nالمحافظة';

  @override
  String get active_drivers => 'السائقون النشطون';

  @override
  String get completed_stops => 'المحطات المكتملة';

  @override
  String get open_issues => 'المشكلات المفتوحة';

  @override
  String get on_time_service => 'الخدمة في الوقت';

  @override
  String get areas_covered => 'المناطق المشمولة';

  @override
  String get total_trucks => 'إجمالي الشاحنات';

  @override
  String get daily_km_smart => 'كم يومي (وضع ذكي)';

  @override
  String get fuel_saved => 'الوقود الموفَّر';

  @override
  String get route_distance_reduced => 'تم تقليل مسافة المسار بنسبة 18٪';

  @override
  String get estimated_fuel_saved => 'الوقود الموفَّر تقديريًا: 14.2 لتر';

  @override
  String get priority_bins_ontime => 'خدمة الحاويات ذات الأولوية في الوقت: 96٪';

  @override
  String get msar_branding_title => 'Mihwar';

  @override
  String get msar_branding_subtitle =>
      'ابدأ بدراسة المشكلة (قبل) أو الحل الذكي (بعد).';

  @override
  String get login_hint_drivers =>
      'استخدم معرفك الحكومي وكلمة المرور (السائقون 1001، 1006).';

  @override
  String get invalid_credentials_hint =>
      'المعرف أو كلمة المرور غير صحيحة. جرّب السائقين 1001 أو 1006 / 1234 أو 2001/1234 أو 3001/1234.';

  @override
  String get logout => 'خروج';

  @override
  String get compliance_label => 'نسبة الالتزام';

  @override
  String get trip_completed_title => 'انتهت جولتك';

  @override
  String get trip_completed_message => 'أحسنت! لقد أنهيت جميع المحطات المخططة.';

  @override
  String get distance_traveled => 'المسافة المقطوعة';

  @override
  String get exit_label => 'خروج';

  @override
  String get currency_jod => 'دينار';

  @override
  String get km_unit => 'كم';

  @override
  String get liter_unit => 'لتر';

  @override
  String get training_title => 'التدريب / جمع البيانات (عرض تجريبي)';

  @override
  String get training_start_trip => 'ابدأ جولة التدريب';

  @override
  String get training_pick_status => 'اختيار حالة الحاوية';

  @override
  String get training_completed => 'اكتملت جولة التدريب';

  @override
  String get training_trip_ended => 'انتهت جولتك';

  @override
  String get training_moving_next => 'التحرك إلى الحاوية التالية...';

  @override
  String get smart_hint_start_trip => 'ابدأ الرحلة';

  @override
  String get smart_hint_priority_bins =>
      'فقط الحاويات الداكنة متوقعة أن تكون شبه ممتلئة اليوم. الحاويات الباهتة يتم تجاوزها لتوفير الديزل.';

  @override
  String get smart_hint_diesel_shortest_visual =>
      'المسار محسّن لتقليل استهلاك الديزل.';

  @override
  String get driver_compliance_title => 'التزام السائق';

  @override
  String get driver_compliance_formula =>
      'الالتزام = المحطات المؤكدة / المحطات المخططة';

  @override
  String get supervisor_skipped_bins => 'حاويات متخطاة';

  @override
  String get supervisor_bypass_attempts => 'محاولات تجاوز';

  @override
  String get supervisor_late_route => 'تأخر في المسار';

  @override
  String get supervisor_low_compliance => 'انخفاض الالتزام';

  @override
  String get supervisor_yes => 'نعم';

  @override
  String get supervisor_no => 'لا';

  @override
  String get demo_loaded => 'تم تحميل السيناريو التجريبي.';

  @override
  String get demo_reset_done => 'تمت إعادة تعيين العرض التجريبي.';

  @override
  String get reset_demo => 'إعادة تعيين العرض';

  @override
  String get ai_predictive_engine => 'الذكاء الاصطناعي / المحرك التنبؤي';

  @override
  String get governorate_before_after_title => 'تأثير الديزل قبل مقابل بعد';

  @override
  String get governorate_optimize_hint =>
      'نحن نحسّن لاستهلاك الديزل وليس فقط للمسافة.';

  @override
  String get governorate_route_time => 'زمن المسار';

  @override
  String governorate_route_time_value(int before, int after) {
    return '$before دقيقة -> $after دقيقة';
  }

  @override
  String get governorate_unnecessary_stops => 'تقليل المحطات غير الضرورية';

  @override
  String governorate_stops_per_day_value(int count) {
    return '$count محطة/يوم';
  }

  @override
  String get governorate_co2_saved => 'تقدير الانبعاثات الموفّرة';

  @override
  String governorate_kg_per_year_value(Object count) {
    return '$count كغ/سنة';
  }

  @override
  String get governorate_route_demo_failed => 'فشل عرض المسار';

  @override
  String get governorate_demo_controls => 'أدوات السيناريو التجريبي';

  @override
  String get governorate_settings_title => 'الإعدادات / حول';

  @override
  String get governorate_about_title => 'حول هذا العرض';

  @override
  String get governorate_about_threshold =>
      'عتبة الأولوية هي 85٪ من الامتلاء المتوقع.';

  @override
  String get governorate_about_frequency =>
      'الحاويات السكنية تُخدم مرتين يوميًا، والتجارية أربع مرات يوميًا في البيانات التاريخية المولدة.';

  @override
  String get governorate_about_seasonality =>
      'تعديلات الموسمية تشمل رمضان وفترة الصيف/العطلات.';

  @override
  String get governorate_about_diesel_model =>
      'تحسين المسار يفضّل تقليل استهلاك الديزل وليس فقط أقصر مسافة.';

  @override
  String get governorate_load_demo => 'تحميل السيناريو التجريبي';

  @override
  String get governorate_predictive_failed => 'فشل المحرك التنبؤي';

  @override
  String get governorate_score => 'الدرجة';

  @override
  String get governorate_todo_export =>
      'لاحقًا: ربط تصدير PDF في المرحلة التالية.';

  @override
  String get governorate_before_after_map => 'خريطة قبل مقابل بعد';

  @override
  String get governorate_why_route => 'لماذا هذا المسار؟';

  @override
  String get governorate_route_before_label => 'قبل (مسار ثابت)';

  @override
  String get governorate_route_after_label => 'بعد (مسار ذكي بالأولويات)';

  @override
  String get governorate_short_uphill_demo =>
      'مثال صعود قصير مقابل طريق منبسط أطول';

  @override
  String get governorate_road_profile_effect =>
      'طبيعة الطريق تؤثر بقوة على استهلاك الديزل، لذلك يركّز المُحسّن على الوقود وليس الكيلومترات فقط.';

  @override
  String get governorate_period_daily => 'يومي';

  @override
  String get governorate_period_weekly => 'أسبوعي';

  @override
  String get governorate_period_monthly => 'شهري';

  @override
  String get governorate_period_yearly => 'سنوي';

  @override
  String get supervisor_diesel_before_after => 'الديزل قبل / بعد';

  @override
  String get supervisor_totals_title => 'إجمالي المنطقة (جميع السائقين)';

  @override
  String get predict_reason_commercial_fast =>
      'المنطقة التجارية تمتلئ بسرعة أكبر.';

  @override
  String get predict_reason_commercial_high =>
      'كثافة النشاط التجاري عالية في هذه المنطقة.';

  @override
  String get predict_reason_commercial_medium =>
      'كثافة النشاط التجاري متوسطة في هذه المنطقة.';

  @override
  String get predict_reason_commercial_low =>
      'النشاط التجاري أخف في هذه المنطقة.';

  @override
  String get predict_reason_residential_slow =>
      'المنطقة السكنية تمتلئ أبطأ عادةً.';

  @override
  String get predict_reason_residential_high =>
      'الكثافة السكنية عالية في هذه المنطقة.';

  @override
  String get predict_reason_residential_medium =>
      'الكثافة السكنية متوسطة في هذه المنطقة.';

  @override
  String get predict_reason_residential_low =>
      'الكثافة السكنية أقل في هذه المنطقة.';

  @override
  String get predict_reason_history_full =>
      'سجل الامتلاء السابق يدعم إعطاء أولوية اليوم.';

  @override
  String get predict_reason_ramadan_multiplier =>
      'النمط الموسمي يرفع الامتلاء خلال شهر مشابه لرمضان.';

  @override
  String get predict_reason_summer_multiplier =>
      'فترة الصيف ترفع معدلات الامتلاء بشكل عام.';

  @override
  String get predict_reason_weekend_increase =>
      'نمط نهاية الأسبوع يزيد الامتلاء المتوقع.';

  @override
  String get predict_reason_early_week_reduction =>
      'نمط بداية الأسبوع يخفض الامتلاء المتوقع قليلًا.';

  @override
  String get predict_reason_last_service_stale =>
      'مرور وقت أطول منذ آخر خدمة يزيد احتمال الامتلاء الحالي.';

  @override
  String get predict_reason_avg_daily_fill_high =>
      'ملف الامتلاء اليومي المتوسط لهذه الحاوية مرتفع.';

  @override
  String get predict_reason_avg_daily_fill_medium =>
      'ملف الامتلاء اليومي المتوسط لهذه الحاوية متوسط.';

  @override
  String get predict_reason_avg_daily_fill_low =>
      'ملف الامتلاء اليومي المتوسط لهذه الحاوية أقل.';

  @override
  String get predict_reason_fallback_top3 =>
      'لم تتجاوز أي حاوية العتبة، فتم عرض أفضل 3 خيارات.';

  @override
  String get predict_reason_generic_fallback =>
      'تم التنبؤ اعتمادًا على عوامل النموذج لهذه الوردية.';

  @override
  String get predict_reason_weekend_commercial =>
      'تأثير نهاية الأسبوع يرفع الطلب التجاري.';

  @override
  String get predict_reason_weekday_residential =>
      'نمط الأسر في أيام الأسبوع معتدل.';

  @override
  String get predict_reason_priority_today => 'متوقع كأولوية لليوم.';

  @override
  String get area_name_1001 => 'الزرقاء - الكرامة شمال';

  @override
  String get area_name_1002 => 'الزرقاء - الكرامة شرق';

  @override
  String get area_name_1003 => 'الزرقاء - الكرامة جنوب';

  @override
  String get area_name_1004 => 'الزرقاء - الكرامة غرب';

  @override
  String get area_name_1005 => 'الزرقاء - الكرامة وسط';

  @override
  String get area_name_1006 => 'ساحة التدريب';

  @override
  String get area_name_generic => 'الزرقاء - الكرامة';

  @override
  String get before_label => 'قبل';

  @override
  String get after_label => 'بعد';

  @override
  String get before_study_title => 'قبل: دراسة المشكلة';

  @override
  String get before_study_placeholder =>
      'سيتم إضافة شاشة دراسة المشكلة في الخطوة 2 (بدون خرائط، مع تحليل الزيارات المهدرة واستهلاك الديزل).';

  @override
  String get supervisor_section_driver_info => 'معلومات السائق';

  @override
  String get supervisor_route_compliance_efficiency => 'كفاءة الالتزام بالمسار';

  @override
  String get supervisor_section_compliance_summary => 'ملخص الالتزام';

  @override
  String get supervisor_section_stops_summary => 'ملخص الحاويات';

  @override
  String get supervisor_section_diesel => 'الديزل (قبل / بعد / التوفير)';

  @override
  String get supervisor_section_compliance_explanation => 'شرح احتساب الالتزام';

  @override
  String get supervisor_fully_compliant => 'ملتزم بالكامل';

  @override
  String get supervisor_trips_title => 'الجولات اليومية';

  @override
  String supervisor_trip_label(int number) {
    return 'جولة $number';
  }

  @override
  String get supervisor_predicted_bins_count => 'الحاويات المتنبأ بها';

  @override
  String get supervisor_serviced_bins_count => 'الحاويات التي تم خدمتها';

  @override
  String get supervisor_missed_bins_count => 'حاويات تم تخطيها';

  @override
  String get supervisor_route_deviation_level => 'مستوى الانحراف عن المسار';

  @override
  String get supervisor_route_penalty_points => 'خصم المسار';

  @override
  String get supervisor_app_penalty_points => 'خصم الالتزام بالتطبيق';

  @override
  String get supervisor_route_deviation_none => 'بدون';

  @override
  String get supervisor_route_deviation_low => 'منخفض';

  @override
  String get supervisor_route_deviation_medium => 'متوسط';

  @override
  String get supervisor_route_deviation_high => 'مرتفع';

  @override
  String get supervisor_route_deviation_severe => 'شديد';

  @override
  String get supervisor_no_non_compliant_alerts =>
      'لا توجد تنبيهات على السائقين غير الملتزمين';

  @override
  String get supervisor_liters_label => 'اللترات';

  @override
  String get supervisor_cost_label => 'التكلفة';

  @override
  String get supervisor_savings_label => 'التوفير';

  @override
  String get supervisor_saved_liters_label => 'اللترات الموفرة';

  @override
  String get supervisor_saved_cost_label => 'التكلفة الموفرة';

  @override
  String get supervisor_percent_label => 'النسبة';

  @override
  String get supervisor_points_unit => 'نقطة';

  @override
  String get supervisor_score_formula =>
      'النتيجة النهائية = 100 - (خصم الحاويات + خصم المسار + خصم الالتزام بالتطبيق). الأوزان: الحاويات 60، المسار 30، التطبيق 10.';

  @override
  String get supervisor_bin_penalty => 'خصم الحاويات';

  @override
  String get supervisor_route_penalty => 'خصم المسار';

  @override
  String get supervisor_app_penalty => 'خصم الالتزام بالتطبيق';

  @override
  String get supervisor_final_result => 'النتيجة النهائية';

  @override
  String get supervisor_alert_reason_missed_bins => 'تم تخطي حاويات متنبأ بها';

  @override
  String get supervisor_alert_reason_route_medium =>
      'انحراف متوسط عن المسار المخطط';

  @override
  String get supervisor_alert_reason_route_high =>
      'انحراف مرتفع عن المسار المخطط';

  @override
  String get supervisor_alert_reason_app =>
      'عدم الالتزام الكامل بخطوات التطبيق';

  @override
  String get governorate_manager_dashboard_title => 'لوحة مدير المحافظة';

  @override
  String get governorate_zarqa_subtitle => 'محافظة الزرقاء';

  @override
  String get governorate_dashboard_note =>
      'عرض مناطق المحافظة ومشرف كل منطقة وملخص السائقين.';

  @override
  String get governorate_area_supervisor_label => 'مشرف المنطقة';

  @override
  String get governorate_supervisor_unavailable => 'غير متوفر';

  @override
  String get governorate_area_drivers_title => 'سائقو المنطقة';

  @override
  String get governorate_expected_daily_label => 'المتوقع (يومي)';

  @override
  String get governorate_actual_daily_label => 'الفعلي (يومي)';

  @override
  String get governorate_area_totals_diesel_title => 'إجمالي المنطقة - الديزل';

  @override
  String get governorate_non_compliant_drivers_count =>
      'عدد السائقين غير الملتزمين';

  @override
  String get governorate_empty_area_state =>
      'لا توجد بيانات لهذه المنطقة في الديمو حالياً';

  @override
  String get governorate_status_below_expected => 'أقل من المتوقع';

  @override
  String get governorate_status_within_expected => 'ضمن المتوقع';

  @override
  String get governorate_status_above_expected => 'أعلى من المتوقع';

  @override
  String get governorate_alerts_non_compliant =>
      'التنبيهات (لغير الملتزمين فقط)';

  @override
  String get governorate_alert_reason_missed_bins => 'تم تخطي حاويات متنبأ بها';

  @override
  String get governorate_alert_reason_route_medium =>
      'انحراف متوسط عن المسار المخطط';

  @override
  String get governorate_alert_reason_route_high =>
      'انحراف مرتفع عن المسار المخطط';

  @override
  String get governorate_alert_reason_app =>
      'عدم الالتزام الكامل بخطوات التطبيق';

  @override
  String get governorate_liters_label => 'اللترات';

  @override
  String get governorate_cost_label => 'التكلفة';

  @override
  String get governorate_savings_label => 'التوفير';

  @override
  String get governorate_saved_liters_label => 'اللترات الموفرة';

  @override
  String get governorate_saved_cost_label => 'التكلفة الموفرة';

  @override
  String get governorate_percent_label => 'النسبة';

  @override
  String get governorate_area_karama_street => 'الزرقاء - شارع الكرامة';

  @override
  String get governorate_area_new_zarqa => 'الزرقاء - الزرقاء الجديدة';

  @override
  String get governorate_area_russeifa => 'الزرقاء - الرصيفة';

  @override
  String get governorate_area_hashmiya => 'الزرقاء - الهاشمية';

  @override
  String get governorate_area_old_zarqa => 'الزرقاء - وسط المدينة';
}
