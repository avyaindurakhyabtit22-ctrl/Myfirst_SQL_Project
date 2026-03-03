# llm_analysis.py

import mysql.connector
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Step 1: Connect to MySQL
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root",   # replace with your MySQL password
    database="my_first_db"      # this is your database name
)

# Step 2: Run a query and load into Pandas
query = """
SELECT model_name, overall_benchmark_avg, performance_per_dollar
FROM llm_benchmarks;
"""
df = pd.read_sql(query, conn)
print("Preview of data:")
print(df.head())

# Step 3: Visualize with Seaborn
sns.scatterplot(
    data=df,
    x="performance_per_dollar",
    y="overall_benchmark_avg",
    hue="model_name"
)
plt.title("Performance vs Benchmark Score")
plt.xlabel("Performance per Dollar")
plt.ylabel("Overall Benchmark Avg")
plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()

# Close connection
conn.close()
