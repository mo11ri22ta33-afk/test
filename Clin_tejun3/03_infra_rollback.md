# 1. ロールバック概要

Cisco Catalyst 2960 スイッチの EtherChannel 設定を元に戻すためのロールバック手順です。Port-channel10 を削除し、GigabitEthernet 0/23、0/24 を個別の Trunk ポートに戻します。これにより、設定変更前の状態に復元できます。

- **対象インターフェース**: GigabitEthernet 0/23, 0/24
- **変更内容**: EtherChannel を解除し、個別 Trunk 設定に戻す

# 2. ロールバック対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **ロールバックコマンド**:
  ```
  interface GigabitEthernet0/23
   no channel-group 10 mode active
  !
  interface GigabitEthernet0/24
   no channel-group 10 mode active
  !
  no interface Port-channel10
  !
  ```

# 3. 差分（変更後 / ロールバック後）

**変更後 (ロールバック前)**:

```
interface GigabitEthernet0/23
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
 channel-group 10 mode active
!
interface GigabitEthernet0/24
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
 channel-group 10 mode active
!
interface Port-channel10
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
```

**ロールバック後 (変更前状態に戻る)**:

```
interface GigabitEthernet0/23
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
!
interface GigabitEthernet0/24
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
```

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: 対向スイッチの EtherChannel も解除する必要あり。
- **影響範囲**: ロールバックにより帯域が半減し、STP 再計算が発生。一時的なネットワーク中断の可能性あり。
- **セキュリティ**: Trunk 設定は維持されるため、VLAN 許可は変わらない。
- **テスト**: ロールバック後、show etherchannel summary でチャネルが削除されていることを確認。
