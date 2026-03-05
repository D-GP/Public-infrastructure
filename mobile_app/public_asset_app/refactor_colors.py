import os
import re

lib_dir = "c:/Users/gowth/Desktop/smart_public/mobile_app/public_asset_app/lib"

# Mappings from harsh or default colors to a comfortable, soft light theme (Ocean / Soft Teal)
# primary: 0xFF4A90E2 (Soft Blue) or 0xFF009688 (Teal) -> Let's use a soft Teal 0xFF26A69A
# background: 0xFFF7FAFC
color_map = {
    # Blue / Indigo variants -> Soft Teal
    r"Colors\.blue(?!\[|\.)": "Color(0xFF26A69A)",
    r"Colors\.lightBlueAccent": "Color(0xFF80CBC4)",
    r"Color\(0xFF2563EB\)": "Color(0xFF26A69A)", # old primary blue
    r"Colors\.blue\[\d+\]\*?": "Color(0xFFB2DFDB)", # soft teal background
    r"Colors\.blueAccent": "Color(0xFF4DB6AC)",
    
    # Backgrounds
    r"Color\(0xFFF5F5F5\)": "Color(0xFFF4F9F9)", # softer airy background
    
    # Black text to soft slate
    r"Colors\.black87": "Color(0xFF2D3748)",
    r"Colors\.black": "Color(0xFF1A202C)",
    
    # Greens to soft mint
    r"Colors\.green": "Color(0xFF66BB6A)",
    
    # Oranges to soft peach
    r"Colors\.orange": "Color(0xFFFFB74D)",
    
    # Purples to soft lavender
    r"Colors\.purple": "Color(0xFFBA68C8)",
    
    # Reds to soft coral
    r"Colors\.red": "Color(0xFFE57373)",
    r"Colors\.red\.shade100": "Color(0xFFFFCDD2)",
    r"Colors\.red\.shade400": "Color(0xFFE57373)",
    r"Colors\.red\.shade700": "Color(0xFFD32F2F)",
}

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content
    for pattern, replacement in color_map.items():
        # we do a simple regex sub
        new_content = re.sub(pattern, replacement, new_content)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for filename in files:
        if filename.endswith(".dart"):
            process_file(os.path.join(root, filename))

print("Color refactoring complete.")
