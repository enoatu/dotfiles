import sys

def is_multibyte(char):
    return ord(char) > 127

raw_input_text = sys.stdin.read()
input_lines = raw_input_text.split('\n')
formatted_lines = []

for line_index, line in enumerate(input_lines):
    if line_index > 0:
        line = line.lstrip()

    if line_index == len(input_lines) - 1:
        formatted_lines.append(line.rstrip())
        break

    next_line = input_lines[line_index+1].lstrip()
    has_padding = len(line) > 0 and line[-1] in (' ', '\t')
    stripped_line = line.rstrip()

    if not stripped_line:
        formatted_lines.append('\n')
        continue

    if not next_line:
        formatted_lines.append(stripped_line + '\n')
        continue

    last_char = stripped_line[-1]
    next_char = next_line[0]

    if is_multibyte(last_char) or is_multibyte(next_char) or not has_padding:
        formatted_lines.append(stripped_line)
    else:
        formatted_lines.append(stripped_line + ' ')

joined_output_text = "".join(formatted_lines)
print(joined_output_text, end='')
