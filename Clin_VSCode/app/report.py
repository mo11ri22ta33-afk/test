from .processor import process_data

def generate_report():
    data = process_data()

    # Markdown形式でレポートを生成
    report = f"""# API Data Report

## Summary
{data['summary']}

## Items Count
{data['items_count']}

## Raw Data
```json
{data['raw_data']}
```

Generated on {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

    # レポートをコンソールに出力
    print(report)

    # レポートをファイルに保存
    with open('report.md', 'w', encoding='utf-8') as f:
        f.write(report)

if __name__ == "__main__":
    generate_report()
