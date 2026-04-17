import { useState, useEffect, useCallback } from 'react';

const STORAGE_KEY = 'english-buddy-progress';

const LEVELS = [
  { name: 'Newbie', min: 0, max: 99 },
  { name: 'Apprentice', min: 100, max: 299 },
  { name: 'Scholar', min: 300, max: 599 },
  { name: 'Wordsmith', min: 600, max: 999 },
  { name: 'Darling', min: 1000, max: Infinity },
];

function getLevel(xp) {
  return LEVELS.find((l) => xp >= l.min && xp <= l.max) || LEVELS[0];
}

function getNextLevel(xp) {
  const idx = LEVELS.findIndex((l) => xp >= l.min && xp <= l.max);
  return LEVELS[idx + 1] || null;
}

function getLevelProgress(xp) {
  const current = getLevel(xp);
  if (current.max === Infinity) return 100;
  const span = current.max - current.min + 1;
  const earned = xp - current.min;
  return Math.min(100, Math.round((earned / span) * 100));
}

function todayStr() {
  return new Date().toISOString().slice(0, 10);
}

function loadProgress() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function saveProgress(data) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  } catch {}
}

const defaultProgress = () => ({
  xp: 0,
  streak: 0,
  lastPlayedDate: null,
  totalCorrect: 0,
  totalAnswered: 0,
  categoryStats: {},
  sessionsPlayed: 0,
});

export function useProgress() {
  const [progress, setProgress] = useState(() => {
    const saved = loadProgress();
    if (!saved) return defaultProgress();

    // Check streak: if last played was yesterday keep it, if today keep it, otherwise reset
    const today = todayStr();
    const yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
    let streak = saved.streak || 0;
    if (saved.lastPlayedDate !== today && saved.lastPlayedDate !== yesterday) {
      streak = 0;
    }
    return { ...saved, streak };
  });

  useEffect(() => {
    saveProgress(progress);
  }, [progress]);

  const addSessionResult = useCallback((results) => {
    // results: array of { category, correct }
    setProgress((prev) => {
      const today = todayStr();
      const correct = results.filter((r) => r.correct).length;
      const xpGained = correct * 10 + results.filter((r) => !r.correct).length * 2;

      // Streak logic
      let newStreak = prev.streak;
      if (prev.lastPlayedDate !== today) {
        newStreak = prev.lastPlayedDate === new Date(Date.now() - 86400000).toISOString().slice(0, 10)
          ? prev.streak + 1
          : 1;
      }

      // Category stats
      const newCategoryStats = { ...prev.categoryStats };
      results.forEach(({ category, correct: c }) => {
        if (!newCategoryStats[category]) {
          newCategoryStats[category] = { correct: 0, total: 0 };
        }
        newCategoryStats[category].total += 1;
        if (c) newCategoryStats[category].correct += 1;
      });

      return {
        ...prev,
        xp: prev.xp + xpGained,
        streak: newStreak,
        lastPlayedDate: today,
        totalCorrect: prev.totalCorrect + correct,
        totalAnswered: prev.totalAnswered + results.length,
        categoryStats: newCategoryStats,
        sessionsPlayed: prev.sessionsPlayed + 1,
      };
    });
  }, []);

  const resetProgress = useCallback(() => {
    const fresh = defaultProgress();
    setProgress(fresh);
    saveProgress(fresh);
  }, []);

  const level = getLevel(progress.xp);
  const nextLevel = getNextLevel(progress.xp);
  const levelProgress = getLevelProgress(progress.xp);

  return {
    progress,
    level,
    nextLevel,
    levelProgress,
    addSessionResult,
    resetProgress,
  };
}
