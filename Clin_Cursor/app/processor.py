import sys
from pathlib import Path
from typing import List, Dict, Any

# 相対インポートを避けるため、パスを追加
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir))

try:
    from api_client import ApiClient
except ImportError:
    # 直接実行時のフォールバック
    import api_client
    ApiClient = api_client.ApiClient

def process_data(params: dict = None) -> Dict[str, Any]:
    """
    ApiClientを利用してデータを取得し、整形する関数

    Args:
        params: APIリクエストのパラメータ（オプション）

    Returns:
        整形されたデータ
    """
    try:
        # ApiClientのインスタンスを作成
        client = ApiClient()

        # APIからデータを取得
        raw_data = client.get_data(params)

        # データ構造の検証
        if not isinstance(raw_data, dict):
            raise ValueError("APIレスポンスが辞書形式ではありません")

        # タイムスタンプがない場合は自動生成
        from datetime import datetime
        timestamp = raw_data.get("timestamp", datetime.now().isoformat())

        # データを整形
        processed_data = {
            "summary": _create_summary(raw_data),
            "details": _extract_details(raw_data),
            "statistics": _calculate_statistics(raw_data),
            "timestamp": timestamp
        }

        return processed_data

    except Exception as e:
        raise Exception(f"データ処理中にエラーが発生しました: {str(e)}")

def _create_summary(data: dict) -> str:
    """データのサマリーを作成"""
    try:
        # itemsフィールドがある場合（リスト形式）
        items = data.get("items", [])
        if isinstance(items, list) and len(items) > 0:
            total_items = len(items)
            status = data.get("status", "unknown")
            return f"合計{total_items}件のデータを取得しました。ステータス: {status}"

        # itemsフィールドがない場合（単一オブジェクトの場合）
        elif "id" in data:
            task_id = data.get("id", "不明")
            user_id = data.get("userId", "不明")
            title = data.get("title", "タイトルなし")
            completed = data.get("completed", False)
            status_text = "完了" if completed else "未完了"
            return f"タスクID: {task_id}, ユーザーID: {user_id}, タイトル: {title}, ステータス: {status_text}"

        else:
            return "データ形式が不正です。"
    except Exception as e:
        return f"サマリー作成中にエラーが発生しました: {str(e)}"

def _extract_details(data: dict) -> List[Dict[str, Any]]:
    """詳細データを抽出"""
    try:
        # itemsフィールドがある場合（リスト形式）
        items = data.get("items", [])
        if isinstance(items, list) and len(items) > 0:
            # 各アイテムが辞書であることを確認
            validated_items = []
            for item in items:
                if isinstance(item, dict):
                    validated_items.append(item)
                else:
                    print(f"警告: 無効なアイテムをスキップしました: {item}")
            return validated_items

        # itemsフィールドがない場合（単一オブジェクトの場合）
        elif "id" in data:
            # 単一のタスクオブジェクトをリスト形式に変換
            return [data]

        else:
            print("警告: 適切なデータ構造が見つかりません")
            return []

    except Exception as e:
        print(f"詳細データ抽出中にエラーが発生しました: {str(e)}")
        return []

def _calculate_statistics(data: dict) -> Dict[str, Any]:
    """統計情報を計算"""
    try:
        # itemsフィールドがある場合（リスト形式）
        items = data.get("items", [])
        if isinstance(items, list) and len(items) > 0:
            total_count = len(items)
            if total_count == 0:
                return {"total_count": 0, "average_value": 0, "data_points": 0}

            # 数値フィールドがある場合の平均を計算
            numeric_values = []
            for item in items:
                if isinstance(item, dict):
                    value = item.get("value")
                    if isinstance(value, (int, float)) and value is not None:
                        numeric_values.append(float(value))

            avg_value = sum(numeric_values) / len(numeric_values) if numeric_values else 0

            return {
                "total_count": total_count,
                "average_value": round(avg_value, 2),
                "data_points": len(numeric_values)
            }

        # itemsフィールドがない場合（単一オブジェクトの場合）
        elif "id" in data:
            completed = data.get("completed", False)
            user_id = data.get("userId", 0)
            task_id = data.get("id", 0)

            return {
                "total_count": 1,
                "completed": completed,
                "user_id": user_id,
                "task_id": task_id,
                "completion_rate": 100 if completed else 0
            }

        else:
            return {"total_count": 0, "completed": False, "user_id": 0, "task_id": 0, "completion_rate": 0}

    except Exception as e:
        print(f"統計計算中にエラーが発生しました: {str(e)}")
        return {"total_count": 0, "completed": False, "user_id": 0, "task_id": 0, "completion_rate": 0}
