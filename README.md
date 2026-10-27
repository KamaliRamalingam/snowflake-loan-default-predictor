# AI Loan Default Risk Predictor

End-to-end machine learning pipeline built inside Snowflake that predicts loan default risk for borrowers, from synthetic data generation to a Streamlit app that scores new applicants.

**AI Hackathon Stockholm with Snowflake · April 2026 · Team of three**

## The idea

Lenders assess risk with traditional signals like income and net worth. This project adds signals that matter in a labour market reshaped by AI, such as recent unemployment, AI certifications and digital literacy, and asks: **can these help predict which borrowers will default?**

## Pipeline

| Step | File | What it does |
|---|---|---|
| **1. Generate data** | [`01_generate_synthetic_data.sql`](01_generate_synthetic_data.sql) | Creates a synthetic portfolio of 117,000 loans in Snowflake SQL, with a validation step |
| **2. Engineer features** | [`02_feature_engineering.sql`](02_feature_engineering.sql) | Builds a clean feature view and table for modelling |
| **3. Train the model** | [`03_ml_training_pipeline.ipynb`](03_ml_training_pipeline.ipynb) | Trains Random Forest and XGBoost classifiers (80/20 split), compares accuracy and ROC AUC, ranks feature importance, and registers the model in the **Snowflake Model Registry** |
| **4. Score the portfolio** | [`04_prediction_pipeline.ipynb`](04_prediction_pipeline.ipynb) | Loads the registered model, evaluates it with a classification report and confusion matrix, and writes predictions to a table |
| **5. Score new applicants** | [`app.py`](app.py) | A Streamlit app in Snowflake, built with Snowflake Cortex AI: enter borrower details and get a default probability and a risk band (low, medium or high) |

## Design choices

- **Everything runs inside Snowflake:** data, features, training, the model registry and the app, so no data leaves the platform
- **Tuned decision threshold (0.3):** lowered from the default 0.5 to catch more potential defaults, since missing a default costs a lender more than a false alarm
- **Same threshold in evaluation, batch scoring and the app,** so results stay consistent

## Features used

Annual income, net worth, income volatility, years in current role, months unemployed in the last three years, AI certification, collateral, digital literacy, education and social support.

## Data

All data is **synthetic**, generated with SQL in step 1. No real borrower data was used.

## Run it

The files are designed for a Snowflake account (warehouse `HACKATHON_WH`, database `AI_CRISIS_LOANS`, schema `LOAN_ANALYTICS`). Run the SQL files in order, then the two notebooks in Snowflake Notebooks, then deploy `app.py` as a Streamlit in Snowflake app.

## Built with

Snowflake · SQL · Snowpark · Snowflake ML Model Registry · Snowflake Cortex AI · Python · scikit-learn · XGBoost · Streamlit
