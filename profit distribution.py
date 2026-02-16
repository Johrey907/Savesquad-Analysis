import pandas as pd

# Input data
df = pd.read_csv("C:/data/GitHub/python/save squad/Year1copy.csv")

total_profit = df['Interest'].sum()
# Weights
w_savings = 5       # 50%
w_loanpay = 5      # 50%

# Calculate individual scores
df['Score'] = (
    df['Savings'] * w_savings +
    df['Loanpay'] * w_loanpay  
)

# Normalize scores to distribute profit
total_score = df['Score'].sum()
df['ProfitShare'] = ((df['Score'] / total_score) * total_profit).round().astype(int) if total_score != 0 else 0


# Calculate percentile rank (0-100)
df['pct_rank'] = (df['Score'].rank(pct=True, method='max') * 100).round().astype(int)

# Assign credit grades based on percentile
def assign_grade(p):
    if p >= 70:
        return 'A'
    elif p >= 40:
        return 'B'
    else:
        return 'C'

df['credit_grade'] = df['pct_rank'].apply(assign_grade)

# Final output
final_result = df[['Member', 'Savings', 'Loanpay', 'Interest', 'Score', 'ProfitShare', 'pct_rank', 'credit_grade']]
print(final_result)

# Saving to CSV file 
final_result.to_csv('save_squad_finalcopy.csv', index=False)

print("CSV file saved: save_squad_finalcopy.csv")

