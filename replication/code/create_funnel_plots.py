#!/usr/bin/env python3

import csv
import os
import re

import matplotlib
import numpy as np
from matplotlib.lines import Line2D

matplotlib.use("Agg")
import matplotlib.pyplot as plt

try:
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
except NameError:
    BASE_DIR = os.environ.get("SUPPLEMENT_PATH", os.getcwd())
OUTPUT_DIR = os.path.join(BASE_DIR, "output")
RESULTS_DIR = os.path.join(OUTPUT_DIR, "results")
STUDY_LEVEL_FILE = os.path.join(OUTPUT_DIR, "_funnel_study_level.csv")


def parse_latex_number(filename):
    path = os.path.join(RESULTS_DIR, filename)
    with open(path, encoding="utf-8") as handle:
        value = handle.read().strip()
    value = value.replace("$-$", "-").replace("$+$", "")
    return float(value)


def load_study_level_data():
    if not os.path.exists(STUDY_LEVEL_FILE):
        raise FileNotFoundError(
            f"Missing {STUDY_LEVEL_FILE}. Run the Stata replication scripts first."
        )

    groups = {"Calcium": [], "Iron": []}
    with open(STUDY_LEVEL_FILE, newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            group = row["Type"]
            if group not in groups:
                continue
            study = re.sub(r"^\s*-\s*", "", row["study"]).strip()
            rob = (row.get("rob") or "low").strip().lower()
            if rob not in {"low", "some", "high"}:
                rob = "low"
            groups[group].append(
                {
                    "name": study,
                    "effect": float(row["effect"]),
                    "se": float(row["se_effect"]),
                    "rob": rob,
                }
            )
    return groups


def create_funnel_plot(ax, studies, pooled_effect, title):
    effects = [study["effect"] for study in studies]
    ses = [study["se"] for study in studies]

    for study in studies:
        if study["rob"] == "high":
            color = "red"
            marker = "s"
        elif study["rob"] == "some":
            color = "orange"
            marker = "o"
        else:
            color = "blue"
            marker = "o"
        ax.scatter(
            study["effect"],
            study["se"],
            c=color,
            s=80,
            marker=marker,
            edgecolors="black",
            linewidths=0.5,
            zorder=3,
        )

    se_range = np.linspace(0, max(ses) * 1.3, 100)
    lower_bound = pooled_effect - 1.96 * se_range
    upper_bound = pooled_effect + 1.96 * se_range

    ax.fill_betweenx(se_range, lower_bound, upper_bound, alpha=0.1, color="gray")
    ax.plot(lower_bound, se_range, "k--", alpha=0.5, linewidth=1)
    ax.plot(upper_bound, se_range, "k--", alpha=0.5, linewidth=1)
    ax.axvline(x=pooled_effect, color="black", linestyle=":", linewidth=1.5)
    ax.axvline(x=0, color="gray", linestyle="-", linewidth=0.5, alpha=0.5)

    ax.invert_yaxis()
    ax.set_xlabel("Effect size (μg/dL)", fontsize=11)
    ax.set_ylabel("Standard Error", fontsize=11)
    ax.set_title(title, fontsize=12, fontweight="bold")

    x_margin = 0.5
    ax.set_xlim(min(effects + [pooled_effect]) - x_margin, max(effects + [pooled_effect]) + x_margin)
    ax.set_ylim(max(ses) * 1.2, 0)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)


def main():
    studies = load_study_level_data()
    calcium_pooled = parse_latex_number("ca_all_b.tex")
    iron_pooled = parse_latex_number("fe_all_b.tex")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    create_funnel_plot(ax1, studies["Calcium"], calcium_pooled, f"Calcium (n={len(studies['Calcium'])})")
    create_funnel_plot(ax2, studies["Iron"], iron_pooled, f"Iron (n={len(studies['Iron'])})")

    legend_elements = [
        Line2D([0], [0], marker="o", color="w", markerfacecolor="blue", markersize=10, markeredgecolor="black", label="Low risk of bias"),
        Line2D([0], [0], marker="o", color="w", markerfacecolor="orange", markersize=10, markeredgecolor="black", label="Some concerns"),
        Line2D([0], [0], marker="s", color="w", markerfacecolor="red", markersize=10, markeredgecolor="black", label="High risk of bias"),
    ]
    fig.legend(handles=legend_elements, loc="lower center", ncol=3, bbox_to_anchor=(0.5, -0.02), frameon=False)

    plt.tight_layout()
    plt.subplots_adjust(bottom=0.15)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    plt.savefig(os.path.join(OUTPUT_DIR, "funnel_plots.png"), dpi=300, bbox_inches="tight", facecolor="white")
    print("Funnel plots saved.")


if __name__ == "__main__":
    main()
