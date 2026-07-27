# Revenue at Risk: Quantifying the Cost of Delivery Delay on Olist

**A data analytics case study on the Olist Brazilian E-Commerce dataset — SQL · Python · Power BI**

> How much revenue is Olist exposing itself to because of delivery failures, and where is that exposure concentrated?

Most public analyses of the Olist dataset treat revenue, logistics, and customer satisfaction as three separate, descriptive pillars. This project instead links them into a single causal chain — delay affects satisfaction, dissatisfaction affects repeat purchases, and that effect can be scaled into an estimated dollar exposure, localized down to specific sellers and regions.

---

## Dashboard

![Dashboard preview](dashboard/olist-dashboard.pdf)

*(Power BI dashboard — pages covering revenue overview, delay & satisfaction, repeat purchase impact, exposure quantification, and seller/regional localization.)*

---

## The Question, Broken Into Five Pillars

| Pillar | Question | File |
|---|---|---|
| 1. Baseline | What does Olist's monthly revenue look like? | [`01_revenue_overview.sql`](sql/01_revenue_overview.sql) |
| 2. Mechanism | Does delivery delay predict lower satisfaction, and where does it matter most? | [`02_delay_satisfaction.sql`](sql/02_delay_satisfaction.sql) |
| 3. Cost | Does a late first delivery reduce the odds of a repeat purchase? | [`03_repeat_purchase_impact.sql`](sql/03_repeat_purchase_impact.sql) |
| 4. Exposure | How much revenue is tied to high-delay orders, and what is it costing annually? | [`04_revenue_at_risk.sql`](sql/04_revenue_at_risk.sql) |
| 5. Localization | Which sellers and regions disproportionately drive delay risk? | [`05_regional_exposure.sql`](sql/05_regional_exposure.sql) |

Every SQL technique used — and the reasoning behind it — is commented directly in each `.sql` file linked above.

---

## Key Findings

- **Delay collapses satisfaction:** average review score drops from **4.29** (on-time) to **1.70** (8+ days late) across 96,470 delivered orders — a monotonic 2.59-point decline with no exceptions.
- **Small Appliances is the most delay-sensitive category** (3.55-point gap), consistent with these being urgency-driven, functional purchases.
- **Repeat purchasing is rare overall (2.3%–3.0%)**, but customers with an on-time first delivery return at a modestly higher rate than those with any delay. The gap does **not** scale cleanly with delay severity, and counterintuitively did not widen during Olist's worst delay months (Nov 2017, Mar 2018) — a reminder that this analysis is correlational, not causal.
- **Estimated annual revenue exposure from delay-driven churn: $2,500–$6,800** — real, but small relative to Olist's monthly revenue.
- **The bigger exposure is operational, not behavioral:** up to **10.2%** of a single month's revenue (March 2018) was tied to severely delayed orders — a scale problem, not a retention problem.
- **A small group of outlier sellers** show delay rates up to **28.95%** — roughly 10x the platform average — while high-volume sellers consistently perform well.
- **Delivery estimates run ~11–14 days ahead of actual delivery** in nearly every state, suggesting Olist's promised delivery windows are conservatively padded rather than reflecting true logistics speed.

---

## Data

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) — ~100,000 orders, October 2016–August 2018, 9 relational tables (orders, order items, payments, reviews, products, sellers, customers, geolocation, category translation).

Data files are not included in this repository (see `.gitignore`) — download directly from Kaggle to reproduce.

---

## Repository Structure

```
├── data/
│   └── raw/                        # (gitignored — download from Kaggle)
├── notebooks/
│   └── 01_data_cleaning.ipynb      # Python/pandas cleaning + PostgreSQL load
├── sql/
│   ├── 01_revenue_overview.sql
│   ├── 02_delay_satisfaction.sql
│   ├── 03_repeat_purchase_impact.sql
│   ├── 04_revenue_at_risk.sql
│   └── 05_regional_exposure.sql
├── dashboard/
│   └── olist_revenue_at_risk.pbix
├── docs/
│   └── dashboard_preview.png
└── README.md
```

---

## Tools & Approach

- **Python (pandas, Jupyter)** — data cleaning, validation, and PostgreSQL load via SQLAlchemy
- **PostgreSQL** — all analytical logic: CTEs, window functions, conditional aggregation
- **Power BI** — dashboard and visualization

**Data cleaning highlights:** fixed a structurally corrupted source file (customers table loaded with 848 phantom columns), audited every null value for cause rather than blanket-imputing, resolved 551 true duplicate reviews by keeping the most recent submission per order, and used `customer_unique_id` (not `customer_id`) throughout for any person-level analysis, since Olist generates a new `customer_id` per order.

**SQL techniques demonstrated:** CTE chaining, `ROW_NUMBER()` / `MAX() OVER()` window functions for identifying each customer's order sequence, conditional aggregation (`CASE WHEN` inside `AVG()`/`COUNT()`) to avoid unreadable grid outputs, and `HAVING` filters enforcing minimum sample sizes at two levels to prevent single-order noise from producing misleading rankings.

---

## Limitations

This analysis is **correlational, not causal**. While late deliveries are consistently associated with lower review scores and modestly lower repeat-purchase rates, the data cannot confirm delay as the sole or primary cause — product quality, price, packaging, and customer service may all independently influence a customer's review and return decision.

A concrete example from this project: the on-time/late repeat-purchase gap did **not** widen during Olist's worst delay months (Nov 2017, Mar 2018) — in March 2018, severely delayed customers actually returned at a slightly *higher* rate (3.00%) than on-time customers (2.35%) that same month. A simple before/after read of the data would have predicted the opposite direction, which is exactly why this is flagged as correlational rather than causal.

**Sample sizes behind key findings:**

| Finding | Sample size |
|---|---|
| Delay → review score (Pillar 2.1) | 96,470 delivered orders |
| Category / state sensitivity (Pillar 2.2, 2.3) | Filtered to n ≥ 30 orders, n ≥ 10 late orders |
| Repeat purchase impact (Pillar 3) | 93,350 unique first-time customers |
| Seller exposure (Pillar 5.1) | 881 sellers, filtered to n ≥ 20 orders |

**With more time, the following would strengthen the analysis:**
- Report sample sizes (n) alongside every average shown, consistently across all outputs
- Run significance testing (e.g. ANOVA, Kruskal-Wallis, or a chi-square/proportions test) to confirm observed differences exceed what sample noise alone would produce
- Include confidence intervals or standard deviations alongside point estimates
- Examine full review-score distributions, not just averages, to check for skew
- Control for confounding variables (price, category, seller) via regression analysis

---

## Author

**Ishwandeep Kaur (Ishu)**
[LinkedIn](https://linkedin.com/in/ishwandeepkaur03) · [GitHub](https://github.com/ishu-05)
