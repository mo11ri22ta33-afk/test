# 1. 変更点の要約

Cisco Catalyst 2960 スイッチのインターフェース GigabitEthernet 0/23、0/24 に対して、LACP（Link Aggregation Control Protocol）を使用して EtherChannel を設定します。これにより、帯域倍増と冗長性の確保を実現します。

- **対象インターフェース**: GigabitEthernet 0/23, 0/24
- **変更内容**: LACP モード active でチャネルグループ 10 を設定し、Port-channel10 を作成

# 2. 変更対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **変更コマンド**:
  ```
  interface GigabitEthernet0/23
   channel-group 10 mode active
  !
  interface GigabitEthernet0/24
   channel-group 10 mode active
  !
  interface Port-channel10
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 10,20
   switchport mode trunk
  !
  ```

# 3. 差分（Before / After）

**Before (設定変更前)**:

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

**After (設定変更後)**:

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

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: 対向スイッチも LACP 対応であること。VLAN 10,20 は既に作成済み。
- **影響範囲**: EtherChannel 設定により STP 再計算が発生。一時的なネットワーク中断の可能性あり。
- **セキュリティ**: チャネル設定後も VLAN 許可は維持。
- **テスト**: 変更後、show etherchannel summary および show interface trunk で確認。LACP ネゴシエーション成功を確認。
