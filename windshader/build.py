from pathlib import Path
import typer
import beet

from windshader import utils

app = typer.Typer()

@app.command()
def cmd_main(
	base_config: Path = typer.Argument(..., exists=True, dir_okay=False)
):
	config = beet.load_config(base_config)
	minecraft_version = config.meta["texture_atlas"]["minecraft_version"]
	cache = beet.Cache(".beet_cache/texture_atlas")

	for atlas_variant in map(lambda x: x.name, utils.get_uvs_root(cache, minecraft_version).iterdir()):
		config.meta["texture_atlas"]["variant"] = atlas_variant
		config.meta["project_variant"] = atlas_variant
		with beet.run_beet(config) as ctx:
			pass

app()