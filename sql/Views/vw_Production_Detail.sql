/*
==============================================================================
Project      : Automatic Production Line Analytics
Object       : vw_ProductionDetail
Type         : SQL View
Author       : Miroslav Grujic
Version      : 1.0

Description: Cleans and aggregates Production Data. Merges Quality, Production Data and Article Base

Output Grain:
Date + Shift + Production Line + Product + Tool
==============================================================================
*/

CREATE OR ALTER VIEW dbo.vw_Production_Detail
AS
WITH ProductionAgg AS (SELECT Year, Month, Week, Date, Shift, Line, ProductName, Tool, SUM(Produced) AS Produced, MAX(OperatorRespID) AS RespID, 
MAX(Operator1ID) AS Op1ID, MAX(Operator2ID) AS Op2ID
FROM      dbo.ProductionDataBU
GROUP BY Year, Month, Week, Date, Shift, Line, ProductName, Tool), 

ScrapAgg AS
(SELECT Year, Month, Week, Date, Shift, Line, ProductName, Tool, SUM(Total) AS Scrap
FROM      dbo.QualityDataBU
GROUP BY Year, Month, Week, Date, Shift, Line, ProductName, Tool)

SELECT COALESCE (p.Year, s.Year) AS Year, COALESCE (p.Month, s.Month) AS Month, COALESCE (p.Week, s.Week) AS Week, COALESCE (p.Date, s.Date) AS Date, 
                      COALESCE (p.Shift, s.Shift) AS Shift, COALESCE (p.Line, s.Line) AS Line, 
                      COALESCE (p.RespID, 0) AS RespID, COALESCE (p.Op1ID, 0) AS Op1ID, COALESCE (p.Op2ID, 0) AS Op2ID, 
                      COALESCE (p.ProductName, s.ProductName) AS ProductName, COALESCE (p.Tool, s.Tool) AS Tool, ISNULL(p.Produced, 0) 
                      AS Produced, ISNULL(s.Scrap, 0) AS Scrap, 
                      CASE WHEN ISNULL(b.ProductsPerTool, 0) > 0 THEN ISNULL(p.Produced, 0) * 1.0 / b.ProductsPertool ELSE 0 END AS ActualCycles, 
                      b.Weight AS PartWeight, b.Weight * ISNULL(p.Produced, 0) 
                      AS TotalWeight, b.Weight * (ISNULL(p.Produced, 0) - ISNULL(s.Scrap, 0)) AS GoodWeight, b.Weight * ISNULL(s.Scrap, 0) AS ScrapWeight, 
                      COALESCE (par.TheoricPerShift, 0) AS TheoricPerShift, COALESCE (par.TheoricPerShiftTotal, 0) 
                      AS TheoricPerShiftTotal, COALESCE (p.Produced - par.TheoricPerShift *
                          (SELECT ProductsPerTool
                           FROM      dbo.ArticleBaseBU AS a
                           WHERE   (p.ProductName = ProductName)), 0) AS PcsLossPerf
    FROM     ProductionAgg AS p 
    FULL OUTER JOIN   ScrapAgg AS s ON p.Date = s.Date AND p.Shift = s.Shift AND p.Line = s.Line AND p.ProductName = s.ProductName AND p.Tool = s.Tool 
    LEFT OUTER JOIN   dbo.ArticleBaseBU AS b ON COALESCE (p.ProductName, s.ProductName) = b.ProductName 
    LEFT OUTER JOIN   dbo.ProductionLineParameterBU AS par ON p.Month = par.Month AND p.Year = par.Year AND p.Line = par.Line


