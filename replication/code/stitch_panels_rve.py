#!/usr/bin/env python3

"""Stitch the three main-manuscript forest plot panels into one figure."""

import os

import matplotlib

matplotlib.use("Agg")
import matplotlib.image as mpimg
import matplotlib.pyplot as plt


try:
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
except NameError:
    BASE_DIR = os.environ.get("SUPPLEMENT_PATH", os.getcwd())

OUTPUT_DIR = os.path.join(BASE_DIR, "output")


def stack_panels(panel_paths, output_path, dpi=150):
    missing = [path for path in panel_paths if not os.path.exists(path)]
    if missing:
        print(
            f"Skipping {os.path.basename(output_path)}; missing panels: "
            f"{[os.path.basename(path) for path in missing]}"
        )
        return

    images = [mpimg.imread(path) for path in panel_paths]
    heights = [image.shape[0] for image in images]
    width = images[0].shape[1]

    fig_width = width / dpi
    fig_height = sum(heights) / dpi
    fig, axes = plt.subplots(
        len(images),
        1,
        figsize=(fig_width, fig_height),
        gridspec_kw={"height_ratios": heights},
    )

    if len(images) == 1:
        axes = [axes]

    for axis, image in zip(axes, images):
        axis.imshow(image)
        axis.axis("off")

    plt.subplots_adjust(left=0, right=1, top=1, bottom=0, hspace=0)
    fig.savefig(output_path, dpi=dpi, bbox_inches="tight", pad_inches=0, facecolor="white")
    plt.close(fig)
    print(f"Saved {output_path}")


stack_panels(
    [
        os.path.join(OUTPUT_DIR, "tmp_panel_allest_calr.png"),
        os.path.join(OUTPUT_DIR, "tmp_panel_allest_cahr.png"),
        os.path.join(OUTPUT_DIR, "tmp_panel_allest_fe.png"),
    ],
    os.path.join(OUTPUT_DIR, "forest_all_estimates.png"),
)
