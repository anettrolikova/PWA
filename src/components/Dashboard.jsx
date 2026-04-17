import { useState } from 'react';
import { CATEGORIES } from '../data/questions.js';

const STREAK_MESSAGES = [
  'Get started — day one awaits.',
  'One day in. Keep the momentum.',
  'Two days! This is becoming a thing.',
  '3-day streak. You\'re on a roll.',
  '4 days strong. Language muscle memory is forming.',
  '5 days. Most people quit by now. Not you.',
  'Six days of sharpness. Impressive.',
  'A full week! Your grammar is noticeably better.',
  'Eight days. You\'re in the habit now.',
  'Nine! Almost at ten. Don\'t stop.',
  '10-day streak. Double digits. Respect.',
];

function getStreakMessage(streak) {
  if (streak >= 10) return `${streak}-day streak. You\'re on a serious run. 🔥`;
  return STREAK_MESSAGES[streak] || `${streak}-day streak. Keep going.`;
}

export default function Dashboard({ progress, level, nextLevel, levelProgress, onStartQuiz, onReset }) {
  const [showReset, setShowReset] = useState(false);

  const accuracy = progress.totalAnswered > 0
    ? Math.round((progress.totalCorrect / progress.totalAnswered) * 100)
    : null;

  const categoryEntries = Object.entries(CATEGORIES);

  return (
    <div className="screen dashboard">
      <header className="dashboard-header">
        <div className="brand">
          <span className="brand-g">G</span>
          <span className="brand-text">English, <em>buddy</em></span>
        </div>
      </header>

      <main className="dashboard-main">
        {/* Streak */}
        <div className="streak-card">
          <div className="streak-number">
            <span className="streak-flame">🔥</span>
            <span className="streak-count">{progress.streak}</span>
          </div>
          <p className="streak-message">{getStreakMessage(progress.streak)}</p>
        </div>

        {/* Level + XP */}
        <div className="level-card">
          <div className="level-header">
            <div>
              <p className="level-label">Level</p>
              <h2 className="level-name">{level.name}</h2>
            </div>
            <div className="xp-badge">
              <span className="xp-number">{progress.xp}</span>
              <span className="xp-label">XP</span>
            </div>
          </div>
          <div className="level-bar-track">
            <div className="level-bar-fill" style={{ width: `${levelProgress}%` }} />
          </div>
          {nextLevel && (
            <p className="level-next">
              {level.max + 1 - progress.xp} XP to <strong>{nextLevel.name}</strong>
            </p>
          )}
          {!nextLevel && <p className="level-next">You've reached the top. Sharp as an Einstein.</p>}
        </div>

        {/* Stats row */}
        {progress.totalAnswered > 0 && (
          <div className="stats-row">
            <div className="stat-chip">
              <span className="stat-value">{progress.sessionsPlayed}</span>
              <span className="stat-label">sessions</span>
            </div>
            <div className="stat-chip">
              <span className="stat-value">{progress.totalAnswered}</span>
              <span className="stat-label">answered</span>
            </div>
            <div className="stat-chip">
              <span className="stat-value">{accuracy}%</span>
              <span className="stat-label">accuracy</span>
            </div>
          </div>
        )}

        {/* Category breakdown */}
        {Object.keys(progress.categoryStats).length > 0 && (
          <div className="categories-section">
            <h3 className="section-title">Your Focus Areas</h3>
            <div className="category-list">
              {categoryEntries.map(([key, meta]) => {
                const stats = progress.categoryStats[key];
                if (!stats) return null;
                const pct = Math.round((stats.correct / stats.total) * 100);
                return (
                  <div className="category-row" key={key}>
                    <div className="category-info">
                      <span className="category-icon">{meta.icon}</span>
                      <span className="category-label">{meta.label}</span>
                    </div>
                    <div className="category-bar-wrap">
                      <div className="category-bar-track">
                        <div
                          className="category-bar-fill"
                          style={{ width: `${pct}%`, background: meta.color }}
                        />
                      </div>
                      <span className="category-pct" style={{ color: meta.color }}>{pct}%</span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* CTA */}
        <button className="btn-primary" onClick={onStartQuiz}>
          {progress.sessionsPlayed === 0 ? 'Start your first session' : 'Practice now'}
        </button>

        <p className="session-hint">5–10 questions · ~3 minutes · no excuses</p>

        {/* Reset */}
        <div className="reset-area">
          {!showReset ? (
            <button className="btn-ghost-sm" onClick={() => setShowReset(true)}>
              Reset progress
            </button>
          ) : (
            <div className="reset-confirm">
              <span>Are you sure? This can't be undone.</span>
              <button className="btn-danger-sm" onClick={() => { onReset(); setShowReset(false); }}>
                Yes, reset
              </button>
              <button className="btn-ghost-sm" onClick={() => setShowReset(false)}>
                Cancel
              </button>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
