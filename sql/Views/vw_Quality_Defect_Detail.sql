CREATE OR ALTER VIEW vw_Quality_Defect_Detail AS
WITH DefectData AS
(
    SELECT
    Year,
    Month,
    Week,
    Date,
    Shift,
    Line,
    ProductName,
    Tool,
    Cavity,
    Defect,
    ScrapPCS
FROM
(
    SELECT
        Year,
        Month,
        Week,
        Date,
        Shift,
        Line,
        ProductName,
        Tool,
        Cavity,
        D0, D1, D2, D3, D4, D5,
        D6, D7, D8, D9, D10,
        D11, D12, D13, D14, D15,
        D16, D17, D18, D19, D20,
        D21, D22, D23, D24, D25,
        D26, D27, D28, D29, D30,
        D31, D32, D33, D34, D35,
        D36, D37, D38, D39, D40
    FROM dbo.QualityDataBU
) AS SourceData
UNPIVOT
(
    ScrapPCS FOR Defect IN
    (
        D0, D1, D2, D3, D4, D5,
        D6, D7, D8, D9, D10,
        D11, D12, D13, D14, D15,
        D16, D17, D18, D19, D20,
        D21, D22, D23, D24, D25,
        D26, D27, D28, D29, D30,
        D31, D32, D33, D34, D35,
        D36, D37, D38, D39, D40
    )
) AS UnpivotData
WHERE ScrapPCS > 0
)
SELECT
    Year,
    Month,
    Week,
    Date,
    Shift,
    ProductName,
    Tool,
    Cavity,
    Defect,
    SUM(ScrapPCS) AS ScrapPCS
FROM DefectData
GROUP BY
    Year,
    Month,
    Week,
    Date,
    Shift,
    ProductName,
    Tool,
    Cavity,
    Defect;

