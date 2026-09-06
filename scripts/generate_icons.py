from PIL import Image
import os

source_path = "logo.png"
if not os.path.exists(source_path):
    print(f"Error: {source_path} not found")
    exit(1)

img = Image.open(source_path).convert("RGBA")

# Ensure RGB without alpha for Apple App Store 1024x1024 requirement
def to_rgb_with_background(image, bg_color=(15, 15, 15)):
    background = Image.new("RGB", image.size, bg_color)
    background.paste(image, mask=image.split()[3])
    return background

android_res = "android/app/src/main/res"
android_sizes = {
    "mipmap-mdpi/ic_launcher.png": (48, 48),
    "mipmap-hdpi/ic_launcher.png": (72, 72),
    "mipmap-xhdpi/ic_launcher.png": (96, 96),
    "mipmap-xxhdpi/ic_launcher.png": (144, 144),
    "mipmap-xxxhdpi/ic_launcher.png": (192, 192),
}

for rel_path, size in android_sizes.items():
    full_path = os.path.join(android_res, rel_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    resized = img.resize(size, Image.Resampling.LANCZOS)
    resized.save(full_path, "PNG")
    print(f"Generated Android: {full_path} ({size[0]}x{size[1]})")

ios_res = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
ios_sizes = {
    "Icon-App-1024x1024@1x.png": (1024, 1024),
    "Icon-App-83.5x83.5@2x.png": (167, 167),
    "Icon-App-76x76@1x.png": (76, 76),
    "Icon-App-76x76@2x.png": (152, 152),
    "Icon-App-60x60@2x.png": (120, 120),
    "Icon-App-60x60@3x.png": (180, 180),
    "Icon-App-40x40@1x.png": (40, 40),
    "Icon-App-40x40@2x.png": (80, 80),
    "Icon-App-40x40@3x.png": (120, 120),
    "Icon-App-29x29@1x.png": (29, 29),
    "Icon-App-29x29@2x.png": (58, 58),
    "Icon-App-29x29@3x.png": (87, 87),
    "Icon-App-20x20@1x.png": (20, 20),
    "Icon-App-20x20@2x.png": (40, 40),
    "Icon-App-20x20@3x.png": (60, 60),
}

for filename, size in ios_sizes.items():
    full_path = os.path.join(ios_res, filename)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    resized = img.resize(size, Image.Resampling.LANCZOS)
    if filename == "Icon-App-1024x1024@1x.png":
        # iOS 1024 icon must not have transparency
        rgb_img = to_rgb_with_background(resized)
        rgb_img.save(full_path, "PNG")
    else:
        resized.save(full_path, "PNG")
    print(f"Generated iOS: {full_path} ({size[0]}x{size[1]})")

# Play Store 512x512
play_store_dir = "store_assets/play_store"
os.makedirs(play_store_dir, exist_ok=True)
icon_512 = img.resize((512, 512), Image.Resampling.LANCZOS)
rgb_512 = to_rgb_with_background(icon_512)
rgb_512.save(os.path.join(play_store_dir, "icon_512.png"), "PNG")
print("Generated Play Store 512x512 icon")
