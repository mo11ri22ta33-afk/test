# 1. ロールバック概要

Cisco Catalyst 2960 スイッチの設定変更を元に戻すためのロールバック手順です。VLAN 500 を削除し、GigabitEthernet 0/1、0/2、0/3 をトランクモードからアクセスモードに戻します。これにより、設定変更前の状態に復元できます。

- **削除される VLAN**: VLAN 500（Service）
- **対象インターフェース**: GigabitEthernet 0/1, 0/2, 0/3
- **変更内容**: インターフェースをアクセスモードに戻し、元の VLAN 割り当てに復元

# 2. ロールバック対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **ロールバックコマンド**:
  ```
  no vlan 500
  !
  interface GigabitEthernet0/1
   switchport access vlan 10
   switchport mode access
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20,500
  !
  interface GigabitEthernet0/2
   switchport access vlan 10
   switchport mode access
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20,500
  !
  interface GigabitEthernet0/3
   switchport access vlan 20
   switchport mode access
   no switchport trunk encapsulation dot1q
   no switchport trunk allowed vlan 10,20,500
  !
  ```

# 3. 差分（変更後 / ロールバック後）

**変更後 (ロールバック前)**:

```
interface Vlan1
 no ip address
 shutdown
!
vlan 10
 name Mgmt
!
vlan 20
 name Data
!
vlan 500
 name Service
!
interface GigabitEthernet0/1
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20,500
 switchport mode trunk
!
interface GigabitEthernet0/2
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20,500
 switchport mode trunk
!
interface GigabitEthernet0/3
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20,500
 switchport mode trunk
```

**ロールバック後 (変更前状態に戻る)**:

```
interface Vlan1
 no ip address
 shutdown
!
vlan 10
 name Mgmt
!
vlan 20
 name Data
!
interface GigabitEthernet0/1
 switchport access vlan 10
 switchport mode access
!
interface GigabitEthernet0/2
 switchport access vlan 10
 switchport mode access
!
interface GigabitEthernet0/3
 switchport access vlan 20
 switchport mode access
```

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: Trunk ポート（GigabitEthernet 0/24）の allowed vlan から 500 を削除（例: switchport trunk allowed vlan 10,20）。VTP Transparent モードのため、他のスイッチの伝播は手動。
- **影響範囲**: ロールバックにより、インターフェースの接続デバイスは元の VLAN（10/20）に戻るため、ネットワーク接続が復元。STP 再計算が発生し、一時的な中断の可能性あり。
- **セキュリティ**: VLAN 500 削除により、関連する ACL やセキュリティ設定も無効化。バックアップから復元する場合、事前確認を推奨。
- **テスト**: ロールバック後、show vlan brief および show interface status で確認。必要に応じて再変更。
