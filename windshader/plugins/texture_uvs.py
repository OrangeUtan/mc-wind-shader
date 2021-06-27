from logging import getLogger
import csv
from pathlib import Path
from beet import Context
from beet.core.cache import Cache

from windshader import utils

logger = getLogger(__name__)

def beet_default(ctx: Context):
	cache = ctx.cache["texture_atlas"]

	config = ctx.meta["texture_atlas"]
	minecraft_version = config["minecraft_version"]
	atlas_variant = config["variant"]

	config["uvs"] = get_texture_category_uvs(cache, minecraft_version, atlas_variant, "block")



def get_texture_category_uvs(
	cache: Cache,
	minecraft_version: str,
	atlas_category: str,
	texture_category: str,
):
	uvs_root = utils.get_uvs_root(cache, minecraft_version)
	uvs_file = Path(uvs_root / atlas_category, texture_category + ".csv")

	uvs: dict[str, dict] = {}
	with uvs_file.open("r") as f:
		for row in csv.reader(f, dialect="excel", delimiter=";"):
			uvs[f"{texture_category}/{row[0]}"] = {
				"u" : int(row[1]),
				"v": int(row[2])
			}

	return uvs