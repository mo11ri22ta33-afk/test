# 1. 変更点の要約

Cisco Catalyst 2960 スイッチのインターフェース GigabitEthernet 0/5、0/6、0/7 に対して、VLAN 20（Data）を割り当てます。これにより、既存の VLAN 10 および 20 に加え、これらのポートがデータネットワークに統合されます。

- **対象インターフェース**: GigabitEthernet 0/5, 0/6, 0/7
- **変更内容**: 各インターフェースをアクセスモードに設定し、VLAN 20 を割り当て

# 2. 変更対象ファイル / コマンド

- **対象ファイル**: スイッチの running-config（Cisco IOS CLI 経由で変更）
- **変更コマンド**:
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
  ```

# 3. 差分（Before / After）

**Before (設定変更前)**:

```
interface GigabitEthernet0/5
!
interface GigabitEthernet0/6
!
interface GigabitEthernet0/7
```

**After (設定変更後)**:

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
```

# 4. 注意点（依存関係・影響範囲）

- **依存関係**: VLAN 20 は既に作成済み（Clin_tejun2/01_infra_base.md 参照）。Trunk ポート（GigabitEthernet 0/24）の allowed vlan は変更不要。
- **影響範囲**: 該当インターフェースの接続デバイスは VLAN 20 のネットワークに移動するため、IP アドレスやルーティングの再設定が必要。STP 再計算が発生し、一時的なネットワーク中断の可能性あり。
- **セキュリティ**: VLAN 20 はデータ用なので、必要に応じて ACL やポートセキュリティを検討。バックアップとして変更前に show running-config を実行。
- **テスト**: 変更後、show vlan brief および show interface status で確認。必要に応じて rollback 準備。
