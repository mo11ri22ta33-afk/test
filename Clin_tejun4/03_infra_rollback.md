# 1. ロールバック概要

Cisco Catalyst 2960 スイッチの設定変更を元に戻すためのロールバック手順です。Port-channel 1 を削除し、GigabitEthernet 0/23、0/24 を shutdown 状態に戻します。これにより、設定変更前の状態に復元できます。

- **削除される Port-channel**: Port-channel 1
- **対象インターフェース**: GigabitEthernet 0/23, 0/24
- **変更内容**: インターフェースを shutdown に戻し、channel-group を削除

# 2. ロールバック対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **ロールバックコマンド**:
  ```
  interface GigabitEthernet0/23
   shutdown
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20
   no switchport mode trunk
   no channel-group 1 mode active
  !
  interface GigabitEthernet0/24
   shutdown
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20
   no switchport mode trunk
   no channel-group 1 mode active
  !
  no interface Port-channel1
  !
  ```

# 3. 差分（変更後 / ロールバック後）

**変更後 (ロールバック前)**:

```
interface Port-channel1
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
!
interface GigabitEthernet0/23
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
 channel-group 1 mode active
!
interface GigabitEthernet0/24
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
 channel-group 1 mode active
```

**ロールバック後 (変更前状態に戻る)**:

```
interface GigabitEthernet0/23
 shutdown
!
interface GigabitEthernet0/24
 shutdown
```

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: Port-channel 削除により、STP 計算が変更。対向側の LACP 設定も解除が必要。
- **影響範囲**: ロールバックにより、リンクバンドルが解除され、ネットワーク接続が失われる可能性あり。STP 再計算が発生し、一時的な中断の可能性あり。
- **セキュリティ**: Port-channel 削除により、関連するトランク設定が無効化。バックアップから復元する場合、事前確認を推奨。
- **テスト**: ロールバック後、show etherchannel summary および show interface status で確認。必要に応じて再変更。
