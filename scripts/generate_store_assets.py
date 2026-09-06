import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# Paths
os.makedirs("store_assets/google_play", exist_ok=True)
os.makedirs("store_assets/app_store_6.5", exist_ok=True)
os.makedirs("store_assets/app_store_5.5", exist_ok=True)

# Copy 512 icon to google_play
if os.path.exists("store_assets/play_store/icon_512.png"):
    img_512 = Image.open("store_assets/play_store/icon_512.png")
    img_512.save("store_assets/google_play/icon_512.png")

# Fonts
FONT_BOLD = "C:/Windows/Fonts/consola.ttf"
FONT_TITLE = "C:/Windows/Fonts/courbd.ttf"

def get_fonts(title_size, subtitle_size):
    return (
        ImageFont.truetype(FONT_TITLE, title_size),
        ImageFont.truetype(FONT_BOLD, subtitle_size),
    )

# Screens configuration
screens_info = [
    {
        "src": "screen_game.png",
        "title": "MONOCHROME LCD",
        "subtitle": "PURE 2000s HANDHELD NOSTALGIA",
        "name": "screenshot_1_lcd.png",
    },
    {
        "src": "screen_border_live.png",
        "title": "WALL BORDER MODE",
        "subtitle": "SURVIVE THE SOLID BOUNDARY",
        "name": "screenshot_2_border.png",
    },
    {
        "src": "screen_splash_bar.png",
        "title": "RETRO 1-9 KEYPAD",
        "subtitle": "PLAY WITH AUTHENTIC 2-4-6-8 KEYS",
        "name": "screenshot_3_keypad.png",
    },
    {
        "src": "screen_top3_ready.png",
        "title": "TOP 3 LEADERBOARD",
        "subtitle": "CHASE THE 019960 PERFECT SCORE",
        "name": "screenshot_4_leaderboard.png",
    },
    {
        "src": "screen_settings.png",
        "title": "CUSTOM LCD THEMES",
        "subtitle": "OLIVE, GREY, AMBER & MATRIX CYAN",
        "name": "screenshot_5_settings.png",
    },
]

def crop_gameplay(img):
    # Original is 720x1600. Crop top status bar (y: 80) and bottom android nav bar (y: 1520)
    w, h = img.size
    top = int(h * 0.055)
    bottom = int(h * 0.945)
    return img.crop((0, top, w, bottom))

def draw_background(draw, width, height):
    # Dark retro gradient with subtle grid pattern
    for y in range(height):
        # Vertical gradient from #0D1208 to #050704
        factor = y / height
        r = int(14 * (1 - factor) + 5 * factor)
        g = int(22 * (1 - factor) + 8 * factor)
        b = int(10 * (1 - factor) + 4 * factor)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    # Grid overlay
    grid_spacing = 40
    for x in range(0, width, grid_spacing):
        draw.line([(x, 0), (x, height)], fill=(25, 38, 18, 50))
    for y in range(0, height, grid_spacing):
        draw.line([(0, y), (width, y)], fill=(25, 38, 18, 50))

def create_store_screenshot(src_path, title, subtitle, target_size):
    tw, th = target_size
    canvas = Image.new("RGB", (tw, th))
    draw = ImageDraw.Draw(canvas)

    # Background
    draw_background(draw, tw, th)

    # Header sizing based on target resolution
    scale = tw / 1080.0
    title_font_size = int(62 * scale)
    sub_font_size = int(28 * scale)
    title_font, sub_font = get_fonts(title_font_size, sub_font_size)

    # Header text
    header_top = int(80 * scale)

    # Accent color #A3C133 (classic olive retro LCD green)
    accent_color = (181, 203, 56)
    dim_color = (130, 150, 40)

    # Title
    t_bbox = draw.textbbox((0, 0), title, font=title_font)
    t_w = t_bbox[2] - t_bbox[0]
    t_x = (tw - t_w) // 2
    draw.text((t_x, header_top), title, font=title_font, fill=accent_color)

    # Subtitle
    s_bbox = draw.textbbox((0, 0), subtitle, font=sub_font)
    s_w = s_bbox[2] - s_bbox[0]
    s_x = (tw - s_w) // 2
    s_y = header_top + int(80 * scale)
    draw.text((s_x, s_y), subtitle, font=sub_font, fill=(220, 235, 180))

    # Decorative Line
    line_y = s_y + int(50 * scale)
    line_w = int(240 * scale)
    draw.line([((tw - line_w) // 2, line_y), ((tw + line_w) // 2, line_y)], fill=accent_color, width=max(2, int(3 * scale)))

    # Frame and Game screenshot
    if os.path.exists(src_path):
        raw_screen = Image.open(src_path)
        cropped = crop_gameplay(raw_screen)

        # Compute placement
        avail_h = th - line_y - int(80 * scale)
        avail_w = tw - int(120 * scale)

        c_w, c_h = cropped.size
        fit_ratio = min(avail_w / c_w, avail_h / c_h)
        new_w = int(c_w * fit_ratio)
        new_h = int(c_h * fit_ratio)

        resized_screen = cropped.resize((new_w, new_h), Image.Resampling.LANCZOS)

        pos_x = (tw - new_w) // 2
        pos_y = line_y + int(40 * scale) + (avail_h - new_h) // 2

        # Device frame shadow & border
        border_thickness = max(3, int(5 * scale))
        draw.rectangle(
            [pos_x - border_thickness, pos_y - border_thickness, pos_x + new_w + border_thickness, pos_y + new_h + border_thickness],
            outline=accent_color,
            width=border_thickness,
        )

        canvas.paste(resized_screen, (pos_x, pos_y))

    return canvas

# 1. Generate Google Play Screenshots (1080 x 2400)
print("Generating Google Play Store screenshots (1080x2400)...")
for info in screens_info:
    shot = create_store_screenshot(info["src"], info["title"], info["subtitle"], (1080, 2400))
    out_path = os.path.join("store_assets/google_play", info["name"])
    shot.save(out_path, "PNG", quality=95)
    print(f"Saved: {out_path}")

# 2. Generate Apple App Store 6.5\" Screenshots (1290 x 2796)
print("Generating Apple App Store 6.5\" screenshots (1290x2796)...")
for info in screens_info:
    shot = create_store_screenshot(info["src"], info["title"], info["subtitle"], (1290, 2796))
    out_path = os.path.join("store_assets/app_store_6.5", info["name"])
    shot.save(out_path, "PNG", quality=95)
    print(f"Saved: {out_path}")

# 3. Generate Apple App Store 5.5\" Screenshots (1242 x 2208)
print("Generating Apple App Store 5.5\" screenshots (1242x2208)...")
for info in screens_info:
    shot = create_store_screenshot(info["src"], info["title"], info["subtitle"], (1242, 2208))
    out_path = os.path.join("store_assets/app_store_5.5", info["name"])
    shot.save(out_path, "PNG", quality=95)
    print(f"Saved: {out_path}")

# 4. Generate Google Play Feature Graphic (1024 x 500)
print("Generating Google Play Feature Graphic (1024x500)...")
fg = Image.new("RGB", (1024, 500))
fg_draw = ImageDraw.Draw(fg)
draw_background(fg_draw, 1024, 500)

# Paste logo on left
if os.path.exists("logo.png"):
    logo_img = Image.open("logo.png").convert("RGBA")
    logo_resized = logo_img.resize((380, 380), Image.Resampling.LANCZOS)
    fg.paste(logo_resized, (60, 60), mask=logo_resized.split()[3])

# Text on right
title_font = ImageFont.truetype(FONT_TITLE, 64)
sub_font = ImageFont.truetype(FONT_BOLD, 26)
badge_font = ImageFont.truetype(FONT_BOLD, 20)

accent_color = (181, 203, 56)
fg_draw.text((470, 110), "COOL SNAKES", font=title_font, fill=accent_color)
fg_draw.text((475, 195), "AUTHENTIC MONOCHROME LCD", font=sub_font, fill=(230, 245, 190))
fg_draw.text((475, 235), "EARLY-2000s RETRO EXPERIENCE", font=sub_font, fill=(180, 200, 140))

# Features pill/badge
badge_y = 310
badges = ["1-9 KEYPAD", "SOLID WALLS", "MAX SCORE 019960", "100% OFFLINE"]
bx = 475
for b in badges:
    bbox = fg_draw.textbbox((0, 0), b, font=badge_font)
    bw = bbox[2] - bbox[0] + 16
    bh = bbox[3] - bbox[1] + 10
    if bx + bw > 990:
        bx = 475
        badge_y += 40
    fg_draw.rectangle([bx, badge_y, bx + bw, badge_y + bh], outline=accent_color, width=2)
    fg_draw.text((bx + 8, badge_y + 4), b, font=badge_font, fill=accent_color)
    bx += bw + 12

fg_out = "store_assets/google_play/feature_graphic_1024x500.png"
fg.save(fg_out, "PNG", quality=95)
print(f"Saved Feature Graphic: {fg_out}")

print("All promotional store assets generated successfully!")
