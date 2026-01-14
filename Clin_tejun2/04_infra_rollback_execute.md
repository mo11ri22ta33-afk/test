# インフラ設定ロールバック実行手順

このドキュメントは、Clin_tejun2/03_infra_rollback.md に基づくロールバック実行手順です。Cisco Catalyst 2960 スイッチのインターフェース GigabitEthernet 0/5、0/6、0/7 をデフォルト設定に戻します。

## 1. 準備

- **情報取得**: ロールバック前に以下のコマンドを実行し、情報をバックアップ。
  - `show running-config`
  - `show vlan brief`
  - `show interface status`
  - `show interface trunk`
  - `show spanning-tree brief`
  - `show version`
- **アクセス確認**: Console または SSH でスイッチにアクセスし、enable モードに入る。
- **依存関係確認**: 他のインターフェースが VLAN 20 を使用中であることを確認。
- **メンテナンス通知**: ロールバックによるネットワーク中断の可能性を関係者に通知。

## 2. ロールバック手順

以下のコマンドを順次実行してください。エラーが発生した場合、中止してさらなる対応を検討。各ステップのコピペ用コマンドを参照。

1. **インターフェース GigabitEthernet 0/5 の復元**:

   ```
   configure terminal
   interface GigabitEthernet0/5
   no switchport access vlan 20
   no switchport mode access
   exit
   ```

2. **インターフェース GigabitEthernet 0/6 の復元**:

   ```
   interface GigabitEthernet0/6
   no switchport access vlan 20
   no switchport mode access
   exit
   ```

3. **インターフェース GigabitEthernet 0/7 の復元**:

   ```
   interface GigabitEthernet0/7
   no switchport access vlan 20
   no switchport mode access
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

ロールバック後、以下のコマンドで設定を確認してください。

- **VLAN 確認**: `show vlan brief`
  - VLAN 20 からポート 5,6,7 が削除されていることを確認。
- **インターフェース確認**: `show interface GigabitEthernet0/5 status`
  - モードがデフォルト（未設定）であることを確認。
- **トランク確認**: `show interface GigabitEthernet0/5 trunk`
  - 該当ポートがトランクではないことを確認（N/A）。
- **STP 確認**: `show spanning-tree`
  - ループがないことを確認。
- **接続テスト**: 接続デバイスがデフォルト VLAN に戻っているかテスト。

## 4. さらなるロールバック手順

問題が解決しない場合、事前バックアップから reload を検討。

- バックアップ復元: `reload` を実行し、事前設定に戻す。

## 5. 注意点

- **実行時間**: 各手順を 1-2 分以内に完了。STP 収束を待つ。
- **監視**: 変更中は ping 監視を実施。
- **ログ**: 変更ログを記録。
- **責任者**: 変更実行者は認定資格者とする。
