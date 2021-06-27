from beet.core.cache import Cache
from zipfile import ZipFile

def get_uvs_root(cache: Cache, minecraft_version: str):
	uvs_zip_path = cache.download(f"https://github.com/OrangeUtan/mc-atlas-uv-resolver/releases/download/res{minecraft_version}/uvs.zip")
	extracted_uvs_path = cache.get_path(f"uvs")

	if cache.has_changed(uvs_zip_path):
		with ZipFile(uvs_zip_path, "r") as zip:
			zip.extractall(extracted_uvs_path)

	return extracted_uvs_path