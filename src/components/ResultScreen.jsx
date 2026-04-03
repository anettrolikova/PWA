import { CATEGORIES } from '../data/questions.js';

const XP_PER_CORRECT = 10;
const XP_PER_WRONG = 2;

const RESULT_MESSAGES = {
  perfect: ['Perfect score. That\'s very Darling of you.', 'All correct. Your grammar is sharper than most native speakers\'s.'],
  great: ['Really strong session.', 'Great work — you clearly know your stuff.'],
  good: ['Solid session. A few to review, but you\'re getting there.', 'Good progress. Every mistake is data.'],
  okay: ['You\'ll get there. The explanations are doing their job.', 'Keep going — it gets easier.'],
  rough: ['Rough one. That\'s okay — grammar is hard, and you\'re doing it anyway.', 'This is exactly how improvement works.'],
};

function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }

function getMessage(correct, total) {
  const pct = correct / total;
  if (pct === 1) return pick(RESULT_MESSAGES.perfect);
  if (pct >= 0.75) return pick(RESULT_MESSAGES.great);
  if (pct >= 0.55) return pick(RESULT_MESSAGES.good);
  if (pct >= 0.4) return pick(RESULT_MESSAGES.okay);
  return pick(RESULT_MESSAGES.rough);
}

export default function ResultScreen({ results, onFinish }) {
  const correct = results.filter((r) => r.correct).length;
  const total = results.length;
  const xpEarned = correct * XP_PER_CORRECT + (total - correct) * XP_PER_WRONG;

  // Group mistakes by category
  const wrongByCategory = {};
  results.filter((r) => !r.correct).forEach((r) => {
    const cat = r.category;
    if (!wrongByCategory[cat]) wrongByCategory[cat] = 0;
    wrongByCategory[cat]++;
  });
  const focusAreas = Object.entries(wrongByCategory).sort((a, b) => b[1] - a[1]);

  const pct = Math.round((correct / total) * 100);

  return (
    <div className="screen result-screen">
      <div className="result-main">
        <div className="result-score-ring">
          <svg viewBox="0 0 120 120" className="ring-svg">
            <circle cx="60" cy="60" r="50" className="ring-track" />
            <circle
              cx="60" cy="60" r="50"
              className="ring-fill"
              strokeDasharray={`${(pct / 100) * 314} 314`}
              strokeLinecap="round"
              transform="rotate(-90 60 60)"
            />
          </svg>
          <div className="ring-inner">
            <span className="ring-pct">{pct}%</span>
            <span className="ring-label">{correct}/{total}</span>
          </div>
        </div>

        <h2 className="result-message">{getMessage(correct, total)}</h2>

        <div className="xp-earned">
          <span className="xp-plus">+{xpEarned}</span>
          <span className="xp-label-lg">XP</span>
        </div>

        {/* Breakdown */}
        <div className="result-breakdown">
          {results.map((r, i) => (
            <div key={i} className={`breakdown-row ${r.correct ? 'row-correct' : 'row-wrong'}`}>
              <span className="breakdown-icon">{r.correct ? '✓' : '✗'}</span>
              <span className="breakdown-q">{truncate(r.question.question, 55)}</span>
            </div>
          ))}
        </div>

        {focusAreas.length > 0 && (
          <div className="focus-note">
            <h3 className="focus-title">Keep working on</h3>
            <div className="focus-chips">
              {focusAreas.map(([cat]) => (
                <span key={cat} className="focus-chip" style={{ color: CATEGORIES[cat]?.color, borderColor: CATEGORIES[cat]?.color }}>
                  {CATEGORIES[cat]?.icon} {CATEGORIES[cat]?.label}
                </span>
              ))}
            </div>
          </div>
        )}

        <button className="btn-primary" onClick={onFinish}>
          Back to dashboard
        </button>
      </div>
    </div>
  );
}

function truncate(str, max) {
  return str.length > max ? str.slice(0, max - 1) + '…' : str;
}
