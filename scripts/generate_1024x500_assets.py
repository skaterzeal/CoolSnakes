import os
from PIL import Image, ImageDraw, ImageFont

# Ensure target directories exist
os.makedirs("store_assets/google_play_1024x500", exist_ok=True)
os.makedirs("store_assets/google_play", exist_ok=True)

# System fonts
FONT_BOLD = "C:/Windows/Fonts/consola.ttf"
FONT_TITLE = "C:/Windows/Fonts/courbd.ttf"

def get_fonts():
    return {
        "title": ImageFont.truetype(FONT_TITLE, 38),
        "headline": ImageFont.truetype(FONT_TITLE, 27),
        "subtitle": ImageFont.truetype(FONT_BOLD, 18),
        "bullet": ImageFont.truetype(FONT_BOLD, 17),
        "badge": ImageFont.truetype(FONT_BOLD, 15),
    }

slides_data = [
    {
        "src": "screen_game.png",
        "index_str": "01 / 05",
        "headline": "ORIGINAL MONOCHROME LCD",
        "subtitle": "EARLY-2000s HANDHELD NOSTALGIA",
        "bullets": [
            "Authentic 100x80 low-res LCD pixel grid",
            "Custom 1-bit bitmap typography & HUD",
            "Original procedural buzzer audio chirps",
            "100% Offline & zero advertisements",
        ],
        "badges": ["RETRO LCD", "NO ADS", "OFFLINE"],
        "filename": "feature_1_lcd_1024x500.png",
    },
    {
        "src": "screen_border_live.png",
        "index_str": "02 / 05",
        "headline": "DUAL BOUNDARY MODES",
        "subtitle": "WRAP EDGES OR SOLID WALLS",
        "bullets": [
            "Classic wrap mode: pass through edges",
            "Solid wall mode: survive rigid borders",
            "Dynamic snake head with pixel eyes",
            "Moving tail vacancy safe navigation",
        ],
        "badges": ["SOLID WALLS", "WRAP MODE", "SKILL BASED"],
        "filename": "feature_2_border_1024x500.png",
    },
    {
        "src": "screen_splash_bar.png",
        "index_str": "03 / 05",
        "headline": "RETRO PHONE KEYPAD",
        "subtitle": "TACTILE 2-4-6-8 DIRECTIONAL KEYS",
        "bullets": [
            "Authentic early-2000s 3x3 numeric keypad",
            "Key 2: Up | 4: Left | 6: Right | 8: Down",
            "Tactile button press animations & clicks",
            "Full gesture swipe controls supported",
        ],
        "badges": ["1-9 KEYPAD", "SWIPE SUPPORT", "HAPTIC CLICKS"],
        "filename": "feature_3_keypad_1024x500.png",
    },
    {
        "src": "screen_top3_ready.png",
        "index_str": "04 / 05",
        "headline": "TOP 3 LEADERBOARD",
        "subtitle": "CHASE THE 019960 PERFECT SCORE",
        "bullets": [
            "Deterministic maximum score: 019960",
            "Local device top 3 score persistence",
            "Scarce-cell food placement engine",
            "Zero pay-to-win, 100% pure skill",
        ],
        "badges": ["MAX 019960", "LOCAL SCORES", "PURE SKILL"],
        "filename": "feature_4_leaderboard_1024x500.png",
    },
    {
        "src": "screen_settings.png",
        "index_str": "05 / 05",
        "headline": "CUSTOM LCD THEMES",
        "subtitle": "VINTAGE DISPLAY PALETTES & AUDIO",
        "bullets": [
            "Classic Olive, Pocket Grey & Warm Amber",
            "Futuristic Matrix Cyan LCD theme",
            "Toggle audio buzzer & haptic feedback",
            "4 Constant speed levels: Slow to Turbo",
        ],
        "badges": ["4 PALETTES", "CUSTOM AUDIO", "SPEED MODES"],
        "filename": "feature_5_settings_1024x500.png",
    },
]

def draw_background(draw, width, height):
    for y in range(height):
        factor = y / height
        r = int(14 * (1 - factor) + 5 * factor)
        g = int(22 * (1 - factor) + 8 * factor)
        b = int(10 * (1 - factor) + 4 * factor)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    grid_spacing = 40
    for x in range(0, width, grid_spacing):
        draw.line([(x, 0), (x, height)], fill=(25, 38, 18))
    for y in range(0, height, grid_spacing):
        draw.line([(0, y), (width, y)], fill=(25, 38, 18))

def crop_gameplay(img):
    w, h = img.size
    top = int(h * 0.055)
    bottom = int(h * 0.945)
    return img.crop((0, top, w, bottom))

def build_slide(data):
    W, H = 1024, 500
    canvas = Image.new("RGB", (W, H))
    draw = ImageDraw.Draw(canvas)
    fonts = get_fonts()
    accent = (181, 203, 56)

    # 1. Background
    draw_background(draw, W, H)

    # 2. Right Phone Mockup
    raw = Image.open(data["src"])
    cropped = crop_gameplay(raw)
    fit_h = 440
    fit_w = int(cropped.width * (fit_h / cropped.height))
    resized = cropped.resize((fit_w, fit_h), Image.Resampling.LANCZOS)

    px = W - fit_w - 50
    py = 30

    draw.rectangle([px - 3, py - 3, px + fit_w + 3, py + fit_h + 3], outline=accent, width=3)
    canvas.paste(resized, (px, py))

    # 3. Top-left logo badge & Title
    if os.path.exists("logo.png"):
        logo_img = Image.open("logo.png").convert("RGBA")
        logo_mini = logo_img.resize((64, 64), Image.Resampling.LANCZOS)
        canvas.paste(logo_mini, (50, 35), mask=logo_mini.split()[3])

    draw.text((126, 46), "COOL SNAKES", font=fonts["title"], fill=accent)

    # Separator
    draw.line([(50, 115), (px - 40, 115)], fill=(45, 68, 30), width=1)

    # Headline & Subtitle
    draw.text((50, 135), data["headline"], font=fonts["headline"], fill=(240, 255, 205))
    draw.text((50, 175), data["subtitle"], font=fonts["subtitle"], fill=(165, 190, 125))

    # Bullets
    by = 220
    for b in data["bullets"]:
        draw.text((50, by), f"[>] {b}", font=fonts["bullet"], fill=(220, 235, 185))
        by += 28

    # Badges
    bx = 50
    by = 420
    for bg in data["badges"]:
        bbox = draw.textbbox((0, 0), bg, font=fonts["badge"])
        bw = bbox[2] - bbox[0] + 16
        bh = bbox[3] - bbox[1] + 8
        draw.rectangle([bx, by, bx + bw, by + bh], outline=accent, width=2)
        draw.text((bx + 8, by + 3), bg, font=fonts["badge"], fill=accent)
        bx += bw + 12

    # Slide index
    draw.text((px - 120, 423), f"[ {data['index_str']} ]", font=fonts["badge"], fill=(120, 145, 90))

    # Ensure pure 24-bit RGB (no alpha) for Google Play Feature Graphic specification
    return canvas.convert("RGB")

def build_main_banner():
    W, H = 1024, 500
    canvas = Image.new("RGB", (W, H))
    draw = ImageDraw.Draw(canvas)
    draw_background(draw, W, H)

    accent = (181, 203, 56)

    # Left: Big logo
    if os.path.exists("logo.png"):
        logo_img = Image.open("logo.png").convert("RGBA")
        logo_resized = logo_img.resize((380, 380), Image.Resampling.LANCZOS)
        canvas.paste(logo_resized, (50, 60), mask=logo_resized.split()[3])

    # Right: Branding text & Badges
    font_title = ImageFont.truetype(FONT_TITLE, 60)
    font_sub = ImageFont.truetype(FONT_BOLD, 25)
    font_badge = ImageFont.truetype(FONT_BOLD, 18)

    draw.text((460, 95), "COOL SNAKES", font=font_title, fill=accent)
    draw.text((465, 180), "AUTHENTIC MONOCHROME LCD", font=font_sub, fill=(230, 245, 190))
    draw.text((465, 220), "EARLY-2000s RETRO EXPERIENCE", font=font_sub, fill=(180, 200, 140))

    # Bullets
    font_bullet = ImageFont.truetype(FONT_BOLD, 19)
    draw.text((465, 275), "[+] 1-9 Numeric Phone Keypad & Swipes", font=font_bullet, fill=(215, 235, 175))
    draw.text((465, 305), "[+] Wrap Edges & Solid Wall Modes", font=font_bullet, fill=(215, 235, 175))
    draw.text((465, 335), "[+] 100% Offline, Zero Ads, Pure Arcade", font=font_bullet, fill=(215, 235, 175))

    # Badges
    badges = ["MAX SCORE 019960", "4 LCD THEMES", "ORIGINAL BUZZER AUDIO"]
    bx = 465
    by = 390
    for b in badges:
        bbox = draw.textbbox((0, 0), b, font=font_badge)
        bw = bbox[2] - bbox[0] + 16
        bh = bbox[3] - bbox[1] + 8
        if bx + bw > 990:
            bx = 465
            by += 38
        draw.rectangle([bx, by, bx + bw, by + bh], outline=accent, width=2)
        draw.text((bx + 8, by + 3), b, font=font_badge, fill=accent)
        bx += bw + 12

    return canvas.convert("RGB")

def run():
    print("Generating 1024x500 Feature Graphics & Visuals...")

    # 1. Main Banner
    main_banner = build_main_banner()
    # Save in root
    main_banner.save("feature_graphic_1024x500.png", "PNG", optimize=True)
    # Save in store_assets
    main_banner.save("store_assets/google_play/feature_graphic_1024x500.png", "PNG", optimize=True)
    main_banner.save("store_assets/google_play_1024x500/feature_graphic_main_1024x500.png", "PNG", optimize=True)
    print("Saved: feature_graphic_1024x500.png (Main Branding)")

    # 2. 5x Feature Showcase Visuals
    for data in slides_data:
        slide = build_slide(data)
        fname = data["filename"]

        # Save directly in project root
        slide.save(fname, "PNG", optimize=True)
        # Save in store_assets/google_play_1024x500/
        slide.save(os.path.join("store_assets/google_play_1024x500", fname), "PNG", optimize=True)
        print(f"Saved: {fname}")

    print("All 1024x500 graphics generated successfully!")

if __name__ == "__main__":
    run()
