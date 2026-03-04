from pathlib import Path
from typing import Annotated, Optional

import typer
from google import genai
from google.genai import types

app = typer.Typer(help="Gemini APIを使用して画像を生成します")


def load_binary_file(file_path: Path) -> bytes:
    """バイナリデータを読み込んで返す"""
    with open(file_path, "rb") as f:
        return f.read()


def save_binary_file(file_path: Path, data: bytes) -> None:
    """バイナリデータをファイルに保存してログ出力"""
    file_path.parent.mkdir(parents=True, exist_ok=True)
    with open(file_path, "wb") as f:
        f.write(data)
    typer.echo(f"ファイルを保存しました: {file_path}")


@app.callback(invoke_without_command=True)
def generate(
    prompt: Annotated[str, typer.Argument(help="画像生成のプロンプト")],
    output: Annotated[Path, typer.Argument(help="出力画像のパス")],
    reference_image: Annotated[
        Optional[Path], typer.Option("--reference-image", help="参考画像のパス (省略可)")
    ] = None,
    model: Annotated[
        str, typer.Option(help="使用するモデル名")
    ] = "gemini-3-pro-image-preview",
    temperature: Annotated[float, typer.Option(help="生成の温度パラメータ")] = 0.2,
    image_size: Annotated[str, typer.Option("--image-size", help="画像サイズ")] = "1K",
    aspect_ratio: Annotated[
        str, typer.Option("--aspect-ratio", help="アスペクト比")
    ] = "1:1",
) -> None:
    if output.exists():
        typer.echo(f"既に存在するためスキップします: {output}")
        return

    client = genai.Client(vertexai=True)
    generate_content_config = types.GenerateContentConfig(
        response_modalities=["IMAGE", "TEXT"],
        temperature=temperature,
        image_config=types.ImageConfig(image_size=image_size, aspect_ratio=aspect_ratio),
        thinking_config=types.ThinkingConfig(thinking_budget=0),
    )

    parts = [types.Part.from_text(text=prompt)]

    if reference_image:
        if not reference_image.exists():
            typer.echo(f"参考画像が見つかりません: {reference_image}", err=True)
            raise typer.Exit(code=1)
        parts.append(
            types.Part.from_bytes(
                data=load_binary_file(reference_image), mime_type="image/png"
            )
        )

    contents = types.Content(role="user", parts=parts)

    try:
        typer.echo("画像の生成を開始します...")
        response = client.models.generate_content(
            model=model,
            contents=contents,
            config=generate_content_config,
        )

        if not response.candidates:
            typer.echo("候補が含まれていません。", err=True)
            raise typer.Exit(code=1)

        saved = False
        for candidate in response.candidates:
            if not candidate.content:
                continue
            for part in candidate.content.parts or []:
                if part.inline_data and part.inline_data.data:
                    save_binary_file(output, part.inline_data.data)
                    saved = True
                    break
            if saved:
                break

        if not saved:
            typer.echo("画像が生成されませんでした。", err=True)
            raise typer.Exit(code=1)

    except typer.Exit:
        raise
    except Exception as e:
        typer.echo(f"エラーが発生しました: {e}", err=True)
        raise typer.Exit(code=1)


if __name__ == "__main__":
    app()
