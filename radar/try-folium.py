import folium
import json

# Load GeoJSON data
with open('d82b8650-3096-11ea-858f-a37e71869ad9-version-1.geojson', 'r') as f:
    geojson_data = json.load(f)

# Create base map centered on Toulouse
m = folium.Map(location=[43.6047, 1.4442], zoom_start=12, tiles='OpenStreetMap')

# Add each point
for feature in geojson_data['features']:
    coords = feature['geometry']['coordinates'][0]
    props = feature['properties']
    
    folium.Marker(
        location=[coords[1], coords[0]],  # lat, lon
        popup=f"<b>{props['adresse']}</b><br>{props['lib_off']}<br>ID: {props['id']}",
        tooltip=props['lib_off']
    ).add_to(m)

m.save('toulouse_cameras.html')
