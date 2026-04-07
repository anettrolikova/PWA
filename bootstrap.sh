#!/bin/bash
set -e
echo "Creating Grammar, Darling project..."
mkdir -p ~/grammar-darling/src/components ~/grammar-darling/src/data ~/grammar-darling/src/hooks ~/grammar-darling/public ~/grammar-darling/.github/workflows
cd ~/grammar-darling

cat > package.json << 'EOF'
{
  "name": "grammar-darling",
  "version": "1.0.0",
  "type": "module",
  "scripts": { "dev": "vite", "build": "vite build", "preview": "vite preview" },
  "dependencies": { "react": "^18.3.1", "react-dom": "^18.3.1" },
  "devDependencies": { "@vitejs/plugin-react": "^4.3.1", "vite": "^5.4.2" }
}
EOF

cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
export default defineConfig({
  base: process.env.GITHUB_PAGES ? '/PWA/' : '/',
  plugins: [react()],
  build: { outDir: 'dist', assetsDir: 'assets' },
  server: { port: 3000 },
});
EOF

cat > vercel.json << 'EOF'
{
  "buildCommand": "npm install && npm run build",
  "outputDirectory": "dist",
  "framework": "vite",
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
EOF

cat > .gitignore << 'EOF'
node_modules/
dist/
.DS_Store
*.local
EOF

cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    <meta name="theme-color" content="#0E0E10" />
    <meta name="description" content="Grammar, Darling — a sharp English grammar trainer." />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="apple-mobile-web-app-title" content="Grammar, Darling" />
    <link rel="manifest" href="/manifest.json" />
    <link rel="apple-touch-icon" href="/icon-192.svg" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=Inter:wght@400;500;600&display=swap" rel="stylesheet" />
    <title>Grammar, Darling</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
    <script>
      if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => { navigator.serviceWorker.register('/sw.js').catch(() => {}); });
      }
    </script>
  </body>
</html>
EOF

cat > public/manifest.json << 'EOF'
{
  "name": "Grammar, Darling",
  "short_name": "Grammar, Darling",
  "description": "A sharp English grammar trainer personalized for you.",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0E0E10",
  "theme_color": "#0E0E10",
  "orientation": "portrait",
  "icons": [
    { "src": "/icon-192.svg", "sizes": "192x192", "type": "image/svg+xml", "purpose": "any maskable" },
    { "src": "/icon-512.svg", "sizes": "512x512", "type": "image/svg+xml", "purpose": "any maskable" }
  ],
  "categories": ["education", "lifestyle"]
}
EOF

cat > public/favicon.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <rect width="64" height="64" rx="14" fill="#0E0E10"/>
  <text x="32" y="46" font-family="Georgia, serif" font-size="40" font-weight="900" text-anchor="middle" fill="#E8C547">G</text>
</svg>
EOF

cat > public/icon-192.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 192 192">
  <rect width="192" height="192" rx="40" fill="#0E0E10"/>
  <text x="96" y="138" font-family="Georgia, serif" font-size="120" font-weight="900" text-anchor="middle" fill="#E8C547">G</text>
  <text x="96" y="172" font-family="Georgia, serif" font-size="18" font-style="italic" text-anchor="middle" fill="#8A8A96">darling</text>
</svg>
EOF

cat > public/icon-512.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="100" fill="#0E0E10"/>
  <text x="256" y="360" font-family="Georgia, serif" font-size="320" font-weight="900" text-anchor="middle" fill="#E8C547">G</text>
  <text x="256" y="450" font-family="Georgia, serif" font-size="48" font-style="italic" text-anchor="middle" fill="#8A8A96">darling</text>
</svg>
EOF

cat > public/sw.js << 'EOF'
const CACHE_NAME = 'grammar-darling-v1';
const STATIC_ASSETS = ['/', '/index.html', '/manifest.json', '/icon-192.svg', '/icon-512.svg', '/favicon.svg'];
self.addEventListener('install', (e) => { e.waitUntil(caches.open(CACHE_NAME).then((c) => c.addAll(STATIC_ASSETS))); self.skipWaiting(); });
self.addEventListener('activate', (e) => { e.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))))); self.clients.claim(); });
self.addEventListener('fetch', (e) => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET' || url.origin !== self.location.origin) return;
  e.respondWith(caches.match(e.request).then((cached) => {
    const net = fetch(e.request).then((r) => { if (r.ok) { const cl = r.clone(); caches.open(CACHE_NAME).then((c) => c.put(e.request, cl)); } return r; }).catch(() => cached);
    return cached || net;
  }));
});
EOF

cat > src/main.jsx << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';
ReactDOM.createRoot(document.getElementById('root')).render(<React.StrictMode><App /></React.StrictMode>);
EOF

cat > src/App.jsx << 'EOF'
import { useState } from 'react';
import Dashboard from './components/Dashboard.jsx';
import Quiz from './components/Quiz.jsx';
import { useProgress } from './hooks/useProgress.js';
export default function App() {
  const [screen, setScreen] = useState('dashboard');
  const { progress, level, nextLevel, levelProgress, addSessionResult, resetProgress } = useProgress();
  return (
    <div className="app">
      {screen === 'dashboard' && <Dashboard progress={progress} level={level} nextLevel={nextLevel} levelProgress={levelProgress} onStartQuiz={() => setScreen('quiz')} onReset={resetProgress} />}
      {screen === 'quiz' && <Quiz onFinish={(r) => { addSessionResult(r); setScreen('dashboard'); }} onBack={() => setScreen('dashboard')} />}
    </div>
  );
}
EOF

cat > src/hooks/useProgress.js << 'EOF'
import { useState, useEffect, useCallback } from 'react';
const KEY = 'grammar-darling-progress';
const LEVELS = [{ name: 'Newbie', min: 0, max: 99 },{ name: 'Apprentice', min: 100, max: 299 },{ name: 'Scholar', min: 300, max: 599 },{ name: 'Wordsmith', min: 600, max: 999 },{ name: 'Darling', min: 1000, max: Infinity }];
const getLevel = (xp) => LEVELS.find((l) => xp >= l.min && xp <= l.max) || LEVELS[0];
const getNextLevel = (xp) => { const i = LEVELS.findIndex((l) => xp >= l.min && xp <= l.max); return LEVELS[i + 1] || null; };
const getLevelProgress = (xp) => { const c = getLevel(xp); if (c.max === Infinity) return 100; return Math.min(100, Math.round(((xp - c.min) / (c.max - c.min + 1)) * 100)); };
const todayStr = () => new Date().toISOString().slice(0, 10);
const load = () => { try { const r = localStorage.getItem(KEY); return r ? JSON.parse(r) : null; } catch { return null; } };
const save = (d) => { try { localStorage.setItem(KEY, JSON.stringify(d)); } catch {} };
const def = () => ({ xp: 0, streak: 0, lastPlayedDate: null, totalCorrect: 0, totalAnswered: 0, categoryStats: {}, sessionsPlayed: 0 });
export function useProgress() {
  const [progress, setProgress] = useState(() => {
    const s = load(); if (!s) return def();
    const today = todayStr(), yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
    let streak = s.streak || 0;
    if (s.lastPlayedDate !== today && s.lastPlayedDate !== yesterday) streak = 0;
    return { ...s, streak };
  });
  useEffect(() => { save(progress); }, [progress]);
  const addSessionResult = useCallback((results) => {
    setProgress((prev) => {
      const today = todayStr();
      const correct = results.filter((r) => r.correct).length;
      const xpGained = correct * 10 + results.filter((r) => !r.correct).length * 2;
      let newStreak = prev.streak;
      if (prev.lastPlayedDate !== today) {
        newStreak = prev.lastPlayedDate === new Date(Date.now() - 86400000).toISOString().slice(0, 10) ? prev.streak + 1 : 1;
      }
      const cats = { ...prev.categoryStats };
      results.forEach(({ category, correct: c }) => {
        if (!cats[category]) cats[category] = { correct: 0, total: 0 };
        cats[category].total += 1; if (c) cats[category].correct += 1;
      });
      return { ...prev, xp: prev.xp + xpGained, streak: newStreak, lastPlayedDate: today, totalCorrect: prev.totalCorrect + correct, totalAnswered: prev.totalAnswered + results.length, categoryStats: cats, sessionsPlayed: prev.sessionsPlayed + 1 };
    });
  }, []);
  const resetProgress = useCallback(() => { const f = def(); setProgress(f); save(f); }, []);
  return { progress, level: getLevel(progress.xp), nextLevel: getNextLevel(progress.xp), levelProgress: getLevelProgress(progress.xp), addSessionResult, resetProgress };
}
EOF

cat > src/components/Dashboard.jsx << 'EOF'
import { useState } from 'react';
import { CATEGORIES } from '../data/questions.js';
const SM = ['Get started — day one awaits.','One day in. Keep the momentum.','Two days! This is becoming a thing.','3-day streak. You\'re on a roll.','4 days strong. Language muscle memory is forming.','5 days. Most people quit by now. Not you.','Six days of sharpness. Impressive.','A full week! Your grammar is noticeably better.','Eight days. You\'re in the habit now.','Nine! Almost at ten. Don\'t stop.','10-day streak. Double digits. Respect.'];
const gsm = (s) => s >= 10 ? `${s}-day streak. You're on a serious run. 🔥` : SM[s] || `${s}-day streak. Keep going.`;
export default function Dashboard({ progress, level, nextLevel, levelProgress, onStartQuiz, onReset }) {
  const [showReset, setShowReset] = useState(false);
  const acc = progress.totalAnswered > 0 ? Math.round((progress.totalCorrect / progress.totalAnswered) * 100) : null;
  return (
    <div className="screen dashboard">
      <header className="dashboard-header"><div className="brand"><span className="brand-g">G</span><span className="brand-text">rammar, <em>Darling</em></span></div></header>
      <main className="dashboard-main">
        <div className="streak-card"><div className="streak-number"><span className="streak-flame">🔥</span><span className="streak-count">{progress.streak}</span></div><p className="streak-message">{gsm(progress.streak)}</p></div>
        <div className="level-card">
          <div className="level-header"><div><p className="level-label">Level</p><h2 className="level-name">{level.name}</h2></div><div className="xp-badge"><span className="xp-number">{progress.xp}</span><span className="xp-label">XP</span></div></div>
          <div className="level-bar-track"><div className="level-bar-fill" style={{ width: `${levelProgress}%` }} /></div>
          {nextLevel ? <p className="level-next">{level.max + 1 - progress.xp} XP to <strong>{nextLevel.name}</strong></p> : <p className="level-next">You've reached the top. Sharp as a darling.</p>}
        </div>
        {progress.totalAnswered > 0 && <div className="stats-row"><div className="stat-chip"><span className="stat-value">{progress.sessionsPlayed}</span><span className="stat-label">sessions</span></div><div className="stat-chip"><span className="stat-value">{progress.totalAnswered}</span><span className="stat-label">answered</span></div><div className="stat-chip"><span className="stat-value">{acc}%</span><span className="stat-label">accuracy</span></div></div>}
        {Object.keys(progress.categoryStats).length > 0 && (<div className="categories-section"><h3 className="section-title">Your Focus Areas</h3><div className="category-list">{Object.entries(CATEGORIES).map(([key, meta]) => { const s = progress.categoryStats[key]; if (!s) return null; const p = Math.round((s.correct / s.total) * 100); return (<div className="category-row" key={key}><div className="category-info"><span className="category-icon">{meta.icon}</span><span className="category-label">{meta.label}</span></div><div className="category-bar-wrap"><div className="category-bar-track"><div className="category-bar-fill" style={{ width: `${p}%`, background: meta.color }} /></div><span className="category-pct" style={{ color: meta.color }}>{p}%</span></div></div>); })}</div></div>)}
        <button className="btn-primary" onClick={onStartQuiz}>{progress.sessionsPlayed === 0 ? 'Start your first session' : 'Practice now'}</button>
        <p className="session-hint">5–10 questions · ~3 minutes · no excuses</p>
        <div className="reset-area">{!showReset ? <button className="btn-ghost-sm" onClick={() => setShowReset(true)}>Reset progress</button> : <div className="reset-confirm"><span>Are you sure? This can't be undone.</span><button className="btn-danger-sm" onClick={() => { onReset(); setShowReset(false); }}>Yes, reset</button><button className="btn-ghost-sm" onClick={() => setShowReset(false)}>Cancel</button></div>}</div>
      </main>
    </div>
  );
}
EOF

cat > src/components/Quiz.jsx << 'EOF'
import { useState, useMemo } from 'react';
import { questions, CATEGORIES } from '../data/questions.js';
import QuestionCard from './QuestionCard.jsx';
import ExplanationCard from './ExplanationCard.jsx';
import ResultScreen from './ResultScreen.jsx';
const pick = () => [...questions].sort(() => Math.random() - 0.5).slice(0, 8);
export default function Quiz({ onFinish, onBack }) {
  const sq = useMemo(() => pick(), []);
  const [idx, setIdx] = useState(0);
  const [phase, setPhase] = useState('question');
  const [results, setResults] = useState([]);
  const [chosen, setChosen] = useState(null);
  const cur = sq[idx], total = sq.length;
  function handleAnswer(opt) { setChosen(opt); setResults((p) => [...p, { category: cur.category, correct: opt === cur.answer, chosen: opt, question: cur }]); setPhase('explanation'); }
  function handleNext() { if (idx + 1 >= total) { setPhase('done'); } else { setIdx((i) => i + 1); setChosen(null); setPhase('question'); } }
  if (phase === 'done') return <ResultScreen results={results} onFinish={onFinish} />;
  const prog = ((idx + (phase === 'explanation' ? 1 : 0)) / total) * 100;
  return (
    <div className="screen quiz">
      <div className="quiz-topbar">
        <button className="btn-back" onClick={onBack}>←</button>
        <div className="quiz-progress-wrap"><div className="quiz-progress-track"><div className="quiz-progress-fill" style={{ width: `${prog}%` }} /></div><span className="quiz-counter">{idx + 1} / {total}</span></div>
        <div className="category-tag" style={{ color: CATEGORIES[cur.category]?.color }}>{CATEGORIES[cur.category]?.label}</div>
      </div>
      {phase === 'question' && <QuestionCard question={cur} onAnswer={handleAnswer} />}
      {phase === 'explanation' && <ExplanationCard question={cur} chosen={chosen} onNext={handleNext} isLast={idx + 1 >= total} />}
    </div>
  );
}
EOF

cat > src/components/QuestionCard.jsx << 'EOF'
import { useState } from 'react';
const TL = { crypto: '₿ crypto', expat: '🌍 expat life', work: '💼 work', casual: '☕ casual' };
export default function QuestionCard({ question, onAnswer }) {
  const [sel, setSel] = useState(null);
  function handleSelect(opt) { if (sel) return; setSel(opt); setTimeout(() => onAnswer(opt), 180); }
  const parts = question.question.split('___');
  const qText = parts.length === 1 ? question.question : <>{parts[0]}<span className="blank-marker">___</span>{parts[1]}</>;
  return (
    <div className="question-card">
      <div className="question-theme-tag">{TL[question.theme]}</div>
      <h2 className="question-text">{qText}</h2>
      <div className="options-grid">{question.options.map((opt) => <button key={opt} className={`option-btn ${sel === opt ? 'selected' : ''}`} onClick={() => handleSelect(opt)}>{opt}</button>)}</div>
    </div>
  );
}
EOF

cat > src/components/ExplanationCard.jsx << 'EOF'
const C = ['Nailed it.','Exactly right.','Sharp.','Correct — native speakers would say the same.','You got it.','Spot on.'];
const W = ['Not quite — but now you know.','Close. Here\'s what\'s actually going on:','Common mistake — this is why:','Not this time. Read on.','Good try. The real answer:'];
const rnd = (a) => a[Math.floor(Math.random() * a.length)];
export default function ExplanationCard({ question, chosen, onNext, isLast }) {
  const ok = chosen === question.answer;
  const parts = question.question.split('___');
  const recap = parts.length === 1
    ? <span className="recap-text">{question.question}</span>
    : <span className="recap-text">{parts[0]}<span className="recap-answer">{question.answer}</span>{parts[1]}</span>;
  return (
    <div className="explanation-card">
      <div className={`result-badge ${ok ? 'result-correct' : 'result-wrong'}`}>{ok ? '✓' : '✗'}</div>
      <p className="result-headline">{ok ? rnd(C) : rnd(W)}</p>
      {!ok && <div className="correct-answer-row"><span className="correct-label">Correct answer:</span><span className="correct-value">{question.answer}</span></div>}
      <div className="explanation-text"><span className="explanation-quote">"</span>{question.explanation}</div>
      <div className="question-recap">{recap}</div>
      <button className="btn-primary" onClick={onNext}>{isLast ? 'See results' : 'Next question'}</button>
    </div>
  );
}
EOF

cat > src/components/ResultScreen.jsx << 'EOF'
import { CATEGORIES } from '../data/questions.js';
const M = { perfect: ['Perfect score. That\'s very Darling of you.','All correct. Your grammar is sharper than most.'], great: ['Really strong session.','Great work — you clearly know your stuff.'], good: ['Solid session. A few to review.','Good progress. Every mistake is data.'], okay: ['You\'ll get there.','Keep going — it gets easier.'], rough: ['Rough one. That\'s okay.','This is exactly how improvement works.'] };
const rnd = (a) => a[Math.floor(Math.random() * a.length)];
const gm = (c, t) => { const p = c/t; if (p===1) return rnd(M.perfect); if (p>=0.75) return rnd(M.great); if (p>=0.55) return rnd(M.good); if (p>=0.4) return rnd(M.okay); return rnd(M.rough); };
export default function ResultScreen({ results, onFinish }) {
  const correct = results.filter((r) => r.correct).length, total = results.length;
  const xp = correct * 10 + (total - correct) * 2;
  const pct = Math.round((correct / total) * 100);
  const wbc = {};
  results.filter((r) => !r.correct).forEach((r) => { wbc[r.category] = (wbc[r.category] || 0) + 1; });
  const focus = Object.entries(wbc).sort((a, b) => b[1] - a[1]);
  return (
    <div className="screen result-screen">
      <div className="result-main">
        <div className="result-score-ring">
          <svg viewBox="0 0 120 120" className="ring-svg">
            <circle cx="60" cy="60" r="50" className="ring-track" />
            <circle cx="60" cy="60" r="50" className="ring-fill" strokeDasharray={`${(pct/100)*314} 314`} strokeLinecap="round" transform="rotate(-90 60 60)" />
          </svg>
          <div className="ring-inner"><span className="ring-pct">{pct}%</span><span className="ring-label">{correct}/{total}</span></div>
        </div>
        <h2 className="result-message">{gm(correct, total)}</h2>
        <div className="xp-earned"><span className="xp-plus">+{xp}</span><span className="xp-label-lg">XP</span></div>
        <div className="result-breakdown">{results.map((r, i) => (<div key={i} className={`breakdown-row ${r.correct ? 'row-correct' : 'row-wrong'}`}><span className="breakdown-icon">{r.correct ? '✓' : '✗'}</span><span className="breakdown-q">{r.question.question.length > 55 ? r.question.question.slice(0,54)+'…' : r.question.question}</span></div>))}</div>
        {focus.length > 0 && <div className="focus-note"><h3 className="focus-title">Keep working on</h3><div className="focus-chips">{focus.map(([cat]) => <span key={cat} className="focus-chip" style={{ color: CATEGORIES[cat]?.color, borderColor: CATEGORIES[cat]?.color }}>{CATEGORIES[cat]?.icon} {CATEGORIES[cat]?.label}</span>)}</div></div>}
        <button className="btn-primary" onClick={onFinish}>Back to dashboard</button>
      </div>
    </div>
  );
}
EOF

cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: true
jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run build
        env:
          GITHUB_PAGES: true
      - uses: actions/configure-pages@v4
      - uses: actions/upload-pages-artifact@v3
        with:
          path: dist
      - uses: actions/deploy-pages@v4
        id: deployment
EOF


# ── questions.js ──────────────────────────────────────────────────────────────
cat > src/data/questions.js << 'EOF'
export const CATEGORIES = {
  articles: { label: 'Articles', icon: '📝', color: '#E8C547' },
  prepositions: { label: 'Prepositions', icon: '🔗', color: '#A78BFA' },
  'present-perfect': { label: 'Present Perfect', icon: '⏳', color: '#34D399' },
  'word-order': { label: 'Word Order', icon: '↔️', color: '#F472B6' },
  'countable-uncountable': { label: 'Countable / Uncountable', icon: '🔢', color: '#60A5FA' },
  mixed: { label: 'Mixed', icon: '🎯', color: '#FB923C' },
};

export const questions = [
  { id: 1, category: 'articles', question: 'She just landed ___ job at a major DAO in Zug.', options: ['a', 'an', 'the', '— (no article)'], answer: 'a', explanation: '"A job" — use "a" before consonant sounds for indefinite nouns. The listener does not know which job yet, so it\'s not "the."', theme: 'crypto' },
  { id: 2, category: 'articles', question: 'Bitcoin hit ___ all-time high last week.', options: ['a', 'an', 'the', '— (no article)'], answer: 'an', explanation: '"An all-time high" — use "an" before vowel sounds. "All" starts with a vowel sound. The rule is about sound, not spelling.', theme: 'crypto' },
  { id: 3, category: 'articles', question: 'Can you give me ___ advice on my token allocation?', options: ['a', 'an', 'the', '— (no article)'], answer: '— (no article)', explanation: '"Advice" is uncountable — you cannot say "an advice" or "advices." Skip the article entirely, or say "some advice."', theme: 'crypto' },
  { id: 4, category: 'articles', question: 'We grabbed coffee near ___ Old Town Square yesterday.', options: ['a', 'an', 'the', '— (no article)'], answer: 'the', explanation: 'Unique, one-of-a-kind places always take "the." There is only one Old Town Square in Prague — it is definite.', theme: 'expat' },
  { id: 5, category: 'articles', question: '___ community feedback we got was actually really valuable.', options: ['A', 'An', 'The', '— (no article)'], answer: 'The', explanation: '"The community feedback" — you are referring to specific feedback (the stuff we got), making it definite. "The" signals: this specific thing we both know about.', theme: 'work' },
  { id: 6, category: 'articles', question: 'He\'s ___ engineer at a Layer 2 protocol.', options: ['a', 'an', 'the', '— (no article)'], answer: 'an', explanation: '"An engineer" — "engineer" starts with a vowel sound, so "an" is correct. The rule is about sound, not the letter.', theme: 'crypto' },
  { id: 7, category: 'articles', question: 'I\'m looking for ___ apartment in Vinohrady.', options: ['a', 'an', 'the', '— (no article)'], answer: 'an', explanation: '"An apartment" — "apartment" starts with a vowel sound. Also indefinite: any apartment, not a specific one the listener knows about.', theme: 'expat' },
  { id: 8, category: 'articles', question: 'She has ___ experience in DeFi protocols.', options: ['a', 'an', 'the', '— (no article)'], answer: '— (no article)', explanation: '"Experience" as a general quality is uncountable — no article. "An experience" means one specific event. "She has experience" means she\'s been around.', theme: 'crypto' },
  { id: 9, category: 'articles', question: '___ Czech Republic has surprisingly good craft beer.', options: ['A', 'An', 'The', '— (no article)'], answer: 'The', explanation: 'Countries containing "Republic," "Kingdom," "States," or "Emirates" always take "the." The Czech Republic, The USA, The UAE — no exceptions.', theme: 'expat' },
  { id: 10, category: 'articles', question: 'Let\'s grab ___ beer after the meetup.', options: ['a', 'an', 'the', '— (no article)'], answer: 'a', explanation: '"A beer" — one indefinite drink (countable). If you had already mentioned which bar and implicitly which beer, you might say "the beer." But here it is just any beer.', theme: 'expat' },
  { id: 11, category: 'prepositions', question: 'I\'ve been living in Prague ___ three years now.', options: ['since', 'for', 'during', 'from'], answer: 'for', explanation: '"For" goes with durations: three years, two months, a decade. "Since" goes with start points: since 2021, since January, since I moved here.', theme: 'expat' },
  { id: 12, category: 'prepositions', question: 'The all-hands call is ___ Friday at 3pm.', options: ['in', 'on', 'at', 'by'], answer: 'on', explanation: '"On" for specific days: on Friday, on Christmas, on my birthday. "In" for months and years. "At" for clock times: at 3pm, at noon.', theme: 'work' },
  { id: 13, category: 'prepositions', question: 'She\'s really interested ___ governance mechanisms.', options: ['about', 'for', 'in', 'on'], answer: 'in', explanation: '"Interested in" is a fixed collocation. Do not confuse with "curious about." This "interested in" pattern is one Slovaks often get wrong.', theme: 'crypto' },
  { id: 14, category: 'prepositions', question: 'We\'re flying to Lisbon ___ May for a conference.', options: ['in', 'on', 'at', 'during'], answer: 'in', explanation: '"In May" — months use "in." Specific dates use "on": on May 15th. The distinction: vague time period means "in," exact date means "on."', theme: 'expat' },
  { id: 15, category: 'prepositions', question: 'He graduated ___ Charles University last spring.', options: ['from', 'of', 'at', 'in'], answer: 'from', explanation: 'You study at a university, but you graduate from it. "Graduated from" is always the right collocation. "Of" does not work here at all.', theme: 'expat' },
  { id: 16, category: 'prepositions', question: 'I\'m working ___ a governance proposal this week.', options: ['at', 'for', 'on', 'with'], answer: 'on', explanation: '"Working on something" means actively doing it. "Working for" means your employer. "Working with" means collaborating. Three prepositions, three meanings.', theme: 'crypto' },
  { id: 17, category: 'prepositions', question: 'Are you coming ___ the Web3 meetup tonight?', options: ['at', 'to', 'in', 'for'], answer: 'to', explanation: 'Movement toward events and places uses "to": come to, go to, travel to. "Arrive at" is for arrival specifically, not the act of coming.', theme: 'crypto' },
  { id: 18, category: 'prepositions', question: 'The whole roadmap depends ___ the token launch going smoothly.', options: ['at', 'of', 'in', 'on'], answer: 'on', explanation: '"Depend on" is fixed — always "on." In Slovak it\'s "zavisí od," which leads to "depend of," but English does not work that way. Also: "rely on," "count on."', theme: 'crypto' },
  { id: 19, category: 'present-perfect', question: 'When ___ you first get into crypto?', options: ['have', 'did', 'do', 'had'], answer: 'did', explanation: '"When" questions always use simple past. "When" pins the action to a specific moment, which rules out present perfect. "When did you?" — never "When have you?"', theme: 'crypto' },
  { id: 20, category: 'present-perfect', question: 'I ___ just finished reading the whitepaper — it\'s wild.', options: ['have', 'had', 'did', 'was'], answer: 'have', explanation: '"I have just finished" — present perfect with "just" signals something very recently completed that is still relevant now. The whitepaper is still on your mind.', theme: 'crypto' },
  { id: 21, category: 'present-perfect', question: 'The project ___ in Q3 2022, during the bear market.', options: ['has launched', 'launched', 'had launched', 'did launch'], answer: 'launched', explanation: '"In Q3 2022" is a specific finished time = simple past, no exceptions. You can never use present perfect with "yesterday," "last week," "in 2022," etc.', theme: 'crypto' },
  { id: 22, category: 'present-perfect', question: 'Have you ___ lost your seed phrase? (Be honest.)', options: ['ever', 'never', 'already', 'yet'], answer: 'ever', explanation: '"Have you ever?" asks about life experience — something at any point up to now. "Ever" is the classic present perfect trigger in questions about experience.', theme: 'crypto' },
  { id: 23, category: 'present-perfect', question: 'I ___ never been to a crypto conference in Asia.', options: ['have', 'had', 'did', 'was'], answer: 'have', explanation: '"I have never been" — present perfect for life experience. "Never" sits between "have" and the past participle. Simple structure, very common mistake.', theme: 'crypto' },
  { id: 24, category: 'present-perfect', question: '___ you talked to the team about the budget yet?', options: ['Did', 'Have', 'Do', 'Had'], answer: 'Have', explanation: '"Yet" at the end is a present perfect signal — it asks whether something has happened up to this moment. "Have you done X yet?" is the standard form.', theme: 'work' },
  { id: 25, category: 'present-perfect', question: 'We ___ last week to go over the Q1 strategy.', options: ['have met', 'met', 'did meet', 'had met'], answer: 'met', explanation: '"Last week" = specific finished time = simple past, period. You cannot say "we have met last week." Specific past time markers block present perfect entirely.', theme: 'work' },
  { id: 26, category: 'present-perfect', question: 'I\'ve been living in Prague ___ 2022.', options: ['for', 'since', 'from', 'during'], answer: 'since', explanation: '"Since 2022" — "since" connects to a start point (2022, last spring, I arrived). "For" connects to a duration (for two years). "2022" is a point, not a span.', theme: 'expat' },
  { id: 27, category: 'word-order', question: 'Which sentence is correct?', options: ['She always is late for calls.', 'She is always late for calls.', 'Always she is late for calls.', 'She is late always for calls.'], answer: 'She is always late for calls.', explanation: 'Frequency adverbs (always, usually, never, often) go AFTER "be" verbs. "She is always late" — not before "is," not at the end. After "be," always.', theme: 'work' },
  { id: 28, category: 'word-order', question: 'Hardly ___ anyone at the Prague DeFi Summit.', options: ['she knew', 'knew she', 'did she know', 'she did know'], answer: 'did she know', explanation: 'Negative adverbs at the start (hardly, never, rarely) trigger subject-auxiliary inversion — same structure as a question. "Hardly did she know" is formal but correct.', theme: 'crypto' },
  { id: 29, category: 'word-order', question: 'Which sentence has the most natural word order?', options: ['I only have a few minutes to chat.', 'Only I have a few minutes to chat.', 'I have a only few minutes to chat.', 'I have only few a minutes to chat.'], answer: 'I only have a few minutes to chat.', explanation: '"Only" belongs right before what it limits. "I only have" = I merely have. "Only I have" would mean no one else has time — which changes the meaning.', theme: 'casual' },
  { id: 30, category: 'word-order', question: '"Not only ___ English, he also speaks Czech and Slovak."', options: ['he speaks', 'does he speak', 'he does speak', 'speaks he'], answer: 'does he speak', explanation: '"Not only" at the start forces inversion: "Not only does he speak..." Same pattern as "hardly," "never," "rarely." Formal tone, used for emphasis.', theme: 'expat' },
  { id: 31, category: 'word-order', question: 'Which sentence(s) are grammatically correct?', options: ['Only A: I sometimes go to Letna for lunch.', 'Only B: Sometimes I go to Letna for lunch.', 'Both A and B are correct.', 'Neither is correct.'], answer: 'Both A and B are correct.', explanation: 'Frequency adverbs like "sometimes" can go before the main verb or at the start of a sentence for emphasis. Both positions are natural and grammatically fine.', theme: 'expat' },
  { id: 32, category: 'countable-uncountable', question: 'Can you give me ___ on structuring the DAO?', options: ['an advice', 'some advices', 'some advice', 'a few advices'], answer: 'some advice', explanation: '"Advice" is always uncountable — no "an advice," no "advices." Use "some advice" or, if you want to count it, "a piece of advice."', theme: 'crypto' },
  { id: 33, category: 'countable-uncountable', question: 'I need to buy ___ for my new flat in Zizkov.', options: ['a furniture', 'some furnitures', 'some furniture', 'furnitures'], answer: 'some furniture', explanation: '"Furniture" is uncountable — always. "Some furniture" or "a piece of furniture." You cannot say "a furniture" or "furnitures." Same goes for luggage, equipment, clothing.', theme: 'expat' },
  { id: 34, category: 'countable-uncountable', question: 'We have ___ work to do before the token launch.', options: ['too many', 'too much', 'too few', 'too little'], answer: 'too much', explanation: '"Work" (as a general concept) is uncountable, so use "too much." Countable things use "too many": too many tasks, too many meetings.', theme: 'crypto' },
  { id: 35, category: 'countable-uncountable', question: 'There are ___ people at the office since the new policy.', options: ['less', 'fewer', 'lesser', 'little'], answer: 'fewer', explanation: '"Fewer" = countable nouns (people, items, emails, days). "Less" = uncountable (less time, less money, less effort). People are countable, so fewer people.', theme: 'work' },
  { id: 36, category: 'countable-uncountable', question: 'I only have ___ time before my next call.', options: ['a few', 'few', 'a little', 'little'], answer: 'a little', explanation: '"A little time" = some time, a small amount (uncountable noun). "A few" is for countable: a few minutes. "Little" without "a" is more negative — almost none.', theme: 'work' },
  { id: 37, category: 'countable-uncountable', question: 'She gave me ___ really helpful information about the grant.', options: ['an', 'some', 'a few', 'many'], answer: 'some', explanation: '"Information" is always uncountable. Never "an information" or "informations." Use "some information" or "a piece of information" if you need to single one out.', theme: 'work' },
  { id: 38, category: 'countable-uncountable', question: '"The news about the airdrop ___ actually pretty good."', options: ['were', 'are', 'was', 'is'], answer: 'is', explanation: '"News" looks plural (ends in -s) but is grammatically singular. Always: "the news is." Same applies to mathematics, physics, economics — singular despite the -s.', theme: 'crypto' },
  { id: 39, category: 'mixed', question: 'If I ___ you were coming, I would have cooked something.', options: ['knew', 'had known', 'would know', 'know'], answer: 'had known', explanation: 'Third conditional: "If + past perfect, would have + past participle." For past situations that did not happen. "If I had known" = but I did not know.', theme: 'casual' },
  { id: 40, category: 'mixed', question: 'She ___ work in traditional finance before switching to Web3.', options: ['use to', 'used to', 'was used to', 'would use to'], answer: 'used to', explanation: '"Used to + infinitive" = past habit or state that no longer exists. Note the -d: "used to," not "use to." "Was used to" means "was accustomed to" — completely different.', theme: 'crypto' },
  { id: 41, category: 'mixed', question: 'I\'m really looking forward ___ you at the Prague conference.', options: ['to see', 'to seeing', 'seeing', 'see'], answer: 'to seeing', explanation: '"Look forward to + -ing" — the "to" here is a preposition, not part of an infinitive. After prepositions, use the -ing form. "To seeing," "to meeting," "to going."', theme: 'expat' },
  { id: 42, category: 'mixed', question: 'They suggested ___ to a new co-working space in Holesovice.', options: ['to move', 'moving', 'move', 'moved'], answer: 'moving', explanation: '"Suggest + -ing" — the gerund follows "suggest." Never "suggest to do." Same pattern: "recommend doing," "avoid doing," "consider doing," "enjoy doing."', theme: 'expat' },
  { id: 43, category: 'mixed', question: 'The onboarding process made me ___ welcome right away.', options: ['to feel', 'feeling', 'feel', 'felt'], answer: 'feel', explanation: '"Make + object + bare infinitive" — causative verbs (make, let, have) take the infinitive without "to." "Made me feel," never "made me to feel."', theme: 'work' },
  { id: 44, category: 'mixed', question: 'I wish I ___ more time to actually explore Czech culture.', options: ['have', 'had', 'would have', 'will have'], answer: 'had', explanation: '"I wish + past simple" for present wishes about things that are not true now. "I wish I had more time" = I do not have enough right now. Past tense creates the unreal meaning.', theme: 'expat' },
  { id: 45, category: 'mixed', question: 'It\'s high time we ___ a decision on the foundation grant.', options: ['make', 'made', 'will make', 'have made'], answer: 'made', explanation: '"It\'s high time + past simple" — this structure always uses past tense even though it refers to the present or near future. "High time we left, decided, acted." Slightly formal, very native.', theme: 'work' },
];
EOF


# ── index.css ─────────────────────────────────────────────────────────────────
cat > src/index.css << 'EOF'
:root {
  --bg: #0E0E10; --surface: #1A1A1E; --surface-2: #222228;
  --border: #2A2A30; --border-light: #333340;
  --accent: #E8C547; --accent-dim2: rgba(232,197,71,0.08);
  --text-primary: #F2F0E8; --text-secondary: #8A8A96; --text-muted: #55555E;
  --correct: #4ADE80; --correct-bg: rgba(74,222,128,0.12);
  --wrong: #F87171; --wrong-bg: rgba(248,113,113,0.12);
  --radius-sm: 8px; --radius: 14px; --radius-lg: 20px; --max-w: 480px;
}
*,*::before,*::after { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 16px; -webkit-text-size-adjust: 100%; background: var(--bg); }
body { font-family: 'Inter', system-ui, -apple-system, sans-serif; background: var(--bg); color: var(--text-primary); min-height: 100dvh; line-height: 1.6; -webkit-font-smoothing: antialiased; }
button { cursor: pointer; font-family: inherit; border: none; background: none; -webkit-tap-highlight-color: transparent; }
.app { min-height: 100dvh; display: flex; flex-direction: column; }
.screen { min-height: 100dvh; display: flex; flex-direction: column; max-width: var(--max-w); margin: 0 auto; width: 100%; padding: 0 20px; padding-bottom: env(safe-area-inset-bottom, 24px); }
.dashboard-header { padding: 52px 0 32px; border-bottom: 1px solid var(--border); }
.brand { display: flex; align-items: baseline; gap: 2px; }
.brand-g { font-family: 'Playfair Display', Georgia, serif; font-size: 2.6rem; font-weight: 900; color: var(--accent); line-height: 1; }
.brand-text { font-family: 'Playfair Display', Georgia, serif; font-size: 1.5rem; font-weight: 700; color: var(--text-primary); letter-spacing: -0.02em; }
.brand-text em { font-style: italic; color: var(--accent); }
.dashboard-main { flex: 1; display: flex; flex-direction: column; gap: 16px; padding-top: 24px; }
.streak-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 20px 24px; display: flex; align-items: center; gap: 16px; }
.streak-number { display: flex; align-items: center; gap: 6px; flex-shrink: 0; }
.streak-flame { font-size: 1.5rem; }
.streak-count { font-family: 'Playfair Display', Georgia, serif; font-size: 2.4rem; font-weight: 900; color: var(--accent); line-height: 1; }
.streak-message { font-size: 0.85rem; color: var(--text-secondary); line-height: 1.45; }
.level-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 20px 24px; }
.level-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 14px; }
.level-label { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-muted); font-weight: 500; margin-bottom: 2px; }
.level-name { font-family: 'Playfair Display', Georgia, serif; font-size: 1.6rem; font-weight: 700; color: var(--text-primary); letter-spacing: -0.02em; }
.xp-badge { display: flex; flex-direction: column; align-items: flex-end; }
.xp-number { font-family: 'Playfair Display', Georgia, serif; font-size: 1.6rem; font-weight: 700; color: var(--accent); line-height: 1; }
.xp-label { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-muted); }
.level-bar-track { height: 6px; background: var(--border); border-radius: 99px; overflow: hidden; margin-bottom: 8px; }
.level-bar-fill { height: 100%; background: var(--accent); border-radius: 99px; transition: width 0.6s cubic-bezier(0.34,1.56,0.64,1); }
.level-next { font-size: 0.8rem; color: var(--text-secondary); }
.stats-row { display: grid; grid-template-columns: repeat(3,1fr); gap: 10px; }
.stat-chip { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 14px 8px; text-align: center; display: flex; flex-direction: column; gap: 3px; }
.stat-value { font-family: 'Playfair Display', Georgia, serif; font-size: 1.4rem; font-weight: 700; color: var(--text-primary); line-height: 1; }
.stat-label { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-muted); }
.categories-section { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 20px 24px; }
.section-title { font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-muted); font-weight: 500; margin-bottom: 14px; }
.category-list { display: flex; flex-direction: column; gap: 12px; }
.category-row { display: flex; align-items: center; gap: 12px; }
.category-info { display: flex; align-items: center; gap: 6px; flex: 0 0 160px; }
.category-icon { font-size: 0.85rem; flex-shrink: 0; }
.category-label { font-size: 0.8rem; color: var(--text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.category-bar-wrap { flex: 1; display: flex; align-items: center; gap: 8px; }
.category-bar-track { flex: 1; height: 4px; background: var(--border); border-radius: 99px; overflow: hidden; }
.category-bar-fill { height: 100%; border-radius: 99px; transition: width 0.5s ease; }
.category-pct { font-size: 0.75rem; font-weight: 600; width: 32px; text-align: right; flex-shrink: 0; }
.btn-primary { width: 100%; background: var(--accent); color: #0E0E10; font-size: 1rem; font-weight: 600; padding: 16px 24px; border-radius: var(--radius); letter-spacing: -0.01em; transition: transform 0.12s ease, opacity 0.12s ease; margin-top: 4px; }
.btn-primary:hover { opacity: 0.92; }
.btn-primary:active { transform: scale(0.98); }
.session-hint { text-align: center; font-size: 0.78rem; color: var(--text-muted); margin-top: -4px; }
.reset-area { display: flex; flex-direction: column; align-items: center; padding: 8px 0 24px; }
.btn-ghost-sm { font-size: 0.78rem; color: var(--text-muted); padding: 6px 12px; border-radius: var(--radius-sm); transition: color 0.15s ease; }
.btn-ghost-sm:hover { color: var(--text-secondary); }
.reset-confirm { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; justify-content: center; font-size: 0.8rem; color: var(--text-secondary); }
.btn-danger-sm { font-size: 0.78rem; color: var(--wrong); padding: 6px 12px; border-radius: var(--radius-sm); border: 1px solid var(--wrong-bg); }
.quiz { padding-top: 0; }
.quiz-topbar { display: flex; align-items: center; gap: 12px; padding: 16px 0 20px; position: sticky; top: 0; background: var(--bg); z-index: 10; }
.btn-back { font-size: 1.2rem; color: var(--text-secondary); width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; border-radius: 50%; flex-shrink: 0; transition: color 0.15s ease; }
.btn-back:hover { color: var(--text-primary); }
.quiz-progress-wrap { flex: 1; display: flex; flex-direction: column; gap: 6px; }
.quiz-progress-track { height: 4px; background: var(--border); border-radius: 99px; overflow: hidden; }
.quiz-progress-fill { height: 100%; background: var(--accent); border-radius: 99px; transition: width 0.4s cubic-bezier(0.34,1.56,0.64,1); }
.quiz-counter { font-size: 0.72rem; color: var(--text-muted); font-variant-numeric: tabular-nums; }
.category-tag { font-size: 0.7rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em; white-space: nowrap; flex-shrink: 0; }
.question-card { flex: 1; display: flex; flex-direction: column; padding-bottom: 24px; }
.question-theme-tag { font-size: 0.72rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 20px; }
.question-text { font-family: 'Playfair Display', Georgia, serif; font-size: 1.55rem; font-weight: 700; line-height: 1.4; color: var(--text-primary); letter-spacing: -0.02em; margin-bottom: 36px; flex: 1; }
.blank-marker { color: var(--accent); border-bottom: 2px solid var(--accent); padding: 0 4px; }
.options-grid { display: flex; flex-direction: column; gap: 10px; }
.option-btn { width: 100%; background: var(--surface); border: 1.5px solid var(--border); border-radius: var(--radius); padding: 16px 20px; text-align: left; font-size: 0.95rem; color: var(--text-primary); transition: border-color 0.15s ease, background 0.15s ease, transform 0.1s ease; font-weight: 500; }
.option-btn:hover:not(.selected) { border-color: var(--border-light); background: var(--surface-2); }
.option-btn:active:not(.selected) { transform: scale(0.99); }
.option-btn.selected { border-color: var(--accent); background: var(--accent-dim2); color: var(--accent); }
.explanation-card { flex: 1; display: flex; flex-direction: column; gap: 20px; padding-bottom: 24px; }
.result-badge { width: 52px; height: 52px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.4rem; font-weight: 700; flex-shrink: 0; }
.result-correct { background: var(--correct-bg); color: var(--correct); border: 2px solid rgba(74,222,128,0.3); }
.result-wrong { background: var(--wrong-bg); color: var(--wrong); border: 2px solid rgba(248,113,113,0.3); }
.result-headline { font-family: 'Playfair Display', Georgia, serif; font-size: 1.3rem; font-weight: 700; color: var(--text-primary); letter-spacing: -0.02em; margin-top: -4px; }
.correct-answer-row { display: flex; align-items: center; gap: 10px; background: var(--correct-bg); border: 1px solid rgba(74,222,128,0.2); border-radius: var(--radius-sm); padding: 10px 14px; }
.correct-label { font-size: 0.8rem; color: var(--text-secondary); font-weight: 500; }
.correct-value { font-size: 0.9rem; font-weight: 600; color: var(--correct); }
.explanation-text { background: var(--surface); border: 1px solid var(--border); border-left: 3px solid var(--accent); border-radius: var(--radius-sm); padding: 16px 18px; font-size: 0.9rem; line-height: 1.65; color: var(--text-secondary); }
.explanation-quote { font-family: 'Playfair Display', Georgia, serif; font-size: 1.8rem; color: var(--accent); opacity: 0.4; line-height: 0; vertical-align: -12px; margin-right: 4px; }
.question-recap { background: var(--surface-2); border-radius: var(--radius-sm); padding: 12px 16px; font-size: 0.85rem; }
.recap-text { color: var(--text-secondary); font-style: italic; line-height: 1.6; }
.recap-answer { color: var(--correct); font-weight: 600; font-style: normal; text-decoration: underline; text-decoration-color: rgba(74,222,128,0.4); text-underline-offset: 2px; margin: 0 2px; }
.explanation-card .btn-primary { margin-top: auto; }
.result-screen { justify-content: center; padding-top: 40px; }
.result-main { display: flex; flex-direction: column; align-items: center; gap: 20px; width: 100%; }
.result-score-ring { position: relative; width: 140px; height: 140px; }
.ring-svg { width: 100%; height: 100%; }
.ring-track { fill: none; stroke: var(--border); stroke-width: 8; }
.ring-fill { fill: none; stroke: var(--accent); stroke-width: 8; stroke-dasharray: 0 314; transition: stroke-dasharray 0.8s cubic-bezier(0.34,1.56,0.64,1); }
.ring-inner { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; }
.ring-pct { font-family: 'Playfair Display', Georgia, serif; font-size: 1.8rem; font-weight: 900; color: var(--text-primary); line-height: 1; }
.ring-label { font-size: 0.78rem; color: var(--text-muted); margin-top: 2px; }
.result-message { font-family: 'Playfair Display', Georgia, serif; font-size: 1.2rem; font-weight: 700; color: var(--text-primary); text-align: center; letter-spacing: -0.02em; max-width: 300px; line-height: 1.4; }
.xp-earned { display: flex; align-items: baseline; gap: 4px; }
.xp-plus { font-family: 'Playfair Display', Georgia, serif; font-size: 2rem; font-weight: 900; color: var(--accent); line-height: 1; }
.xp-label-lg { font-size: 0.85rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.1em; }
.result-breakdown { width: 100%; display: flex; flex-direction: column; gap: 6px; }
.breakdown-row { display: flex; align-items: center; gap: 10px; padding: 10px 14px; background: var(--surface); border-radius: var(--radius-sm); border: 1px solid var(--border); }
.row-correct { border-color: rgba(74,222,128,0.15); }
.row-wrong { border-color: rgba(248,113,113,0.15); }
.breakdown-icon { font-size: 0.85rem; font-weight: 700; flex-shrink: 0; }
.row-correct .breakdown-icon { color: var(--correct); }
.row-wrong .breakdown-icon { color: var(--wrong); }
.breakdown-q { font-size: 0.8rem; color: var(--text-secondary); min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.focus-note { width: 100%; }
.focus-title { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-muted); margin-bottom: 10px; font-weight: 500; }
.focus-chips { display: flex; flex-wrap: wrap; gap: 8px; }
.focus-chip { font-size: 0.78rem; font-weight: 500; padding: 6px 12px; border-radius: 99px; border: 1.5px solid; background: transparent; }
.result-screen .btn-primary { width: 100%; margin-top: 4px; }
@media (max-height: 700px) {
  .dashboard-header { padding: 28px 0 20px; }
  .brand-g { font-size: 2rem; } .brand-text { font-size: 1.25rem; }
  .dashboard-main { gap: 12px; }
  .streak-card, .level-card, .categories-section { padding: 14px 18px; }
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { transition-duration: 0.01ms !important; animation-duration: 0.01ms !important; }
}
EOF

# ── Git: push to GitHub ───────────────────────────────────────────────────────
echo ""
echo "All files created. Pushing to GitHub..."
git init
git add .
git commit -m "Build Grammar, Darling PWA"
git branch -M main
git remote add origin https://github.com/anettrolikova/PWA.git
git push -u origin main --force

echo ""
echo "Done! Visit https://github.com/anettrolikova/PWA to see your code."
echo "Now go to vercel.com, import the repo, and deploy."
