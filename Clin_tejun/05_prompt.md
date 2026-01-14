# 次回依頼用プロンプトテンプレート

## 概要

Cisco Catalyst 2960 スイッチのインフラ設定変更に関する一連のドキュメントを作成します。ベース構成、変更差分、実行手順、ロールバック差分、ロールバック実行手順の 5 つのファイルを生成します。

### 共通要件

- **対象インフラ**: Cisco Catalyst 2960 シリーズスイッチ
- **出力形式**: Markdown 形式、各ファイルに指定されたセクションを含む
- **言語**: 日本語

### ベース構成作成プロンプト

あなたは IT インフラ構築・運用の専門家です。このファイルは Clin_tejun/01_infra_base.md です。ここでは「設定変更前のインフラ構成モデル」を生成します。

以下の要件に基づき、設定変更前のインフラ構成を再現性のあるテキストモデルとして作成してください。

【要件】

- 対象インフラ：Catalyst 2960
- 想定規模：インターフェースへの Vlan 設定
- 現在の設定：必要に応じて初期設定を生成してよい
- 出力形式：設定ファイル、CLI show 結果、構成図テキストなど

【出力フォーマット】

# 1. システム概要

# 2. 設定ファイル（コードブロックで）

# 3. 運用上の前提条件

# 4. 想定される制約

### 設定変更差分作成プロンプト

あなたは IT インフラの設定変更差分を正確に抽出する専門家です。このファイルは Clin_tejun/02_infra_diff.md です。ここでは「設定変更前の設定」と「変更後の要件」から差分を生成します。

【設定変更前】
[設定変更前の設定をここに記載]

【変更後にしたい内容】
[変更要件をここに記載]

【出力フォーマット】

# 1. 変更点の要約

# 2. 変更対象ファイル / コマンド

# 3. 差分（Before / After）

# 4. 注意点（依存関係・影響範囲）

### 設定変更実行手順作成プロンプト

あなたは IT インフラの設定変更実行手順を作成する専門家です。このファイルは Clin_tejun/02_infra_execute.md です。ここでは「変更差分」に基づく実行手順を生成します。

【変更差分】
[02_infra_diff.md の内容をここに記載]

【出力フォーマット】

# 1. 準備

# 2. 変更手順

# 3. 確認手順

# 4. ロールバック手順

# 5. 注意点

【追加要件】

- コマンドはコピペしやすい一行ごと形式
- 事前情報取得は show running-config, show vlan brief, show interface status, show interface trunk, show spanning-tree brief, show version
- 変更確認で show running-config を取得し、事前比較
- write memory は確認後別手順

### ロールバック差分作成プロンプト

あなたは IT インフラのロールバック差分を正確に抽出する専門家です。このファイルは Clin_tejun/03_infra_rollback.md です。ここでは「設定変更後の設定」と「変更前の設定」からロールバック差分を生成します。

【設定変更後】
[変更後の設定をここに記載]

【変更前に戻す内容】
[ロールバック要件をここに記載]

【出力フォーマット】

# 1. ロールバック概要

# 2. ロールバック対象ファイル / コマンド

# 3. 差分（変更後 / ロールバック後）

# 4. 注意点（依存関係・影響範囲）

### ロールバック実行手順作成プロンプト

あなたは IT インフラのロールバック実行手順を作成する専門家です。このファイルは Clin_tejun/04_infra_rollback_execute.md です。ここでは「ロールバック差分」に基づく実行手順を生成します。

【ロールバック差分】
[03_infra_rollback.md の内容をここに記載]

【出力フォーマット】

# 1. 準備

# 2. ロールバック手順

# 3. 確認手順

# 4. さらなるロールバック手順

# 5. 注意点

【追加要件】

- コマンドはコピペしやすい一行ごと形式
- 事前情報取得は show running-config, show vlan brief, show interface status, show interface trunk, show spanning-tree brief, show version
- 変更確認で show running-config を取得し、事前比較
- write memory は確認後別手順

## 使用例

以下の具体例に基づき、ファイルを生成してください。

### 設定変更前

```
interface Vlan1
 no ip address
 shutdown
!
vlan 10
 name Mgmt
!
vlan 20
 name Data
!
interface GigabitEthernet0/1
 switchport access vlan 10
 switchport mode access
!
interface GigabitEthernet0/2
 switchport access vlan 10
 switchport mode access
!
interface GigabitEthernet0/3
 switchport access vlan 20
 switchport mode access
!
interface GigabitEthernet0/5
 shutdown
!
interface GigabitEthernet0/6
 shutdown
!
interface GigabitEthernet0/7
 shutdown
!
interface GigabitEthernet0/8
 shutdown
!
interface GigabitEthernet0/9
 shutdown
!
interface GigabitEthernet0/10
 shutdown
!
interface GigabitEthernet0/11
 shutdown
!
interface GigabitEthernet0/12
 shutdown
```

### 変更後にしたい内容

- GigabitEthernet 0/1, 0/2, 0/3 に新しいサービス用 VLAN 500 を追加
- VLAN 500 は新規作成、インターフェースをトランクモードに変更

### 出力フォーマット

各ファイルに指定されたセクション（# 1. XXX, # 2. XXX など）を厳守。

### 追加要件

- コマンドはコピペしやすい一行ごと形式
- 事前情報取得は show running-config, show vlan brief, show interface status, show interface trunk, show spanning-tree brief, show version
- 変更確認で show running-config を取得し、事前比較
- write memory は確認後別手順
- ロールバックはインターフェース復元後 VLAN 削除

## 最終出力

Clin_tejun/01_infra_base.md から 04_infra_rollback_execute.md までを作成し、GitHub にコミット・プッシュしてください。
