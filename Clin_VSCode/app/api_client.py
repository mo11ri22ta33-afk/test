import json
import os
import requests

class ApiClient:
    def __init__(self):
        settings_path = os.path.join(os.path.dirname(__file__), '..', 'config', 'settings.json')
        with open(settings_path, 'r') as f:
            self.settings = json.load(f)

    def get_data(self):
        headers = {
            'Authorization': f"Bearer {self.settings['api_key']}"
        }
        response = requests.get(self.settings['endpoint_url'], headers=headers, timeout=self.settings['timeout'])
        response.raise_for_status()  # エラーチェック
        return response.json()
