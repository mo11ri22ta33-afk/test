# 1. 変更点の要約

Cisco Catalyst 2960 スイッチのインターフェース GigabitEthernet 0/23、0/24 に対して、LACP (Link Aggregation Control Protocol) によるポートチャネリングを設定します。Port-channel 1 を作成し、該当インターフェースをトランクモードでバンドルします。これにより、帯域幅の増加と冗長性の向上が図れます。

- **追加される Port-channel**: Port-channel 1（LACP active mode）
- **対象インターフェース**: GigabitEthernet 0/23, 0/24
- **変更内容**: 各インターフェースをトランクモードに変更し、channel-group 1 に追加

# 2. 変更対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **変更コマンド**:
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
   no shutdown
  !
  interface GigabitEthernet0/24
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 10,20
   switchport mode trunk
   channel-group 1 mode active
   no shutdown
  !
  ```

# 3. 差分（Before / After）

**Before (設定変更前)**:

```
interface GigabitEthernet0/23
 shutdown
!
interface GigabitEthernet0/24
 shutdown
```

**After (設定変更後)**:

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

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: VLAN 10, 20 が存在することを前提。STP が有効で、Port-channel の STP 計算が必要。
- **影響範囲**: LACP 設定により、接続デバイスとのリンクがバンドルされるため、対向側の設定も必要。STP 再計算が発生し、一時的なネットワーク中断の可能性あり。
- **セキュリティ**: Port-channel はトランクなので、VLAN アクセス制御を検討。バックアップとして変更前に show running-config を実行。
- **テスト**: 変更後、show etherchannel summary および show interface status で確認。必要に応じて rollback 準備。
