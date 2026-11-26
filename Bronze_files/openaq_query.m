// openaq_query
let
    api_key = "286a083bfeaa68b3964f38b5f144a1554b7e6271af010f4724609adecd4ede08",
    base_url = "https://api.openaq.org",
    lat = "40.7128",
    lon = "-74.0060",
    year = 2025,
    page_size = 1000,
    headers = [#"X-API-Key" = api_key],
    Delay = (seconds as number) => Function.InvokeAfter(() => null, #duration(0, 0, 0, seconds)),
    FetchPage = (endpoint as text, params as record, page_num as number) as list =>
        let
            q = Record.Combine({params, [page = Number.ToText(page_num), limit = Number.ToText(page_size)]}),
            response = Web.Contents(base_url, [RelativePath = endpoint, Query = q, Headers = headers]),
            json = Json.Document(response),
            results = if Record.HasFields(json, "results") then json[results] else {}
        in
            results,
    FetchAllPages = (endpoint as text, params as record) as list =>
        let
            pages = List.Generate(
                () => [Page = 1, Data = FetchPage(endpoint, params, 1)],
                each List.Count([Data]) > 0,
                each [Page = [Page] + 1, Data = Delay(1) & FetchPage(endpoint, params, [Page] + 1)],
                each [Data]),
            combined = List.Combine(pages)
        in
            combined,
    loc_list = FetchAllPages("v3/locations", [coordinates = lat & "," & lon, radius = "25000"]),
    loc_table = Table.FromList(loc_list, Splitter.SplitByNothing(), {"Location"}, null, ExtraValues.Error),
    exp_loc = Table.ExpandRecordColumn(loc_table, "Location", {"id", "coordinates", "sensors"}, {"location_id", "coordinates", "sensors"}),
    exp_coord = Table.ExpandRecordColumn(exp_loc, "coordinates", {"latitude", "longitude"}, {"latitude", "longitude"}),
    exp_sensor = Table.ExpandListColumn(exp_coord, "sensors"),
    exp_sensor_rec = Table.ExpandRecordColumn(exp_sensor, "sensors", {"id", "parameter"}, {"sensor_id", "parameter"}),
    exp_param = Table.ExpandRecordColumn(exp_sensor_rec, "parameter", {"name"}, {"parameter_name"}),
    target_sensors = Table.SelectRows(exp_param, each [parameter_name] = "pm25" or [parameter_name] = "no2"),
    sensor_records = Table.ToRecords(target_sensors),
    FetchSensorData = (sensor_record as record) as list =>
        let
            sid = sensor_record[sensor_id],
            sparam = sensor_record[parameter_name],
            s_loc_id = sensor_record[location_id],
            s_lat = sensor_record[latitude],
            s_lon = sensor_record[longitude],
            monthly_data = List.Transform({1..12}, (m) =>
                let
                    start_date = #datetime(year, m, 1, 0, 0, 0),
                    end_date = if m = 12 then #datetime(year + 1, 1, 1, 0, 0, 0) else #datetime(year, m + 1, 1, 0, 0, 0),
                    d_from = DateTime.ToText(start_date, "yyyy-MM-ddTHH:mm:ssZ"),
                    d_to = DateTime.ToText(end_date, "yyyy-MM-ddTHH:mm:ssZ"),
                    meas = FetchAllPages("v3/sensors/" & Number.ToText(sid) & "/measurements", [datetime_from = d_from, datetime_to = d_to]),
                    enriched = List.Transform(meas, (x) => Record.Combine({x, [
                        sensor_id = sid,
                        parameter = sparam,
                        location_id = s_loc_id,
                        latitude = s_lat,
                        longitude = s_lon
                        ]})
                    ),
                    _ = Delay(1.5)
                in
                    enriched),
            flattened = List.Combine(monthly_data)
        in
            flattened,
    all_measurements = List.Combine(List.Transform(sensor_records, each FetchSensorData(_))),
    meas_table = Table.FromList(all_measurements, Splitter.SplitByNothing(), {"Measurement"}, null, ExtraValues.Error),
    exp_meas = Table.ExpandRecordColumn(meas_table, "Measurement", 
        {"sensor_id", "parameter", "location_id", "latitude", "longitude", "period", "value"}, 
        {"sensor_id", "parameter", "location_id", "latitude", "longitude", "period", "value"}),
    exp_period = Table.ExpandRecordColumn(exp_meas, "period", {"datetimeFrom"}, {"datetime_from"}),
    exp_dt = Table.ExpandRecordColumn(exp_period, "datetime_from", {"utc"}, {"datetime_utc"}),
    converted = Table.TransformColumnTypes(exp_dt, {
        {"datetime_utc", type text}, {"value", type number},
        {"latitude", type number}, {"longitude", type number},
        {"sensor_id", Int64.Type}, {"location_id", Int64.Type} }),
    final = Table.SelectColumns(converted, {"sensor_id", "parameter", "location_id", "latitude", "longitude", "datetime_utc", "value"})
in
    final