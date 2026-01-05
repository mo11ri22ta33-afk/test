import sys
from pathlib import Path
from typing import Dict, Any

# 相対インポートを避けるため、パスを追加
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir))

try:
    from processor import process_data
except ImportError:
    # 直接実行時のフォールバック
    import processor
    process_data = processor.process_data

def generate_markdown_report(params: dict = None) -> str:
    """
    process_data()の結果をMarkdown形式でレポートとして出力

    Args:
        params: process_dataに渡すパラメータ（オプション）

    Returns:
        Markdown形式のレポート文字列
    """
    try:
        # データを処理
        data = process_data(params)

        # Markdownレポートを生成
        report_lines = []
        report_lines.append("# データレポート\n")
        report_lines.append(f"**タイムスタンプ:** {data.get('timestamp', 'N/A')}\n")
        report_lines.append("---\n")

        # サマリーセクション
        report_lines.append("## サマリー\n")
        summary = data.get('summary', 'サマリー情報なし')
        report_lines.append(f"{summary}\n")
        report_lines.append("---\n")

        # 統計情報セクション
        report_lines.append("## 統計情報\n")
        stats = data.get('statistics', {})
        if stats:
            report_lines.append("| 項目 | 値 |")
            report_lines.append("|------|-----|")

            # 共通の項目
            if 'total_count' in stats:
                report_lines.append(f"| 総件数 | {stats.get('total_count', 0)} |")

            # タスク固有の項目（単一タスクの場合）
            if 'completed' in stats:
                completed_text = "完了" if stats.get('completed', False) else "未完了"
                report_lines.append(f"| 完了状態 | {completed_text} |")
                report_lines.append(f"| 完了率 | {stats.get('completion_rate', 0)}% |")

            if 'user_id' in stats:
                report_lines.append(f"| ユーザーID | {stats.get('user_id', 0)} |")

            if 'task_id' in stats:
                report_lines.append(f"| タスクID | {stats.get('task_id', 0)} |")

            # 数値データの統計（リスト形式の場合）
            if 'average_value' in stats:
                report_lines.append(f"| 平均値 | {stats.get('average_value', 0)} |")

            if 'data_points' in stats:
                report_lines.append(f"| データポイント数 | {stats.get('data_points', 0)} |")

            report_lines.append("")
        else:
            report_lines.append("統計情報がありません。\n")

        # 詳細データセクション
        report_lines.append("## 詳細データ\n")
        details = data.get('details', [])

        if details and len(details) > 0:
            # データがある場合の処理
            if isinstance(details[0], dict):
                # 最初のアイテムからキーを取得してヘッダーを作成
                headers = list(details[0].keys())
                report_lines.append("| " + " | ".join(headers) + " |")
                report_lines.append("| " + " | ".join(["---"] * len(headers)) + " |")

                # 各詳細データをテーブル行として追加
                for item in details:
                    if isinstance(item, dict):
                        row_values = [str(item.get(header, "")) for header in headers]
                        report_lines.append("| " + " | ".join(row_values) + " |")
                    else:
                        # 辞書でないアイテムの処理
                        report_lines.append(f"| 無効なデータ | {str(item)} |")
                report_lines.append("")
            else:
                # 最初のアイテムが辞書でない場合
                report_lines.append("詳細データの形式が不正です。\n")
                for i, item in enumerate(details):
                    report_lines.append(f"{i+1}. {str(item)}\n")
        else:
            report_lines.append("詳細データがありません。\n")

        return "\n".join(report_lines)

    except Exception as e:
        error_report = "# エラーレポート\n\n"
        error_report += f"レポート生成中にエラーが発生しました: {str(e)}\n"
        import traceback
        error_report += f"```\n{traceback.format_exc()}\n```\n"
        return error_report

def save_report_to_file(report_content: str, filename: str = "report.md"):
    """
    レポートをファイルに保存

    Args:
        report_content: 保存するレポート内容
        filename: 保存するファイル名
    """
    try:
        # スクリプトの場所を基準にファイルパスを解決
        script_dir = Path(__file__).parent.parent
        file_path = script_dir / filename

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(report_content)
        print(f"レポートを {file_path} に保存しました。")
    except Exception as e:
        print(f"レポートの保存に失敗しました: {str(e)}")
        import traceback
        print(traceback.format_exc())

if __name__ == "__main__":
    # テスト実行
    try:
        report = generate_markdown_report()
        print("=== 生成されたレポート ===")
        print(report)
        print("=== レポート生成完了 ===")
        save_report_to_file(report)
    except Exception as e:
        print(f"実行中にエラーが発生しました: {str(e)}")
        import traceback
        print(traceback.format_exc())
