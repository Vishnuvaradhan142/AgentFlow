"""
Application bootstrap helpers for the AgentFlow viewer.
"""

from __future__ import annotations

from pathlib import Path
from typing import Optional

from flask import Flask

from .routes import register_routes


def create_app(root: Path) -> Flask:
    """
    Build the Flask application configured to serve a specific artifact directory.
    """

    package_root = Path(__file__).parent
    app = Flask(
        __name__,
        static_folder=str(package_root / "static"),
        template_folder=str(package_root / "templates"),
    )
    register_routes(app, root)
    return app


def run_viewer(*, directory: Path, host: str, port: int) -> None:
    """
    Launch the viewer web server.
    """

    app = create_app(directory)
    app.run(host=host, port=port, debug=False, use_reloader=False)
