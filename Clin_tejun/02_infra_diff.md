# 1. 変更点の要約

Cisco Catalyst 2960 スイッチのインターフェース GigabitEthernet 0/1、0/2、0/3 に対して、新しいサービス用 VLAN 500 を追加します。VLAN 500 は新規作成され、該当インターフェースをトランクモードに変更し、VLAN 500 をトランクで許可します。これにより、既存の VLAN 10 および 20 に加え、VLAN 500 が利用可能になります。

- **追加される VLAN**: VLAN 500（名前: Service）
- **対象インターフェース**: GigabitEthernet 0/1, 0/2, 0/3
- **変更内容**: 各インターフェースをトランクモードに変更し、allowed vlan に 500 を追加

# 2. 変更対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **変更コマンド**:
  ```
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
  !
  ```

# 3. 差分（Before / After）

**Before (設定変更前)**:

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

**After (設定変更後)**:

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

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: VLAN 500 の作成は Trunk ポート（GigabitEthernet 0/24）の allowed vlan に 500 を追加する必要があります（例: switchport trunk allowed vlan 10,20,500）。VTP Transparent モードのため、他のスイッチへの伝播は手動。
- **影響範囲**: 該当インターフェース（Gi0/1-3）の接続デバイスは VLAN 500 のネットワークに移動するため、IP アドレスやルーティングの再設定が必要。STP 再計算が発生し、一時的なネットワーク中断の可能性あり。
- **セキュリティ**: VLAN 500 は新規サービス用なので、ACL やポートセキュリティを検討。バックアップとして変更前に show running-config を実行。
- **テスト**: 変更後、show vlan brief および show interface status で確認。必要に応じて rollback 準備。
