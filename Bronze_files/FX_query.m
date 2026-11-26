// FX_query
let
    base_url = "https://data-api.ecb.europa.eu",
    relative_path = "service/data/EXR/D.USD.EUR.SP00.A",
    query_params = [format = "csvdata"],
    response = Web.Contents(base_url,[RelativePath = relative_path, Query = query_params]),
    csvTable = Csv.Document(response, [Delimiter=",", Columns=12, Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    promoted = Table.PromoteHeaders(csvTable, [PromoteAllScalars=true]),
    selected = Table.SelectColumns(promoted, {"TIME_PERIOD", "OBS_VALUE"}),
    renamed = Table.RenameColumns(selected, {{"TIME_PERIOD", "date_string"}, {"OBS_VALUE", "eur_to_usd"}}),
    changedType = Table.TransformColumnTypes(renamed, {{"date_string", type date}, {"eur_to_usd", type number}})
in
    changedType