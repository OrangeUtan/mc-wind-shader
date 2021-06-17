import PIL.Image as Image
import typer
from pathlib import Path
import cv2
from prettytable import PrettyTable

app = typer.Typer()


def img_from_bin_file(path: Path):
	with path.open("rb") as f:
		data = f.read()
		return Image.frombytes("RGBA", (1024, 1024), data)

def get_texture_location_in_atlas(atlas, texture):
	result = cv2.matchTemplate(atlas, texture, cv2.TM_SQDIFF_NORMED)
	_, _, loc, _ = cv2.minMaxLoc(result)
	return loc


@app.command(name="atlas")
def atlas_from_bytes(
		source: Path = typer.Argument(..., exists=True, readable=True, dir_okay=False),
		dest: Path = typer.Argument(Path("atlas.png"), writable=True, dir_okay=False)
	):
	img = img_from_bin_file(source)
	img.save(dest)

@app.command(name="find")
def find_textures_in_atlas(
		atlas: Path = typer.Argument(..., exists=True, readable=True, dir_okay=False)
	):

	table = PrettyTable(["texture", "x", "y"])
	table.align["texture"] = "l"

	atlas = cv2.imread(str(atlas))
	for path in Path("tools/textures").iterdir():
		texture = cv2.imread(str(path))
		x, y = get_texture_location_in_atlas(atlas, texture)
		table.add_row([path, int(x/16), int(y/16)])

	print(table)

app()