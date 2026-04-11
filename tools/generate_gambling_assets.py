from PIL import Image, ImageDraw
import os


OUT_DIR = os.path.join("Sprites", "Gambling")
os.makedirs(OUT_DIR, exist_ok=True)


def save(img: Image.Image, name: str) -> None:
    img.save(os.path.join(OUT_DIR, name), "PNG")


def make_window_bg() -> None:
    w, h = 2048, 1365
    bg = Image.new("RGBA", (w, h), (12, 18, 28, 255))
    d = ImageDraw.Draw(bg)

    for y in range(h):
        t = y / float(h - 1)
        r = int(10 + 35 * t)
        g = int(18 + 42 * t)
        b = int(30 + 28 * t)
        d.line([(0, y), (w, y)], fill=(r, g, b, 255))

    for i, alpha in enumerate([90, 70, 50, 35]):
        pad = 120 + i * 120
        d.ellipse((pad, 80 + i * 40, w - pad, h - 320 + i * 20), outline=(255, 208, 120, alpha), width=4)

    for x in range(180, w, 220):
        d.rectangle((x, h - 260, x + 90, h - 210), fill=(45, 85, 110, 120))
        d.rectangle((x + 95, h - 240, x + 170, h - 190), fill=(55, 100, 130, 120))

    save(bg, "window_bg.png")


def make_game_box_frame() -> None:
    fw, fh = 1600, 760
    frame = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    d = ImageDraw.Draw(frame)

    for i, col in enumerate([(44, 90, 116, 255), (66, 131, 160, 255), (106, 171, 199, 255)]):
        m = 8 + i * 10
        d.rounded_rectangle((m, m, fw - m, fh - m), radius=46, outline=col, width=14)

    d.polygon([(30, 30), (170, 30), (30, 170)], fill=(255, 198, 88, 220))
    d.polygon([(fw - 30, 30), (fw - 170, 30), (fw - 30, 170)], fill=(255, 198, 88, 220))
    d.polygon([(30, fh - 30), (170, fh - 30), (30, fh - 170)], fill=(255, 198, 88, 220))
    d.polygon([(fw - 30, fh - 30), (fw - 170, fh - 30), (fw - 30, fh - 170)], fill=(255, 198, 88, 220))

    save(frame, "game_box_frame.png")


def make_character(state: str) -> Image.Image:
    cw, ch = 320, 320
    img = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    dr = ImageDraw.Draw(img)

    dr.ellipse((45, 55, 275, 285), fill=(255, 221, 138, 70))
    body = (228, 170, 66, 255)
    dark = (89, 56, 17, 255)

    head_y = 58 if state == "jump" else 76
    dr.ellipse((110, head_y, 210, head_y + 100), fill=(252, 218, 170, 255), outline=dark, width=5)

    if state == "fail":
        dr.line((140, head_y + 44, 155, head_y + 59), fill=(40, 25, 20, 255), width=4)
        dr.line((155, head_y + 44, 140, head_y + 59), fill=(40, 25, 20, 255), width=4)
        dr.line((166, head_y + 44, 181, head_y + 59), fill=(40, 25, 20, 255), width=4)
        dr.line((181, head_y + 44, 166, head_y + 59), fill=(40, 25, 20, 255), width=4)
        dr.arc((138, head_y + 72, 184, head_y + 96), 20, 160, fill=(90, 20, 20, 255), width=4)
    else:
        dr.ellipse((142, head_y + 44, 152, head_y + 54), fill=(30, 30, 30, 255))
        dr.ellipse((168, head_y + 44, 178, head_y + 54), fill=(30, 30, 30, 255))
        dr.arc((142, head_y + 68, 180, head_y + 92), 12, 172, fill=(90, 40, 10, 255), width=4)

    torso_top = 168 if state == "jump" else 184
    dr.rounded_rectangle((124, torso_top, 196, torso_top + 74), radius=20, fill=body, outline=dark, width=5)
    dr.polygon([(159, torso_top + 18), (174, torso_top + 40), (159, torso_top + 72), (144, torso_top + 40)], fill=(184, 28, 28, 255))

    if state == "jump":
        dr.line((124, torso_top + 20, 86, torso_top - 8), fill=dark, width=7)
        dr.line((196, torso_top + 20, 234, torso_top - 8), fill=dark, width=7)
    else:
        dr.line((124, torso_top + 26, 90, torso_top + 44), fill=dark, width=7)
        dr.line((196, torso_top + 26, 230, torso_top + 44), fill=dark, width=7)

    leg_y = torso_top + 72
    if state == "jump":
        dr.line((144, leg_y, 128, leg_y + 48), fill=dark, width=8)
        dr.line((176, leg_y, 196, leg_y + 48), fill=dark, width=8)
    else:
        dr.line((146, leg_y, 146, leg_y + 58), fill=dark, width=8)
        dr.line((174, leg_y, 174, leg_y + 58), fill=dark, width=8)

    if state != "fail":
        dr.rectangle((230, 38, 292, 74), fill=(96, 169, 72, 255), outline=(35, 78, 25, 255), width=4)
        dr.text((250, 44), "$", fill=(225, 250, 210, 255))

    return img


def make_tiles() -> None:
    tile_specs = [
        ("tile_base_low.png", ((52, 92, 64), (74, 126, 86), (118, 168, 126))),
        ("tile_base_mid.png", ((66, 88, 130), (94, 132, 182), (132, 178, 226))),
        ("tile_base_high.png", ((122, 74, 54), (176, 108, 72), (236, 166, 102))),
    ]

    for name, cols in tile_specs:
        tw, th = 256, 180
        img = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
        dr = ImageDraw.Draw(img)
        dr.rounded_rectangle((6, 8, tw - 6, th - 8), radius=24, fill=cols[1], outline=cols[2], width=6)
        dr.rounded_rectangle((18, 20, tw - 18, th - 18), radius=16, outline=cols[0], width=3)
        for x in range(24, tw - 24, 30):
            dr.line((x, 24, x - 12, th - 24), fill=(255, 255, 255, 28), width=2)
        save(img, name)


def make_button(name: str, base: tuple[int, int, int, int], edge: tuple[int, int, int, int], glow: tuple[int, int, int, int]) -> None:
    bw, bh = 640, 220
    img = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    dr = ImageDraw.Draw(img)
    dr.rounded_rectangle((8, 8, bw - 8, bh - 8), radius=58, fill=base, outline=edge, width=10)
    dr.rounded_rectangle((24, 22, bw - 24, bh - 100), radius=44, fill=glow)
    save(img, name)


def make_buttons() -> None:
    make_button("btn_step_normal.png", (34, 110, 84, 255), (148, 240, 202, 255), (78, 164, 132, 210))
    make_button("btn_step_hover.png", (46, 130, 98, 255), (180, 255, 226, 255), (96, 182, 150, 220))
    make_button("btn_step_pressed.png", (26, 90, 68, 255), (116, 208, 170, 255), (56, 140, 110, 210))

    make_button("btn_stand_normal.png", (120, 58, 52, 255), (242, 174, 162, 255), (164, 96, 88, 210))
    make_button("btn_stand_hover.png", (136, 66, 58, 255), (255, 196, 184, 255), (184, 110, 100, 220))
    make_button("btn_stand_pressed.png", (98, 46, 42, 255), (220, 152, 140, 255), (136, 78, 72, 210))

    make_button("btn_bet_normal.png", (56, 74, 122, 255), (176, 204, 255, 255), (90, 116, 174, 210))
    make_button("btn_bet_hover.png", (66, 88, 140, 255), (196, 222, 255, 255), (106, 132, 190, 220))
    make_button("btn_bet_pressed.png", (44, 60, 102, 255), (152, 182, 236, 255), (70, 94, 152, 210))


def main() -> None:
    make_window_bg()
    make_game_box_frame()
    save(make_character("idle"), "character_idle.png")
    save(make_character("jump"), "character_jump.png")
    save(make_character("fail"), "character_fail.png")
    make_tiles()
    make_buttons()
    print("Generated assets in", OUT_DIR)


if __name__ == "__main__":
    main()
