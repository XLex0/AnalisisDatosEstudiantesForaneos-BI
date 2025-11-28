with open("Mapping.csv", "r", encoding="utf-8") as f:
    lines = f.readlines()

clean = [line.replace(";", ",") for line in lines]

with open("Mapping.csv", "w", encoding="utf-8") as f:
    f.writelines(clean)
