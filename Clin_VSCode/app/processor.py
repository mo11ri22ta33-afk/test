from .api_client import ApiClient

def process_data():
    client = ApiClient()
    data = client.get_data()
    # データを整形: 例として、データを辞書にまとめ、統計を追加
    processed = {
        'raw_data': data,
        'items_count': len(data) if isinstance(data, list) else 1,
        'summary': 'Processed data from API'
    }
    return processed
