"""Gera os ícones do aplicativo a partir da mesma geometria de AppLogo.

Uso, na raiz do projeto: python tool/gerar_icones.py (precisa do Pillow).
"""
from PIL import Image, ImageDraw

BLUE = (0x00, 0x6F, 0xA8, 255)
AMBER = (0xF2, 0xA9, 0x00, 255)
WHITE = (255, 255, 255, 255)

# Medidas em fração do lado, iguais às de lib/widgets/app_logo.dart.
LEFT, TOP, RIGHT, BOTTOM = 0.22, 0.16, 0.78, 0.84
RADIUS, TEAR, NOTCH = 0.07, 0.62, 0.055
CHECK = [(0.37, 0.39), (0.47, 0.49), (0.65, 0.29)]
CHECK_WIDTH = 0.075


def draw(size):
    scale = 4  # desenha maior e reduz, para suavizar as bordas
    side = size * scale

    def p(value):
        return round(value * side)

    image = Image.new('RGBA', (side, side), BLUE)
    pen = ImageDraw.Draw(image)

    # Ingresso branco com o canhoto âmbar.
    mask = Image.new('L', (side, side), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [p(LEFT), p(TOP), p(RIGHT), p(BOTTOM)], radius=p(RADIUS), fill=255
    )
    ticket = Image.new('RGBA', (side, side), WHITE)
    ImageDraw.Draw(ticket).rectangle([0, p(TEAR), side, side], fill=AMBER)
    image.paste(ticket, (0, 0), mask)

    # Entalhes dos dois lados, na altura do picote.
    for x in (LEFT, RIGHT):
        pen.ellipse(
            [p(x - NOTCH), p(TEAR - NOTCH), p(x + NOTCH), p(TEAR + NOTCH)],
            fill=BLUE,
        )

    # Picote.
    x = LEFT + NOTCH + 0.025
    while x + 0.035 <= RIGHT - NOTCH:
        pen.rectangle(
            [p(x), p(TEAR - 0.008), p(x + 0.035), p(TEAR + 0.008)], fill=BLUE
        )
        x += 0.065

    # Sinal de presença confirmada, com pontas arredondadas.
    points = [(p(a), p(b)) for a, b in CHECK]
    pen.line(points, fill=BLUE, width=p(CHECK_WIDTH), joint='curve')
    r = p(CHECK_WIDTH) // 2
    for cx, cy in points:
        pen.ellipse([cx - r, cy - r, cx + r, cy + r], fill=BLUE)

    return image.resize((size, size), Image.LANCZOS)


# O desenho fica dentro da área segura dos ícones recortáveis (80% central).
OUTPUTS = {
    'web/favicon.png': 48,
    'web/icons/Icon-192.png': 192,
    'web/icons/Icon-512.png': 512,
    'web/icons/Icon-maskable-192.png': 192,
    'web/icons/Icon-maskable-512.png': 512,
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
}

for path, size in OUTPUTS.items():
    draw(size).save(path)
    print(path, size)
