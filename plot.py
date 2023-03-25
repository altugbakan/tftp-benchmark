import pandas as pd
import matplotlib.pyplot as plt

# Read in the CSV file and create a pandas DataFrame
df = pd.read_csv("test_results.csv")

# Filter the DataFrame to only include rows where the transfer type is "get" and block size is 1024
df = df[(df["transfer_type"] == "get") & (df["block_size_bytes"] == 1024)]

# Loop over each unique "name" and create a plot
for name in df["name"].unique():
    name_df = df[df["name"] == name]
    plt.plot(name_df["file_size_kb"], name_df["transfer_time_seconds"], label=name)

# Add labels and a legend
plt.xlabel("File Size (KB)")
plt.ylabel("Transfer Time (Seconds)")
plt.title("Comparison of Transfer Time with Block Size = 1024")
plt.legend()
plt.savefig("results.png")
plt.show()
