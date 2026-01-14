# インフラ設定変更実行手順

このドキュメントは、Clin_tejun3/02_infra_diff.md に基づく設定変更の実行手順です。Cisco Catalyst 2960 スイッチのインターフェース GigabitEthernet 0/23、0/24 に LACP を使用した EtherChannel を設定します。

## 1. 準備

- **情報取得**: 変更前に以下のコマンドを実行し、情報をバックアップ。
  - `show running-config`
  - `show vlan brief`
  - `show interface status`
  - `show interface trunk`
  - `show spanning-tree brief`
  - `show version`
- **アクセス確認**: Console または SSH でスイッチにアクセスし、enable モードに入る。
- **依存関係確認**: 対向スイッチが LACP 対応であること。
- **メンテナンス通知**: EtherChannel 設定によるネットワーク中断の可能性を関係者に通知。

## 2. 変更手順

以下のコマンドを順次実行してください。エラーが発生した場合、中止してロールバックを検討。各ステップのコピペ用コマンドを参照。

1. **GigabitEthernet 0/23 のチャネル設定**:

   ```
   configure terminal
   interface GigabitEthernet0/23
   channel-group 10 mode active
   exit
   ```

2. **GigabitEthernet 0/24 のチャネル設定**:

   ```
   interface GigabitEthernet0/24
   channel-group 10 mode active
   exit
   ```

3. **Port-channel10 の設定**:

   ```
   interface Port-channel10
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 10,20
   switchport mode trunk
   exit
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

変更後、以下のコマンドで設定を確認してください。

- **EtherChannel 確認**: `show etherchannel summary`
  - Port-channel10 が SU (Up) 状態であることを確認。
- **インターフェース確認**: `show interface GigabitEthernet0/23 status`
  - ポートが bundled (P) 状態であることを確認。
- **トランク確認**: `show interface Port-channel10 trunk`
  - Allowed VLAN に 10,20 が含まれていることを確認。
- **STP 確認**: `show spanning-tree`
  - ループがないことを確認。
- **接続テスト**: 対向スイッチとの LACP ネゴシエーションが成功しているかテスト。

## 4. ロールバック手順

問題が発生した場合、Clin_tejun3/03_infra_rollback.md を参照してロールバックを実行してください。

- 即時ロールバック: Port-channel を削除し、物理ポートを個別設定に戻す。
- バックアップ復元: 事前バックアップから reload。

## 5. 注意点

- **実行時間**: 各手順を 1-2 分以内に完了。STP 収束を待つ。
- **監視**: 変更中は ping 監視を実施。
- **ログ**: 変更ログを記録。
- **責任者**: 変更実行者は認定資格者とする。
