import json

# Read notebook
with open("notebooks/conflict/acled_post_assad.ipynb", "r") as f:
    nb = json.load(f)

# Voronoi code
voronoi_code = '''from scipy.spatial import Voronoi
from shapely.geometry import Polygon, MultiPolygon, box
import numpy as np

# Load Syria boundary
syria_boundary = gpd.read_file("../../data/boundaries/syr_admin0.shp")

# Get point coordinates
coords = np.array([[point.x, point.y] for point in areas_of_control.geometry])

# Create Voronoi diagram
vor = Voronoi(coords)

# Function to create finite polygons from Voronoi regions
def voronoi_finite_polygons(vor, radius=None):
    """Reconstruct infinite voronoi regions to finite regions."""
    if vor.points.shape[1] != 2:
        raise ValueError("Requires 2D input")

    new_regions = []
    new_vertices = vor.vertices.tolist()

    center = vor.points.mean(axis=0)
    if radius is None:
        radius = vor.points.ptp(axis=0).max() * 2

    # Construct a map containing all ridges for a given point
    all_ridges = {}
    for (p1, p2), (v1, v2) in zip(vor.ridge_points, vor.ridge_vertices):
        all_ridges.setdefault(p1, []).append((p2, v1, v2))
        all_ridges.setdefault(p2, []).append((p1, v1, v2))

    # Reconstruct infinite regions
    for p1, region in enumerate(vor.point_region):
        vertices = vor.regions[region]

        if all(v >= 0 for v in vertices):
            # finite region
            new_regions.append(vertices)
            continue

        # reconstruct a non-finite region
        ridges = all_ridges[p1]
        new_region = [v for v in vertices if v >= 0]

        for p2, v1, v2 in ridges:
            if v2 < 0:
                v1, v2 = v2, v1
            if v1 >= 0:
                # finite ridge: already in the region
                continue

            # Compute the missing endpoint of an infinite ridge
            t = vor.points[p2] - vor.points[p1]
            t /= np.linalg.norm(t)
            n = np.array([-t[1], t[0]])

            midpoint = vor.points[[p1, p2]].mean(axis=0)
            direction = np.sign(np.dot(midpoint - center, n)) * n
            far_point = vor.vertices[v2] + direction * radius

            new_region.append(len(new_vertices))
            new_vertices.append(far_point.tolist())

        # sort region counterclockwise
        vs = np.asarray([new_vertices[v] for v in new_region])
        c = vs.mean(axis=0)
        angles = np.arctan2(vs[:, 1] - c[1], vs[:, 0] - c[0])
        new_region = np.array(new_region)[np.argsort(angles)]

        new_regions.append(new_region.tolist())

    return new_regions, np.asarray(new_vertices)

# Get finite Voronoi regions
regions, vertices = voronoi_finite_polygons(vor)

# Create polygons for each point and clip to Syria boundary
control_polygons = []
control_values = []

for i, region in enumerate(regions):
    polygon_coords = vertices[region]
    polygon = Polygon(polygon_coords)

    # Clip to Syria boundary
    clipped = polygon.intersection(syria_boundary.union_all())

    # Only keep valid polygons
    if not clipped.is_empty and clipped.area > 0:
        control_polygons.append(clipped)
        control_values.append(areas_of_control.iloc[i]['2026-01-01'])

# Create new GeoDataFrame with polygons
areas_of_control_polygons = gpd.GeoDataFrame({
    '2026-01-01': control_values,
    'geometry': control_polygons
}, crs=areas_of_control.crs)

print(f"Created {len(areas_of_control_polygons)} polygons from {len(areas_of_control)} points")
print(areas_of_control_polygons['2026-01-01'].value_counts())

areas_of_control_polygons'''

viz_code = """import matplotlib.pyplot as plt
import contextily as ctx
from matplotlib.colors import ListedColormap

# World Bank categorical colors
wb_colors = ['#34A7F2', '#FF9800', '#664AB6', '#4EC2C0', '#F3578E',
             '#081079', '#0C7C68', '#AA0000', '#DDDA21']

# Create figure
fig, ax = plt.subplots(figsize=(10, 8))

# Plot the areas of control with legend
gdf_plot = areas_of_control_polygons.to_crs(epsg=3857)
gdf_plot.plot(
    column='2026-01-01',
    ax=ax,
    legend=True,
    categorical=True,
    cmap=ListedColormap(wb_colors),
    alpha=1.0,
    edgecolor='#666666',
    linewidth=0.1,
    legend_kwds={'loc': 'lower right', 'frameon': False, 'title': 'Control'}
)

# Add basemap
ctx.add_basemap(
    ax,
    source=MAPBOX_BASEMAP_URL,
    alpha=0.3,
    zoom='auto',
    zorder=0
)

# Remove axes
ax.set_axis_off()

# Add title and subtitle
fig.suptitle('Areas of Control in Syria', fontsize=16, fontweight='bold', x=0.125, ha='left', y=0.96)
fig.text(0.125, 0.90, 'January 2026', fontsize=12, ha='left')

# Add source note
fig.text(0.125, 0.02, f'Source: Carter Center. Extracted {extracted_date_formatted}',
         fontsize=9, ha='left', style='italic', color='#666666')

plt.tight_layout(rect=[0, 0.03, 1, 0.92])
plt.show()"""

# Find and update cells
for cell in nb["cells"]:
    if cell.get("id") == "VSC-97407ab3":
        cell["source"] = voronoi_code
    elif cell.get("id") == "VSC-28534811":
        cell["source"] = viz_code

# Write back
with open("notebooks/conflict/acled_post_assad.ipynb", "w") as f:
    json.dump(nb, f, indent=1)

print("Notebook updated successfully")
