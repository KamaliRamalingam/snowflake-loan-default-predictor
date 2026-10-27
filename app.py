import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session
from snowflake.ml.registry import Registry

# ================================
# PAGE CONFIG
# ================================
st.set_page_config(page_title="AI Loan Risk Predictor", layout="centered")

st.title("🏦 AI Loan Default Risk Predictor")

# ================================
# LOAD MODEL (FROM SNOWFLAKE)
# ================================
session = get_active_session()
reg = Registry(session=session)

model = reg.get_model("AI_CRISIS_DEFAULT_MODEL_PIPELINE").version("SHY_SNAKE_4")

# ================================
# INPUT FORM
# ================================
st.header("Enter Borrower Details")

age = st.slider("Age", 18, 70, 30)
income = st.number_input("Annual Income (USD)", 1000, 200000, 50000)
volatility = st.slider("Income Volatility (0-1)", 0.0, 1.0, 0.3)
net_worth = st.number_input("Net Worth (USD)", 0, 500000, 20000)
years_role = st.slider("Years in Current Role", 0, 40, 5)
unemployed = st.slider("Months Unemployed (last 3 yrs)", 0, 36, 2)

ai_cert = st.selectbox("AI Certification", ["No", "Yes"])
collateral = st.selectbox("Has Collateral", ["No", "Yes"])

digital = st.slider("Digital Literacy Score", 1, 4, 2)
education = st.slider("Education Level Score", 1, 5, 3)
social = st.slider("Social Support Score", 1, 3, 2)

# Convert categorical
ai_cert_flag = 1 if ai_cert == "Yes" else 0
collateral_flag = 1 if collateral == "Yes" else 0

# ================================
# PREDICT BUTTON
# ================================
if st.button("🔍 Predict Risk"):

    input_df = pd.DataFrame([{
        "AGE": age,
        "ANNUAL_INCOME_USD": income,
        "INCOME_VOLATILITY_SCORE": volatility,
        "NET_WORTH_USD": net_worth,
        "YEARS_IN_CURRENT_ROLE": years_role,
        "MONTHS_UNEMPLOYED_LAST3YR": unemployed,
        "HAS_AI_CERT_FLAG": ai_cert_flag,
        "HAS_COLLATERAL_FLAG": collateral_flag,
        "DIGITAL_LITERACY_SCORE": digital,
        "EDUCATION_SCORE": education,
        "SOCIAL_SUPPORT_SCORE_NUM": social
    }])

    # Run model
    pred = model.run(
        session.create_dataframe(input_df),
        function_name="predict_proba"
    )

    pred_pd = pred.to_pandas()
    pred_pd.columns = [c.strip('"') for c in pred_pd.columns]

    probability = pred_pd.iloc[0, 1]

    # Threshold
    threshold = 0.3
    prediction = 1 if probability > threshold else 0

    # Risk bucket
    if probability > 0.7:
        risk = "🔴 HIGH"
    elif probability > 0.3:
        risk = "🟡 MEDIUM"
    else:
        risk = "🟢 LOW"

    # ================================
    # OUTPUT
    # ================================
    st.subheader("📊 Prediction Result")

    st.metric("Default Probability", f"{probability:.2%}")
    st.metric("Prediction", "Default" if prediction == 1 else "No Default")
    st.metric("Risk Level", risk)

    if prediction == 1:
        st.error("⚠️ High Risk Borrower")
    else:
        st.success("✅ Safe Borrower")