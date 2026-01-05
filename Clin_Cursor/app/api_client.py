import json
import os
import requests
from pathlib import Path
from datetime import datetime

class ApiClient:
    def __init__(self, config_path: str = None):
        if config_path is None:
            # スクリプトの場所からconfig/settings.jsonを解決
            script_dir = Path(__file__).parent.parent
            self.config_path = script_dir / "config" / "settings.json"
        else:
            self.config_path = Path(config_path)
        self.settings = self._load_settings()

    def _load_settings(self):
        """設定ファイルを読み込む"""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            raise FileNotFoundError(f"設定ファイルが見つかりません: {self.config_path}")
        except json.JSONDecodeError:
            raise ValueError(f"設定ファイルの形式が正しくありません: {self.config_path}")

    def get_data(self, params: dict = None) -> dict:
        """APIからデータを取得する"""
        # モックデータを使用する場合
        if self.settings.get("use_mock_data", False):
            return self._get_mock_data(params)

        # 実際のAPIリクエスト
        try:
            response = requests.get(
                self.settings["endpoint_url"],
                headers={"Authorization": f"Bearer {self.settings['api_key']}"},
                params=params,
                timeout=self.settings["timeout"]
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            raise Exception(f"APIリクエストに失敗しました: {str(e)}")

    def _get_mock_data(self, params: dict = None) -> dict:
        """モックデータを返す"""
        mock_data = {
            "timestamp": datetime.now().isoformat(),
            "items": [
                {"id": 1, "name": "Item A", "value": 10.5, "category": "Type 1"},
                {"id": 2, "name": "Item B", "value": 20.0, "category": "Type 2"},
                {"id": 3, "name": "Item C", "value": 15.2, "category": "Type 1"},
                {"id": 4, "name": "Item D", "value": 8.7, "category": "Type 3"},
                {"id": 5, "name": "Item E", "value": 25.0, "category": "Type 2"}
            ],
            "total_count": 5,
            "status": "success"
        }
        return mock_data
