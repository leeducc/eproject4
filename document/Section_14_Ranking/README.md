## 🏆 Section 14: Ranking & Leaderboards (Mobile)

### 14.1 Global and Skill-Specific Rankings

Students can see their rank compared to others based on study points or band scores.

- **API Calls**:
  - `GET /api/v1/ranking/global`: Fetches top students globally.
  - `GET /api/v1/ranking/skill/{skill}`: Ranking for a specific skill (e.g., WRITING).

- **Model Table Design**:

  | Table | Column | Type | Description |
  | :--- | :--- | :--- | :--- |
  | `user_stats` | `total_points` | INT | Aggregate study points |
  | `user_stats` | `avg_band_score` | DOUBLE | Mean IELTS score across tests |

- **UI Design**: [IMAGE_PLACEHOLDER: RANKING_LEADERBOARD]
