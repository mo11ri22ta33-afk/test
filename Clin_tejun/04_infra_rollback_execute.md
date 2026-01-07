# インフラ設定ロールバック実行手順

このドキュメントは、Clin_tejun/03_infra_rollback.md に基づくロールバック実行手順です。Cisco Catalyst 2960 スイッチの設定変更を元に戻し、VLAN 500 を削除し、インターフェースをアクセスモードに戻します。

## 1. 準備

- **情報取得**: ロールバック前に以下のコマンドを実行し、情報をバックアップ。
  - `show running-config`
  - `show vlan brief`
  - `show interface status`
  - `show interface trunk`
  - `show spanning-tree brief`
  - `show version`
- **アクセス確認**: Console または SSH でスイッチにアクセスし、enable モードに入る。
- **依存関係確認**: Trunk ポート（Gi0/24）の allowed vlan から 500 を削除する準備。
- **メンテナンス通知**: ロールバックによるネットワーク中断の可能性を関係者に通知。

## 2. ロールバック手順

以下のコマンドを順次実行してください。エラーが発生した場合、中止してさらなる対応を検討。各ステップのコピペ用コマンドを参照。

1. **インターフェース GigabitEthernet 0/1 の復元**:

   ```
   configure terminal
   interface GigabitEthernet0/1
   switchport access vlan 10
   switchport mode access
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20,500
   exit
   ```

2. **インターフェース GigabitEthernet 0/2 の復元**:

   ```
   interface GigabitEthernet0/2
   switchport access vlan 10
   switchport mode access
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20,500
   exit
   ```

3. **インターフェース GigabitEthernet 0/3 の復元**:

   ```
   interface GigabitEthernet0/3
   switchport access vlan 20
   switchport mode access
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20,500
   exit
   ```

4. **Trunk ポートの更新（オプション）**:

   ```
   interface GigabitEthernet0/24
   switchport trunk allowed vlan remove 500
   exit
   ```

5. **VLAN 500 削除**:

   ```
   no vlan 500
   ```

6. **変更確認**:

   ```
   end
   show vlan brief
   show interface status
   show spanning-tree brief
   show running-config
   ```

   - 変更後の running-config を取得し、事前バックアップと比較して変更内容を確認。

7. **設定保存**:
   ```
   write memory
   ```

## 3. 確認手順

ロールバック後、以下のコマンドで設定を確認してください。

- **VLAN 確認**: `show vlan brief`
  - VLAN 500 が削除されていることを確認。
- **インターフェース確認**: `show interface GigabitEthernet0/1 status`
  - モードが access、VLAN が 10 または 20 であることを確認。
- **トランク確認**: `show interface GigabitEthernet0/1 trunk`
  - VLAN 500 が許可されていないことを確認。
- **STP 確認**: `show spanning-tree`
  - ループがないことを確認。
- **接続テスト**: 接続デバイスが元の VLAN に復元されているかテスト。

## 4. さらなるロールバック手順

問題が解決しない場合、事前バックアップから reload を検討。

- バックアップ復元: `reload` を実行し、事前設定に戻す。

## 5. 注意点

- **実行時間**: 各手順を 1-2 分以内に完了。STP 収束を待つ。
- **監視**: 変更中は ping 監視を実施。
- **ログ**: 変更ログを記録。
- **責任者**: 変更実行者は認定資格者とする。
