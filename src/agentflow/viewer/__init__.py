"""
AgentFlow viewer package.

Expose ``run_viewer`` so the CLI can launch the Flask web UI.
"""

from .server import run_viewer

__all__ = ["run_viewer"]
