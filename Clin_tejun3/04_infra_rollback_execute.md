# インフラ設定ロールバック実行手順

このドキュメントは、Clin_tejun3/03_infra_rollback.md に基づくロールバック実行手順です。Cisco Catalyst 2960 スイッチの EtherChannel を解除し、GigabitEthernet 0/23、0/24 を個別 Trunk ポートに戻します。

## 1. 準備

- **情報取得**: ロールバック前に以下のコマンドを実行し、情報をバックアップ。
  - `show running-config`
  - `show vlan brief`
  - `show interface status`
  - `show interface trunk`
  - `show spanning-tree brief`
  - `show version`
- **アクセス確認**: Console または SSH でスイッチにアクセスし、enable モードに入る。
- **依存関係確認**: 対向スイッチの EtherChannel も解除する準備。
- **メンテナンス通知**: ロールバックによるネットワーク中断の可能性を関係者に通知。

## 2. ロールバック手順

以下のコマンドを順次実行してください。エラーが発生した場合、中止してさらなる対応を検討。各ステップのコピペ用コマンドを参照。

1. **GigabitEthernet 0/23 のチャネル解除**:

   ```
   configure terminal
   interface GigabitEthernet0/23
   no channel-group 10 mode active
   exit
   ```

2. **GigabitEthernet 0/24 のチャネル解除**:

   ```
   interface GigabitEthernet0/24
   no channel-group 10 mode active
   exit
   ```

3. **Port-channel10 削除**:

   ```
   no interface Port-channel10
   ```

4. **変更確認**:

   ```
   end
   show etherchannel summary
   show interface trunk
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

- **EtherChannel 確認**: `show etherchannel summary`
  - Port-channel10 が削除されていることを確認。
- **インターフェース確認**: `show interface GigabitEthernet0/23 status`
  - ポートが個別 (I) 状態であることを確認。
- **トランク確認**: `show interface GigabitEthernet0/23 trunk`
  - Trunk 設定が維持されていることを確認。
- **STP 確認**: `show spanning-tree`
  - ループがないことを確認。
- **接続テスト**: 対向スイッチとの接続が維持されているかテスト。

## 4. さらなるロールバック手順

問題が解決しない場合、事前バックアップから reload を検討。

- バックアップ復元: `reload` を実行し、事前設定に戻す。

## 5. 注意点

- **実行時間**: 各手順を 1-2 分以内に完了。STP 収束を待つ。
- **監視**: 変更中は ping 監視を実施。
- **ログ**: 変更ログを記録。
- **責任者**: 変更実行者は認定資格者とする。
