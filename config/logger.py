import logging
import os
from datetime import datetime
from config.settings import Config

_is_configured = False

def setup_logging() -> None:
    """
    Membuat instance logger untuk setiap module pipeline
    """
    global _is_configured
    if _is_configured:
        return
    
    # buat folder jika belum dan buat file untuk menyimpan hasil log
    os.makedirs(Config.LOG_DIR, exist_ok=True)
    log_filename = Config.LOG_DIR / f"pipeline_{datetime.now().strftime('%Y-%m-%d')}.log"

    # format log
    log_format = "%(asctime)s | %(levelname)-6s | %(name)s | %(message)s"
    date_format = "%Y-%m-%d %H:%M:%S"
    formatter = logging.Formatter(
        fmt=log_format,
        datefmt=date_format
    )

    # root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.DEBUG)

    # output log terminal
    stream_handler = logging.StreamHandler()
    stream_handler.setLevel(logging.INFO)
    stream_handler.setFormatter(formatter)

    # output log file
    file_handler = logging.FileHandler(log_filename, encoding='utf-8')
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)

    # add handlers
    root_logger.addHandler(stream_handler)
    root_logger.addHandler(file_handler)

    _is_configured = True

def get_logger(name: str) -> logging.Logger:
    """
    Dipanggil untuk setiap module untuk mendapatkan logger
    """
    setup_logging()
    return logging.getLogger(name)
