# インフラ設定変更実行手順

このドキュメントは、Clin_tejun2/02_infra_diff.md に基づく設定変更の実行手順です。Cisco Catalyst 2960 スイッチのインターフェース GigabitEthernet 0/5、0/6、0/7 に VLAN 20 を割り当てます。

## 1. 準備

- **情報取得**: 変更前に以下のコマンドを実行し、情報をバックアップ。
  - `show running-config`
  - `show vlan brief`
  - `show interface status`
  - `show interface trunk`
  - `show spanning-tree brief`
  - `show version`
- **アクセス確認**: Console または SSH でスイッチにアクセスし、enable モードに入る。
- **依存関係確認**: VLAN 20 が作成済みであることを確認。
- **メンテナンス通知**: 変更によるネットワーク中断の可能性を関係者に通知。

## 2. 変更手順

以下のコマンドを順次実行してください。エラーが発生した場合、中止してロールバックを検討。各ステップのコピペ用コマンドを参照。

1. **GigabitEthernet 0/5 の設定変更**:

   ```
   configure terminal
   interface GigabitEthernet0/5
   switchport access vlan 20
   switchport mode access
   exit
   ```

2. **GigabitEthernet 0/6 の設定変更**:

   ```
   interface GigabitEthernet0/6
   switchport access vlan 20
   switchport mode access
   exit
   ```

3. **GigabitEthernet 0/7 の設定変更**:

   ```
   interface GigabitEthernet0/7
   switchport access vlan 20
   switchport mode access
   exit
   ```

4. **変更確認**:

   ```
   end
   show vlan brief
   show interface status
   show spanning-tree brief
   show running-config
   ```

   - 変更後の running-config を取得し、事前バックアップと比較して変更内容を確認。

5. **設定保存**:
   ```
   write memory
   ```

## 3. 確認手順

変更後、以下のコマンドで設定を確認してください。

- **VLAN 確認**: `show vlan brief`
  - VLAN 20 にポート 5,6,7 が割り当てられていることを確認。
- **インターフェース確認**: `show interface GigabitEthernet0/5 status`
  - モードが access、VLAN が 20 であることを確認。
- **トランク確認**: `show interface GigabitEthernet0/5 trunk`
  - 該当ポートがトランクではないことを確認（N/A）。
- **STP 確認**: `show spanning-tree`
  - ループがないことを確認。
- **接続テスト**: 接続デバイスから VLAN 20 にアクセス可能かテスト。

## 4. ロールバック手順

問題が発生した場合、Clin_tejun2/03_infra_rollback.md を参照してロールバックを実行してください。

- 即時ロールバック: インターフェースをデフォルト設定に戻す。
- バックアップ復元: 事前バックアップから reload。

## 5. 注意点

- **実行時間**: 各手順を 1-2 分以内に完了。STP 収束を待つ。
- **監視**: 変更中は ping 監視を実施。
- **ログ**: 変更ログを記録。
- **責任者**: 変更実行者は認定資格者とする。
