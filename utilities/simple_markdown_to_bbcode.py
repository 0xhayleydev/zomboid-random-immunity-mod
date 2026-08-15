import re
from typing import Callable

LINE_PREFIX = "description="

class RegexReplace:
    def __init__(self, match: str, result: str, func: Callable[[str], str]|None = None) -> None:
        self._match = match
        self._result = result
        self._func = func

    def run_on_text(self, text: str) -> str|None:
        match = re.match(self._match, text)

        if match == None:
            return None

        groups = match.groups()
        if self._func is not None:
            groups = [self._func(g) for g in groups]
        return self._result.format(*groups)

def convert_image_to_github_url(image: str) -> str:
    if not image.startswith("images"):
        return image

    return f"https://raw.githubusercontent.com/0xhayleydev/zomboid-random-immunity-mod/refs/heads/main/{image}"

replacements = [
    RegexReplace(r"^###(.*)$", "[h3]{0}[/h3]", str.strip),
    RegexReplace(r"^##(.*)$", "[h2]{0}[/h2]", str.strip),
    RegexReplace(r"^#(.*)$", "[h1]{0}[/h1]", str.strip),
    RegexReplace(r"^\[!\[.*\]\((.*)\)\]\((.*)\)$", "[url={1}][img]{0}[/img][/url]", convert_image_to_github_url),
    RegexReplace(r"^.*\!\[.*\]\((.*)\).*$", "[img]{0}[/img]", convert_image_to_github_url),
    RegexReplace(r"^(?!:!.*)\[(.*)\]\((.*)\)$", "[url={1}]{0}[/url]"),
]

def recurse_replacement(text: str) -> str:
    for r in replacements:
        result = r.run_on_text(text)

        if result is None:
            continue

        return result

    return text


lines: list[str] = []
with open(r"README.md", "r") as readme:
    readme_lines = readme.read().splitlines()
    for line in readme_lines:
        lines.append(f"{LINE_PREFIX}{recurse_replacement(line)}")

with open(r"README.bbc", "w+") as readme:
    readme.write("\n".join(lines))
