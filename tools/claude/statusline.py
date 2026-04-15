#!/usr/bin/env python3
import json, os, subprocess, sys, time

data = json.load(sys.stdin)

BRAILLE = ' ⣀⣄⣤⣦⣶⣷⣿'
R = '\033[0m'
DIM = '\033[2m'
CACHE_FILE = '/tmp/claude_usage.json'
CACHE_MAX_AGE = 60
GET_USAGE_SCRIPT = os.path.expanduser('~/dotfiles/tools/claude/get_usage.sh')

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

def fmt(label, pct):
    p = round(pct)
    return f'{DIM}{label}{R} {gradient(pct)}{braille_bar(pct)}{R} {p}%'

def get_usage_cache():
    try:
        with open(CACHE_FILE, 'r') as f:
            cache = json.load(f)
        updated = cache.get('updated', 0)
        if time.time() - updated > CACHE_MAX_AGE:
            subprocess.Popen([GET_USAGE_SCRIPT], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return cache
    except:
        subprocess.Popen([GET_USAGE_SCRIPT], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return {}

cwd = data.get('cwd', os.getcwd())
project_name = os.path.basename(cwd)
try:
    branch = subprocess.check_output(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        cwd=cwd, stderr=subprocess.DEVNULL
    ).decode().strip()
except Exception:
    branch = ''

model = data.get('model', {}).get('display_name', 'Claude')

info_parts = [f'📁 {cwd}', f'📦 {project_name}']
if branch:
    info_parts.append(f'🌿 {branch}')
info_parts.append(f'🤖 {model}')
info_line = f' {DIM}|{R} '.join(info_parts)

parts = []

ctx_data = data.get('context_window', {})
ctx = ctx_data.get('used_percentage')
if ctx is None:
    usage = ctx_data.get('current_usage', {})
    size = ctx_data.get('context_window_size', 0)
    if size > 0:
        used = usage.get('input_tokens', 0) + usage.get('cache_creation_input_tokens', 0) + usage.get('cache_read_input_tokens', 0)
        ctx = used / size * 100
if ctx is not None:
    parts.append(fmt('ctx', ctx))

usage_cache = get_usage_cache()
session = usage_cache.get('session')
if session is not None:
    parts.append(fmt('ses', session))
week = usage_cache.get('week')
if week is not None:
    parts.append(fmt('week', week))

rate_line = f' {DIM}│{R} '.join(parts)
output = info_line
if rate_line:
    output += f' {DIM}│{R} ' + rate_line
print(output, end='')
