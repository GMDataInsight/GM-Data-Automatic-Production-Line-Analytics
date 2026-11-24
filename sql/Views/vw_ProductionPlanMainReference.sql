CREATE OR ALTER VIEW dbo.vw_ProductionPlanMainReference
AS

WITH PlanData AS
(
    SELECT
        P.[Year],
        P.[Week],
        P.[Line],
        P.[ProductName],

        V.DOW,
        V.Shift,

        V.PlanPositions,
        V.PlanQuantity

    FROM dbo.ProductionPlanBU P

    CROSS APPLY
    (
        VALUES

        -- Monday
        ('MON', 'I',   TRY_CAST(P.MON1 AS INT), TRY_CAST(P.PLANPON1 AS INT)),
        ('MON', 'II',  TRY_CAST(P.MON2 AS INT), TRY_CAST(P.PLANPON2 AS INT)),
        ('MON', 'III', TRY_CAST(P.MON3 AS INT), TRY_CAST(P.PLANPON3 AS INT)),

        -- Tuesday
        ('TUE', 'I',   TRY_CAST(P.TUE1 AS INT), TRY_CAST(P.PLANUTO1 AS INT)),
        ('TUE', 'II',  TRY_CAST(P.TUE2 AS INT), TRY_CAST(P.PLANUTO2 AS INT)),
        ('TUE', 'III', TRY_CAST(P.TUE3 AS INT), TRY_CAST(P.PLANUTO3 AS INT)),

        -- Wednesday
        ('WED', 'I',   TRY_CAST(P.WED1 AS INT), TRY_CAST(P.PLANSRE1 AS INT)),
        ('WED', 'II',  TRY_CAST(P.WED2 AS INT), TRY_CAST(P.PLANSRE2 AS INT)),
        ('WED', 'III', TRY_CAST(P.WED3 AS INT), TRY_CAST(P.PLANSRE3 AS INT)),

        -- Thursday
        ('THU', 'I',   TRY_CAST(P.THU1 AS INT), TRY_CAST(P.PLANCET1 AS INT)),
        ('THU', 'II',  TRY_CAST(P.THU2 AS INT), TRY_CAST(P.PLANCET2 AS INT)),
        ('THU', 'III', TRY_CAST(P.THU3 AS INT), TRY_CAST(P.PLANCET3 AS INT)),

        -- Friday
        ('FRI', 'I',   TRY_CAST(P.FRI1 AS INT), TRY_CAST(P.PLANPET1 AS INT)),
        ('FRI', 'II',  TRY_CAST(P.FRI2 AS INT), TRY_CAST(P.PLANPET2 AS INT)),
        ('FRI', 'III', TRY_CAST(P.FRI3 AS INT), TRY_CAST(P.PLANPET3 AS INT)),

        -- Saturday
        ('SAT', 'I',   TRY_CAST(P.SAT1 AS INT), TRY_CAST(P.PLANSUB1 AS INT)),
        ('SAT', 'II',  TRY_CAST(P.SAT2 AS INT), TRY_CAST(P.PLANSUB2 AS INT)),
        ('SAT', 'III', TRY_CAST(P.SAT3 AS INT), TRY_CAST(P.PLANSUB3 AS INT))

    ) V(DOW, Shift, PlanPositions, PlanQuantity)
),

ISOWeekStart AS
(
    SELECT
        *,
        DATEADD
        (
            DAY,
            -((DATEPART(WEEKDAY, DATEFROMPARTS([Year], 1, 4)) + 5) % 7),
            DATEFROMPARTS([Year], 1, 4)
        ) AS FirstMonday
    FROM PlanData
),

PlanWithDate AS
(
    SELECT
        [Year],
        [Week],
        [Line],
        [ProductName],
        DOW,
        Shift,
        PlanPositions,
        PlanQuantity,

        DATEADD
        (
            DAY,
            ([Week] - 1) * 7
            +
            CASE DOW
                WHEN 'MON' THEN 0
                WHEN 'TUE' THEN 1
                WHEN 'WED' THEN 2
                WHEN 'THU' THEN 3
                WHEN 'FRI' THEN 4
                WHEN 'SAT' THEN 5
            END,
            FirstMonday
        ) AS PlanDate

    FROM ISOWeekStart
)

SELECT

    [Year],

    MONTH(PlanDate) AS [Month],

    [Week],

    PlanDate AS [Date],

    [Line],

    [ProductName],

    DOW,

    Shift,

    PlanPositions,

    PlanQuantity

FROM PlanWithDate;
