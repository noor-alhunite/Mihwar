# -*- coding: utf-8 -*-

# =========================================================
# قبل التشغيل على جهازك (مرة واحدة فقط) نفّذ:
# pip install xgboost scikit-learn ortools pandas numpy
#
# ثم شغّل:
# python ai/code/predict_bins.py
# =========================================================

from pathlib import Path
import json
import urllib.request
import urllib.error
from math import radians, sin, cos, sqrt, atan2

import pandas as pd
import numpy as np
from xgboost import XGBRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.preprocessing import LabelEncoder
from ortools.constraint_solver import pywrapcp, routing_enums_pb2


# =========================================================
# 1) إعدادات المشروع
# =========================================================
BASE_DIR = Path(__file__).resolve().parents[1]   # ai/
DATASET_DIR = BASE_DIR / "dataset"
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

CSV_FILE = DATASET_DIR / "smart_bins_10.csv"

# أفضل 10 حاويات لشاحنة 1001
TARGET_BINS = [
    "BIN-004",
    "BIN-006",
    "BIN-007",
    "BIN-005",
    "BIN-009",
    "BIN-011",
    "BIN-015",
    "BIN-012",
    "BIN-020",
    "BIN-017",
]

# العتبة المعتمدة في المشروع
THRESHOLD = 85

# وقت الجولة (للناتج الحالي single-round)
ROUTE_HOUR = 9
ROUTE_TIME_LABEL = "Morning"

TIME_CODE_MAP = {
    "Morning": 0,
    "Noon": 1,
    "Afternoon": 2,
    "Evening": 3,
}
ROUTE_TIME_CODE = TIME_CODE_MAP[ROUTE_TIME_LABEL]

# 4 جولات تشغيلية للتنبؤ متعدد الجولات (لـ Flutter driver 1001)
# Round 1 = 08:00, Round 2 = 11:00, Round 3 = 14:00, Round 4 = 18:00
OPERATIONAL_ROUNDS = [
    (1, 8, 0),   # round_num, hour, time_code (Morning)
    (2, 11, 1),  # Noon
    (3, 14, 2),  # Afternoon
    (4, 18, 3),  # Evening
]

# موقع الشاحنة الحالي / نقطة الانطلاق
TRUCK_START_LAT = 32.0589
TRUCK_START_LON = 36.065

# OSRM
OSRM_BASE_URL = "https://router.project-osrm.org"


# =========================================================
# 2) دوال مساعدة
# =========================================================
def haversine_km(lat1, lon1, lat2, lon2):
    """Fallback فقط في حال فشل OSRM."""
    r = 6371.0
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return r * c


def osrm_get_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": "msar-ai/1.0"})
    with urllib.request.urlopen(req, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def build_osrm_distance_matrix(coords):
    """
    coords: list of tuples [(lat, lon), ...]
    Returns matrix in METERS based on road network.
    If OSRM fails, falls back to haversine meters.
    """
    coord_str = ";".join([f"{lon},{lat}" for lat, lon in coords])
    url = f"{OSRM_BASE_URL}/table/v1/driving/{coord_str}?annotations=distance"

    try:
        data = osrm_get_json(url)
        if data.get("code") != "Ok":
            raise ValueError(f"OSRM table error: {data}")

        distances = data.get("distances")
        if not distances:
            raise ValueError("OSRM table returned no distances.")

        matrix = []
        for i, row in enumerate(distances):
            new_row = []
            for j, value in enumerate(row):
                if value is None:
                    # fallback لهذه الخلية فقط
                    meters = haversine_km(
                        coords[i][0], coords[i][1],
                        coords[j][0], coords[j][1]
                    ) * 1000.0
                    new_row.append(int(meters))
                else:
                    new_row.append(int(value))
            matrix.append(new_row)

        return matrix, "osrm"

    except Exception as e:
        print(f"\n[WARN] فشل OSRM Table، سيتم استخدام fallback haversine. السبب: {e}")

        n = len(coords)
        matrix = [[0] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                if i != j:
                    meters = haversine_km(
                        coords[i][0], coords[i][1],
                        coords[j][0], coords[j][1]
                    ) * 1000.0
                    matrix[i][j] = int(meters)
        return matrix, "fallback_haversine"


def solve_tsp(distance_matrix, depot_index=0):
    """
    يحسب أقصر ترتيب زيارة باستخدام OR-Tools
    اعتمادًا على مصفوفة مسافات الطرق (وليس خط مستقيم).
    """
    manager = pywrapcp.RoutingIndexManager(len(distance_matrix), 1, depot_index)
    routing = pywrapcp.RoutingModel(manager)

    def distance_callback(from_index, to_index):
        from_node = manager.IndexToNode(from_index)
        to_node = manager.IndexToNode(to_index)
        return distance_matrix[from_node][to_node]

    transit_callback_index = routing.RegisterTransitCallback(distance_callback)
    routing.SetArcCostEvaluatorOfAllVehicles(transit_callback_index)

    search_parameters = pywrapcp.DefaultRoutingSearchParameters()
    search_parameters.first_solution_strategy = routing_enums_pb2.FirstSolutionStrategy.PATH_CHEAPEST_ARC

    solution = routing.SolveWithParameters(search_parameters)
    if not solution:
        return None, None

    index = routing.Start(0)
    route_nodes = []
    total_distance_m = 0

    while not routing.IsEnd(index):
        node_index = manager.IndexToNode(index)
        route_nodes.append(node_index)

        previous_index = index
        index = solution.Value(routing.NextVar(index))
        total_distance_m += routing.GetArcCostForVehicle(previous_index, index, 0)

    route_nodes.append(0)  # العودة إلى نقطة البداية
    return route_nodes, total_distance_m / 1000.0


def fetch_osrm_route_geometry(start_lat, start_lon, end_lat, end_lon):
    """
    يرجّع هندسة المسار على الشوارع بين نقطتين.
    """
    coord_str = f"{start_lon},{start_lat};{end_lon},{end_lat}"
    url = (
        f"{OSRM_BASE_URL}/route/v1/driving/{coord_str}"
        f"?overview=full&geometries=geojson&steps=false"
    )

    try:
        data = osrm_get_json(url)
        if data.get("code") != "Ok":
            raise ValueError(f"OSRM route error: {data}")

        route = data["routes"][0]
        geometry = route["geometry"]["coordinates"]  # [[lon, lat], ...]
        distance_m = route.get("distance", 0.0)
        duration_s = route.get("duration", 0.0)

        return {
            "geometry": geometry,
            "distance_m": distance_m,
            "duration_s": duration_s,
            "source": "osrm"
        }

    except Exception as e:
        print(f"[WARN] فشل OSRM Route لهذه القطعة، سيتم fallback بسيط. السبب: {e}")
        # fallback geometry بسيط
        return {
            "geometry": [[start_lon, start_lat], [end_lon, end_lat]],
            "distance_m": haversine_km(start_lat, start_lon, end_lat, end_lon) * 1000.0,
            "duration_s": None,
            "source": "fallback_straight_line"
        }


def explain_bin(row):
    reasons = []

    bin_type = str(row["bin_type"]).strip().lower()

    if bin_type == "commercial":
        reasons.append("منطقة تجارية تمتلئ أسرع")
    elif bin_type == "residential_dense":
        reasons.append("منطقة سكنية مكتظة")
    elif bin_type == "residential_quiet":
        reasons.append("منطقة سكنية هادئة")
    else:
        reasons.append("نوع منطقة غير مصنف بدقة")

    if row["prev_fill"] >= 70:
        reasons.append("آخر قراءة كانت مرتفعة")
    elif row["prev_fill"] >= 50:
        reasons.append("آخر قراءة كانت متوسطة وتميل للارتفاع")

    if row["fill_rate"] > 10:
        reasons.append("معدل الامتلاء ارتفع بسرعة")
    elif row["fill_rate"] > 0:
        reasons.append("هناك ارتفاع مستمر في الامتلاء")

    if row["rolling_fill_mean_3"] >= 65:
        reasons.append("المتوسط في آخر القراءات مرتفع")

    if row["predicted_fill"] >= THRESHOLD:
        reasons.append(f"متوقع أن تصل إلى {THRESHOLD}% أو أكثر وقت الجولة")

    return " | ".join(reasons)


# =========================================================
# 3) قراءة البيانات
# =========================================================
if not CSV_FILE.exists():
    raise FileNotFoundError(f"لم يتم العثور على ملف الداتاسيت: {CSV_FILE}")

df = pd.read_csv(CSV_FILE)

print("البيانات الخام:")
print(df.head())
print(f"عدد السجلات الكلي: {len(df)}")

# =========================================================
# 4) تصفية البيانات للحاويات المستهدفة فقط
# =========================================================
df = df[df["bin_id"].isin(TARGET_BINS)].copy()

print(f"\nعدد السجلات بعد اختيار الحاويات المستهدفة: {len(df)}")
print("الحاويات المستخدمة:")
print(sorted(df["bin_id"].unique()))

# =========================================================
# 5) تنظيف البيانات وتحضيرها
# =========================================================
df = df.dropna(subset=["fill_level_percent"]).copy()
df["timestamp"] = pd.to_datetime(df["timestamp"], errors="coerce")
df = df.dropna(subset=["timestamp"]).copy()
df = df.sort_values(["bin_id", "timestamp"]).reset_index(drop=True)

# البطارية
if "battery_level_percent" in df.columns:
    df["battery_level_percent"] = df.groupby("bin_id")["battery_level_percent"].ffill()
    df["battery_level_percent"] = df.groupby("bin_id")["battery_level_percent"].transform(
        lambda x: x.fillna(x.mean())
    )
    df["battery_level_percent"] = df["battery_level_percent"].fillna(80.0)
else:
    df["battery_level_percent"] = 80.0

# حالة الحاوية
df["bin_status"] = df["bin_status"].fillna("unknown")
le_status = LabelEncoder()
df["status_code"] = le_status.fit_transform(df["bin_status"])

# نوع الحاوية
le_type = LabelEncoder()
df["type_code"] = le_type.fit_transform(df["bin_type"])

# =========================================================
# 6) استخراج الميزات الزمنية
# =========================================================
df["hour"] = df["timestamp"].dt.hour
df["day"] = df["timestamp"].dt.day
df["month"] = df["timestamp"].dt.month
df["day_of_week_num"] = df["timestamp"].dt.dayofweek
df["time_code"] = df["time_of_day"].map(TIME_CODE_MAP).fillna(0).astype(int)

# =========================================================
# 7) ميزات تاريخية للحاوية
# =========================================================
df["prev_fill"] = df.groupby("bin_id")["fill_level_percent"].shift(1)
df["prev_fill"] = df["prev_fill"].fillna(df["fill_level_percent"])

df["fill_diff"] = df.groupby("bin_id")["fill_level_percent"].diff().fillna(0)
df["fill_rate"] = df["fill_diff"]

df["rolling_fill_mean_3"] = (
    df.groupby("bin_id")["fill_level_percent"]
      .rolling(window=3, min_periods=1)
      .mean()
      .reset_index(level=0, drop=True)
)

df["rolling_fill_max_3"] = (
    df.groupby("bin_id")["fill_level_percent"]
      .rolling(window=3, min_periods=1)
      .max()
      .reset_index(level=0, drop=True)
)

# =========================================================
# 8) تعريف الميزات والهدف
# =========================================================
features = [
    "hour",
    "day",
    "month",
    "day_of_week_num",
    "time_code",
    "location_latitude",
    "location_longitude",
    "battery_level_percent",
    "type_code",
    "status_code",
    "prev_fill",
    "fill_rate",
    "rolling_fill_mean_3",
    "rolling_fill_max_3",
]

available_features = [col for col in features if col in df.columns]

X = df[available_features].copy()
y = df["fill_level_percent"].copy()

# =========================================================
# 9) تقسيم البيانات
# =========================================================
split_index = int(len(X) * 0.8)
X_train, X_test = X.iloc[:split_index], X.iloc[split_index:]
y_train, y_test = y.iloc[:split_index], y.iloc[split_index:]

print(f"\nبيانات التدريب: {len(X_train)} صف")
print(f"بيانات الاختبار: {len(X_test)} صف")

# =========================================================
# 10) تدريب نموذج XGBoost
# =========================================================
model = XGBRegressor(
    n_estimators=400,
    max_depth=5,
    learning_rate=0.05,
    subsample=0.9,
    colsample_bytree=0.9,
    objective="reg:squarederror",
    random_state=42,
    n_jobs=-1,
)

model.fit(X_train, y_train)
y_pred = model.predict(X_test)

mae = mean_absolute_error(y_test, y_pred)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))
r2 = r2_score(y_test, y_pred)

print("\n--- أداء نموذج XGBoost ---")
print(f"MAE: {mae:.2f}%")
print(f"RMSE: {rmse:.2f}%")
print(f"R²: {r2:.3f}")

# =========================================================
# 11) تجهيز آخر حالة لكل حاوية وربطها بوقت الجولة
# =========================================================
latest = df.sort_values("timestamp").groupby("bin_id").last().reset_index()

# التنبؤ مرتبط بوقت الجولة
latest["hour"] = ROUTE_HOUR
latest["time_code"] = ROUTE_TIME_CODE

X_latest = latest[available_features].fillna(0)
latest["predicted_fill"] = model.predict(X_latest)
latest["predicted_fill"] = latest["predicted_fill"].clip(0, 100)

# =========================================================
# 12) تفسير سبب الاختيار
# =========================================================
latest["prediction_reason"] = latest.apply(explain_bin, axis=1)

# =========================================================
# 12b) تنبؤ متعدد الجولات: جميع الـ 10 حاويات × 4 جولات (لـ Flutter)
# =========================================================
multiround_output = {}
for round_num, round_hour, time_code in OPERATIONAL_ROUNDS:
    latest_round = latest.copy()
    latest_round["hour"] = round_hour
    latest_round["time_code"] = time_code
    X_round = latest_round[available_features].fillna(0)
    latest_round["predicted_fill"] = model.predict(X_round)
    latest_round["predicted_fill"] = latest_round["predicted_fill"].clip(0, 100)
    latest_round["prediction_reason"] = latest_round.apply(explain_bin, axis=1)
    round_list = []
    for _, row in latest_round.sort_values("predicted_fill", ascending=False).iterrows():
        round_list.append({
            "bin_id": row["bin_id"],
            "predicted_fill": round(float(row["predicted_fill"]), 1),
            "location_latitude": float(row["location_latitude"]),
            "location_longitude": float(row["location_longitude"]),
            "bin_type": row["bin_type"],
            "prediction_reason": row["prediction_reason"],
        })
    multiround_output[f"round_{round_num}"] = round_list

# =========================================================
# 13) اختيار الحاويات ذات الأولوية
# =========================================================
latest["selected_for_collection"] = latest["predicted_fill"] >= THRESHOLD
bins_to_collect = latest[latest["selected_for_collection"]].copy()

print(f"\nعدد الحاويات المتوقع وصولها إلى {THRESHOLD}% أو أكثر: {len(bins_to_collect)}")

# =========================================================
# 14) جميع النتائج
# =========================================================
result = latest[
    [
        "bin_id",
        "bin_type",
        "address_city",
        "location_latitude",
        "location_longitude",
        "predicted_fill",
        "selected_for_collection",
        "prediction_reason",
    ]
].copy()

result = result.sort_values("predicted_fill", ascending=False).reset_index(drop=True)
predicted_bins = result[result["selected_for_collection"]].copy()

print("\n--- جميع الحاويات مع نسبة التنبؤ ---")
print(result)

print("\n--- الحاويات المختارة للجمع ---")
print(predicted_bins)

# =========================================================
# 15) حساب أقصر جولة على الشوارع من موقع الشاحنة
# =========================================================
route_summary = pd.DataFrame()
route_json_output = {}

if len(predicted_bins) > 0:
    # نقطة 0 = موقع الشاحنة الحالي
    coords = [(TRUCK_START_LAT, TRUCK_START_LON)]

    # باقي النقاط = الحاويات المختارة
    selected_rows = predicted_bins.reset_index(drop=True)
    for _, row in selected_rows.iterrows():
        coords.append((row["location_latitude"], row["location_longitude"]))

    distance_matrix_m, distance_source = build_osrm_distance_matrix(coords)
    route_opt, dist_opt_km = solve_tsp(distance_matrix_m, depot_index=0)

    if route_opt is not None:
        print("\n--- أقصر مسار على الشوارع لإنهاء الجولة ---")
        print("ترتيب العقد:", route_opt)
        print(f"المسافة الإجمالية: {dist_opt_km:.2f} كم")
        print(f"مصدر المسافات: {distance_source}")

        route_rows = []
        route_legs = []
        full_geometry = []

        # تجهيز ملخص الزيارة + هندسة كل قطعة
        for seq, node in enumerate(route_opt):
            if node == 0:
                route_rows.append({
                    "visit_order": seq + 1,
                    "bin_id": "TRUCK_START",
                    "predicted_fill": None,
                    "prediction_reason": "موقع الشاحنة الحالي / البداية أو العودة",
                })
            else:
                bin_row = selected_rows.iloc[node - 1]
                route_rows.append({
                    "visit_order": seq + 1,
                    "bin_id": bin_row["bin_id"],
                    "predicted_fill": round(float(bin_row["predicted_fill"]), 1),
                    "prediction_reason": bin_row["prediction_reason"],
                })

        # جلب هندسة الطريق الحقيقي لكل قطعة
        for idx in range(len(route_opt) - 1):
            from_node = route_opt[idx]
            to_node = route_opt[idx + 1]

            from_lat, from_lon = coords[from_node]
            to_lat, to_lon = coords[to_node]

            leg_route = fetch_osrm_route_geometry(from_lat, from_lon, to_lat, to_lon)

            from_id = "TRUCK_START" if from_node == 0 else selected_rows.iloc[from_node - 1]["bin_id"]
            to_id = "TRUCK_START" if to_node == 0 else selected_rows.iloc[to_node - 1]["bin_id"]

            route_legs.append({
                "leg_order": idx + 1,
                "from": from_id,
                "to": to_id,
                "distance_m": round(float(leg_route["distance_m"]), 2) if leg_route["distance_m"] is not None else None,
                "duration_s": round(float(leg_route["duration_s"]), 2) if leg_route["duration_s"] is not None else None,
                "geometry": leg_route["geometry"],
                "source": leg_route["source"],
            })

            # دمج geometry كامل للمسار
            if leg_route["geometry"]:
                if not full_geometry:
                    full_geometry.extend(leg_route["geometry"])
                else:
                    # نتجنب تكرار أول نقطة
                    full_geometry.extend(leg_route["geometry"][1:])

        route_summary = pd.DataFrame(route_rows)

        route_json_output = {
            "truck_start": {
                "lat": TRUCK_START_LAT,
                "lon": TRUCK_START_LON
            },
            "route_time_label": ROUTE_TIME_LABEL,
            "route_hour": ROUTE_HOUR,
            "threshold": THRESHOLD,
            "total_distance_km": round(float(dist_opt_km), 2),
            "distance_source": distance_source,
            "visit_order": route_rows,
            "legs": route_legs,
            "full_geometry": full_geometry,
        }

    else:
        print("لم يتم العثور على مسار أمثل.")
else:
    print("لا توجد حاويات متجاوزة للعتبة، لذلك لا يوجد مسار للجولة.")

# =========================================================
# 16) حفظ النتائج للتطبيق وللتحليل
# =========================================================
all_predicted_bins_csv = OUTPUT_DIR / "all_predicted_bins.csv"
predicted_bins_csv = OUTPUT_DIR / "predicted_bins.csv"
optimal_trip_order_csv = OUTPUT_DIR / "optimal_trip_order.csv"
optimal_trip_route_json = OUTPUT_DIR / "optimal_trip_route.json"
predicted_bins_flutter_json = OUTPUT_DIR / "predicted_bins_for_flutter.json"
predicted_bins_multiround_flutter_json = OUTPUT_DIR / "predicted_bins_multiround_flutter.json"

result.to_csv(all_predicted_bins_csv, index=False, encoding="utf-8-sig")
predicted_bins.to_csv(predicted_bins_csv, index=False, encoding="utf-8-sig")

if not route_summary.empty:
    route_summary.to_csv(optimal_trip_order_csv, index=False, encoding="utf-8-sig")

if route_json_output:
    with open(optimal_trip_route_json, "w", encoding="utf-8") as f:
        json.dump(route_json_output, f, ensure_ascii=False, indent=2)

# ملف جاهز لـ Flutter
flutter_output = []
for _, row in predicted_bins.iterrows():
    flutter_output.append({
        "bin_id": row["bin_id"],
        "predicted_fill": round(float(row["predicted_fill"]), 1),
        "selected_for_collection": bool(row["selected_for_collection"]),
        "prediction_reason": row["prediction_reason"],
        "location_latitude": float(row["location_latitude"]),
        "location_longitude": float(row["location_longitude"]),
        "bin_type": row["bin_type"],
    })

with open(predicted_bins_flutter_json, "w", encoding="utf-8") as f:
    json.dump(flutter_output, f, ensure_ascii=False, indent=2)

# ملف متعدد الجولات: جميع الـ 10 حاويات × 4 جولات (لـ Flutter driver 1001)
with open(predicted_bins_multiround_flutter_json, "w", encoding="utf-8") as f:
    json.dump(multiround_output, f, ensure_ascii=False, indent=2)

# =========================================================
# 17) ملخص نهائي
# =========================================================
print("\n========== ملخص نهائي ==========")
print(f"عدد الحاويات المستخدمة في النموذج: {len(TARGET_BINS)}")
print(f"وقت الجولة المعتمد: {ROUTE_TIME_LABEL} (الساعة {ROUTE_HOUR})")
print(f"Threshold المعتمد: {THRESHOLD}%")
print(f"عدد الحاويات المختارة للجمع: {len(predicted_bins)}")
print(f"\nتم حفظ الملفات داخل: {OUTPUT_DIR}")

print("\nالملفات الناتجة:")
print(f"1) {all_predicted_bins_csv.name}         -> جميع الحاويات مع نسبة التنبؤ")
print(f"2) {predicted_bins_csv.name}             -> فقط الحاويات المختارة (>= 85%)")
print(f"3) {predicted_bins_flutter_json.name}    -> ملف JSON جاهز لربطه مع Flutter (جولة واحدة)")
print(f"4) {predicted_bins_multiround_flutter_json.name} -> جميع الـ 10 حاويات × 4 جولات لـ Flutter")

if route_json_output:
    print(f"5) {optimal_trip_order_csv.name}         -> ترتيب الجولة")
    print(f"6) {optimal_trip_route_json.name}        -> المسار الكامل على الشوارع")