-- ================================
-- SET CONTEXT
-- ================================
USE ROLE SYSADMIN;
USE WAREHOUSE HACKATHON_WH;
USE DATABASE AI_CRISIS_LOANS;
USE SCHEMA LOAN_ANALYTICS;

-- ================================
-- CREATE CLEAN FEATURE VIEW (NO LEAKAGE)
-- ================================
CREATE OR REPLACE VIEW LOAN_FEATURES_V_CLEAN AS
SELECT
    BORROWER_ID,

    -- ================================
    -- SAFE NUMERIC FEATURES (PRE-EVENT)
    -- ================================
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

    LOAN_AMOUNT_USD,
    LOAN_TERM_MONTHS,
    INTEREST_RATE_PCT,
    CREDIT_SCORE,
    DEBT_TO_INCOME_RATIO,
    EXISTING_LOAN_COUNT,

    YEARS_IN_CURRENT_ROLE,
    MONTHS_UNEMPLOYED_LAST3YR,

    -- ================================
    -- BINARY FEATURES
    -- ================================
    CASE WHEN HAS_AI_CERTIFICATION = 'Yes' THEN 1 ELSE 0 END AS HAS_AI_CERT_FLAG,
    CASE WHEN HAS_COLLATERAL        = 'Yes' THEN 1 ELSE 0 END AS HAS_COLLATERAL_FLAG,

    -- ================================
    -- ORDINAL FEATURES
    -- ================================
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

    CASE SOCIAL_SUPPORT_SCORE
        WHEN 'Low'    THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'High'   THEN 3
        ELSE 0
    END AS SOCIAL_SUPPORT_SCORE_NUM,

    -- ================================
    -- TARGET (ONLY THIS IS ALLOWED)
    -- ================================
    WILL_DEFAULT_24MO AS TARGET

FROM LOAN_PORTFOLIO_RAW
WHERE ANNUAL_INCOME_USD > 0
  AND LOAN_AMOUNT_USD   > 0;

-- ================================
-- VALIDATION CHECKS
-- ================================

-- Row count
SELECT COUNT(*) AS TOTAL_ROWS FROM LOAN_FEATURES_V_CLEAN;

-- Target distribution
SELECT
    TARGET,
    COUNT(*) AS COUNT,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS PCT
FROM LOAN_FEATURES_V_CLEAN
GROUP BY TARGET;

-- Null check
SELECT
    SUM(CASE WHEN ANNUAL_INCOME_USD IS NULL THEN 1 ELSE 0 END) AS NULL_INCOME,
    SUM(CASE WHEN CREDIT_SCORE IS NULL THEN 1 ELSE 0 END) AS NULL_CREDIT,
    SUM(CASE WHEN TARGET IS NULL THEN 1 ELSE 0 END) AS NULL_TARGET
FROM LOAN_FEATURES_V_CLEAN;

-- ================================
-- MATERIALIZE TABLE (FOR ML)
-- ================================
CREATE OR REPLACE TABLE LOAN_FEATURES_TABLE_CLEAN AS
SELECT * FROM LOAN_FEATURES_V_CLEAN;

-- Optional clustering
ALTER TABLE LOAN_FEATURES_TABLE_CLEAN
CLUSTER BY (TARGET);

-- Final count
SELECT COUNT(*) FROM LOAN_FEATURES_TABLE_CLEAN;