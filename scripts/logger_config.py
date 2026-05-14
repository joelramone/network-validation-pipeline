import logging
from pathlib import Path


def setup_logging(log_file: str = 'logs/network_validation.log') -> None:
    Path(log_file).parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s | %(levelname)s | %(name)s | %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(),
        ],
    )
