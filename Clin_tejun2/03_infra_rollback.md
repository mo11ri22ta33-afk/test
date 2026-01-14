# 1. ロールバック概要

Cisco Catalyst 2960 スイッチの設定変更を元に戻すためのロールバック手順です。GigabitEthernet 0/5、0/6、0/7 の VLAN 20 割り当てを解除し、デフォルト設定に戻します。これにより、設定変更前の状態に復元できます。

- **対象インターフェース**: GigabitEthernet 0/5, 0/6, 0/7
- **変更内容**: インターフェースをデフォルト設定に戻す（VLAN 割り当て解除）

# 2. ロールバック対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **ロールバックコマンド**:
  ```
  interface GigabitEthernet0/5
   no switchport access vlan 20
   no switchport mode access
  !
  interface GigabitEthernet0/6
   no switchport access vlan 20
   no switchport mode access
  !
  interface GigabitEthernet0/7
   no switchport access vlan 20
   no switchport mode access
  !
  ```

# 3. 差分（変更後 / ロールバック後）

**変更後 (ロールバック前)**:

```
interface GigabitEthernet0/5
 switchport access vlan 20
 switchport mode access
!
interface GigabitEthernet0/6
 switchport access vlan 20
 switchport mode access
!
interface GigabitEthernet0/7
 switchport access vlan 20
 switchport mode access
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

**ロールバック後 (変更前状態に戻る)**:

```
interface GigabitEthernet0/5
!
interface GigabitEthernet0/6
!
interface GigabitEthernet0/7
```

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: VLAN 20 はそのまま残す（他のポートで使用中）。
- **影響範囲**: ロールバックにより、インターフェースの接続デバイスはデフォルト VLAN（VLAN 1）に戻るため、ネットワーク接続が切断される可能性あり。STP 再計算が発生し、一時的な中断の可能性あり。
- **セキュリティ**: デフォルト設定に戻すため、セキュリティ設定も無効化。バックアップから復元する場合、事前確認を推奨。
- **テスト**: ロールバック後、show vlan brief および show interface status で確認。必要に応じて再変更。
