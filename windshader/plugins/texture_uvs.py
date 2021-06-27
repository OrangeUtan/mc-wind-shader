from logging import getLogger
import csv
from pathlib import Path
from beet import Context
from zipfile import ZipFile
from beet.core.cache import Cache

logger = getLogger(__name__)

def beet_default(ctx: Context):
	cache = ctx.cache["texture_atlas"]

	config = ctx.meta["texture_atlas"]
	minecraft_version = config["minecraft_version"]
	atlas_variant = config["variant"]

	config["uvs"] = get_texture_category_uvs(cache, minecraft_version, atlas_variant, "block")

def get_uvs_root(cache: Cache, minecraft_version: str):
	uvs_zip_path = cache.download(f"https://github.com/OrangeUtan/mc-atlas-uv-resolver/releases/download/res{minecraft_version}/uvs.zip")
	extracted_uvs_path = cache.get_path(f"uvs")

	if cache.has_changed(uvs_zip_path):
		with ZipFile(uvs_zip_path, "r") as zip:
			zip.extractall(extracted_uvs_path)

	return extracted_uvs_path

def get_texture_category_uvs(
	cache: Cache,
	minecraft_version: str,
	atlas_category: str,
	texture_category: str,
):
	uvs_root = get_uvs_root(cache, minecraft_version)
	uvs_file = Path(uvs_root / atlas_category, texture_category + ".csv")

	uvs: dict[str, dict] = {}
	with uvs_file.open("r") as f:
		for row in csv.reader(f, dialect="excel", delimiter=";"):
			uvs[f"{texture_category}/{row[0]}"] = {
				"u" : int(row[1]),
				"v": int(row[2])
			}

	return uvs