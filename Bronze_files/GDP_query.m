// GDP_query
let
    base_url = "https://api.worldbank.org",
    relative_path = "v2/country/USA/indicator/NY.GDP.MKTP.CD",
    query_params = [format = "json", per_page = "100"],
    response = Web.Contents(base_url, [RelativePath = relative_path, Query = query_params]),
    json = Json.Document(response),
    dataArray = json{1},
    toTable = Table.FromList(dataArray, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    expandRecord = Table.ExpandRecordColumn(toTable, "Column1", {"country", "date", "value"}, {"country_record", "year", "gdp_usd"}),
    expandCountry = Table.ExpandRecordColumn(expandRecord, "country_record", {"value"}, {"country_name"}),
    filterNulls = Table.SelectRows(expandCountry, each [gdp_usd] <> null),
    changedType = Table.TransformColumnTypes(filterNulls, {{"country_name", type text}, {"year", Int64.Type}, {"gdp_usd", Int64.Type}})
in
    changedType