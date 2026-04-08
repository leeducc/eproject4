## 💰 Section 4: Economy & i-Coins (Mobile)

### 4.1 Shop & Balance

Users can purchase i-Coins or exchange them for PRO subscriptions.

- **API Calls**:
  - `GET /api/icoin/balance`: Current wallet balance.
  - `POST /api/subscriptions/purchase`: Spends coins to upgrade account.

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `icoin_transactions` | `id` | BIGINT | PK |
  | `icoin_transactions` | `amount` | INT | Coins added/removed |
  | `icoin_transactions` | `type` | VARCHAR | PURCHASE, REWARD, SPEND |

- **Sequence Diagram**:

  ```mermaid
  sequenceDiagram
      participant App as Mobile App
      participant API as Spring Boot API
      App->>API: GET /api/icoin/balance
      API-->>App: {balance: 500}
      App->>API: POST /api/subscriptions/purchase {months: 1}
      API-->>App: 200 OK (Account status updated to PRO)
  ```

- **UI Design**: [IMAGE_PLACEHOLDER: ICOIN_SHOP_SCREEN]
