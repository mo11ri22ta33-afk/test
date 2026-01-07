# インフラ設定変更実行手順

このドキュメントは、Clin_tejun/02_infra_diff.md に基づく設定変更の実行手順です。Cisco Catalyst 2960 スイッチのインターフェースに VLAN 500 を追加し、トランクモードに変更します。

## 1. 準備

- **情報取得**: 変更前に以下のコマンドを実行し、情報をバックアップ。
  - `show running-config`
  - `show vlan brief`
  - `show interface status`
  - `show interface trunk`
  - `show spanning-tree brief`
  - `show version`
- **アクセス確認**: Console または SSH でスイッチにアクセスし、enable モードに入る。
- **依存関係確認**: Trunk ポート（Gi0/24）の allowed vlan に 500 を追加する準備。
- **メンテナンス通知**: 変更によるネットワーク中断の可能性を関係者に通知。

## 2. 変更手順

以下のコマンドを順次実行してください。エラーが発生した場合、中止してロールバックを検討。各ステップのコピペ用コマンドを参照。

1. **VLAN 500 作成**:

   ```
   configure terminal
   vlan 500
   name Service
   exit
   ```

2. **GigabitEthernet 0/1 の設定変更**:

   ```
   interface GigabitEthernet0/1
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 10,20,500
   switchport mode trunk
   exit
   ```

3. **GigabitEthernet 0/2 の設定変更**:

   ```
   interface GigabitEthernet0/2
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 10,20,500
   switchport mode trunk
   exit
   ```

4. **GigabitEthernet 0/3 の設定変更**:

   ```
   interface GigabitEthernet0/3
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 10,20,500
   switchport mode trunk
   exit
   ```

5. **Trunk ポートの更新（オプション）**:

   ```
   interface GigabitEthernet0/24
   switchport trunk allowed vlan add 500
   exit
   ```

6. **変更確認**:

   ```
   end
   show vlan brief
   show interface trunk
   show spanning-tree brief
   show running-config
   ```

   - 変更後の running-config を取得し、事前バックアップと比較して変更内容を確認。

7. **設定保存**:
   ```
   write memory
   ```

## 3. 確認手順

変更後、以下のコマンドで設定を確認してください。

- **VLAN 確認**: `show vlan brief`
  - VLAN 500 が作成されていることを確認。
- **インターフェース確認**: `show interface GigabitEthernet0/1 status`
  - モードが trunk、VLAN が許可されていることを確認。
- **トランク確認**: `show interface GigabitEthernet0/1 trunk`
  - Allowed VLAN に 10,20,500 が含まれていることを確認。
- **STP 確認**: `show spanning-tree`
  - ループがないことを確認。
- **接続テスト**: 接続デバイスから VLAN 500 にアクセス可能かテスト。

## 4. ロールバック手順

問題が発生した場合、Clin_tejun/03_infra_rollback.md を参照してロールバックを実行してください。

- 即時ロールバック: インターフェースをアクセスモードに戻し、VLAN 500 削除。
- バックアップ復元: 事前バックアップから reload。

## 5. 注意点

- **実行時間**: 各手順を 1-2 分以内に完了。STP 収束を待つ。
- **監視**: 変更中は ping 監視を実施。
- **ログ**: 変更ログを記録。
- **責任者**: 変更実行者は認定資格者とする。
