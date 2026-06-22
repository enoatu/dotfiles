#!/usr/bin/env python3
import json, os, subprocess, sys
from datetime import datetime

data = json.load(sys.stdin)

BRAILLE = ' ⣀⣄⣤⣦⣶⣷⣿'
R = '\033[0m'
DIM = '\033[2m'

def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f'\033[38;2;{r};200;80m'
    else:
        g = int(200 - (pct - 50) * 4)
        return f'\033[38;2;255;{max(g, 0)};60m'

def braille_bar(pct, width=8):
    pct = min(max(pct, 0), 100)
    level = pct / 100
    bar = ''
    for i in range(width):
        seg_start = i / width
        seg_end = (i + 1) / width
        if level >= seg_end:
            bar += BRAILLE[7]
        elif level <= seg_start:
            bar += BRAILLE[0]
        else:
            frac = (level - seg_start) / (seg_end - seg_start)
            bar += BRAILLE[min(int(frac * 7), 7)]
    return bar

def reset_label(resets_at):
    if resets_at is None:
        return ''
    reset_dt = datetime.fromtimestamp(resets_at)
    if reset_dt.date() == datetime.now().date():
        text = reset_dt.strftime('%H:%M')
    else:
        text = reset_dt.strftime('%Y-%m-%d %H:%M')
    return f' (～{text})'

def fmt(label, pct, resets_at=None):
    p = round(pct)
    return f'{label}{R} {gradient(pct)}{braille_bar(pct)}{R} {p}%{reset_label(resets_at)}'

cwd = data.get('cwd', os.getcwd())
project_name = os.path.basename(cwd)
try:
    branch = subprocess.check_output(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        cwd=cwd, stderr=subprocess.DEVNULL
    ).decode().strip()
except (subprocess.CalledProcessError, FileNotFoundError):
    branch = ''

model = data.get('model', {}).get('display_name', 'Claude')

info_parts = [f'📁 {cwd}', f'📦 {project_name}']
if branch:
    info_parts.append(f'🌿 {branch}')
info_parts.append(f'🤖 {model}')
info_line = f' | '.join(info_parts)

parts = []

ctx = data.get('context_window', {}).get('used_percentage')
if ctx is not None:
    parts.append(fmt('CTX', ctx))

rate_limits = data.get('rate_limits', {})
for label, key in (('5H', 'five_hour'), ('7D', 'seven_day')):
    rl = rate_limits.get(key, {})
    if rl.get('used_percentage') is not None:
        parts.append(fmt(label, rl['used_percentage'], rl.get('resets_at')))

rate_line = f' | '.join(parts)
output = info_line
if rate_line:
    output += f'\n' + rate_line
print(output, end='')
