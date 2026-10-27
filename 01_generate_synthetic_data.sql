-- Everyone run this first thing
USE ROLE SYSADMIN;
USE WAREHOUSE HACKATHON_WH;
USE DATABASE AI_CRISIS_LOANS;
USE SCHEMA LOAN_ANALYTICS;

-- ============================================================
-- STEP 1: Generate sequence
-- ============================================================
CREATE OR REPLACE TABLE NUMBER_SEQUENCE AS
SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) AS N
FROM TABLE(GENERATOR(ROWCOUNT => 117000));


-- ============================================================
-- STEP 2: Generate synthetic dataset
-- ============================================================
CREATE OR REPLACE TABLE LOAN_PORTFOLIO_RAW AS
WITH BASE AS (
    SELECT N,
        ABS(MOD(HASH(N * 7   + 1),  10000)) / 10000.0 AS R1,
        ABS(MOD(HASH(N * 13  + 2),  10000)) / 10000.0 AS R2,
        ABS(MOD(HASH(N * 17  + 3),  10000)) / 10000.0 AS R3,
        ABS(MOD(HASH(N * 19  + 4),  10000)) / 10000.0 AS R4,
        ABS(MOD(HASH(N * 23  + 5),  10000)) / 10000.0 AS R5,
        ABS(MOD(HASH(N * 29  + 6),  10000)) / 10000.0 AS R6,
        ABS(MOD(HASH(N * 31  + 7),  10000)) / 10000.0 AS R7,
        ABS(MOD(HASH(N * 37  + 8),  10000)) / 10000.0 AS R8,
        ABS(MOD(HASH(N * 41  + 9),  10000)) / 10000.0 AS R9,
        ABS(MOD(HASH(N * 43  + 10), 10000)) / 10000.0 AS R10,
        ABS(MOD(HASH(N * 47  + 11), 10000)) / 10000.0 AS R11,
        ABS(MOD(HASH(N * 53  + 12), 10000)) / 10000.0 AS R12
    FROM NUMBER_SEQUENCE
),

CATEGORICALS AS (
    SELECT *,

        CASE
            WHEN R1 < 0.2100 THEN 'AI-Augmented Professional'
            WHEN R1 < 0.3850 THEN 'AI-Displaced Worker'
            WHEN R1 < 0.5375 THEN 'Traditional Stable'
            WHEN R1 < 0.6808 THEN 'Gig/Platform Worker'
            WHEN R1 < 0.8133 THEN 'Healthcare/Essential'
            WHEN R1 < 0.9183 THEN 'Entrepreneur/Startup'
            ELSE                   'Creative/Arts'
        END AS BORROWER_SEGMENT,

        CASE
            WHEN R2 < 0.0917 THEN 'Agriculture'
            WHEN R2 < 0.1808 THEN 'Construction'
            WHEN R2 < 0.2692 THEN 'Technology'
            WHEN R2 < 0.3575 THEN 'Manufacturing'
            WHEN R2 < 0.4450 THEN 'Transportation/Logistics'
            WHEN R2 < 0.5317 THEN 'Healthcare'
            WHEN R2 < 0.6150 THEN 'Retail/E-Commerce'
            WHEN R2 < 0.6967 THEN 'Finance/Banking'
            WHEN R2 < 0.7750 THEN 'Creative/Media'
            WHEN R2 < 0.8525 THEN 'Education'
            WHEN R2 < 0.9275 THEN 'Government/Public'
            ELSE                   'Hospitality'
        END AS INDUSTRY,

        CASE
            WHEN R3 < 0.4367 THEN 'Full-Time'
            WHEN R3 < 0.6017 THEN 'Part-Time'
            WHEN R3 < 0.7350 THEN 'Self-Employed'
            WHEN R3 < 0.8150 THEN 'Unemployed'
            WHEN R3 < 0.8858 THEN 'Gig'
            WHEN R3 < 0.9367 THEN 'Freelance'
            WHEN R3 < 0.9750 THEN 'Retraining'
            ELSE                   'Founder'
        END AS EMPLOYMENT_STATUS,

        CASE
            WHEN R4 < 0.3825 THEN 'Bachelor'
            WHEN R4 < 0.6025 THEN 'High School'
            WHEN R4 < 0.8075 THEN 'Master'
            WHEN R4 < 0.9375 THEN 'Vocational'
            ELSE                   'PhD'
        END AS EDUCATION_LEVEL,

        CASE
            WHEN R5 < 0.3642 THEN 'High'
            WHEN R5 < 0.6450 THEN 'Medium'
            WHEN R5 < 0.8592 THEN 'Expert'
            ELSE                   'Low'
        END AS DIGITAL_LITERACY,

        -- Simplified: AI Crisis focus only
        CASE
            WHEN R6 < 0.3500 THEN 'AI_Transition'
            ELSE                  'Other'
        END AS CRISIS_ANALOGUE,

        CASE
            WHEN R7 < 0.3750 THEN 'Low'
            WHEN R7 < 0.7283 THEN 'Medium'
            ELSE                   'High'
        END AS SOCIAL_SUPPORT_SCORE,

        CASE
            WHEN R8 < 0.2083 THEN 'Housing'
            WHEN R8 < 0.3975 THEN 'Debt Consolidation'
            WHEN R8 < 0.5350 THEN 'Living Expenses'
            WHEN R8 < 0.6517 THEN 'Reskilling/Education'
            WHEN R8 < 0.7533 THEN 'Business Start-Up'
            WHEN R8 < 0.8408 THEN 'Medical'
            WHEN R8 < 0.9242 THEN 'Personal'
            ELSE                   'Equipment/Tech'
        END AS LOAN_PURPOSE,

        CASE WHEN R9  < 0.3675 THEN 'Yes' ELSE 'No' END AS HAS_COLLATERAL,
        CASE WHEN R10 < 0.2525 THEN 'Yes' ELSE 'No' END AS HAS_AI_CERTIFICATION

    FROM BASE
),

NUMERICS AS (
    SELECT *,

        GREATEST(22, LEAST(67, ROUND(44.28 + 13.31 * (R1 + R2 + R3 + R4 + R5 + R6 - 3.0) / 1.732, 0)))
            AS AGE,

        GREATEST(927, ROUND(
            CASE BORROWER_SEGMENT
                WHEN 'AI-Augmented Professional' THEN 121052 + 34418 * (R3 + R4 + R5 - 1.5) / 0.866
                WHEN 'AI-Displaced Worker'        THEN  26947 + 10220 * (R3 + R4 + R5 - 1.5) / 0.866
                WHEN 'Traditional Stable'         THEN  65613 + 17024 * (R3 + R4 + R5 - 1.5) / 0.866
                WHEN 'Gig/Platform Worker'        THEN  42389 + 13498 * (R3 + R4 + R5 - 1.5) / 0.866
                WHEN 'Healthcare/Essential'       THEN  76383 + 20188 * (R3 + R4 + R5 - 1.5) / 0.866
                WHEN 'Entrepreneur/Startup'       THEN 102328 + 59210 * (R3 + R4 + R5 - 1.5) / 0.866
                WHEN 'Creative/Arts'              THEN  34542 + 12600 * (R3 + R4 + R5 - 1.5) / 0.866
                ELSE 69904
            END
        , 0)) AS ANNUAL_INCOME_USD,

        GREATEST(306, LEAST(850, ROUND(637 + 103 * (R6 + R7 + R8 - 1.5) / 0.866, 0)))
            AS CREDIT_SCORE,

        GREATEST(2064, LEAST(149921, ROUND(74818 + 42557 * (R4 + R5 + R6 - 1.5) / 0.866, 0)))
            AS LOAN_AMOUNT_USD,

        CASE
            WHEN R7 < 0.20 THEN 12
            WHEN R7 < 0.38 THEN 24
            WHEN R7 < 0.56 THEN 36
            WHEN R7 < 0.68 THEN 48
            WHEN R7 < 0.80 THEN 60
            WHEN R7 < 0.91 THEN 84
            ELSE 120
        END AS LOAN_TERM_MONTHS,

        GREATEST(3.0, LEAST(19.13, ROUND(8.69 + 3.26 * (R8 + R9 + R10 - 1.5) / 0.866, 2)))
            AS INTEREST_RATE_PCT,

        GREATEST(0.01, LEAST(1.07, ROUND(0.39 + 0.21 * (R5 + R6 + R7 - 1.5) / 0.866, 3)))
            AS DEBT_TO_INCOME_RATIO,

        ROUND(GREATEST(0.06, LEAST(0.95, 0.46 + 0.25 * (R1 + R2 - 1.0))), 3) AS INCOME_VOLATILITY_SCORE,
        ROUND(GREATEST(0.15, LEAST(1.00, 0.60 + 0.19 * (R2 + R3 - 1.0))), 3) AS AI_DISRUPTION_INDEX,
        ROUND(GREATEST(0.16, LEAST(1.00, 0.59 + 0.21 * (R3 + R4 - 1.0))), 3) AS JOB_AUTOMATION_RISK,
        ROUND(GREATEST(0.00, LEAST(1.00, 0.49 + 0.24 * (R4 + R5 - 1.0))), 3) AS AI_TOOL_USAGE_SCORE,
        ROUND(GREATEST(0.00, LEAST(0.85, 0.34 + 0.15 * (R5 + R6 - 1.0))), 3) AS FINANCIAL_STRESS_INDEX,
        ROUND(GREATEST(0.10, LEAST(1.00, 0.56 + 0.26 * (R6 + R7 - 1.0))), 3) AS REGIONAL_AI_ADOPTION,

        GREATEST(20, LEAST(14993, ROUND(7394 + 4340 * (R7 + R8 - 1.0), 0)))
            AS RESKILLING_INVESTMENT_USD,

        ROUND(GREATEST(-200000, LEAST(1498354, 201282 + 274117 * (R8 + R9 - 1.0))), 0)
            AS NET_WORTH_USD,

        GREATEST(0, LEAST(27, FLOOR(3.64  + 4.07  * R9)))  AS YEARS_IN_CURRENT_ROLE,
        GREATEST(0, LEAST(35, FLOOR(5.87  + 7.62  * R10))) AS MONTHS_UNEMPLOYED_LAST3YR,
        GREATEST(0, LEAST(27, FLOOR(3.05  + 3.67  * R11))) AS SAVINGS_MONTHS_RUNWAY,
        GREATEST(0, LEAST(4,  FLOOR(1.26  + 1.20  * R12))) AS EXISTING_LOAN_COUNT,
        GREATEST(0, LEAST(4,  FLOOR(0.70  + 1.06  * R1)))  AS NUM_PAST_DEFAULTS,
        GREATEST(0, LEAST(5,  FLOOR(1.01  + 1.32  * R2)))  AS MISSED_PAYMENTS_12MO,

        -- Loan date: randomly spread over past 5 years
        DATEADD(DAY, -FLOOR(ABS(MOD(HASH(N * 97 + 13), 1825))), CURRENT_DATE()) AS LOAN_DATE

    FROM CATEGORICALS
),

WITH_DEFAULT AS (
    SELECT *,
        LEAST(0.99, GREATEST(0.01, ROUND(
            0.30
            + CASE BORROWER_SEGMENT
                WHEN 'AI-Displaced Worker'       THEN  0.30
                WHEN 'Gig/Platform Worker'       THEN  0.12
                WHEN 'Healthcare/Essential'      THEN -0.02
                WHEN 'Entrepreneur/Startup'      THEN  0.05
                WHEN 'Creative/Arts'             THEN -0.07
                WHEN 'AI-Augmented Professional' THEN -0.12
                WHEN 'Traditional Stable'        THEN -0.15
                ELSE 0
              END
            + CASE INDUSTRY
                WHEN 'Manufacturing'            THEN  0.12
                WHEN 'Transportation/Logistics' THEN  0.09
                WHEN 'Retail/E-Commerce'        THEN  0.08
                WHEN 'Hospitality'              THEN  0.05
                WHEN 'Finance/Banking'          THEN  0.04
                WHEN 'Creative/Media'           THEN  0.02
                WHEN 'Technology'               THEN -0.04
                WHEN 'Healthcare'               THEN -0.07
                WHEN 'Government/Public'        THEN -0.12
                ELSE 0
              END
            + (INCOME_VOLATILITY_SCORE * 0.10)
            + (JOB_AUTOMATION_RISK     * 0.08)
            + (FINANCIAL_STRESS_INDEX  * 0.07)
            + (DEBT_TO_INCOME_RATIO    * 0.07)
            + (NUM_PAST_DEFAULTS       * 0.04)
            + (MISSED_PAYMENTS_12MO    * 0.02)
            - (AI_TOOL_USAGE_SCORE     * 0.06)
            - ((CREDIT_SCORE - 306.0) / 544.0 * 0.15)
            + (R11 - 0.5) * 0.10
        , 4))) AS DEFAULT_PROBABILITY_24MO
    FROM NUMERICS
)

SELECT
    'BRW' || LPAD(N::VARCHAR, 8, '0')          AS BORROWER_ID,
    BORROWER_SEGMENT,
    AGE,
    EDUCATION_LEVEL,
    DIGITAL_LITERACY,
    INDUSTRY,
    EMPLOYMENT_STATUS,
    YEARS_IN_CURRENT_ROLE,
    MONTHS_UNEMPLOYED_LAST3YR,
    ANNUAL_INCOME_USD,
    INCOME_VOLATILITY_SCORE,
    NET_WORTH_USD,
    SAVINGS_MONTHS_RUNWAY,
    AI_DISRUPTION_INDEX,
    JOB_AUTOMATION_RISK,
    AI_TOOL_USAGE_SCORE,
    RESKILLING_INVESTMENT_USD,
    HAS_AI_CERTIFICATION,
    REGIONAL_AI_ADOPTION,
    CRISIS_ANALOGUE,
    SOCIAL_SUPPORT_SCORE,
    FINANCIAL_STRESS_INDEX,
    LOAN_PURPOSE,
    LOAN_AMOUNT_USD,
    LOAN_TERM_MONTHS,
    INTEREST_RATE_PCT,
    CREDIT_SCORE,
    DEBT_TO_INCOME_RATIO,
    EXISTING_LOAN_COUNT,
    NUM_PAST_DEFAULTS,
    MISSED_PAYMENTS_12MO,
    HAS_COLLATERAL,
    LOAN_DATE,
    DATEDIFF(DAY, LOAN_DATE, CURRENT_DATE())    AS DAYS_SINCE_LOAN,
    CASE WHEN DEFAULT_PROBABILITY_24MO >= 0.62 THEN 1 ELSE 0 END AS IS_DEFAULTED
FROM WITH_DEFAULT;


-- ============================================================
-- STEP 3: Validate
-- ============================================================

-- Should be ~70% 0 and ~30% 1
SELECT
    IS_DEFAULTED,
    COUNT(*) AS COUNT,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS PCT
FROM LOAN_PORTFOLIO_RAW
GROUP BY 1 ORDER BY 1;

-- Segment default rates
SELECT
    BORROWER_SEGMENT,
    COUNT(*)                                          AS BORROWERS,
    ROUND(AVG(IS_DEFAULTED) * 100, 1)                AS DEFAULT_RATE_PCT,
    ROUND(AVG(ANNUAL_INCOME_USD), 0)                  AS AVG_INCOME_USD,
    ROUND(AVG(CREDIT_SCORE), 0)                       AS AVG_CREDIT_SCORE
FROM LOAN_PORTFOLIO_RAW
GROUP BY 1
ORDER BY DEFAULT_RATE_PCT DESC;

-- Numeric means
SELECT
    ROUND(AVG(AGE), 1)                        AS AVG_AGE,
    ROUND(AVG(ANNUAL_INCOME_USD), 0)          AS AVG_INCOME,
    ROUND(AVG(CREDIT_SCORE), 0)               AS AVG_CREDIT,
    ROUND(AVG(LOAN_AMOUNT_USD), 0)            AS AVG_LOAN,
    ROUND(AVG(AI_DISRUPTION_INDEX), 2)        AS AVG_AI_DISRUPTION,
    ROUND(AVG(DEBT_TO_INCOME_RATIO), 2)       AS AVG_DTI,
    ROUND(AVG(INTEREST_RATE_PCT), 2)          AS AVG_RATE,
    ROUND(AVG(FINANCIAL_STRESS_INDEX), 2)     AS AVG_STRESS
FROM LOAN_PORTFOLIO_RAW;


-- ============================================================
-- Setup (run once)
-- ============================================================
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS HACKATHON_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 120
  AUTO_RESUME = TRUE;

CREATE DATABASE IF NOT EXISTS AI_CRISIS_LOANS;
CREATE SCHEMA IF NOT EXISTS AI_CRISIS_LOANS.LOAN_ANALYTICS;
USE SCHEMA AI_CRISIS_LOANS.LOAN_ANALYTICS;

CREATE STAGE IF NOT EXISTS LOAN_STAGE
  FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

SELECT * FROM AI_CRISIS_LOANS.LOAN_ANALYTICS.LOAN_PORTFOLIO_RAW;


-- ============================================================
-- LOAN_FEATURES_V view
-- ============================================================
CREATE OR REPLACE VIEW LOAN_FEATURES_V AS
SELECT
    BORROWER_ID,
    AGE,
    ANNUAL_INCOME_USD,
    INCOME_VOLATILITY_SCORE,
    NET_WORTH_USD,
    SAVINGS_MONTHS_RUNWAY,
    AI_DISRUPTION_INDEX,
    JOB_AUTOMATION_RISK,
    AI_TOOL_USAGE_SCORE,
    RESKILLING_INVESTMENT_USD,
    REGIONAL_AI_ADOPTION,
    FINANCIAL_STRESS_INDEX,
    LOAN_AMOUNT_USD,
    LOAN_TERM_MONTHS,
    INTEREST_RATE_PCT,
    CREDIT_SCORE,
    DEBT_TO_INCOME_RATIO,
    EXISTING_LOAN_COUNT,
    NUM_PAST_DEFAULTS,
    MISSED_PAYMENTS_12MO,
    YEARS_IN_CURRENT_ROLE,
    MONTHS_UNEMPLOYED_LAST3YR,
    CASE WHEN HAS_AI_CERTIFICATION = 'Yes' THEN 1 ELSE 0 END AS HAS_AI_CERT_FLAG,
    CASE WHEN HAS_COLLATERAL        = 'Yes' THEN 1 ELSE 0 END AS HAS_COLLATERAL_FLAG,
    CASE DIGITAL_LITERACY
        WHEN 'Low'    THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High'   THEN 3
        WHEN 'Expert' THEN 4
        ELSE 0
    END AS DIGITAL_LITERACY_SCORE,
    CASE EDUCATION_LEVEL
        WHEN 'High School' THEN 1
        WHEN 'Vocational'  THEN 2
        WHEN 'Bachelor'    THEN 3
        WHEN 'Master'      THEN 4
        WHEN 'PhD'         THEN 5
        ELSE 0
    END AS EDUCATION_SCORE,
    CASE WHEN BORROWER_SEGMENT = 'AI-Displaced Worker'        THEN 1 ELSE 0 END AS SEG_AI_DISPLACED,
    CASE WHEN BORROWER_SEGMENT = 'Gig/Platform Worker'        THEN 1 ELSE 0 END AS SEG_GIG,
    CASE WHEN BORROWER_SEGMENT = 'Healthcare/Essential'        THEN 1 ELSE 0 END AS SEG_HEALTHCARE,
    CASE WHEN BORROWER_SEGMENT = 'AI-Augmented Professional'  THEN 1 ELSE 0 END AS SEG_AI_AUGMENTED,
    CASE WHEN BORROWER_SEGMENT = 'Traditional Stable'          THEN 1 ELSE 0 END AS SEG_TRADITIONAL,
    CASE WHEN BORROWER_SEGMENT = 'Creative/Arts'               THEN 1 ELSE 0 END AS SEG_CREATIVE,
    CASE WHEN BORROWER_SEGMENT = 'Entrepreneur/Startup'        THEN 1 ELSE 0 END AS SEG_ENTREPRENEUR,
    CASE WHEN INDUSTRY = 'Manufacturing'            THEN 1 ELSE 0 END AS IND_MANUFACTURING,
    CASE WHEN INDUSTRY = 'Transportation/Logistics' THEN 1 ELSE 0 END AS IND_TRANSPORT,
    CASE WHEN INDUSTRY = 'Retail/E-Commerce'        THEN 1 ELSE 0 END AS IND_RETAIL,
    CASE WHEN INDUSTRY = 'Technology'               THEN 1 ELSE 0 END AS IND_TECHNOLOGY,
    CASE WHEN INDUSTRY = 'Healthcare'               THEN 1 ELSE 0 END AS IND_HEALTHCARE,
    CASE WHEN INDUSTRY = 'Government/Public'        THEN 1 ELSE 0 END AS IND_GOVERNMENT,
    -- AI Crisis only ✓
    CASE WHEN CRISIS_ANALOGUE = 'AI_Transition'     THEN 1 ELSE 0 END AS CRISIS_AI,
    (AI_DISRUPTION_INDEX * JOB_AUTOMATION_RISK)                 AS AI_RISK_COMPOSITE,
    (FINANCIAL_STRESS_INDEX / NULLIF(SAVINGS_MONTHS_RUNWAY, 0)) AS STRESS_TO_RUNWAY_RATIO,
    (MISSED_PAYMENTS_12MO + NUM_PAST_DEFAULTS * 2)               AS CREDIT_STRAIN_INDEX,
    (AI_TOOL_USAGE_SCORE + RESKILLING_INVESTMENT_USD / 10000)    AS ADAPTABILITY_SCORE,
    LOAN_AMOUNT_USD / NULLIF(ANNUAL_INCOME_USD, 0)               AS LOAN_TO_INCOME_RATIO,
    LOAN_DATE,
    DAYS_SINCE_LOAN,
    IS_DEFAULTED AS TARGET
FROM LOAN_PORTFOLIO_RAW
WHERE ANNUAL_INCOME_USD > 0;

SELECT * FROM AI_CRISIS_LOANS.LOAN_ANALYTICS.LOAN_PORTFOLIO_RAW;