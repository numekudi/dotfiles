import typer

from src.cmd import image_generation

app = typer.Typer()

app.add_typer(image_generation.app, name="image-generation")

if __name__ == "__main__":
    app()
