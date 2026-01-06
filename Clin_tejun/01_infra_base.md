# 1. システム概要

このドキュメントは、Cisco Catalyst 2960 スイッチを対象とした設定変更前のインフラ構成モデルを定義します。想定規模はインターフェースへの VLAN 設定に限定し、基本的なネットワーク構成を再現可能なテキストモデルとして表現します。

- **対象インフラ**: Cisco Catalyst 2960 シリーズスイッチ（24 ポートモデルを想定）
- **想定規模**: VLAN ID 10（管理用）、VLAN ID 20（データ用）を GigabitEthernet 0/1-12 に割り当て、Trunk ポートとして GigabitEthernet 0/24 を設定
- **現在の設定**: 初期設定（ホスト名、インターフェース基本設定、VLAN 作成）を生成。VTP モードは Transparent とし、STP はデフォルト有効
- **構成図テキスト**:
  ```
  [Catalyst 2960 Switch]
  +-------------------+
  | Hostname: SW-Core |
  |                   |
  | VLAN 10: Mgmt     |
  | VLAN 20: Data     |
  |                   |
  | Gi0/1-12: Access  |
  | (VLAN 10/20)      |
  |                   |
  | Gi0/24: Trunk     |
  | (Dot1Q)           |
  +-------------------+
  ```

# 2. 設定ファイル（コードブロックで）

以下は、Cisco IOS CLI を使用して生成した初期設定と VLAN 設定の例です。これをスイッチに適用することで、設定変更前の状態を再現できます。

```
! Catalyst 2960 Initial Configuration
!
hostname SW-Core
!
enable secret cisco
!
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
!
interface GigabitEthernet0/4
 switchport access vlan 20
 switchport mode access
!
! (同様にGi0/5-12までVLAN 10または20を割り当て、必要に応じて拡張)
!
interface GigabitEthernet0/24
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
!
vtp mode transparent
!
spanning-tree mode pvst
!
end
```

**CLI show 結果の例 (show running-config の一部抜粋)**:

```
SW-Core#show running-config
Building configuration...

Current configuration : 2048 bytes
!
version 15.0
no service pad
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname SW-Core
!
!
!
!
!
!
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
!
interface GigabitEthernet0/4
 switchport access vlan 20
 switchport mode access
!
interface GigabitEthernet0/24
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 10,20
 switchport mode trunk
!
! (以下省略)
```

# 3. 運用上の前提条件

- **ソフトウェア要件**: Cisco IOS Version 15.0 以上を推奨。VLAN 機能が有効であること。
- **ハードウェア要件**: Catalyst 2960 シリーズ（24 ポート以上）。電源および冷却が適切に確保されていること。
- **接続要件**: 管理アクセスは Console ポートまたは SSH 経由。Trunk ポートは上位スイッチまたはルータに接続。
- **セキュリティ**: enable secret パスワードを設定。必要に応じて AAA 認証を追加。
- **バックアップ**: 設定変更前に running-config を startup-config に保存。

# 4. 想定される制約

- **VLAN 数制限**: Catalyst 2960 は最大 255 個の VLAN をサポート。ただし、メモリや CPU 使用率に注意。
- **ポート数**: 24 ポートモデルでは、Trunk ポート 1 つ、Access ポート 23 つまで。拡張モジュール使用時はさらに制限あり。
- **STP 制約**: PVST モード使用時、VLAN ごとに STP インスタンスが生成され、CPU 負荷が増大。
- **パフォーマンス**: 高トラフィック環境では、ポートバッファやバックプレーン帯域を考慮（2960 は 1Gbps/ポート）。
- **互換性**: VTP Transparent モードのため、他の VTP ドメインとの統合時は注意。
