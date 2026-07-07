from pathlib import Path
import requests
from config.logger import get_logger

logger = get_logger(__name__)

class DataExtractor:
    """
    Extract taxi trips and zones data from external sources
    """
    def __init__(
        self,
        taxi_trips_url: str,
        taxi_file: Path,
        taxi_zones_url: str,
        zones_file: Path
        ) -> None:
        self.taxi_trips_url = taxi_trips_url
        self.taxi_file = taxi_file
        self.taxi_zones_url = taxi_zones_url
        self.zones_file = zones_file

    def run(self) -> None:
        """
        Execute extraction process
        """
        logger.info("Starting extraction process")

        self._download_file(
            url=self.taxi_trips_url,
            file_path=self.taxi_file
        )

        self._download_file(
            url=self.taxi_zones_url,
            file_path=self.zones_file
        )

        logger.info("Extraction completed successfully")
    
    def _download_file(
        self,
        url: str,
        file_path: Path,
        timeout: tuple[float, float] = (10.0, 30.0),
        chunk_size: int = 1024 * 1024 * 8
        ) -> None:
        """
        Download file if it does not already exist
        """
        if file_path.exists():
            logger.info("File already exists: %s", file_path)
            return
        
        self._ensure_parent_directory(file_path)
        self._stream_response_to_disk(
            url=url,
            file_path=file_path,
            timeout=timeout,
            chunk_size=chunk_size
        )

    def _stream_response_to_disk(
        self,
        url: str,
        file_path: Path,
        timeout: tuple[float, float],  
        chunk_size: int
    ) -> None:
        """
        Stream the HTTP response body to disk in chunks safely and atomically.
        """
        logger.info("Downloading dataset from url: %s", url)

        temporary_file = file_path.with_suffix(f"{file_path.suffix}.part")
        download_success = False

        try:
            with requests.get(url=url, stream=True, timeout=timeout) as response:
                response.raise_for_status()

                with temporary_file.open("wb") as output_file:
                    for chunk in response.iter_content(chunk_size=chunk_size):
                        if chunk:
                            output_file.write(chunk)
            
            if not temporary_file.exists() or temporary_file.stat().st_size == 0:
                raise ValueError(f"Downloaded file is empty: {file_path.name}")
            
            temporary_file.replace(file_path)
            download_success = True
            logger.info("File successfully saved to: %s", file_path)

        except requests.exceptions.Timeout as timeout_err:
            logger.error("Request Timed out: %s", timeout_err)
            raise
        except requests.exceptions.HTTPError as http_err:
            logger.error("HTTP error: %s", http_err)
            raise
        except requests.exceptions.RequestException as req_err:
            logger.error("Request failed: %s", req_err)
            raise
        except Exception as err:
            logger.error("Unexpected error during download: %s", err)
            raise
        finally:
            if not download_success:
                try:
                    temporary_file.unlink(missing_ok=True)
                    logger.debug("Cleaned up temporary file: %s", temporary_file)
                except Exception as cleanup_err:
                    logger.warning("Failed to clean up temporary file: %s", cleanup_err)

    def _ensure_parent_directory(self, file_path: Path) -> None:
        """
        Create parent directory if it doesn't exist
        """
        file_path.parent.mkdir(parents=True, exist_ok=True)