from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Literal

from pydantic import BaseModel, Field


class Target(BaseModel):
    name: str
    host: str
    protocol: Literal['dns', 'tcp', 'http', 'https', 'tls', 'ping', 'traceroute']
    port: int | None = None
    path: str | None = None


class RuntimeConfig(BaseModel):
    targets_file: str
    namespace: str
    pod: str
    enable_ping: bool = True
    enable_traceroute: bool = False


class CheckResult(BaseModel):
    name: str
    check_type: str
    target: str
    status: Literal['PASS', 'FAIL']
    details: str


class ValidationReport(BaseModel):
    generated_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    context: dict[str, Any]
    checks: list[CheckResult]
